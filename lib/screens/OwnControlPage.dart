import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart'; // For styles and colors
import 'package:open_shock/main.dart';
import 'package:open_shock/model/shockobjs/OwnShocker.dart';
import 'package:open_shock/model/shockobjs/SelfUser.dart';
import 'package:open_shock/model/shockobjs/ShockerLogEntry.dart';
import 'package:open_shock/utils/AppColors.dart'; // Your color constants

class OwnControlPage extends StatefulWidget {
  final SelfUser selfUser; // Pass the entire SharedUser object
  final String shockerName; // Name of the shocker
  final OwnShocker shockerObj; // Shocker object with methods

  OwnControlPage({
    required this.selfUser, // Accept the SharedUser object
    required this.shockerName,
    required this.shockerObj,
  });

  @override
  _OwnControlPageState createState() => _OwnControlPageState();
}

class _OwnControlPageState extends State<OwnControlPage> {
  double intensity = 25; // Default intensity value
  double duration = 1; // Default duration value in seconds
  bool isLoading = false;
  String loadingButton = ""; // To track which button is loading
  Color buttonColor = Colors.pink; // Default button color

  final GlobalKey<AnimatedListState> _listKey =
      GlobalKey<AnimatedListState>(); // Key for AnimatedList
  List<ShockerLogEntry> logEntries = []; // List of log entries

  @override
  void initState() {
    super.initState();
    clientWs?.removeMessageHandler("Log");
    clientWs?.addMessageHandler('Log', (message) {
      // Assuming message is a list where:
      // - message[0] contains user data (connectionId, customName, image, id, name)
      // - message[1] contains a list of actions (shocker data, type, intensity, duration, executedAt)

      if (message!.length == 2) {
        var userInfo = message[0];
        var actionList = message[1];

        if (userInfo is Map<String, dynamic> && actionList is List) {
          String name = userInfo['name'] ?? '';
          String customName = userInfo['customName'] ?? '';
          String imageUrl = userInfo['image'] ?? '';

          for (var action in actionList) {
            if (action is Map<String, dynamic> && action['shocker'] != null) {
              String actionType = action['type'] == 1
                  ? 'Shock'
                  : action['type'] == 2
                      ? 'Vibrate'
                      : 'Sound';
              int intensity = action['intensity'] ?? 0;
              int durationMs = action['duration'] ?? 0;
              double durationSec = durationMs / 1000.0; // Convert to seconds
              String shockerId = action['shocker']['id'];

              if (shockerId == widget.shockerObj.id) {
                // Add the new log entry - If matching current shocker

                _addLogEntry(ShockerLogEntry(
                  action: actionType,
                  duration: durationSec,
                  shockerId: shockerId,
                  intensity: intensity,
                  name: name,
                  imageUrl: imageUrl,
                  customName: customName.isNotEmpty ? customName : null,
                ));
                break;
              }
            }
          }
        }
      }
    });
  }

