import 'package:equatable/equatable.dart';

enum NoteSide { front, back }

class NoteVariation extends Equatable {
  const NoteVariation({
    required this.series,
    required this.side,
    required this.imageUrl,
    required this.sourcePageUrl,
  });

  final String series;
  final NoteSide side;
  final String imageUrl;
  final String sourcePageUrl;

  String get label =>
      '$series · ${side == NoteSide.front ? 'Front' : 'Back'}';

  bool get isFront => side == NoteSide.front;

  @override
  List<Object> get props => [series, side, imageUrl, sourcePageUrl];
}

class VietnamNote extends Equatable {
  const VietnamNote({
    required this.amountVnd,
    required this.title,
    required this.variations,
  });

  final int amountVnd;
  final String title;
  final List<NoteVariation> variations;

  @override
  List<Object> get props => [amountVnd, title, variations];
}

class NoteEquivalent extends Equatable {
  const NoteEquivalent({required this.usdText, required this.nprText});

  final String usdText;
  final String nprText;

  @override
  List<Object> get props => [usdText, nprText];
}
