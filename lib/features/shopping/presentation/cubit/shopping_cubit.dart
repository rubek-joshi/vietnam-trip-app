import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:vietnam_handbook/features/shopping/domain/entities/shopping_item.dart';
import 'package:vietnam_handbook/features/shopping/domain/repositories/shopping_repository.dart';
import 'package:vietnam_handbook/features/shopping/domain/shopping_text.dart';

class ShoppingState extends Equatable {
  const ShoppingState({
    this.items = const [],
    this.isLoading = true,
    this.isReordering = false,
    this.message,
  });

  final List<ShoppingItem> items;
  final bool isLoading;
  final bool isReordering;
  final String? message;

  List<ShoppingItem> get toBuy {
    final list = items.where((item) => !item.bought).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return list;
  }

  List<ShoppingItem> get bought {
    final list = items.where((item) => item.bought).toList()
      ..sort((a, b) {
        final aAt = a.boughtAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bAt = b.boughtAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bAt.compareTo(aAt);
      });
    return list;
  }

  int get nextToBuyOrder => toBuy.isEmpty ? 0 : toBuy.last.order + 1;

  ShoppingState copyWith({
    List<ShoppingItem>? items,
    bool? isLoading,
    bool? isReordering,
    String? message,
    bool clearMessage = false,
  }) {
    return ShoppingState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isReordering: isReordering ?? this.isReordering,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [items, isLoading, isReordering, message];
}

class ShoppingCubit extends Cubit<ShoppingState> {
  ShoppingCubit(this._repository) : super(const ShoppingState());

  final ShoppingRepository _repository;
  final _uuid = const Uuid();

  Future<void> init() async {
    await refresh();
  }

  Future<void> refresh() async {
    final result = await _repository.getAll();
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, message: f.message)),
      (items) => emit(state.copyWith(items: items, isLoading: false)),
    );
  }

  void toggleReorderMode() =>
      emit(state.copyWith(isReordering: !state.isReordering));

  Future<String?> add(String title) async {
    final trimmed = capitalizeFirstWord(title.trim());
    if (trimmed.isEmpty) return null;
    final item = ShoppingItem(
      id: _uuid.v4(),
      title: trimmed,
      order: state.nextToBuyOrder,
    );
    await _upsertLocal(item);
    return trimmed;
  }

  Future<void> editTitle(ShoppingItem item, String title) async {
    final trimmed = capitalizeFirstWord(title.trim());
    if (trimmed.isEmpty) return;
    await _upsertLocal(item.copyWith(title: trimmed));
  }

  Future<void> editBought({
    required ShoppingItem item,
    required String title,
    required String note,
  }) async {
    if (!item.bought) return;
    final trimmed = capitalizeFirstWord(title.trim());
    if (trimmed.isEmpty) return;
    await _upsertLocal(item.copyWith(title: trimmed, note: note.trim()));
  }

  Future<void> toggle(ShoppingItem item) async {
    if (item.bought) {
      await _upsertLocal(
        item.copyWith(
          bought: false,
          order: state.nextToBuyOrder,
          clearBoughtAt: true,
        ),
      );
      return;
    }
    await _upsertLocal(item.copyWith(bought: true, boughtAt: DateTime.now()));
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex == newIndex) return;

    final toBuy = [...state.toBuy];
    if (oldIndex < 0 ||
        oldIndex >= toBuy.length ||
        newIndex < 0 ||
        newIndex >= toBuy.length) {
      return;
    }

    final moved = toBuy.removeAt(oldIndex);
    toBuy.insert(newIndex, moved);
    final reindexed = [
      for (var i = 0; i < toBuy.length; i++) toBuy[i].copyWith(order: i),
    ];
    final byId = {for (final item in reindexed) item.id: item};
    emit(
      state.copyWith(
        items: [for (final item in state.items) byId[item.id] ?? item],
      ),
    );
    for (final item in reindexed) {
      final result = await _repository.upsert(item);
      result.fold((f) => emit(state.copyWith(message: f.message)), (_) {});
    }
  }

  Future<void> remove(String id) async {
    final result = await _repository.delete(id);
    result.fold(
      (f) => emit(state.copyWith(message: f.message)),
      (_) => emit(
        state.copyWith(items: state.items.where((e) => e.id != id).toList()),
      ),
    );
  }

  Future<void> _upsertLocal(ShoppingItem item) async {
    final result = await _repository.upsert(item);
    result.fold((f) => emit(state.copyWith(message: f.message)), (_) {
      final exists = state.items.any((e) => e.id == item.id);
      final list = exists
          ? state.items.map((e) => e.id == item.id ? item : e).toList()
          : [...state.items, item];
      emit(state.copyWith(items: list));
    });
  }
}
