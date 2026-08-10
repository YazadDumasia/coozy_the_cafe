import 'dart:ui';

import 'package:coozy_the_cafe/packages/core/coozy_core.dart' as core;
import 'package:coozy_the_cafe/packages/shared/coozy_shared.dart' as shared;
import 'package:coozy_the_cafe/injection.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await shared.LocalManager.preferencesInit();
  await initDI();
  core.NotificationApi.onNotification.stream.listen((payload) async {
    if (payload != null) {
      switch (payload) {
        case 'run_backup':
          // await DatabaseHelper.instance.backupDatabase();

          break;
        // case '':
        //   break;
        default:
          // Constants.debugLog(
          //   MyApp,
          //   'Notification clicked with payload: $payload',
          // );
          break;
      }
    } else {
      // Constants.debugLog(MyApp, 'Notification clicked with payload: $payload');
    }
  });
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) =>
              shared.ThemeBloc()..add(shared.ThemeLoadRequested()),
        ),
        BlocProvider(create: (context) => shared.LocaleCubit()),
      ],
      child: BlocBuilder<shared.ThemeBloc, shared.ThemeState>(
        builder: (context, themeState) {
          return BlocBuilder<shared.LocaleCubit, Locale>(
            builder: (context, locale) {
              // Create the text theme using the custom font family
              final textTheme = shared.createTextTheme(
                context,
                shared.FontFamily.bwAletaNo10,
                shared.FontFamily.bwAletaNo10,
              );

              final theme = shared.MaterialTheme(textTheme);

              return MaterialApp.router(
                title: 'Coozy the Cafe',
                debugShowCheckedModeBanner: false,
                themeMode: themeState.themeMode,
                theme: theme.light(),
                darkTheme: theme.dark(),
                routerConfig: core.AppRouter.router,
                highContrastDarkTheme: theme.darkHighContrast(),
                highContrastTheme: theme.lightHighContrast(),
                themeAnimationCurve: Curves.linear,
                themeAnimationDuration: const Duration(milliseconds: 700),
                locale: locale,
                builder: (context, child) {
                  return PageStorage(
                    bucket: shared.bucketGlobal,
                    child: Theme(
                      data: Theme.of(context).copyWith(
                        extensions: [
                          shared.AppThemeExtension(
                            inkWellRadius: BorderRadius.circular(0.0),
                          ),
                        ],
                        elevatedButtonTheme: ElevatedButtonThemeData(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),
                        outlinedButtonTheme: OutlinedButtonThemeData(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                          ),
                        ),

                        textButtonTheme: TextButtonThemeData(
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                              vertical: 10.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            visualDensity:
                                VisualDensity.adaptivePlatformDensity,
                          ),
                        ),
                        floatingActionButtonTheme:
                            FloatingActionButtonThemeData(
                              iconSize: 25,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                            ),
                        inputDecorationTheme: InputDecorationTheme(
                          contentPadding: const EdgeInsets.only(
                            left: 10,
                            right: 10,
                            bottom: 5,
                            top: 5,
                          ),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).disabledColor,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Theme.of(context).colorScheme.error,
                            ),
                            borderRadius: BorderRadius.circular(5),
                          ),
                        ),
                        cardTheme: Theme.of(context).cardTheme.copyWith(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        dropdownMenuTheme: Theme.of(context).dropdownMenuTheme
                            .copyWith(
                              inputDecorationTheme: Theme.of(
                                context,
                              ).inputDecorationTheme,
                            ),

                        navigationRailTheme: NavigationRailThemeData(
                          useIndicator: true,
                          indicatorShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          elevation: 5.0,
                        ),
                        bottomNavigationBarTheme:
                            const BottomNavigationBarThemeData(
                              type: BottomNavigationBarType.fixed,
                              showSelectedLabels: true,
                              showUnselectedLabels: true,
                            ),
                      ),
                      child: child!,
                    ),
                  );
                },
                restorationScopeId: 'app',

                scrollBehavior: ScrollConfiguration.of(context).copyWith(
                  multitouchDragStrategy: MultitouchDragStrategy.sumAllPointers,
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  dragDevices: <PointerDeviceKind>{
                    PointerDeviceKind.mouse,
                    PointerDeviceKind.touch,
                    PointerDeviceKind.trackpad,
                    PointerDeviceKind.stylus,
                  },
                ),
                localeResolutionCallback: (locale, supportedLocales) {
                  return locale;
                },
                localizationsDelegates: [
                  shared.AppLocalizationsDelegate(
                    shared.LanguageModel.getLanguages(),
                  ),
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                supportedLocales: shared.LanguageModel.getLanguages().map((e) {
                  return e.countryCode == null
                      ? Locale(e.code!)
                      : Locale(e.code!, e.countryCode);
                }).toList(),
              );
            },
          );
        },
      ),
    );
  }
}
