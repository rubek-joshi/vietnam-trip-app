import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vietnam_handbook/features/phrases/domain/entities/phrase.dart';

class PhrasesState extends Equatable {
  const PhrasesState({
    this.query = '',
    this.category,
  });

  final String query;
  final String? category;

  List<Phrase> get filtered {
    final q = query.trim().toLowerCase();
    return travelPhrases.where((p) {
      if (category != null && p.category != category) return false;
      if (q.isEmpty) return true;
      return p.english.toLowerCase().contains(q) ||
          p.vietnamese.toLowerCase().contains(q) ||
          p.pronunciation.toLowerCase().contains(q);
    }).toList();
  }

  Map<String, List<Phrase>> get grouped {
    final map = <String, List<Phrase>>{};
    for (final p in filtered) {
      map.putIfAbsent(p.category, () => []).add(p);
    }
    return map;
  }

  PhrasesState copyWith({String? query, String? category, bool clearCategory = false}) {
    return PhrasesState(
      query: query ?? this.query,
      category: clearCategory ? null : (category ?? this.category),
    );
  }

  @override
  List<Object?> get props => [query, category];
}

class PhrasesCubit extends Cubit<PhrasesState> {
  PhrasesCubit() : super(const PhrasesState());

  void setQuery(String query) => emit(state.copyWith(query: query));

  void setCategory(String? category) {
    if (category == null) {
      emit(state.copyWith(clearCategory: true));
    } else {
      emit(state.copyWith(category: category));
    }
  }
}
