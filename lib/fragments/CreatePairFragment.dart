import 'package:flutter/material.dart';
import 'package:open_shock/component/WifiNetworkListView.dart';
import 'package:open_shock/main.dart';
import 'package:open_shock/model/HubSocket.dart';
import 'package:open_shock/serialization/HubToLocalMessage_open_shock.serialization.local_generated.dart';
import 'package:open_shock/serialization/WifiNetworkEventType_open_shock.serialization.types_generated.dart';
import 'package:open_shock/utils/AppColors.dart';
import 'package:open_shock/utils/DialogUtil.dart';
import 'package:open_shock/serialization/WifiNetwork_open_shock.serialization.types_generated.dart'; // Assuming WifiNetwork and related types are here

class CreatePairFragment extends StatefulWidget {
  static String tag = '/CreatePairFragment';

  @override
  CreatePairFragmentState createState() => CreatePairFragmentState();
}

class CreatePairFragmentState extends State<CreatePairFragment> {
  HubSocket hubSocket = HubSocket(); // For managing hub WebSocket
  bool isHubConnected = false;
  bool isTextFieldEnabled = true;
  bool showWiFiInstructions = false;
  String buttonText = "Continue";
  bool isLoading = false;
  String pairCode = "";
  List<WifiNetwork> wifiNetworks = []; // List to hold Wi-Fi networks
  List<String> bssidsFound = [];

  TextEditingController hubNameController =
      TextEditingController(); // Controller for hub name input

  @override
  void initState() {
    super.initState();
    wifiNetworks = [];
    bssidsFound = [];
    clientWs!
        .stopConnection(); // Stop control socket as the device's Wi-Fi will lose internet access
    init();
  }

  Future<void> init() async {
    // Initialization logic can go here
  }

  void sendWifiCredentialsToHub(String ssid, String password) {
    print('Sending Wi-Fi credentials: SSID: $ssid, Password: $password');
    // Handle sending Wi-Fi credentials to the hub via WebSocket
  }

  void sendPairCodeToHub(String pairCode) {
    print('Sending pair code to the hub: $pairCode');
    // Handle sending the pair code to the hub via WebSocket
  }

  Future<void> connectToHub() async {
    setState(() => isLoading = true);
    bool success = await hubSocket.connectToHub();
    setState(() {
      isHubConnected = success;
      isLoading = false;
    });
    if (!success) {
      // Show an error dialog if hub connection fails
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
    } else {
      // Listen to incoming messages from the hub WebSocket
      hubSocket.listenToMessages((message) {
        handleHubMessage(message);
      });
    }
  }

  void handleHubMessage(dynamic message) {
    print('Received message from hub: $message');
    final bytes = message as List<int>;
    try {
      // Decode FlatBuffer message
      final hubMessage = HubToLocalMessage(
          bytes); // HubMessage is a generated FlatBuffer class
      print(hubMessage);

      switch (hubMessage.payloadType) {
        case HubToLocalMessagePayloadTypeId.WifiNetworkEvent:
          final wifiEvent = hubMessage.payload as WifiNetworkEvent;

          if (wifiEvent.eventType == WifiNetworkEventType.Connected) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Connected; Attempting to Pair to account'),
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
          break;

        case HubToLocalMessagePayloadTypeId.AccountLinkCommandResult:
          final linkResult = hubMessage.payload as AccountLinkCommandResult;
          if (linkResult.result == AccountLinkResultCode.Success) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(
                  'Account Linked, Hub will reboot, please reconnect to internet.'),
            ));
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text('Unable to link.'),
            ));
          }
          break;

        default:
          // Handle other payload types if necessary
          break;
      }
    } catch (e) {
      print('Error decoding FlatBuffer message: $e');
    }
  }

  Widget getTextOrLoading() {
    return isLoading
        ? CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 3,
          )
        : Text(buttonText,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppScaffoldDarkColor,
      appBar: AppBar(
        title: Text("Pair a hub",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: AppScaffoldDarkColor,
      ),
      body: isHubConnected
          ? WifiNetworkListView(
              wifiNetworks: wifiNetworks,
              onNetworkTap: (WifiNetwork network) {
                // Show the Wi-Fi password dialog when a network is tapped
                DialogUtil.showWifiPasswordDialog(
                  context,
                  network.ssid ?? "Unknown",
                  (password) =>
                      sendWifiCredentialsToHub(network.ssid!, password),
                );
              },
            )
          : SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: buildPreConnection(context),
              ),
            ),
    );
  }

  Widget buildPreConnection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        Center(
          child: Text(
            "Please have your OpenShock hub turned on, you should see a Wi-Fi for this within your settings.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white),
          ),
        ),
        SizedBox(height: 30),
        TextField(
          controller: hubNameController,
          style: TextStyle(color: Colors.white),
          enabled: isTextFieldEnabled,
          decoration: InputDecoration(
            labelText: "Enter new hub name",
            labelStyle: TextStyle(color: Colors.grey),
            border: OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
          ),
        ),
        SizedBox(height: 30),
        showWiFiInstructions
            ? Text(
                "Please connect to the OpenShock Wi-Fi network now.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
              )
            : Container(),
        (pairCode != "")
            ? Column(
                children: [
                  SizedBox(height: 10),
                  Text(
                    "Pair code",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white),
                  ),
                  Text(
                    pairCode,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: SHOCKPrimColor, fontSize: 24),
                  ),
                ],
              )
            : Container(),
        SizedBox(height: 30),
        ElevatedButton(
          onPressed: () async {
            if (isLoading) return;
            if (buttonText == "Continue") {
              setState(() => isLoading = true);
              String code = await createHubGetPairCode();

              // First button press - API call and show instructions
              setState(() {
                isTextFieldEnabled = false;
                showWiFiInstructions = true;
                buttonText = "I have connected";
                isLoading = false;
                pairCode = code;
              });
            } else {
              // Second button press - check connection
              setState(() => isLoading = true);
              await connectToHub();
              setState(() => isLoading = false);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: SHOCKPrimColor,
            foregroundColor: Colors.white, // Text color
          ),
          child: getTextOrLoading(),
        ),
      ],
    );
  }

  Future<String> createHubGetPairCode() async {
    // Simulate an API call to get the pair code
    String tmpCode =
        await clientApi.getPairCode('cb495859-4ad3-4a51-823b-339972c448ca');
    return Future.value(tmpCode);
  }
}
