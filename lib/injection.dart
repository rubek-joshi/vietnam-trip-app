import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:vietnam_handbook/features/budget/data/repositories/budget_repository_impl.dart';
import 'package:vietnam_handbook/features/budget/domain/repositories/budget_repository.dart';
import 'package:vietnam_handbook/features/budget/presentation/cubit/budget_cubit.dart';
import 'package:vietnam_handbook/features/checklist/data/repositories/checklist_repository_impl.dart';
import 'package:vietnam_handbook/features/checklist/domain/repositories/checklist_repository.dart';
import 'package:vietnam_handbook/features/checklist/presentation/cubit/checklist_cubit.dart';
import 'package:vietnam_handbook/features/converter/data/repositories/conversion_history_repository_impl.dart';
import 'package:vietnam_handbook/features/converter/data/repositories/fx_rates_repository_impl.dart';
import 'package:vietnam_handbook/features/converter/domain/repositories/conversion_history_repository.dart';
import 'package:vietnam_handbook/features/converter/domain/repositories/fx_rates_repository.dart';
import 'package:vietnam_handbook/features/converter/domain/usecases/convert_currency.dart';
import 'package:vietnam_handbook/features/converter/presentation/cubit/converter_cubit.dart';
import 'package:vietnam_handbook/features/itinerary/data/repositories/tipping_rates_repository_impl.dart';
import 'package:vietnam_handbook/features/itinerary/domain/repositories/tipping_rates_repository.dart';
import 'package:vietnam_handbook/features/itinerary/presentation/cubit/tipping_cubit.dart';
import 'package:vietnam_handbook/features/phrases/presentation/cubit/phrases_cubit.dart';
import 'package:vietnam_handbook/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:vietnam_handbook/features/settings/domain/repositories/settings_repository.dart';
import 'package:vietnam_handbook/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:vietnam_handbook/features/shopping/data/repositories/shopping_repository_impl.dart';
import 'package:vietnam_handbook/features/shopping/domain/repositories/shopping_repository.dart';
import 'package:vietnam_handbook/features/shopping/presentation/cubit/shopping_cubit.dart';

final getIt = GetIt.instance;

Future<void> initDependencies() async {
  await Hive.initFlutter();

  final fxBox = await openFxRatesBox();
  final historyBox = await openSavedConversionsBox();
  final checklistBox = await openChecklistBox();
  final budgetBoxes = await openBudgetBoxes();
  final settingsBox = await openSettingsBox();
  final tippingRatesBox = await openTippingRatesBox();
  final shoppingBox = await openShoppingBox();

  getIt
    ..registerLazySingleton<FxRatesRepository>(
      () => FxRatesRepositoryImpl(fxBox),
    )
    ..registerLazySingleton<SettingsRepository>(
      () => SettingsRepositoryImpl(settingsBox),
    )
    ..registerLazySingleton(() => SettingsCubit(getIt()))
    ..registerLazySingleton<ConversionHistoryRepository>(
      () => ConversionHistoryRepositoryImpl(historyBox),
    )
    ..registerLazySingleton<ChecklistRepository>(
      () => ChecklistRepositoryImpl(checklistBox),
    )
    ..registerLazySingleton<BudgetRepository>(
      () => BudgetRepositoryImpl(
        configBox: budgetBoxes.$1,
        exchangesBox: budgetBoxes.$2,
        expensesBox: budgetBoxes.$3,
      ),
    )
    ..registerLazySingleton(() => ConvertCurrency())
    ..registerFactory(
      () => ConverterCubit(
        fxRatesRepository: getIt(),
        historyRepository: getIt(),
        convertCurrency: getIt(),
      ),
    )
    ..registerFactory(() => ChecklistCubit(getIt()))
    ..registerLazySingleton<TippingRatesRepository>(
      () => TippingRatesRepositoryImpl(tippingRatesBox),
    )
    ..registerLazySingleton<ShoppingRepository>(
      () => ShoppingRepositoryImpl(shoppingBox),
    )
    ..registerFactory(
      () => TippingCubit(
        fxRatesRepository: getIt(),
        tippingRatesRepository: getIt(),
      ),
    )
    ..registerFactory(() => ShoppingCubit(getIt()))
    ..registerFactory(
      () => BudgetCubit(budgetRepository: getIt(), fxRatesRepository: getIt()),
    )
    ..registerFactory(PhrasesCubit.new);

  await getIt<SettingsCubit>().load();
}
