import 'package:equatable/equatable.dart';

class ChecklistItem extends Equatable {
  const ChecklistItem({
    required this.id,
    required this.day,
    required this.title,
    this.done = false,
    this.order = 0,
  });

  final String id;
  final int day;
  final String title;
  final bool done;
  final int order;

  ChecklistItem copyWith({
    String? id,
    int? day,
    String? title,
    bool? done,
    int? order,
  }) {
    return ChecklistItem(
      id: id ?? this.id,
      day: day ?? this.day,
      title: title ?? this.title,
      done: done ?? this.done,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'day': day,
        'title': title,
        'done': done,
        'order': order,
      };

  factory ChecklistItem.fromJson(Map<dynamic, dynamic> json) {
    return ChecklistItem(
      id: json['id'] as String,
      day: json['day'] as int,
      title: json['title'] as String,
      done: json['done'] as bool? ?? false,
      order: json['order'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, day, title, done, order];
}

/// Practical seeds from the package itinerary.
List<ChecklistItem> seedChecklistItems() {
  const seeds = <(int day, String title)>[
    (1, 'Airport meet & hotel check-in (after 14:00)'),
    (1, 'Hoi An Ancient Town walk'),
    (1, 'Release lantern on Hoai River'),
    (2, 'Breakfast at hotel'),
    (2, 'Ba Na Hills + Golden Bridge'),
    (2, 'Fantasy Park / French Village'),
    (2, 'Evening free — My Khe Beach optional'),
    (3, 'Check out & flight Danang → Hanoi'),
    (3, 'Hotel check-in in Hanoi'),
    (3, 'Mega Grand World visit'),
    (4, 'Hotel pickup ~08:00 for Halong'),
    (4, 'Amanda / Halong cruise check-in'),
    (4, 'Kayaking at Luon Cave'),
    (4, 'Titop Island hike or swim'),
    (4, 'Sunset party & cooking class'),
    (5, 'Tai Chi / Sung Sot Cave'),
    (5, 'Cruise checkout & return to Hanoi'),
    (5, 'Half-day city tour (Mausoleum, Train Street, Hoan Kiem)'),
    (6, 'Pickup ~08:30 for Ninh Binh'),
    (6, 'Hoa Lu Ancient Capital'),
    (6, 'Trang An boat ride'),
    (6, 'Evening free in Old Quarter'),
    (7, 'Breakfast & hotel checkout'),
    (7, 'Airport transfer — departure'),
  ];

  return [
    for (var i = 0; i < seeds.length; i++)
      ChecklistItem(
        id: 'seed-$i',
        day: seeds[i].$1,
        title: seeds[i].$2,
        order: i,
      ),
  ];
}
