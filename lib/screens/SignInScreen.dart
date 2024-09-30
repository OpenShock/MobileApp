import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_shock/main.dart';
import 'package:open_shock/screens/DashboardScreen.dart';
import 'package:open_shock/utils/OpenShockAPI.dart';
import 'package:open_shock/utils/AppColors.dart';
import 'package:open_shock/utils/AppComman.dart';
import 'package:url_launcher/url_launcher.dart';

class SignInScreen extends StatefulWidget {
  @override
  SignInScreenState createState() => SignInScreenState();
}

class SignInScreenState extends State<SignInScreen> {
  TextEditingController apiKeyController = TextEditingController();
  TextEditingController apiHostController = TextEditingController();

  @override
  void initState() {
    super.initState();
    init();
    apiHostController.text = "https://api.openshock.app";
  }

  void init() async {
    setStatusBarColor(Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.dark);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  Future<bool> checkAPIToken() async {
    Openshockapi api =
        new Openshockapi(apiHostController.text, apiKeyController.text);

    bool loggedIn = await api.validateKey();

    if (loggedIn) {
      final storage = new FlutterSecureStorage();
      await storage.write(key: "api_token", value: apiKeyController.text);
      await storage.write(key: "api_host", value: apiHostController.text);
      clientApi = api;
      user = await api.getSelfUser();
    }

    return Future.value(loggedIn);
  }

  @override
  void dispose() {
    apiKeyController.dispose();
    apiHostController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Stack(
          children: [
            commonAppCachedNetworkImage(
              'https://openshock.app/assets/img/background6.9bda1a83..jpg',
              fit: BoxFit.cover,
              height: context.height(),
              width: context.width(),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                  color: AppScaffoldDarkColor,
                ),
                padding: EdgeInsets.symmetric(vertical: 32, horizontal: 16),
                width: context.width(),
                height: context.height() * 0.7,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Welcome back',
                          style: boldTextStyle(color: white, size: 25)),
                      16.height,
                      AppTextField(
                        textStyle: primaryTextStyle(color: white),
                        cursorColor: white,
                        textFieldType: TextFieldType.URL,
                        controller: apiHostController,
                        decoration: buildSHInputDecoration('OpenShock Server',
                            textColor: Colors.grey),
                      ),
                      16.height,
                      AppTextField(
                        textStyle: primaryTextStyle(color: white),
                        cursorColor: white,
                        textFieldType: TextFieldType.PASSWORD,
                        suffixIconColor: white,
                        controller: apiKeyController,
                        suffix:
                            Icon(Icons.remove_red_eye_rounded, color: white),
                        decoration: buildSHInputDecoration('API Key',
                            textColor: Colors.grey),
                      ),
                      16.height,
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text('Create API Key',
                                style: boldTextStyle(color: white),
                                textAlign: TextAlign.end)
                            .onTap(
                          () {
                            launchUrl(Uri.parse(
                                'https://next.openshock.app/settings/api-tokens'));
                          },
                        ),
                      ),
                      80.height,
                      button(
                        context: context,
                        textColor: white,
                        width: context.width(),
                        text: 'Sign In',
                        onTap: () async {
                          bool success = await checkAPIToken();
                          if (success) {
                            DashboardScreen().launch(context);
                          } else {
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                title: Text('Login Failed'),
                                content: Text(
                                  'Invalid API Key or Host',
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      32.height,
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Don\'t have account?',
                              style: primaryTextStyle(color: grey)),
                          4.width,
                          Text('Get Started',
                                  style: boldTextStyle(color: white, size: 16))
                              .onTap(
                            () {
                              launchUrl(Uri.parse(
                                  'https://openshock.app/#/account/signup'));
                            },
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
