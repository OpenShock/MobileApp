import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_shock/utils/AppColors.dart';

// ignore: must_be_immutable
class CreatePairFragment extends StatefulWidget {
  static String tag = '/CreatePairFragment';
  List<Color> availableColors = [
    purple,
    yellow,
    mediumSlateBlue,
    orange,
    orchid,
    violet,
  ];

  @override
  CreatePairFragmentState createState() => CreatePairFragmentState();
}

class CreatePairFragmentState extends State<CreatePairFragment> {
  List<Color> graphContainerColor = [
    Color(0xFF3B3340),
    Color(0xFF3C3441),
    Color(0xFF29313E),
    Color(0xFF2B354E)
  ];
  final Color barBackgroundColor = AppScaffoldDarkColor;
  final Duration animDuration = Duration(milliseconds: 250);

  int touchedIndex = -1;

  bool isPlaying = false;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future<void> init() async {}

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppScaffoldDarkColor,
      appBar: AppBar(
        title: Text("Pair a hub", style: boldTextStyle(color: white)),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: AppScaffoldDarkColor,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            50.height,
            Center(
                child: Text("Not yet supported.\nPlease add a hub via the site",
                    style: boldTextStyle(size: 22, color: redColor),
                    textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }

  Future<dynamic> refreshState() async {
    setState(() {});
    await Future<dynamic>.delayed(animDuration + Duration(milliseconds: 50));
    if (isPlaying) {
      await refreshState();
    }
  }
}
