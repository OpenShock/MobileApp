import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_shock/screens/SignInScreen.dart';

import 'package:url_launcher/url_launcher.dart';

class InitalSignScreen extends StatefulWidget {
  @override
  InitalSignScreenState createState() => InitalSignScreenState();
}

class InitalSignScreenState extends State<InitalSignScreen> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    setStatusBarColor(Colors.transparent);
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String assetName = 'images/logos/Icon.svg';
    final Widget svg = SvgPicture.asset(
      assetName,
    );

    return Scaffold(
      body: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: context.width(),
                height: context.height(),
                color: Color(0x18141c),
              ),
              Column(
                children: [
                  svg,
                  SizedBox(height: 25),
                  Text('A truly Shocking experience.',
                      style: boldTextStyle(color: white, size: 30),
                      textAlign: TextAlign.center),
                  16.height,
                  Text(
                      'OpenShock is an open-source platform designed to control various shocking devices over the internet, catering to all your masochistic needs! ',
                      style: primaryTextStyle(color: white),
                      textAlign: TextAlign.center),
                  16.height,
                  AppButton(
                      textColor: white,
                      color: Color(0xe14a6d),
                      width: context.width(),
                      text: 'Get Started',
                      onTap: () {
                        launchUrl(Uri.parse(
                            'https://openshock.app/#/account/signup'));
                      }),
                  16.height,
                  AppButton(
                    color: context.cardColor,
                    text: 'Sign In',
                    textStyle: boldTextStyle(),
                    width: context.width(),
                    shapeBorder: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16)),
                    onTap: () {
                      finish(context);
                      SignInScreen().launch(context);
                    },
                  ),
                ],
              ).paddingSymmetric(vertical: 16, horizontal: 16)
            ],
          ),
        ],
      ),
    );
  }
}
