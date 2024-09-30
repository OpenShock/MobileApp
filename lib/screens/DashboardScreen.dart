import 'package:flutter/material.dart';
import 'package:flutter_vector_icons/flutter_vector_icons.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_shock/component/BottomNavbarWidget.dart';
import 'package:open_shock/fragments/CreatePairFragment.dart';
import 'package:open_shock/fragments/HomeFragment.dart';
import 'package:open_shock/fragments/SharedUsersFragment.dart';
import 'package:open_shock/utils/AppColors.dart';

class DashboardScreen extends StatefulWidget {
  static String tag = '/DashboardScreen';

  @override
  DashboardScreenState createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  List<Widget> dashBoardScreenList = [
    HomeFragment(),
    SharedUsersFragment(),
    CreatePairFragment(),
  ];

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {
    setStatusBarColor(
      AppContainerColor,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.light,
    );
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppScaffoldDarkColor,
      body: dashBoardScreenList[_currentIndex],
      bottomNavigationBar: BottomNavbarWidget(
        selectedIndex: _currentIndex,
        showElevation: true,
        curve: Curves.easeIn,
        backgroundColor: AppScaffoldDarkColor,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
        },
        items: [
          BottomNavyBarItem(
              icon: Icon(FontAwesome.home),
              title: Text('Home',
                  style: boldTextStyle(color: Colors.white, size: 14))),
          BottomNavyBarItem(
              icon: Icon(Icons.cloud),
              title: Text('Shared',
                  style: boldTextStyle(color: Colors.white, size: 14))),
          BottomNavyBarItem(
              icon: Icon(Icons.add_box_rounded),
              title: Text('Add New',
                  style: boldTextStyle(color: Colors.white, size: 14))),
        ],
      ).paddingTop(12),
    );
  }
}
