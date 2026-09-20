import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:vietnam_handbook/features/settings/presentation/cubit/settings_cubit.dart';
import 'package:vietnam_handbook/injection.dart';

class VietnamHandbookApp extends StatelessWidget {
  const VietnamHandbookApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: getIt<SettingsCubit>(),
      child: BlocBuilder<SettingsCubit, SettingsState>(
        buildWhen: (previous, current) => previous.settings != current.settings,
        builder: (context, state) {
          return ShadApp.custom(
            themeMode: state.themeMode,
            theme: ShadThemeData(
              brightness: Brightness.light,
              colorScheme: ShadColorScheme.fromName(state.settings.colorScheme),
            ),
            darkTheme: ShadThemeData(
              brightness: Brightness.dark,
              colorScheme: ShadColorScheme.fromName(
                state.settings.colorScheme,
                brightness: Brightness.dark,
              ),
            ),
            appBuilder: (context) {
              return MaterialApp.router(
                title: 'Vietnam Handbook',
                debugShowCheckedModeBanner: false,
                theme: Theme.of(context),
                routerConfig: router,
                localizationsDelegates: const [
                  GlobalShadLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                ],
                builder: (context, child) {
                  return ShadAppBuilder(child: child!);
                },
              );
            },
          );
        },
      ),
    );
  }
}
