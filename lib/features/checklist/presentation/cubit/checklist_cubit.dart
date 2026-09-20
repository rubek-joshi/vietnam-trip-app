import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import 'package:vietnam_handbook/core/trip/trip_dates.dart';
import 'package:vietnam_handbook/features/checklist/domain/entities/checklist_item.dart';
import 'package:vietnam_handbook/features/checklist/domain/repositories/checklist_repository.dart';

class ChecklistState extends Equatable {
  const ChecklistState({
    this.items = const [],
    this.currentDay = 1,
    this.isLoading = true,
    this.isReordering = false,
    this.message,
  });

  final List<ChecklistItem> items;
  final int currentDay;
  final bool isLoading;
  final bool isReordering;
  final String? message;

  List<ChecklistItem> get dayItems =>
      items.where((e) => e.day == currentDay).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  ChecklistState copyWith({
    List<ChecklistItem>? items,
    int? currentDay,
    bool? isLoading,
    bool? isReordering,
    String? message,
    bool clearMessage = false,
  }) {
    return ChecklistState(
      items: items ?? this.items,
      currentDay: currentDay ?? this.currentDay,
      isLoading: isLoading ?? this.isLoading,
      isReordering: isReordering ?? this.isReordering,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [
    items,
    currentDay,
    isLoading,
    isReordering,
    message,
  ];
}

class ChecklistCubit extends Cubit<ChecklistState> {
  ChecklistCubit(this._repository)
    : super(ChecklistState(currentDay: TripDates.activeDay()));

  final ChecklistRepository _repository;
  final _uuid = const Uuid();

  Future<void> init() async {
    await _repository.seedIfEmpty();
    await refresh();
  }

  Future<void> refresh() async {
    final result = await _repository.getAll();
    result.fold(
      (f) => emit(state.copyWith(isLoading: false, message: f.message)),
      (items) => emit(state.copyWith(items: items, isLoading: false)),
    );
  }

  void setDay(int day) => emit(state.copyWith(currentDay: day));

  void toggleReorderMode() =>
      emit(state.copyWith(isReordering: !state.isReordering));

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (newIndex > oldIndex) newIndex -= 1;
    if (oldIndex == newIndex) return;

    final dayItems = [...state.dayItems];
    if (oldIndex < 0 ||
        oldIndex >= dayItems.length ||
        newIndex < 0 ||
        newIndex >= dayItems.length) {
      return;
    }

    final moved = dayItems.removeAt(oldIndex);
    dayItems.insert(newIndex, moved);
    final reindexed = [
      for (var i = 0; i < dayItems.length; i++) dayItems[i].copyWith(order: i),
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

  Future<void> toggle(ChecklistItem item) async {
    final updated = item.copyWith(done: !item.done);
    await _upsertLocal(updated);
  }

  Future<void> add(String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    final item = ChecklistItem(
      id: _uuid.v4(),
      day: state.currentDay,
      title: trimmed,
      order: state.dayItems.length,
    );
    await _upsertLocal(item);
  }

  Future<void> edit(ChecklistItem item, String title) async {
    final trimmed = title.trim();
    if (trimmed.isEmpty) return;
    await _upsertLocal(item.copyWith(title: trimmed));
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

  Future<void> _upsertLocal(ChecklistItem item) async {
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
