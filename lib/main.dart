import 'package:flutter/material.dart';
import 'package:hellclientui/views/pages/qapage.dart';
import 'states/appstate.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'views/pages/homepage.dart';
import 'views/pages/createpage.dart';
import 'views/pages/updatepage.dart';
import 'views/pages/game.dart';
import 'views/pages/displaysettings.dart';
import 'workers/notification.dart';
import 'views/pages/notificationpage.dart';
import 'package:local_notifier/local_notifier.dart';
import 'dart:io';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  currentAppState = await AppState.init();
  currentNotification.updateConfig(currentAppState.config.notificationConfig);
  if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
    await localNotifier.setup(
      appName: 'hellcientui',
      // The parameter shortcutPolicy only works on Windows
      shortcutPolicy: ShortcutPolicy.requireCreate,
    );
  }
  runApp(MyApp(state: currentAppState));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key, required this.state});
  final AppState state;
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    final navigatorKey = GlobalKey<NavigatorState>();

    return ChangeNotifierProvider(
      create: (context) => state,
      child: MaterialApp(
          title: 'Hellclient',
          navigatorKey: navigatorKey,
          theme: ThemeData(
            // This is the theme of your application.
            //
            // TRY THIS: Try running your application with "flutter run". You'll see
            // the application has a blue toolbar. Then, without quitting the app,
            // try changing the seedColor in the colorScheme below to Colors.green
            // and then invoke "hot reload" (save your changes or press the "hot
            // reload" button in a Flutter-supported IDE, or press "r" if you used
            // the command line to start the app).
            //
            // Notice that the counter didn't reset back to zero; the application
            // state is not lost during the reload. To reset the state, use hot
            // restart instead.
            //
            // This works for code too, not just values: Most code changes can be
            // tested with just a hot reload.
            colorScheme:
                ColorScheme.fromSeed(seedColor: const Color(0xff409EFF)),
            useMaterial3: true,
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
          ],
          supportedLocales: const [Locale("zh", "CN")],
          locale: const Locale("zh", "CN"),
          initialRoute: "/",
          routes: {
            "/": (context) => const HomePage(),
            "/create": (context) => CreatePage(),
            "/update": (context) => UpdatePage(),
            "/game": (context) => const Game(),
            "/notification": (context) => const NotificationPage(),
            "/displaysettings": (context) => const DisplaySettings(),
            "/qa": (context) => const QAPage(),
          }),
    );
  }
}
