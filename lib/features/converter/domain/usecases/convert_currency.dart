import 'package:vietnam_handbook/core/fx/fx_rates.dart';
import 'package:vietnam_handbook/features/converter/domain/entities/saved_conversion.dart';

class ConvertCurrency {
  ConversionTriplet call({
    required double amount,
    required CurrencyCode from,
    required FxRates rates,
  }) {
    final usd = rates.convert(
      amount: amount,
      from: from,
      to: CurrencyCode.usd,
    );
    final npr = rates.convert(
      amount: amount,
      from: from,
      to: CurrencyCode.npr,
    );
    final vnd = rates.convert(
      amount: amount,
      from: from,
      to: CurrencyCode.vnd,
    );
    return ConversionTriplet(usd: usd, npr: npr, vnd: vnd, source: from);
  }
}
