import 'package:core/util/routing/router.dart';
import 'package:core/util/theme/theme_util.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:kmpo_invent/domain/const.dart';
import 'package:kmpo_invent/domain/user.dart';
import 'package:kmpo_invent/screens/auth/landing_screen.dart';
import 'package:kmpo_invent/services/auth.dart';
import 'package:kmpo_invent/utils/adaptation_util.dart';
import 'package:kmpo_invent/widget/adaptation.dart';
import 'package:parse_server_sdk_flutter/parse_server_sdk_flutter.dart';
import 'package:provider/provider.dart';
import 'package:toastification/toastification.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
  await Parse().initialize(
    "application",
    "http://82.146.47.140:1339/parse/api/",
    clientKey: "jnjcM&kiQrMSfx#gLixq&#kCri4&3kYXLTJoABSC",
    debug: true,
    liveQueryUrl: "ws://82.146.47.140:1339/parse/api/",
    autoSendSessionId: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _service = AuthService();

  final _initialUser = ParseUser.currentUser();
  final _adaptation = TAdaptation.create();

  @override
  Widget build(BuildContext context) {
    return ToastificationWrapper(
      child: AdaptationUtil.buildScaled(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<TAdaptation>.value(
              value: _adaptation,
            ),
            ChangeNotifierProvider.value(
              value: _service,
            )
          ],
          child: _buildApp(),
        ),
      ),
    );
  }

  FutureBuilder<dynamic> _buildApp() {
    return FutureBuilder(
        future: _initialUser,
        builder: (context, value) {
          if (value.connectionState == ConnectionState.waiting) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          final defaultTheme = ThemeData(
              brightness: Brightness.light,
              fontFamily: "AlsHauss",
              useMaterial3: false);

          return StreamProvider<MyUser?>.value(
            initialData: value.data != null
                ? MyUser.fromParseUser(value.data as ParseUser)
                : null,
            value: _service.currentUser,
            child: GestureDetector(
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: MaterialApp(
                title: 'KMPOInvent',
                navigatorKey: SRRouter.mainNavigatorKey,
                locale: const Locale.fromSubtags(languageCode: "ru"),
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  DefaultMaterialLocalizations.delegate,
                  DefaultCupertinoLocalizations.delegate,
                  DefaultWidgetsLocalizations.delegate
                ],
                builder: (context, child) {
                  return GestureDetector(
                      child: child,
                      onTap: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                      });
                },
                home: LandingScreen(),
                theme: defaultTheme.copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: ThemeUtil.accent,
                      secondary: ThemeUtil.accent,
                    ),
                    appBarTheme: const AppBarTheme(
                      backgroundColor: ThemeUtil.accent,
                      titleTextStyle: TextStyle(
                        fontFamily: 'Oswald',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      centerTitle: true,
                    ),
                    elevatedButtonTheme: ElevatedButtonThemeData(
                      style: ElevatedButton.styleFrom(
                          elevation: 0,
                          padding: const EdgeInsets.all(20),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(45)),
                          textStyle: const TextStyle(
                              color: Const.white,
                              fontWeight: FontWeight.bold,
                              fontFamily: "AlsHauss",
                              fontSize: 18)),
                    ),
                    textButtonTheme: TextButtonThemeData(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.all(20),
                        textStyle: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    inputDecorationTheme: const InputDecorationTheme(
                      hintStyle: TextStyle(fontSize: 18, color: Colors.black26),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color:
                              ThemeUtil.accent, // Замените на нужный вам цвет
                          width: 2,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.black45, width: 1),
                      ),
                    )),
              ),
            ),
          );
        });
  }
}
