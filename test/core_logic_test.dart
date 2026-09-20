import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';
import 'package:vietnam_handbook/core/trip/trip_dates.dart';
import 'package:vietnam_handbook/features/budget/domain/entities/budget_entities.dart';
import 'package:vietnam_handbook/features/itinerary/presentation/cubit/tipping_cubit.dart';
import 'package:vietnam_handbook/features/settings/domain/entities/app_settings.dart';

void main() {
  group('FxRates', () {
    const rates = FxRates(usdToNpr: 153.50, usdToVnd: 25960);

    test('converts USD to NPR and VND', () {
      expect(
        rates.convert(amount: 10, from: CurrencyCode.usd, to: CurrencyCode.npr),
        1535,
      );
      expect(
        rates.convert(amount: 1, from: CurrencyCode.usd, to: CurrencyCode.vnd),
        25960,
      );
    });

    test('round-trips NPR through USD', () {
      final usd = rates.toUsd(153.50, CurrencyCode.npr);
      expect(usd, closeTo(1, 0.0001));
      expect(rates.fromUsd(usd, CurrencyCode.npr), closeTo(153.50, 0.0001));
    });

    test('toNpr from VND', () {
      final npr = rates.toNpr(25960, CurrencyCode.vnd);
      expect(npr, closeTo(153.50, 0.01));
    });
  });

  group('TripDates', () {
    test('active day before trip is 1', () {
      expect(TripDates.activeDay(DateTime(2026, 9, 1)), 1);
    });

    test('active day during trip', () {
      expect(TripDates.activeDay(DateTime(2026, 9, 22)), 1);
      expect(TripDates.activeDay(DateTime(2026, 9, 25)), 4);
      expect(TripDates.activeDay(DateTime(2026, 9, 28)), 7);
    });

    test('active day after trip is 7', () {
      expect(TripDates.activeDay(DateTime(2026, 10, 5)), 7);
    });

    test('remaining days', () {
      expect(TripDates.remainingDays(DateTime(2026, 9, 22)), 7);
      expect(TripDates.remainingDays(DateTime(2026, 9, 28)), 1);
      expect(TripDates.remainingDays(DateTime(2026, 9, 29)), 0);
    });
  });

  group('BudgetSnapshot', () {
    test('tracks remaining after exchange and expenses', () {
      const rates = FxRates.defaults;
      final snap = BudgetSnapshot(
        config: const BudgetConfig(
          initialUsd: 500,
          initialVnd: 0,
          configured: true,
        ),
        exchanges: [
          ExchangeRecord(
            id: '1',
            usdAmount: 100,
            vndReceived: 2500000,
            date: DateTime(2026, 9, 22),
          ),
        ],
        expenses: [
          ExpenseRecord(
            id: 'e1',
            title: 'Coffee',
            amount: 50000,
            currency: ExpenseCurrency.vnd,
            date: DateTime(2026, 9, 22),
          ),
          ExpenseRecord(
            id: 'e2',
            title: 'Souvenir',
            amount: 20,
            currency: ExpenseCurrency.usd,
            date: DateTime(2026, 9, 22),
          ),
        ],
        rates: rates,
      );

      expect(snap.remainingUsd, 380); // 500 - 100 - 20
      expect(snap.remainingVnd, 2450000); // 0 + 2500000 - 50000
      expect(snap.isOverspent, isFalse);
    });

    test('suggested per-day uses remaining days', () {
      const rates = FxRates.defaults;
      const snap = BudgetSnapshot(
        config: BudgetConfig(initialUsd: 700, configured: true),
        exchanges: [],
        expenses: [],
        rates: rates,
      );
      final days = TripDates.remainingDays(DateTime(2026, 9, 22));
      expect(days, 7);
      expect(snap.remainingUsdEquivalent / days, closeTo(100, 0.01));
    });
  });

  group('AppSettings', () {
    test('serializes theme mode and color scheme', () {
      const settings = AppSettings(
        themeMode: AppThemeMode.dark,
        colorScheme: 'rose',
      );
      final restored = AppSettings.fromJson(settings.toJson());
      expect(restored.themeMode, AppThemeMode.dark);
      expect(restored.colorScheme, 'rose');
    });

    test('falls back to system theme and zinc on invalid json', () {
      final restored = AppSettings.fromJson({
        'themeMode': 'neon',
        'colorScheme': 'not-a-scheme',
      });
      expect(restored.themeMode, AppThemeMode.system);
      expect(restored.colorScheme, AppSettings.defaultColorScheme);
    });
  });

  group('TippingState', () {
    test('defaults to USD 1.5 per person for 9 people', () {
      const state = TippingState(isLoading: false);
      expect(state.pax, 9);
      expect(state.perPersonUsd, 1.5);
      expect(state.totalUsd, 13.5);
      expect(state.isPreset(TippingCubit.halfDayUsd), isTrue);
      expect(state.totalVnd, closeTo(13.5 * FxRates.defaults.usdToVnd, 0.01));
      expect(state.totalNpr, closeTo(13.5 * FxRates.defaults.usdToNpr, 0.01));
    });

    test('full-day preset is USD 27 for the group', () {
      const state = TippingState(
        perPersonUsd: TippingCubit.fullDayUsd,
        isLoading: false,
      );
      expect(state.totalUsd, 27);
      expect(state.isPreset(TippingCubit.fullDayUsd), isTrue);
    });
  });
}
