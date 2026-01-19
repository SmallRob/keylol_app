import 'dart:async';
import 'package:flutter/foundation.dart';
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
import 'package:dio/dio.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';

// 全局日志实例（后续移除 config/logger.dart 中的重复定义）
final talker = TalkerFlutter.init(
  settings: TalkerSettings(
    useConsoleLogs: true,
    useHistory: !kIsWeb, // Web 端减少历史记录以节省内存
  ),
);

void main() async {
  runZonedGuarded(
    () async {
      final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
      FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

      talker.info('>>> [App Start] 开始初始化流程 (kIsWeb: $kIsWeb)');

      // 1. 初始化存储 (Web 适配)
      SharedPreferences? sharedPreferences;
      try {
        sharedPreferences = await SharedPreferences.getInstance();
        talker.info('SharedPreferences 初始化成功');
      } catch (e) {
        talker.error('SharedPreferences 初始化失败', e);
      }

      // 2. 初始化 HydratedStorage (Web 安全版)
      try {
        talker.info('正在初始化 HydratedStorage...');
        if (kIsWeb) {
          // Web 端使用内存存储或专门的 web 目录，坚决不触发 path_provider
          HydratedBloc.storage = await HydratedStorage.build(
            storageDirectory: HydratedStorageDirectory.web,
          );
        } else {
          final directory = await getTemporaryDirectory();
          HydratedBloc.storage = await HydratedStorage.build(
            storageDirectory: HydratedStorageDirectory(directory.path),
          );
        }
        talker.info('HydratedStorage 完成');
      } catch (e) {
        talker.error('HydratedStorage 失败 (已跳过)', e);
      }

      // 3. 初始化数据库 (仅原生或适配后的 Web)
      final databaseService = DatabaseService();
      try {
        talker.info('开始数据库初始化...');
        await databaseService.init();
        talker.info('数据库初始化任务结束');
      } catch (e) {
        talker.error('数据库任务异常 (已忽略)', e);
      }

      // 4. 初始化 Keylol 客户端 (Web 安全版)
      Keylol? client;
      try {
        talker.info('开始创建 Keylol 客户端...');
        if (kIsWeb) {
          final dio = Dio(BaseOptions(
            baseUrl: 'https://keylol.com',
            queryParameters: {'version': 4},
          ));
          final cj = CookieJar(); // Web 端使用内存 cookie
          dio.interceptors.add(CookieManager(cj));
          client = Keylol(dio, cj);
        } else {
          client = await Keylol.create();
        }
        talker.info('Keylol 客户端就绪');
      } catch (e) {
        talker.error('Keylol 客户端生成失败!', e);
        // 如果 client 为空，后续会导致崩溃，所以这里需要一个兜底
        if (client == null) {
          final dio = Dio(BaseOptions(baseUrl: 'https://keylol.com'));
          client = Keylol(dio, CookieJar());
        }
      }

      // 5. 配置拦截器
      final authenticationRepository = AuthenticationRepository();
      client!.addInterceptor(DioCacheInterceptor(
        options: CacheOptions(
          store: MemCacheStore(),
          keyBuilder: CacheOptions.defaultCacheKeyBuilder,
        ),
      ));
      client.addInterceptor(AuthenticationInterceptor(authenticationRepository));
      client.addInterceptor(TalkerDioLogger(talker: talker));

      // 6. 配置全局观察者
      Bloc.observer = TalkerBlocObserver(talker: talker);

      talker.info('>>> [RunApp] 准备启动 Widget 树');
      
      runApp(
        MultiRepositoryProvider(
          providers: [
            RepositoryProvider.value(value: sharedPreferences!),
            RepositoryProvider.value(value: databaseService),
            RepositoryProvider.value(value: client),
            RepositoryProvider.value(value: authenticationRepository),
          ],
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
            child: MultiBlocProvider(
              providers: [
                BlocProvider(
                  create: (context) => AuthenticationBloc(
                    context.read<Keylol>(),
                    context.read<AuthenticationRepository>(),
                  ),
                ),
                BlocProvider(
                  create: (context) =>
                      SettingsCubit(context.read<SettingsRepository>()),
                ),
              ],
              child: const MyApp(),
            ),
          ),
        ),
      );

      // 7. 延迟移除启动屏
      Future.delayed(const Duration(milliseconds: 200), () {
        try {
          FlutterNativeSplash.remove();
        } catch (_) {}
      });
    },
    (error, stack) {
      talker.error('Fatal crash inside zone!', error, stack);
    },
  );
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
                  debugShowCheckedModeBanner: false,
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
