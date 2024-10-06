import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_shock/utils/AppColors.dart';
import 'dart:io'; // For ping functionality

// ignore: must_be_immutable
class CreatePairFragment extends StatefulWidget {
  static String tag = '/CreatePairFragment';

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
  TextEditingController hubNameController = TextEditingController();
  bool isHubNameEntered = false;
  bool isTextFieldEnabled = true;
  bool showWiFiInstructions = false;
  String buttonText = "Continue";
  bool isLoading = false;
  String pairCode = "";
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

  Future<String> createHubGetPairCode() async {
    await Future.delayed(Duration(seconds: 2)); // Simulate API call
    return Future.value('C0DE-HERE');
  }

  Widget getTextOrLoading() {
    if (isLoading) {
      return CircularProgressIndicator(
        color: Colors.white,
        strokeWidth: 3,
      );
    } else {
      return Text(buttonText, style: boldTextStyle(color: white));
    }
  }

  checkHubBtnPressed() async {
    //Check if the Hub IP is open on port 80.
    bool success = await checkForHubConnection();
    if (success) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content: Text('OpenShock Hub found and connected.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Cannot connect to OpenShock Hub.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }
  }

  Future<bool> checkForHubConnection() async {
    try {
      await Socket.connect('10.10.10.10', 80, timeout: Duration(seconds: 2));
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              20.height,
              Center(
                child: Text(
                  "Please have your OpenShock hub turned on, you should see a WiFi for this within your settings.",
                  textAlign: TextAlign.center,
                  style: primaryTextStyle(color: white),
                ),
              ),
              30.height,
              TextField(
                controller: hubNameController,
                style: primaryTextStyle(color: white),
                enabled: isTextFieldEnabled,
                decoration: InputDecoration(
                  labelText: "Enter new hub name",
                  labelStyle: primaryTextStyle(color: Colors.grey),
                  border: OutlineInputBorder(),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: white),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                ),
              ),
              30.height,
              showWiFiInstructions
                  ? Text(
                      "Please connect to the OpenShock WiFi network now.",
                      textAlign: TextAlign.center,
                      style: primaryTextStyle(color: white),
                    )
                  : Container(),
              (pairCode != "")
                  ? Column(children: [
                      10.height,
                      Text(
                        "Pair code",
                        textAlign: TextAlign.center,
                        style: primaryTextStyle(color: white),
                      ),
                      Text(
                        pairCode,
                        textAlign: TextAlign.center,
                        style:
                            primaryTextStyle(color: SHOCKPrimColor, size: 24),
                      )
                    ])
                  : Container(),
              30.height,
              ElevatedButton(
                onPressed: () async {
                  if (isLoading) {
                    return;
                  }
                  if (buttonText == "Continue") {
                    setState(() {
                      isLoading = true;
                    });
                    String code = await createHubGetPairCode();

                    // First button press - API call and show instructions
                    setState(() {
                      isTextFieldEnabled = false;
                      showWiFiInstructions = true;
                      buttonText = "I have connected";
                      isLoading = false;
                      pairCode = code;
                    });
                    // Simulating the API call
                  } else {
                    // Second button press - check connection
                    setState(() {
                      isLoading = true;
                    });

                    await checkHubBtnPressed();

                    setState(() {
                      isLoading = false;
                    });
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: SHOCKPrimColor,
                  foregroundColor: white, // Text color
                ),
                child: getTextOrLoading(),
              ),
            ],
          ),
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
