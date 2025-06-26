import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'themes/app_theme.dart';
import 'screens/modern_home_screen.dart';
import 'services/app_service_manager.dart';
import 'providers/language_provider.dart';
import 'l10n/app_localizations.dart';
import 'core/plugins/plugin_manager.dart';
import 'core/discovery/content_discovery_service.dart';
import 'core/downloads/download_manager.dart';
import 'core/subtitles/subtitle_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize the service manager
  await AppServiceManager().initialize();
  
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF121212),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => AppServiceManager()),
        ChangeNotifierProxyProvider<AppServiceManager, PluginManager>(
          create: (_) => PluginManager(),
          update: (_, serviceManager, pluginManager) => serviceManager.pluginManager,
        ),
        ChangeNotifierProxyProvider<AppServiceManager, ContentDiscoveryService>(
          create: (_) => ContentDiscoveryService(),
          update: (_, serviceManager, contentDiscovery) => serviceManager.contentDiscoveryService,
        ),
        ChangeNotifierProxyProvider<AppServiceManager, DownloadManager>(
          create: (_) => DownloadManager(),
          update: (_, serviceManager, downloadManager) => serviceManager.downloadManager,
        ),
        ChangeNotifierProxyProvider<AppServiceManager, SubtitleService>(
          create: (_) => SubtitleService(),
          update: (_, serviceManager, subtitleService) => serviceManager.subtitleService,
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LanguageProvider>(
      builder: (context, languageProvider, child) {
        return MaterialApp(
          title: 'Streamy',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          locale: languageProvider.locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LanguageProvider.supportedLocales,
          home: const HomeScreen(),
        );
      },
    );
  }
}
