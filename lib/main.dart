import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_shock/model/shockobjs/SelfUser.dart';
import 'package:open_shock/screens/SplashScreen.dart';
import 'package:open_shock/store/AppStore.dart';
import 'package:open_shock/utils/AppTheme.dart';
import 'package:open_shock/utils/OpenShockAPI.dart';

AppStore appStore = AppStore();
late Openshockapi clientApi; // Declare your global API client object

late SelfUser user; // Declare global user objec
final appVersion = '1.0.3';

final storage = new FlutterSecureStorage();
const isDarkModeOnPref = 'isDarkModeOnPref';

void preformLogout(BuildContext context) async {
  await storage.deleteAll();
  finish(context);
  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initialize(aLocaleLanguageList: [
    LanguageDataModel(
        id: 1, name: 'English', languageCode: 'en', fullLanguageCode: 'en-US')
  ]);

  appStore.toggleDarkMode(value: getBoolAsync(isDarkModeOnPref));

  defaultRadius = 10;
  defaultToastGravityGlobal = ToastGravity.BOTTOM;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Observer(
      builder: (_) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'OpenShock ${!isMobile ? ' ${platformName()}' : ''}',
        home: SplashScreen(),
        theme: !appStore.isDarkModeOn
            ? AppThemeData.lightTheme
            : AppThemeData.darkTheme,
        navigatorKey: navigatorKey,
        scrollBehavior: SBehavior(),
        themeAnimationDuration: Duration(milliseconds: 150),
        supportedLocales: LanguageDataModel.languageLocales(),
        localeResolutionCallback: (locale, supportedLocales) => locale,
      ),
    );
  }
}
