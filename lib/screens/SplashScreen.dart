import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:open_shock/main.dart';
import 'package:open_shock/screens/DashboardScreen.dart';

import '../utils/OpenShockAPI.dart';
import 'InitalSignScreen.dart';

class SplashScreen extends StatefulWidget {
  static String tag = '/SplashScreen';

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(
      Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    );

    // Create storage
    final storage = new FlutterSecureStorage();

    // Read value
    bool hasToken = await storage.containsKey(key: "api_token");

    if (!hasToken) {
      await Future.delayed(Duration(seconds: 3));
      goToLogin();
    } else {
      String? host = await storage.read(key: "api_host");
      String? key = await storage.read(key: "api_token");

      Openshockapi api = new Openshockapi(host!, key!);

      bool loggedIn = await api.validateKey();

      if (loggedIn) {
        clientApi = api;
        user = await api.getSelfUser();
        goToMenu();
      } else {
        await storage.deleteAll();
        goToLogin();
      }
    }
  }

  void goToLogin() {
    finish(context);
    InitalSignScreen().launch(context);
  }

  void goToMenu() {
    finish(context);
    DashboardScreen().launch(context);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    final String assetName = 'images/logos/IconLoadingSpin.svg';
    final Widget svg = SvgPicture.asset(
      assetName,
    );

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Color(0x1b1d1e),
        ),
        child: Center(child: svg),
      ),
    );
  }
}