  // Build the log section with AnimatedList
  Widget _buildLogSection() {
    return ExpansionTile(
      title: Text('Action Log', style: boldTextStyle(color: Colors.white)),
      iconColor: SHOCKPrimColor,
      children: [
        Container(
          height: 200, // Set a fixed height for the log section
          child: AnimatedList(
            key: _listKey,
            initialItemCount: logEntries.length,
            itemBuilder: (context, index, animation) {
              var entry = logEntries[index];
              IconData actionIcon;
              switch (entry.action) {
                case 'Shock':
                  actionIcon = Icons.flash_on;
                  break;
                case 'Vibrate':
                  actionIcon = Icons.vibration;
                  break;
                case 'Sound':
                default:
                  actionIcon = Icons.volume_up;
                  break;
              }

              // Wrap the ListTile in SlideTransition for the slide-in effect
              return SlideTransition(
                position: animation.drive(
                  Tween<Offset>(begin: Offset(1, 0), end: Offset(0, 0))
                      .chain(CurveTween(curve: Curves.easeInOut)),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(entry.imageUrl),
                    radius: 20,
                  ),
                  title: Text(
                    entry.customName ?? entry.name,
                    style: boldTextStyle(color: Colors.white),
                  ),
                  subtitle: Row(
                    children: [
                      Icon(actionIcon, color: Colors.white),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Intensity: ${entry.intensity} | Duration: ${entry.duration}s',
                          style: secondaryTextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Add a new log entry
  void _addLogEntry(ShockerLogEntry entry) {
    setState(() {
      logEntries.insert(0, entry);
      _listKey.currentState?.insertItem(
          0); // Trigger animation for the new entry // Add to the top of the list
    });
  }

  // Build a slider for intensity and duration with step sizes
  Widget _buildSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String Function(double) displayValue,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          '$title: ${displayValue(value)}', // Show slider value
          style: boldTextStyle(color: Colors.white, size: 18),
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: Colors.pink,
          inactiveColor: Colors.grey,
          label: displayValue(value),
          onChanged: onChanged,
        ),
        SizedBox(height: 10),
      ],
    );
  }

  // Control Button (Shock, Beep, Vibrate)
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required String action,
    required Future<bool> Function()
        onPressedAction, // The async function to be called
  }) {
    return Column(
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: loadingButton == action
                ? Colors.grey
                : buttonColor, // Show loading color or normal color
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            shadowColor: Colors.pinkAccent, // Add shadow for better appearance
            elevation: 8, // Make the buttons stand out
          ),
          onPressed: isLoading
              ? null
              : () async {
                  setState(() {
                    isLoading = true;
                    loadingButton = action;
                  });

                  // Call the async action (shock, vibrate, beep)
                  bool success = await onPressedAction();

                  if (success) {
                    // If successful, show loading on all buttons for the duration
                    Timer(Duration(seconds: duration.toInt()), () {
                      setState(() {
                        isLoading = false;
                        loadingButton = "";
                      });
                    });
                  } else {
                    // If failed, flash red on the pressed button
                    setState(() {
                      buttonColor = Colors.orange;
                      isLoading = false;
                      loadingButton = "";
                    });
                    Timer(Duration(seconds: 1), () {
                      setState(() {
                        buttonColor = Colors.pink; // Revert to normal color
                        isLoading = false;
                        loadingButton = "";
                      });
                    });
                  }
                },
          child: isLoading && loadingButton == action
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Icon(icon, color: Colors.white, size: 30),
        ),
        SizedBox(height: 5),
        Text(label, style: secondaryTextStyle(color: Colors.white, size: 14)),
      ],
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppScaffoldDarkColor, // Match app's dark background color
      appBar: AppBar(
        title: Text('Control Page', style: boldTextStyle(color: Colors.white)),
        backgroundColor: AppScaffoldDarkColor, // Apply theme color
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // User's Picture and Shocker Name
              CircleAvatar(
                backgroundImage: NetworkImage(
                    widget.selfUser.image), // Use the image from SharedUser
                radius: 40,
              ),
              SizedBox(height: 10),
              Text(
                widget.selfUser.name, // Use the name from SharedUser
                style: boldTextStyle(color: Colors.white, size: 20),
              ),
              SizedBox(height: 5),
              Text(
                "Controlling ${widget.shockerName}",
                style: secondaryTextStyle(color: Colors.grey, size: 16),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 40),
              // Intensity Slider
              _buildSlider(
                title: 'Intensity',
                value: intensity,
                min: 1,
                max: 100,
                divisions: 100, // Step size of 1
                displayValue: (value) =>
                    value.toInt().toString(), // No decimal point
                onChanged: (newValue) {
                  setState(() {
                    intensity = newValue;
                  });
                },
              ),
              SizedBox(height: 20),
              // Duration Slider (in seconds)
              _buildSlider(
                title: 'Duration',
                value: duration,
                min: 0.3,
                max: 30,
                divisions: (30 / 0.3).toInt(), // Step size of 0.1
                displayValue: (value) =>
                    value.toStringAsFixed(1), // 1 decimal point
                onChanged: (newValue) {
                  setState(() {
                    duration = newValue;
                  });
                },
              ),
              SizedBox(height: 40),
              // Permission Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildControlButton(
                    icon: Icons.volume_up,
                    label: "Sound",
                    action: "sound",
                    onPressedAction: () async {
                      // Call the beep method on shockerObj
                      return await widget.shockerObj.beepWS(
                        clientWs!,
                        intensity.toInt(), // Pass the intensity
                        (duration * 1000).toInt(), // Pass the duration in ms
                      );
                    },
                  ),
                  _buildControlButton(
                    icon: Icons.vibration,
                    label: "Vibrate",
                    action: "vibrate",
                    onPressedAction: () async {
                      // Call the vibrate method on shockerObj
                      return await widget.shockerObj.vibrateWS(
                        clientWs!,
                        intensity.toInt(), // Pass the intensity
                        (duration * 1000).toInt(), // Pass the duration in ms
                      );
                    },
                  ),
                  _buildControlButton(
                    icon: Icons.flash_on,
                    label: "Shock",
                    action: "shock",
                    onPressedAction: () async {
                      // Call the shock method on shockerObj
                      return await widget.shockerObj.shockWS(
                        clientWs!,
                        intensity.toInt(), // Pass the intensity
                        (duration * 1000).toInt(), // Pass the duration in ms
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 20),
              // Log Section
              _buildLogSection(),
            ],
          ),
        ),
      ),
    );
  }
}
