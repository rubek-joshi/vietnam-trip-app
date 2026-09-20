import 'package:vietnam_handbook/features/shopping/domain/entities/shopping_item.dart';

String capitalizeFirstWord(String input) {
  final index = input.indexOf(RegExp(r'\S'));
  if (index < 0) return input;
  final upper = input[index].toUpperCase();
  if (input[index] == upper) return input;
  return '${input.substring(0, index)}$upper${input.substring(index + 1)}';
}

const shoppingListEmptySummary = 'Manage souvenirs, gifts, and other items';

String shoppingListSummary(Iterable<ShoppingItem> items) {
  final list = items.toList();
  if (list.isEmpty) return shoppingListEmptySummary;
  final bought = list.where((item) => item.bought).length;
  final total = list.length;
  final remaining = total - bought;
  return '$bought/$total bought · $remaining remaining';
}
