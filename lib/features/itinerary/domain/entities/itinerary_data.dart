import 'package:equatable/equatable.dart';

class DayItinerary extends Equatable {
  const DayItinerary({
    required this.day,
    required this.title,
    required this.dateLabel,
    required this.meals,
    required this.overnight,
    required this.summary,
    required this.details,
  });

  final int day;
  final String title;
  final String dateLabel;
  final String meals;
  final String overnight;
  final String summary;
  final List<String> details;

  @override
  List<Object?> get props => [
    day,
    title,
    dateLabel,
    meals,
    overnight,
    summary,
    details,
  ];
}

const tripItinerary = <DayItinerary>[
  DayItinerary(
    day: 1,
    title: 'Danang arrival – Hoi An Ancient Town – Release lantern',
    dateLabel: '22 Sep',
    meals: '—',
    overnight: 'Danang',
    summary:
        'Arrive Danang, hotel check-in, afternoon Hoi An walk & lantern release.',
    details: [
      'Meet & greet at Danang International Airport; transfer to hotel.',
      'Normal check-in from 14:00.',
      'Afternoon: proceed to Hoi An Ancient Town.',
      'Walking tour: Japanese Covered Bridge, merchant houses, riverside.',
      'Free time for shops and night market.',
      'Release lantern on Hoai River.',
      'Transfer back; overnight in Danang.',
    ],
  ),
  DayItinerary(
    day: 2,
    title: 'Danang – Ba Na Hills – Golden Bridge',
    dateLabel: '23 Sep',
    meals: 'B / L',
    overnight: 'Danang',
    summary:
        'Full day Ba Na Hills: cable car, Golden Bridge, French Village, Fantasy Park.',
    details: [
      'Breakfast at hotel; depart for Ba Na Hills.',
      'Scenic cable car with forest & waterfall views.',
      'Visit the iconic Golden Bridge (giant stone hands).',
      'Explore Le Jardin D\'Amour, Debay Wine Cellar (own expense), French Village.',
      'Fantasy Park indoor amusement center.',
      'Afternoon cable car down; return to Da Nang.',
      'Evening free — My Khe Beach optional.',
      'Overnight in Danang.',
    ],
  ),
  DayItinerary(
    day: 3,
    title: 'Danang – Hanoi by flight – Mega Grand World',
    dateLabel: '24 Sep',
    meals: 'B',
    overnight: 'Hanoi',
    summary: 'Fly to Hanoi; afternoon shopping at Mega Grand World.',
    details: [
      'Breakfast; check out; transfer to Danang airport for Hanoi flight.',
      'Arrive Hanoi; hotel check-in.',
      'Afternoon free time with transfer.',
      'Proceed to Mega Grand World Hanoi (Venice-inspired streets & canals).',
      'Free time for shopping, photos, cafés, entertainment.',
      'Evening return to hotel; overnight in Hanoi.',
    ],
  ),
  DayItinerary(
    day: 4,
    title: 'Hanoi – Halong Bay overnight cruise',
    dateLabel: '25 Sep',
    meals: 'B / L / D',
    overnight: 'Halong Bay (cruise)',
    summary:
        'Shuttle to Halong; overnight cruise (Amanda Cruise or similar) with kayaking & Titop.',
    details: [
      'Breakfast at hotel.',
      '~08:00 pickup from Hanoi Old Quarter to Ha Long.',
      '11:30–12:00 arrive Tuan Chau; cruise check-in.',
      'Board cruise; welcome drink; lunch while cruising to Luon Cave.',
      'Kayaking / rafting around limestone formations.',
      'Titop Island — hike for views or swim.',
      'Sunset party, cooking class (fresh spring rolls), happy hour.',
      'Gala dinner; evening activities (foot bath, squid fishing, bar).',
      'Overnight on board.',
    ],
  ),
  DayItinerary(
    day: 5,
    title: 'Halong Bay – Hanoi – Half-day city tour',
    dateLabel: '26 Sep',
    meals: 'B / Br',
    overnight: 'Hanoi',
    summary:
        'Sung Sot Cave, brunch, return to Hanoi; half-day city highlights.',
    details: [
      '06:15 Tai Chi on sundeck; light breakfast.',
      'Explore Sung Sot Cave.',
      'Checkout ~09:30; early lunch buffet; settle bills.',
      '11:00 arrive Tuan Chau; shuttle back to Hanoi; hotel check-in.',
      'Half-day city tour: Ho Chi Minh Mausoleum (outside), One Pillar Pagoda.',
      'Hanoi Train Street.',
      'Walk around Hoan Kiem Lake & Old Quarter.',
      'Overnight in Hanoi.',
    ],
  ),
  DayItinerary(
    day: 6,
    title: 'Hanoi – Hoa Lu – Trang An – Hanoi',
    dateLabel: '27 Sep',
    meals: 'B',
    overnight: 'Hanoi',
    summary: 'Day trip to Ninh Binh: Hoa Lu capital & Trang An boat ride.',
    details: [
      'Breakfast at hotel.',
      '~08:30 pickup for Ninh Binh (“Halong Bay on land”).',
      'Visit Hoa Lu Ancient Capital — temples of King Dinh & King Le.',
      'Trang An Scenic Landscape Complex (UNESCO).',
      'Sampan boat through caves, rivers, and karsts.',
      'Return to Hanoi; evening free in Old Quarter.',
      'Overnight in Hanoi.',
    ],
  ),
  DayItinerary(
    day: 7,
    title: 'Hanoi departure',
    dateLabel: '28 Sep',
    meals: 'B',
    overnight: '—',
    summary: 'Breakfast and airport transfer. End of services.',
    details: [
      'Breakfast at the hotel.',
      'Transfer to the airport for your onward flight.',
      'End of services — safe travels!',
    ],
  ),
];

