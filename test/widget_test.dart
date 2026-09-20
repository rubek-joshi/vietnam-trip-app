import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_handbook/core/fx/currency_input_formatter.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';

void main() {
  group('CurrencyFormatter', () {
    test('formats VND with western thousands separators and no decimals', () {
      expect(CurrencyFormatter.format(2500000, CurrencyCode.vnd), '₫2,500,000');
    });

    test('formats USD with western thousands separators', () {
      expect(CurrencyFormatter.format(1234.5, CurrencyCode.usd), '\$1,234.50');
    });

    test('formats NPR with Indian numbering (lakhs / crores)', () {
      expect(CurrencyFormatter.format(1234, CurrencyCode.npr), 'NPR 1,234.00');
      expect(
        CurrencyFormatter.format(12345, CurrencyCode.npr),
        'NPR 12,345.00',
      );
      expect(
        CurrencyFormatter.format(123456, CurrencyCode.npr),
        'NPR 1,23,456.00',
      );
      expect(
        CurrencyFormatter.format(149143, CurrencyCode.npr),
        'NPR 1,49,143.00',
      );
      expect(
        CurrencyFormatter.format(12345678, CurrencyCode.npr),
        'NPR 1,23,45,678.00',
      );
    });

    test('grouped omits the symbol', () {
      expect(CurrencyFormatter.grouped(25960, CurrencyCode.vnd), '25,960');
      expect(
        CurrencyFormatter.grouped(149143, CurrencyCode.npr),
        '1,49,143.00',
      );
    });

    test('maskInput uses Indian grouping for NPR as the user types', () {
      expect(CurrencyFormatter.maskInput('1234', CurrencyCode.npr), '1,234');
      expect(CurrencyFormatter.maskInput('12345', CurrencyCode.npr), '12,345');
      expect(
        CurrencyFormatter.maskInput('123456', CurrencyCode.npr),
        '1,23,456',
      );
      expect(
        CurrencyFormatter.maskInput('1234567', CurrencyCode.npr),
        '12,34,567',
      );
      expect(
        CurrencyFormatter.maskInput('1,23,456.7', CurrencyCode.npr),
        '1,23,456.7',
      );
      expect(CurrencyFormatter.maskInput('1234.', CurrencyCode.npr), '1,234.');
    });

    test('maskInput uses western grouping for USD and VND', () {
      expect(
        CurrencyFormatter.maskInput('1234.5', CurrencyCode.usd),
        '1,234.5',
      );
      expect(
        CurrencyFormatter.maskInput('2500000', CurrencyCode.vnd),
        '2,500,000',
      );
      expect(
        CurrencyFormatter.maskInput('2500000.99', CurrencyCode.vnd),
        '2,500,000',
      );
    });
  });

  group('CurrencyInputFormatter', () {
    test('inserts Indian commas while typing NPR', () {
      const formatter = CurrencyInputFormatter(CurrencyCode.npr);
      final result = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '1,23,45',
          selection: TextSelection.collapsed(offset: 7),
        ),
        const TextEditingValue(
          text: '1,23,456',
          selection: TextSelection.collapsed(offset: 8),
        ),
      );
      expect(result.text, '1,23,456');
      expect(result.selection.baseOffset, 8);
    });

    test('backspacing a comma also deletes the preceding digit', () {
      const formatter = CurrencyInputFormatter(CurrencyCode.npr);
      final result = formatter.formatEditUpdate(
        const TextEditingValue(
          text: '1,23,456',
          selection: TextSelection.collapsed(offset: 5),
        ),
        const TextEditingValue(
          text: '1,23456',
          selection: TextSelection.collapsed(offset: 4),
        ),
      );
      expect(result.text, '12,456');
    });
  });
}
