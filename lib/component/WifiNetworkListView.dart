import 'package:flutter/material.dart';
import 'package:open_shock/serialization/WifiAuthMode_open_shock.serialization.types_generated.dart';
import 'package:open_shock/serialization/WifiNetwork_open_shock.serialization.types_generated.dart';

class WifiNetworkListView extends StatelessWidget {
  final List<WifiNetwork> wifiNetworks;
  final Function(WifiNetwork) onNetworkTap;

  WifiNetworkListView({required this.wifiNetworks, required this.onNetworkTap});

  // Signal strength bars based on RSSI value
  Widget buildSignalStrengthBars(int rssi) {
    IconData signalIcon;
    Color signalColor;

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

    return Icon(signalIcon, color: signalColor, size: 20);
  }

  // Lock icon based on auth mode
  Widget buildLockIcon(WifiAuthMode authMode) {
    return Icon(
      authMode.value == 0 ? Icons.lock_open : Icons.lock,
      color: authMode.value == 0 ? Colors.green : Colors.red,
      size: 16,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: wifiNetworks.length,
      itemBuilder: (context, index) {
        WifiNetwork network = wifiNetworks[index];

        return GestureDetector(
          onTap: () {
            onNetworkTap(network);
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
                    width: 40,
                    child: buildSignalStrengthBars(network.rssi),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      network.ssid ?? "Hidden",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  buildLockIcon(network.authMode),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
