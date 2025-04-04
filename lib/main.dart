import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce/hive.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:path_provider/path_provider.dart';
import 'package:the_umpteenth_logger/the_umpteenth_logger.dart';

import 'data/data.dart';
import 'features/features.dart';
import 'theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = _AppBlocObserver();
  EquatableConfig.stringify = false;
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: kIsWeb
        ? HydratedStorageDirectory.web
        : HydratedStorageDirectory((await getTemporaryDirectory()).path),
  );
  FlutterError.onError = (details) {
    const NthLogger('FlutterError.onError')
        .e(details.exceptionAsString(), details.stack);
  };

  Hive.init(await getApplicationDocumentsDirectory().then((dir) => dir.path));

  // Add cross-flavor configuration here
  NthLogger.disableAllPrinters();
  NthLogger.enablePrinter(
    DevLogPrinter(
      minLevel: LoggerLevel.all,
      formatter: const Formatter(
        useColors: true,
        colorEachLine: true,
        includeClassReference: true,
      ),
    ),
  );

  GetIt.I
    ..registerSingleton(ServiceRepository())
    ..registerSingleton(SettingsRepository());

  // Settings must be loaded before the service repository
  await SettingsRepository.I.load();
  await ServiceRepository.I.load();
  runApp(
    MaterialApp(
      theme: kThemeInitial,
      builder: (context, child) => ThemeWrapper(child: child!),
      home: const MainApp(),
    ),
  );
}

class _AppBlocObserver extends BlocObserver with LoggerMixin {
  _AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    logger.v('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    logger.v('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  int _currentIndex = 0;
  final _screens = [
    (
      title: 'Home',
      widget: const HomepageScreen(),
      icon: Icons.home,
    ),
    (
      title: 'Stats',
      widget: const StatsViewerScreen(),
      icon: Icons.bar_chart,
    ),
    (
      title: 'Settings',
      widget: const SettingsScreen(),
      icon: Icons.settings,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: _screens[_currentIndex].widget,
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          items: _screens
              .map(
                (screen) => BottomNavigationBarItem(
                  icon: Icon(screen.icon),
                  label: screen.title,
                ),
              )
              .toList(),
        ),
      ),
    );
  }
}
