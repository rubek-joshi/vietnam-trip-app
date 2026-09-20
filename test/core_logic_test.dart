import 'package:flutter_test/flutter_test.dart';
import 'package:vietnam_handbook/core/fx/fx_rates.dart';
import 'package:vietnam_handbook/core/trip/trip_dates.dart';
import 'package:vietnam_handbook/features/budget/domain/entities/budget_entities.dart';
import 'package:vietnam_handbook/features/itinerary/domain/entities/tipping_rate_preset.dart';
import 'package:vietnam_handbook/features/itinerary/presentation/cubit/tipping_cubit.dart';
import 'package:vietnam_handbook/features/settings/domain/entities/app_settings.dart';
import 'package:vietnam_handbook/features/shopping/domain/entities/shopping_item.dart';
import 'package:vietnam_handbook/features/shopping/domain/shopping_text.dart';
import 'package:vietnam_handbook/features/shopping/presentation/cubit/shopping_cubit.dart';

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

    test('falls back to system theme and orange on invalid json', () {
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
      expect(state.pax, TippingCubit.defaultPax);
      expect(state.pax, 9);
      expect(state.perPersonUsd, 1.5);
      expect(state.totalUsd, 13.5);
      expect(state.isPreset(TippingCubit.halfDayUsd), isTrue);
      expect(state.totalVnd, closeTo(13.5 * FxRates.defaults.usdToVnd, 0.01));
      expect(state.totalNpr, closeTo(13.5 * FxRates.defaults.usdToNpr, 0.01));
    });

    test('session people count can change totals without persisting', () {
      const fewer = TippingState(pax: 8, isLoading: false);
      const more = TippingState(pax: 10, isLoading: false);
      expect(fewer.totalUsd, 12);
      expect(more.totalUsd, 15);
      expect(const TippingState(isLoading: false).pax, 9);
    });

    test('full-day preset is USD 27 for the group', () {
      const state = TippingState(
        perPersonUsd: TippingCubit.fullDayUsd,
        isLoading: false,
      );
      expect(state.totalUsd, 27);
      expect(state.isPreset(TippingCubit.fullDayUsd), isTrue);
    });

    test('page override rates convert totals without changing app rates', () {
      const override = FxRates(usdToNpr: 140, usdToVnd: 25000);
      const state = TippingState(
        perPersonUsd: TippingCubit.halfDayUsd,
        overrideRates: override,
        isLoading: false,
      );
      expect(state.isOverridden, isTrue);
      expect(state.rateSourceLabel, 'Page override');
      expect(state.appRates, FxRates.defaults);
      expect(state.totalVnd, 13.5 * 25000);
      expect(state.totalNpr, 13.5 * 140);
    });

    test('named preset label is used while that rate is active', () {
      const rates = FxRates(usdToNpr: 148, usdToVnd: 25500);
      const preset = TippingRatePreset(
        id: 'street',
        label: 'Street cash',
        rates: rates,
      );
      const state = TippingState(
        overrideRates: rates,
        activePresetId: 'street',
        presets: [preset],
        isLoading: false,
      );
      expect(state.rateSourceLabel, 'Street cash');
      expect(state.rates, rates);
    });
  });

  group('TippingRatePreset', () {
    test('round-trips rates and label', () {
      const preset = TippingRatePreset(
        id: 'hotel',
        label: 'Hotel desk',
        rates: FxRates(usdToNpr: 150.25, usdToVnd: 26100),
      );
      final restored = TippingRatePreset.fromJson(preset.toJson());
      expect(restored, preset);
    });
  });

  group('ShoppingItem', () {
    test('round-trips title, note, and bought timestamp', () {
      final item = ShoppingItem(
        id: 'hat',
        title: 'Non La',
        bought: true,
        note: 'Size M · Old Quarter',
        order: 2,
        boughtAt: DateTime.utc(2026, 9, 23, 10, 30),
      );
      final restored = ShoppingItem.fromJson(item.toJson());
      expect(restored.id, item.id);
      expect(restored.title, item.title);
      expect(restored.bought, isTrue);
      expect(restored.note, 'Size M · Old Quarter');
      expect(restored.order, 2);
      expect(restored.boughtAt, item.boughtAt);
    });
  });

  group('ShoppingState', () {
    test('splits to-buy and bought lists', () {
      const toBuy = ShoppingItem(id: 'a', title: 'Coffee', order: 1);
      const bought = ShoppingItem(
        id: 'b',
        title: 'Hat',
        bought: true,
        note: 'Blue',
        order: 0,
      );
      const state = ShoppingState(items: [bought, toBuy], isLoading: false);
      expect(state.toBuy, [toBuy]);
      expect(state.bought, [bought]);
      expect(state.bought.first.note, 'Blue');
      expect(state.nextToBuyOrder, 2);
    });

    test('sorts bought items newest first', () {
      final older = ShoppingItem(
        id: 'old',
        title: 'Older',
        bought: true,
        boughtAt: DateTime.utc(2026, 9, 20),
      );
      final newer = ShoppingItem(
        id: 'new',
        title: 'Newer',
        bought: true,
        boughtAt: DateTime.utc(2026, 9, 22),
      );
      final state = ShoppingState(items: [older, newer], isLoading: false);
      expect(state.bought.map((e) => e.id).toList(), ['new', 'old']);
    });
  });

  group('capitalizeFirstWord', () {
    test('capitalizes the first letter of the first word', () {
      expect(capitalizeFirstWord('coffee beans'), 'Coffee beans');
      expect(capitalizeFirstWord('  nón lá'), '  Nón lá');
      expect(capitalizeFirstWord('Already'), 'Already');
      expect(capitalizeFirstWord(''), '');
    });
  });

  group('shoppingListSummary', () {
    test('keeps the description when the list is empty', () {
      expect(shoppingListSummary(const []), shoppingListEmptySummary);
    });

    test('shows bought over total and remaining after items exist', () {
      expect(
        shoppingListSummary(const [
          ShoppingItem(id: '1', title: 'Hat', bought: true),
          ShoppingItem(id: '2', title: 'Coffee'),
          ShoppingItem(id: '3', title: 'Magnet'),
        ]),
        '1/3 bought · 2 remaining',
      );
    });
  });
}
