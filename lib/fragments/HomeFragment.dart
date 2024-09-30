// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_shock/main.dart';
import 'package:open_shock/screens/SettingScreen.dart';
import 'package:open_shock/utils/AppColors.dart';

import '../component/OwnHubListComponent.dart';

class HomeFragment extends StatefulWidget {
  static String tag = '/HomeFragment';
  String? title;

  HomeFragment({this.title});

  @override
  HomeFragmentState createState() => HomeFragmentState();
}

class HomeFragmentState extends State<HomeFragment> {
  int sceneIndex = 0;

  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(AppContainerColor);
    //
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppContainerColor,
        body: SingleChildScrollView(
          physics: NeverScrollableScrollPhysics(),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Welcome " + user.name,
                    style: boldTextStyle(color: white, size: 24),
                  ).paddingOnly(left: 16),
                  Align(
                    alignment: Alignment.topRight,
                    child: Image.network(
                      user.image,
                      fit: BoxFit.cover,
                      height: 70,
                      width: 70,
                    ).cornerRadiusWithClipRRectOnly(bottomLeft: 20).onTap(
                      () {
                        SettingScreen().launch(context,
                            pageRouteAnimation: PageRouteAnimation.Scale);
                      },
                    ),
                  ),
                ],
              ),
              16.height,
              Container(
                  width: context.width(),
                  height: context.height(),
                  decoration: BoxDecoration(
                    color: AppScaffoldDarkColor,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: OwnHubListComponent()),
            ],
          ),
        ),
      ),
    );
  }
}
