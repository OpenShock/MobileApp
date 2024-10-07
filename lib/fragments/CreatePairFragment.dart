import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_shock/main.dart';
import 'package:open_shock/serialization/HubConfig_open_shock.serialization.configuration_generated.dart';
import 'package:open_shock/serialization/LocalToHubMessage_open_shock.serialization.local_generated.dart';
import 'package:open_shock/serialization/WifiAuthMode_open_shock.serialization.types_generated.dart';
import 'package:open_shock/serialization/WifiNetworkEventType_open_shock.serialization.types_generated.dart';
import 'package:open_shock/serialization/WifiNetwork_open_shock.serialization.types_generated.dart';
import 'package:open_shock/utils/AppColors.dart';
import 'package:web_socket_channel/io.dart';
import 'package:open_shock/serialization/HubToLocalMessage_open_shock.serialization.local_generated.dart'; // FlatBuffer generated files
import 'package:flat_buffers/flat_buffers.dart' as fb;

class CreatePairFragment extends StatefulWidget {
  static String tag = '/CreatePairFragment';

  @override
  CreatePairFragmentState createState() => CreatePairFragmentState();
}

class CreatePairFragmentState extends State<CreatePairFragment> {
  // Your existing fields here
  IOWebSocketChannel? channel;
  bool isHubConnected = false;
  bool isHubNameEntered = false;
  bool isTextFieldEnabled = true;
  bool showWiFiInstructions = false;
  String buttonText = "Continue";
  bool isLoading = false;
  String pairCode = "";
  List<WifiNetwork> wifiNetworks = [];
  List<String> bssidsFound = [];
  TextEditingController hubNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    wifiNetworks = [];
    //Stop connection, as we wont have internet during hub setup.
    clientWs!.stopConnection();
    init();
  }

  Future<void> init() async {}

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void showWifiPasswordDialog(WifiNetwork network) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Enter Wi-Fi Password for ${network.ssid}',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          backgroundColor: AppScaffoldDarkColor,
          content: TextField(
            controller: passwordController,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: "Password",
              hintStyle: new TextStyle(color: white),
              border: OutlineInputBorder(
                borderSide: BorderSide(
                  color: SHOCKPrimColor,
                ),
              ),
              labelStyle: new TextStyle(color: white),
              floatingLabelStyle: new TextStyle(color: white),
            ),
            style: TextStyle(color: white),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.pink,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Attempting to connect now.'),
                ));
              },
            ),
            TextButton(
              child: Text('Submit'),
              style: TextButton.styleFrom(
                foregroundColor: white,
              ),
              onPressed: () async {
                sendWifiCredentialsToHub(
                    network.ssid!, passwordController.text);

                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void sendPairCodeToHub(String pairCode) {
    // Create a FlatBufferBuilder instance
    final fb.Builder fbb = fb.Builder(initialSize: 64);
    // Use the AccountLinkCommandObjectBuilder to create the AccountLinkCommand
    final cmdBuilder = AccountLinkCommandObjectBuilder(code: pairCode);

    print('Sending pair code to the hub: ${pairCode}');

    final linkCommandOffsetData = cmdBuilder.finish(fbb);

    // Build the LocalToHubMessage
    var messageBuilder = LocalToHubMessageBuilder(fbb);
    messageBuilder.begin();
    messageBuilder.addPayloadOffset(linkCommandOffsetData);
    messageBuilder
        .addPayloadType(LocalToHubMessagePayloadTypeId.AccountLinkCommand);

    final messageOffset = messageBuilder.finish();

    // Finish the buffer with the root object offset
    fbb.finish(messageOffset);

    // Send the buffer
    channel!.sink.add(fbb.buffer);
  }

  void sendWifiCredentialsToHub(String ssid, String password,
      {bool connect = true}) {
    // Prepare a FlatBuffer message with SSID and password and send it via WebSocket
    print(
        '2Sending Wi-Fi credentials to the hub: SSID: $ssid, Password: $password, Connect: $connect');

    final fbb = fb.Builder(initialSize: 128);

    // Build the WifiNetworkSaveCommandObject
    var commandBuilder = WifiNetworkSaveCommandObjectBuilder(
      password: password,
      ssid: ssid,
      connect: connect,
    );

    final wifiSaveOffset = commandBuilder.finish(fbb);

    // Build the LocalToHubMessage
    var messageBuilder = LocalToHubMessageBuilder(fbb);
    messageBuilder.begin();
    messageBuilder.addPayloadOffset(wifiSaveOffset);
    messageBuilder
        .addPayloadType(LocalToHubMessagePayloadTypeId.WifiNetworkSaveCommand);

    final messageOffset = messageBuilder.finish();

    // Finish the buffer with the root object offset
    fbb.finish(messageOffset);

    // Send the buffer
    channel!.sink.add(fbb.buffer);
  }

  Future<String> createHubGetPairCode() async {
    String tmpCode =
        await clientApi.getPairCode('cb495859-4ad3-4a51-823b-339972c448ca');

    return Future.value(tmpCode);
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

  Future<bool> checkForHubConnection() async {
    try {
      await Socket.connect('10.10.10.10', 81, timeout: Duration(seconds: 2));
      return Future.value(true);
    } catch (e) {
      return Future.value(false);
    }
  }

  Future<void> connectToHub() async {
    try {
      if (isHubConnected) {
        print('Hub already connected.');
        return;
      }

      // Confirm port open before connecting to WS
      bool success = await checkForHubConnection();
      if (success) {
        setState(() {
          isHubConnected = true;
          showWiFiInstructions = false;
          isLoading = true;
        });

        // Connect to WebSocket at ws://10.10.10.10:81/ws
        channel = IOWebSocketChannel.connect('ws://10.10.10.10:81/ws');

        // Listen for WebSocket messages
        channel?.stream.listen((message) {
          final bytes = message as List<int>;
          try {
            // Decode FlatBuffer message
            final hubMessage = HubToLocalMessage(
                bytes); // HubMessage is a generated FlatBuffer class
            print(hubMessage);
            if (hubMessage.payloadType ==
                HubToLocalMessagePayloadTypeId.WifiNetworkEvent) {
              final wifiEvent = hubMessage.payload as WifiNetworkEvent;

              if (wifiEvent.eventType == WifiNetworkEventType.Connected) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Connected; Attepting to Pair to account'),
                ));

                sendPairCodeToHub(pairCode);
              }

              if (wifiEvent.networks != null) {
                var wifiNetworksLocal = wifiEvent.networks!;
                for (int i = 0; i < wifiNetworksLocal.length; i++) {
                  if (!bssidsFound.contains(wifiNetworksLocal[i].bssid)) {
                    wifiNetworks.add(wifiNetworksLocal[i]);
                    bssidsFound.add(wifiNetworksLocal[i].bssid!);
                  }
                }
              }
              setState(() {
                isLoading = false; // Stop loading spinner
              });
            } else if (hubMessage.payloadType ==
                HubToLocalMessagePayloadTypeId.AccountLinkCommandResult) {
              final linkResult = hubMessage.payload as AccountLinkCommandResult;
              if (linkResult.result == AccountLinkResultCode.Success) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(
                      'Account Linked, Hub will reboot, please recoonect to internet.'),
                ));
              } else {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Unable to link.'),
                ));
              }
            }
          } catch (e) {
            print('Error decoding FlatBuffer message: $e');
          }
        });
      } else {
        print('Cannot connect to the hub. Port not open.');
      }
    } catch (e) {
      print('Error connecting to WebSocket: $e');
    }
  }

  // Update your button press to connect to the WebSocket after confirming port
  checkHubBtnPressed() async {
    if (!isHubConnected) {
      await connectToHub();
    } else {
      print('Already connected to the WebSocket.');
    }

    if (isHubConnected) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text('OpenShock Hub found, connected, and listening for messages.'),
      ));
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

  // Signal strength bars based on RSSI value
  Widget buildSignalStrengthBars(int rssi) {
    IconData signalIcon;
    Color signalColor;

    // Determine the number of bars based on RSSI value
    if (rssi >= -50) {
      signalIcon = Icons.signal_cellular_4_bar; // Excellent signal
      signalColor = Colors.green;
    } else if (rssi >= -70) {
      signalIcon = Icons.signal_cellular_4_bar; // Good signal
      signalColor = Colors.orange;
    } else {
      signalIcon = Icons.signal_cellular_4_bar; // Poor signal
      signalColor = Colors.red;
    }

    return Icon(
      signalIcon,
      color: signalColor,
      size: 20, // Adjust size if needed
    );
  }

  // Lock icon based on auth mode
  Widget buildLockIcon(WifiAuthMode authMode) {
    return Icon(
      authMode.value == 0
          ? Icons.lock_open
          : Icons.lock, // Open for no auth, closed for others
      color: authMode.value == 0 ? Colors.green : Colors.red,
      size: 16,
    );
  }

  Widget buildPreConnection(BuildContext context) {
    return Column(
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
                  style: primaryTextStyle(color: SHOCKPrimColor, size: 24),
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
    );
  }

  Widget buildDuringConnection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: wifiNetworks.length,
              itemBuilder: (context, index) {
                WifiNetwork network = wifiNetworks[index];

                return GestureDetector(
                  onTap: () {
                    print('Network SSID: ${network.ssid}');
                    showWifiPasswordDialog(network);
                  },
                  child: Card(
                    color: Colors.grey[800],
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width:
                                40, // Fix the width of the signal strength bars
                            child: buildSignalStrengthBars(network.rssi),
                          ),
                          SizedBox(
                              width:
                                  10), // Spacing between signal bars and SSID
                          Expanded(
                            child: Text(
                              network.ssid != null ? network.ssid! : "Hidden",
                              style: primaryTextStyle(color: white),
                            ),
                          ),
                          buildLockIcon(
                              network.authMode), // The lock icon on the right
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
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
      body: isHubConnected
          ? buildDuringConnection(context)
          : SingleChildScrollView(
              child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: buildPreConnection(context)),
            ),
    );
  }
}
