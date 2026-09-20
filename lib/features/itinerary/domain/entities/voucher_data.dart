import 'package:equatable/equatable.dart';

class VoucherMeta {
  VoucherMeta._();

  static const issued = '20 Sep 2026';
  static const clientName = 'Ashraya Tamrakar';
  static const paxLabel = '09 pax';
  static const adults = 9;
  static const children = 0;
  static const infants = 0;
  static const tourCode = 'NPSH220926';
  static const company = 'Sumegh Holidays';
  static const handledBy = 'Ms Jena';
  static const handledByPhone = '+84 376 597 498';
  static const occupancy = '4 DBL + 1 extra bed';
  static const operatorName = 'VN Bike Tour';
  static const operatorOffice = '470A Nguyen Tat Thanh St, District 4';
  static const operatorHotline = '+84 888 688 911';
  static const operatorEmail = 'info@vnbiketour.com';
  static const operatorWebsite = 'vnbiketour.com';
}

class VoucherStay extends Equatable {
  const VoucherStay({
    required this.from,
    required this.to,
    required this.property,
    required this.room,
    required this.meals,
    required this.nights,
    required this.confirmCode,
  });

  final String from;
  final String to;
  final String property;
  final String room;
  final String meals;
  final int nights;
  final String confirmCode;

  @override
  List<Object?> get props => [
    from,
    to,
    property,
    room,
    meals,
    nights,
    confirmCode,
  ];
}

class VoucherFlight extends Equatable {
  const VoucherFlight({
    required this.date,
    required this.flightNo,
    required this.from,
    required this.to,
    required this.depart,
    required this.arrive,
  });

  final String date;
  final String flightNo;
  final String from;
  final String to;
  final String depart;
  final String arrive;

  @override
  List<Object?> get props => [date, flightNo, from, to, depart, arrive];
}

class VoucherService extends Equatable {
  const VoucherService({
    required this.date,
    required this.name,
    this.flight,
    this.meals = '—',
    this.guide = '—',
    this.transfer = '—',
    this.confirmed = true,
  });

  final String date;
  final String name;
  final String? flight;
  final String meals;
  final String guide;
  final String transfer;
  final bool confirmed;

  @override
  List<Object?> get props => [
    date,
    name,
    flight,
    meals,
    guide,
    transfer,
    confirmed,
  ];
}

const voucherStays = <VoucherStay>[
  VoucherStay(
    from: '22 Sep',
    to: '24 Sep',
    property: 'Anfada Danang Hotel',
    room: 'Deluxe partial sea view',
    meals: 'Breakfast',
    nights: 2,
    confirmCode: '11089',
  ),
  VoucherStay(
    from: '24 Sep',
    to: '25 Sep',
    property: 'La Dolce Vita Hanoi Hotel',
    room: 'Superior',
    meals: 'Breakfast',
    nights: 1,
    confirmCode: 'NPSH150926',
  ),
  VoucherStay(
    from: '25 Sep',
    to: '26 Sep',
    property: 'Le Journey Premium Cruise',
    room: 'Deluxe',
    meals: 'Full board',
    nights: 1,
    confirmCode: '17177',
  ),
  VoucherStay(
    from: '26 Sep',
    to: '28 Sep',
    property: 'La Dolce Vita Hanoi Hotel',
    room: 'Superior',
    meals: 'Breakfast',
    nights: 2,
    confirmCode: 'NPSH150926',
  ),
];

const voucherFlights = <VoucherFlight>[
  VoucherFlight(
    date: '22 Sep',
    flightNo: 'MH 746',
    from: 'KUL',
    to: 'DAD',
    depart: '08:35',
    arrive: '10:25',
  ),
  VoucherFlight(
    date: '24 Sep',
    flightNo: 'VJ 524',
    from: 'DAD',
    to: 'HAN',
    depart: '09:20',
    arrive: '10:40',
  ),
  VoucherFlight(
    date: '28 Sep',
    flightNo: 'MH 753',
    from: 'HAN',
    to: 'KUL',
    depart: '13:05',
    arrive: '17:30',
  ),
];

const voucherServices = <VoucherService>[
  VoucherService(
    date: '22 Sep',
    name: 'Danang arrival – Hoi An Ancient Town – release lantern',
    flight: 'MH 746 KUL → DAD 08:35–10:25',
    meals: '—',
    guide: '1',
    transfer: '16-seat',
  ),
  VoucherService(
    date: '23 Sep',
    name: 'Danang – Ba Na Hills – Golden Bridge',
    meals: 'B / L',
    guide: '1',
    transfer: '16-seat',
  ),
  VoucherService(
    date: '24 Sep',
    name: 'Danang – Hanoi by flight – Mega Grand World',
    flight: 'VJ 524 DAD → HAN 09:20–10:40',
    meals: 'B',
    guide: '—',
    transfer: '16-seat',
  ),
  VoucherService(
    date: '25 Sep',
    name: 'Hanoi – Halong Bay overnight cruise',
    meals: 'B / L / D',
    guide: '1',
    transfer: 'Shuttle bus',
  ),
  VoucherService(
    date: '26 Sep',
    name: 'Halong Bay – Hanoi – half-day city tour',
    meals: 'B / Br',
    guide: '1',
    transfer: 'Shuttle bus + 16-seat',
  ),
  VoucherService(
    date: '27 Sep',
    name: 'Hanoi – Hoa Lu – Trang An – Mua Cave – Hanoi',
    meals: 'B',
    guide: '1',
    transfer: '16-seat',
  ),
  VoucherService(
    date: '28 Sep',
    name: 'Hanoi departure',
    flight: 'MH 753 HAN → KUL 13:05–17:30',
    meals: 'B',
    guide: '—',
    transfer: '16-seat',
  ),
];
