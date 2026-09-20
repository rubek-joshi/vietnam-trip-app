import 'package:equatable/equatable.dart';

class ShoppingItem extends Equatable {
  const ShoppingItem({
    required this.id,
    required this.title,
    this.bought = false,
    this.note = '',
    this.order = 0,
    this.boughtAt,
  });

  final String id;
  final String title;
  final bool bought;
  final String note;
  final int order;
  final DateTime? boughtAt;

  ShoppingItem copyWith({
    String? id,
    String? title,
    bool? bought,
    String? note,
    int? order,
    DateTime? boughtAt,
    bool clearBoughtAt = false,
  }) {
    return ShoppingItem(
      id: id ?? this.id,
      title: title ?? this.title,
      bought: bought ?? this.bought,
      note: note ?? this.note,
      order: order ?? this.order,
      boughtAt: clearBoughtAt ? null : (boughtAt ?? this.boughtAt),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'bought': bought,
    'note': note,
    'order': order,
    if (boughtAt != null) 'boughtAt': boughtAt!.toIso8601String(),
  };

  factory ShoppingItem.fromJson(Map<dynamic, dynamic> json) {
    final boughtAtRaw = json['boughtAt'] as String?;
    return ShoppingItem(
      id: json['id'] as String,
      title: json['title'] as String,
      bought: json['bought'] as bool? ?? false,
      note: json['note'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      boughtAt: boughtAtRaw == null || boughtAtRaw.isEmpty
          ? null
          : DateTime.tryParse(boughtAtRaw),
    );
  }

  @override
  List<Object?> get props => [id, title, bought, note, order, boughtAt];
}
