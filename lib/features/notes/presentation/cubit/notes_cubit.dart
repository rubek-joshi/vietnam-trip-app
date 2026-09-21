import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';
import 'package:vietnam_handbook/features/converter/domain/repositories/fx_rates_repository.dart';
import 'package:vietnam_handbook/features/notes/data/vietnam_notes_catalog.dart';
import 'package:vietnam_handbook/features/notes/domain/entities/vietnam_note.dart';

class NotesState extends Equatable {
  const NotesState({this.rates = FxRates.defaults, this.isLoading = true});

  final FxRates rates;
  final bool isLoading;

  List<VietnamNote> get notes => VietnamNotesCatalog.notes;

  NoteEquivalent equivalentFor(VietnamNote note) {
    final usd = rates.toUsd(note.amountVnd.toDouble(), CurrencyCode.vnd);
    final npr = rates.fromUsd(usd, CurrencyCode.npr);
    return NoteEquivalent(
      usdText: CurrencyFormatter.format(usd, CurrencyCode.usd),
      nprText: CurrencyFormatter.format(npr, CurrencyCode.npr),
    );
  }

  NotesState copyWith({FxRates? rates, bool? isLoading}) {
    return NotesState(
      rates: rates ?? this.rates,
      isLoading: isLoading ?? this.isLoading,
    );
  }

  @override
  List<Object?> get props => [rates, isLoading];
}

class NotesCubit extends Cubit<NotesState> {
  NotesCubit({required FxRatesRepository fxRatesRepository})
    : _fxRatesRepository = fxRatesRepository,
      super(const NotesState());

  final FxRatesRepository _fxRatesRepository;
  StreamSubscription<FxRates>? _ratesSub;

  Future<void> init() async {
    final result = await _fxRatesRepository.getRates();
    emit(
      state.copyWith(
        rates: result.getOrElse(() => FxRates.defaults),
        isLoading: false,
      ),
    );

    _ratesSub = _fxRatesRepository.watchRates().listen((rates) {
      emit(state.copyWith(rates: rates));
    });
  }

  @override
  Future<void> close() {
    _ratesSub?.cancel();
    return super.close();
  }
}
