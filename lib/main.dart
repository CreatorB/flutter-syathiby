import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:syathiby/core/services/shared_preferences_service.dart';
import 'package:syathiby/core/utils/bloc/custom_multi_bloc_provider.dart';
import 'package:syathiby/core/utils/localization/localization_manager.dart';
import 'package:syathiby/core/utils/logger_util.dart';
import 'package:syathiby/core/utils/router/router_manager.dart';
import 'package:syathiby/features/theme/bloc/theme_bloc.dart';
import 'package:syathiby/features/theme/bloc/theme_state.dart';
import 'package:syathiby/common/helpers/ui_helper.dart';
import 'package:syathiby/core/services/theme_service.dart';
import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  LoggerUtil.init(
    Logger(
      printer: PrettyPrinter(
          methodCount: 0,
          errorMethodCount: 8,
          lineLength: 120,
          colors: true,
          printEmojis: true,
          dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart),
      level: kReleaseMode ? Level.error : Level.debug,
    ),
  );

  try {
    LoggerUtil.debug('Initializing application...');

    await dotenv.load();
    await SharedPreferencesService.instance.init();
    WidgetsFlutterBinding.ensureInitialized();
    await EasyLocalization.ensureInitialized();
    ThemeService.getTheme();
    // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    LoggerUtil.info('Application initialized successfully');

    runApp(
      CustomMultiBlocProvider(
        child: LocalizationManager(
          child: const MyApp(),
        ),
      ),
    );
  } catch (e, stackTrace) {
    LoggerUtil.error('Failed to initialize application', e, stackTrace);
    rethrow;
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    ThemeService.initialize(context);
    super.initState();
  }

  @override
  Future<void> didChangeDependencies() async {
    ThemeService.autoChangeTheme(context);
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    UIHelper.initialize(context);
    return BlocBuilder<ThemeBloc, ThemeState>(builder: (context, themeState) {
      return CupertinoApp.router(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        title: 'Syathiby',
        theme: ThemeService.buildTheme(themeState),
        debugShowCheckedModeBanner: false,
        routerConfig: RouterManager.router,
      );
    });
  }
}