DayItinerary itineraryForDay(int day) =>
    tripItinerary.firstWhere((e) => e.day == day);

class HotelInfo {
  const HotelInfo({
    required this.destination,
    required this.name,
    required this.room,
  });

  final String destination;
  final String name;
  final String room;
}

const packageHotels = <HotelInfo>[
  HotelInfo(
    destination: 'Danang',
    name: 'Anfada Danang Hotel',
    room: 'Deluxe partial ocean view (or similar)',
  ),
  HotelInfo(
    destination: 'Hanoi',
    name: 'La Dolce Vita Hanoi Hotel',
    room: 'Superior (or similar)',
  ),
  HotelInfo(
    destination: 'Halong Bay',
    name: 'Le Journey Premium Cruise / Amanda Cruise',
    room: 'Deluxe (or similar)',
  ),
];

const packageInclusions = <String>[
  'Meals mentioned in itinerary (B / Br / L / D)',
  'English-speaking guide on day trips',
  'Tours and sightseeing as per itinerary',
  'Private airport transfers (16 seats)',
  'Private tour transfers (16 seats)',
  'Shuttle bus Hanoi – Halong Bay',
  'Bottled water on vehicles (2/full day, 1/half day or airport)',
  'Accommodations twin/double/triple occupancy',
  'E-Visa to Vietnam (single or multiple entry)',
  'Flight ticket (as included in package)',
  'Compulsory tipping for private tours: USD 3/pax/full day, USD 1.5/half day or airport',
];

const packageExclusions = <String>[
  'Meals not mentioned in the itinerary',
  'Single supplement',
  'Early check-in / late check-out',
  'Room upgrades',
  'International & domestic flights and airport taxes (if not in package)',
  'Bank transfer fees, GST, TCS',
  'Personal expenses (laundry, beverages, tips for SIC/joint tours, hotel/restaurant/boat staff)',
  'Services not mentioned in the itinerary',
];

class PackageCosts {
  static const usdPerPax = 379.0;
  static const nprPackageRateNote =
      'USD 379/pax @ NPR 153 + 3 = NPR 59,124/pax';
  static const internationalTicketNpr = 84130.0;
  static const domesticTicketNpr = 5889.0;
  static const totalNpr = 149143.0;
  static const groupSize = 9;
  static const nights = '6 nights / 7 days';
  static const travelFrom = '22 Sep onwards';
}
