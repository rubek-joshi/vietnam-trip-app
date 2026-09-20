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
    this.message,
  });

  final List<ChecklistItem> items;
  final int currentDay;
  final bool isLoading;
  final String? message;

  List<ChecklistItem> get dayItems =>
      items.where((e) => e.day == currentDay).toList()
        ..sort((a, b) => a.order.compareTo(b.order));

  ChecklistState copyWith({
    List<ChecklistItem>? items,
    int? currentDay,
    bool? isLoading,
    String? message,
    bool clearMessage = false,
  }) {
    return ChecklistState(
      items: items ?? this.items,
      currentDay: currentDay ?? this.currentDay,
      isLoading: isLoading ?? this.isLoading,
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [items, currentDay, isLoading, message];
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
    result.fold(
      (f) => emit(state.copyWith(message: f.message)),
      (_) {
        final exists = state.items.any((e) => e.id == item.id);
        final list = exists
            ? state.items.map((e) => e.id == item.id ? item : e).toList()
            : [...state.items, item];
        emit(state.copyWith(items: list));
      },
    );
  }
}
