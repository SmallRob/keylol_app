import 'dart:async';

import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:hydrated_bloc/hydrated_bloc.dart';
import 'package:keylol_api/keylol_api.dart';
import 'package:keylol_flutter/bloc/authentication/authentication_bloc.dart';
import 'package:keylol_flutter/bloc/settings/settings_cubit.dart';
import 'package:keylol_flutter/l10n/app_localizations.dart';
import 'package:keylol_flutter/config/router.dart';
import 'package:keylol_flutter/repository/authentication_repository.dart';
import 'package:keylol_flutter/repository/database_service.dart';
import 'package:keylol_flutter/repository/favorite_repository.dart';
import 'package:keylol_flutter/repository/history_repository.dart';
import 'package:keylol_flutter/repository/settings_repository.dart';
import 'package:keylol_flutter/widgets/adaptive_dynamic_color_builder.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:talker_bloc_logger/talker_bloc_logger_observer.dart';
import 'package:talker_dio_logger/talker_dio_logger_interceptor.dart';
import 'package:talker_flutter/talker_flutter.dart';

final talker = TalkerFlutter.init();

/// 优化的主入口点
void main() async {
  runZonedGuarded(
    () async {
      // 1. 初始化 Flutter binding
      final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

      // 2. 保留启动屏幕，防止白屏
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      // 3. 并行执行初始化操作
      final results = await Future.wait([
        // 获取 SharedPreferences
        SharedPreferences.getInstance(),
        // 初始化数据库
        _initDatabase(),
        // 初始化 HydratedBloc 存储
        _initHydratedStorage(),
        // 创建 Keylol 客户端
        Keylol.create(),
      ]);

      final sharedPreferences = results[0] as SharedPreferences;
      final databaseService = results[1] as DatabaseService;
      final storageDirectory = results[2] as String;
      final client = results[3] as Keylol;

      // 4. 设置 Bloc observer
      Bloc.observer = TalkerBlocObserver(talker: talker);

      // 5. 配置客户端拦截器
      client.addInterceptor(DioCacheInterceptor(
        options: CacheOptions(
          store: MemCacheStore(),
          keyBuilder: CacheOptions.defaultCacheKeyBuilder,
        ),
      ));

      // 6. 移除启动屏幕（在显示 Flutter UI 后自动移除）
      FlutterNativeSplash.remove();

      // 7. 运行应用
      runApp(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: sharedPreferences),
            RepositoryProvider.value(value: databaseService),
          ],
          child: RepositoryProvider(
            create: (context) => AuthenticationRepository(),
            child: RepositoryProvider(
              create: (context) {
                // 配置认证拦截器
                client.addInterceptor(AuthenticationInterceptor(
                  context.read<AuthenticationRepository>(),
                ));
                // 配置日志拦截器
                client.addInterceptor(TalkerDioLogger(
                  talker: talker,
                ));
                return client;
              },
              child: MultiRepositoryProvider(
                providers: [
                  RepositoryProvider(
                    create: (context) =>
                        SettingsRepository(context.read<SharedPreferences>()),
                  ),
                  RepositoryProvider(
                    create: (context) => HistoryRepository(
                      context.read<DatabaseService>().instance,
                    ),
                  ),
                  RepositoryProvider(
                    create: (context) => FavoriteRepository(
                      context.read<SharedPreferences>(),
                      context.read<DatabaseService>().instance,
                      context.read<Keylol>(),
                    ),
                  ),
                ],
                child: const MyApp(),
              ),
            ),
          ),
        ),
      );
    },
    (error, stack) {
      talker.error('', error, stack);
    },
  );
}

/// 初始化数据库
Future<DatabaseService> _initDatabase() async {
  final databaseService = DatabaseService();
  await databaseService.init();
  return databaseService;
}

/// 初始化 HydratedBloc 存储
Future<String> _initHydratedStorage() async {
  final directory = await getTemporaryDirectory();
  HydratedBloc.storage = await HydratedStorage.build(
    storageDirectory: HydratedStorageDirectory(directory.path),
  );
  return directory.path;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, DateTime>(
      builder: (context, _) {
        return BlocBuilder<AuthenticationBloc, AuthenticationState>(
          builder: (context, state) {
            return AdaptiveDynamicColorBuilder(
              builder: (lightColorScheme, darkColorScheme) {
                return MaterialApp(
                  theme: ThemeData(
                    useMaterial3: true,
                    colorScheme: lightColorScheme,
                  ),
                  darkTheme: ThemeData(
                    useMaterial3: true,
                    colorScheme: darkColorScheme,
                  ),
                  localizationsDelegates:
                      AppLocalizations.localizationsDelegates,
                  supportedLocales: AppLocalizations.supportedLocales,
                  routes: routes,
                  navigatorObservers: [
                    TalkerRouteObserver(talker),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
