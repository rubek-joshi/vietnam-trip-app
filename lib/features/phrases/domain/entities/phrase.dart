import 'package:equatable/equatable.dart';

class Phrase extends Equatable {
  const Phrase({
    required this.english,
    required this.vietnamese,
    required this.pronunciation,
    required this.category,
  });

  final String english;
  final String vietnamese;
  final String pronunciation;
  final String category;

  @override
  List<Object?> get props => [english, vietnamese, pronunciation, category];
}

const phraseCategories = [
  'Greetings',
  'Food',
  'Taxi & Directions',
  'Money',
  'Hotel',
  'Emergency',
];

const travelPhrases = <Phrase>[
  // Greetings
  Phrase(
    english: 'Hello',
    vietnamese: 'Xin chào',
    pronunciation: 'sin chow',
    category: 'Greetings',
  ),
  Phrase(
    english: 'Good morning',
    vietnamese: 'Chào buổi sáng',
    pronunciation: 'chow boo-ee sang',
    category: 'Greetings',
  ),
  Phrase(
    english: 'Thank you',
    vietnamese: 'Cảm ơn',
    pronunciation: 'kahm un',
    category: 'Greetings',
  ),
  Phrase(
    english: 'Thank you very much',
    vietnamese: 'Cảm ơn rất nhiều',
    pronunciation: 'kahm un zut nyew',
    category: 'Greetings',
  ),
  Phrase(
    english: 'You\'re welcome',
    vietnamese: 'Không có gì',
    pronunciation: 'khong kaw mee',
    category: 'Greetings',
  ),
  Phrase(
    english: 'Sorry / Excuse me',
    vietnamese: 'Xin lỗi',
    pronunciation: 'sin loy',
    category: 'Greetings',
  ),
  Phrase(
    english: 'Yes',
    vietnamese: 'Vâng / Có',
    pronunciation: 'vang / kaw',
    category: 'Greetings',
  ),
  Phrase(
    english: 'No',
    vietnamese: 'Không',
    pronunciation: 'khong',
    category: 'Greetings',
  ),
  Phrase(
    english: 'Do you speak English?',
    vietnamese: 'Bạn nói tiếng Anh được không?',
    pronunciation: 'ban noy tyeng ang duk khong?',
    category: 'Greetings',
  ),
  Phrase(
    english: 'I don\'t understand',
    vietnamese: 'Tôi không hiểu',
    pronunciation: 'toy khong hyew',
    category: 'Greetings',
  ),
  // Food
  Phrase(
    english: 'I want this',
    vietnamese: 'Tôi muốn cái này',
    pronunciation: 'toy moo-un kai nay',
    category: 'Food',
  ),
  Phrase(
    english: 'The bill, please',
    vietnamese: 'Tính tiền giúp tôi',
    pronunciation: 'tin tyen zoop toy',
    category: 'Food',
  ),
  Phrase(
    english: 'Delicious!',
    vietnamese: 'Ngon quá!',
    pronunciation: 'ngon kwa!',
    category: 'Food',
  ),
  Phrase(
    english: 'No spicy',
    vietnamese: 'Không cay',
    pronunciation: 'khong kai',
    category: 'Food',
  ),
  Phrase(
    english: 'Less spicy',
    vietnamese: 'Ít cay',
    pronunciation: 'eet kai',
    category: 'Food',
  ),
  Phrase(
    english: 'Water',
    vietnamese: 'Nước lọc',
    pronunciation: 'nuhk lawk',
    category: 'Food',
  ),
  Phrase(
    english: 'Coffee',
    vietnamese: 'Cà phê',
    pronunciation: 'kah feh',
    category: 'Food',
  ),
  Phrase(
    english: 'Beer',
    vietnamese: 'Bia',
    pronunciation: 'bee-ah',
    category: 'Food',
  ),
  Phrase(
    english: 'Vegetarian',
    vietnamese: 'Ăn chay',
    pronunciation: 'an chai',
    category: 'Food',
  ),
  Phrase(
    english: 'I\'m allergic to…',
    vietnamese: 'Tôi bị dị ứng với…',
    pronunciation: 'toy bee zee oong vuh…',
    category: 'Food',
  ),
  // Taxi & Directions
  Phrase(
    english: 'How much to…?',
    vietnamese: 'Đến … bao nhiêu tiền?',
    pronunciation: 'den … bow nyew tyen?',
    category: 'Taxi & Directions',
  ),
  Phrase(
    english: 'Take me to this address',
    vietnamese: 'Đưa tôi đến địa chỉ này',
    pronunciation: 'dua toy den dee-ah chee nay',
    category: 'Taxi & Directions',
  ),
  Phrase(
    english: 'Stop here',
    vietnamese: 'Dừng lại đây',
    pronunciation: 'zung lai day',
    category: 'Taxi & Directions',
  ),
  Phrase(
    english: 'Turn left',
    vietnamese: 'Rẽ trái',
    pronunciation: 'reh chai',
    category: 'Taxi & Directions',
  ),
  Phrase(
    english: 'Turn right',
    vietnamese: 'Rẽ phải',
    pronunciation: 'reh fai',
    category: 'Taxi & Directions',
  ),
  Phrase(
    english: 'Straight ahead',
    vietnamese: 'Đi thẳng',
    pronunciation: 'dee thang',
    category: 'Taxi & Directions',
  ),
  Phrase(
    english: 'Where is the bathroom?',
    vietnamese: 'Nhà vệ sinh ở đâu?',
    pronunciation: 'nya veh sin uh dow?',
    category: 'Taxi & Directions',
  ),
  Phrase(
    english: 'Airport',
    vietnamese: 'Sân bay',
    pronunciation: 'sun buy',
    category: 'Taxi & Directions',
  ),
  Phrase(
    english: 'Train station',
    vietnamese: 'Ga tàu',
    pronunciation: 'gah tow',
    category: 'Taxi & Directions',
  ),
  // Money
  Phrase(
    english: 'How much is this?',
    vietnamese: 'Cái này bao nhiêu?',
    pronunciation: 'kai nay bow nyew?',
    category: 'Money',
  ),
  Phrase(
    english: 'Too expensive',
    vietnamese: 'Đắt quá',
    pronunciation: 'dat kwa',
    category: 'Money',
  ),
  Phrase(
    english: 'Can you lower the price?',
    vietnamese: 'Bớt được không?',
    pronunciation: 'but duk khong?',
    category: 'Money',
  ),
  Phrase(
    english: 'Do you accept cards?',
    vietnamese: 'Có nhận thẻ không?',
    pronunciation: 'kaw nyun teh khong?',
    category: 'Money',
  ),
  Phrase(
    english: 'Cash only?',
    vietnamese: 'Chỉ nhận tiền mặt?',
    pronunciation: 'chee nyun tyen mat?',
    category: 'Money',
  ),
  Phrase(
    english: 'Exchange money',
    vietnamese: 'Đổi tiền',
    pronunciation: 'doy tyen',
    category: 'Money',
  ),
  Phrase(
    english: 'ATM',
    vietnamese: 'Máy ATM',
    pronunciation: 'may ATM',
    category: 'Money',
  ),
  // Hotel
  Phrase(
    english: 'I have a reservation',
    vietnamese: 'Tôi đã đặt phòng',
    pronunciation: 'toy da dat fong',
    category: 'Hotel',
  ),
  Phrase(
    english: 'Check-in',
    vietnamese: 'Nhận phòng',
    pronunciation: 'nyun fong',
    category: 'Hotel',
  ),
  Phrase(
    english: 'Check-out',
    vietnamese: 'Trả phòng',
    pronunciation: 'cha fong',
    category: 'Hotel',
  ),
  Phrase(
    english: 'Wi-Fi password?',
    vietnamese: 'Mật khẩu Wi-Fi?',
    pronunciation: 'mut khow Wi-Fi?',
    category: 'Hotel',
  ),
  Phrase(
    english: 'Can I leave my luggage?',
    vietnamese: 'Tôi gửi hành lý được không?',
    pronunciation: 'toy goo han lee duk khong?',
    category: 'Hotel',
  ),
  Phrase(
    english: 'Room key',
    vietnamese: 'Chìa khóa phòng',
    pronunciation: 'chee-ah kwa fong',
    category: 'Hotel',
  ),
  // Emergency
  Phrase(
    english: 'Help!',
    vietnamese: 'Cứu tôi!',
    pronunciation: 'koo toy!',
    category: 'Emergency',
  ),
  Phrase(
    english: 'Call the police',
    vietnamese: 'Gọi cảnh sát',
    pronunciation: 'goy kang sat',
    category: 'Emergency',
  ),
  Phrase(
    english: 'I need a doctor',
    vietnamese: 'Tôi cần bác sĩ',
    pronunciation: 'toy kun bak see',
    category: 'Emergency',
  ),
  Phrase(
    english: 'Hospital',
    vietnamese: 'Bệnh viện',
    pronunciation: 'ben vee-en',
    category: 'Emergency',
  ),
  Phrase(
    english: 'I am lost',
    vietnamese: 'Tôi bị lạc',
    pronunciation: 'toy bee lak',
    category: 'Emergency',
  ),
  Phrase(
    english: 'Pharmacy',
    vietnamese: 'Nhà thuốc',
    pronunciation: 'nya too-uk',
    category: 'Emergency',
  ),
  Phrase(
    english: 'My phone is stolen',
    vietnamese: 'Điện thoại của tôi bị mất',
    pronunciation: 'dee-en twai kua toy bee mut',
    category: 'Emergency',
  ),
];
