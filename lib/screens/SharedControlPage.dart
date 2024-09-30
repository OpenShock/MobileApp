import 'dart:async';
import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart'; // For styles and colors
import 'package:open_shock/main.dart';
import 'package:open_shock/model/shockobjs/SharedUser.dart'; // Import the SharedUser model
import 'package:open_shock/model/shockobjs/SharedUserShocker.dart';
import 'package:open_shock/utils/AppColors.dart'; // Your color constants

class SharedControlPage extends StatefulWidget {
  final SharedUser sharedUser; // Pass the entire SharedUser object
  final String shockerName; // Name of the shocker
  final bool canVibrate;
  final bool canSound;
  final bool canShock;
  final double intensityLimit; // Max intensity (converted to double)
  final double
      durationLimit; // Max duration in milliseconds (converted to seconds)
  final SharedUserShocker shockerObj; // Shocker object with methods

  SharedControlPage({
    required this.sharedUser, // Accept the SharedUser object
    required this.shockerName,
    required this.canVibrate,
    required this.canSound,
    required this.canShock,
    required this.intensityLimit,
    required this.durationLimit,
    required this.shockerObj,
  });

  @override
  _SharedControlPageState createState() => _SharedControlPageState();
}

class _SharedControlPageState extends State<SharedControlPage> {
  double intensity = 25; // Default intensity value
  double duration = 1; // Default duration value in seconds
  bool isLoading = false;
  String loadingButton = ""; // To track which button is loading
  Color buttonColor = Colors.pink; // Default button color

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
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // User's Picture and Shocker Name
            CircleAvatar(
              backgroundImage: NetworkImage(
                  widget.sharedUser.image), // Use the image from SharedUser
              radius: 40,
            ),
            SizedBox(height: 10),
            Text(
              widget.sharedUser.name, // Use the name from SharedUser
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
              max: widget.intensityLimit,
              divisions: widget.intensityLimit.toInt(), // Step size of 1
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
              max: widget.durationLimit / 1000,
              divisions:
                  (widget.durationLimit / 0.3).toInt(), // Step size of 0.1
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
                if (widget.canSound)
                  _buildControlButton(
                    icon: Icons.volume_up,
                    label: "Sound",
                    action: "sound",
                    onPressedAction: () async {
                      // Call the beep method on shockerObj
                      return await widget.shockerObj.beep(
                        clientApi,
                        intensity.toInt(), // Pass the intensity
                        (duration * 1000).toInt(), // Pass the duration in ms
                      );
                    },
                  ),
                if (widget.canVibrate)
                  _buildControlButton(
                    icon: Icons.vibration,
                    label: "Vibrate",
                    action: "vibrate",
                    onPressedAction: () async {
                      // Call the vibrate method on shockerObj
                      return await widget.shockerObj.vibrate(
                        clientApi,
                        intensity.toInt(), // Pass the intensity
                        (duration * 1000).toInt(), // Pass the duration in ms
                      );
                    },
                  ),
                if (widget.canShock)
                  _buildControlButton(
                    icon: Icons.flash_on,
                    label: "Shock",
                    action: "shock",
                    onPressedAction: () async {
                      // Call the shock method on shockerObj
                      return await widget.shockerObj.shock(
                        clientApi,
                        intensity.toInt(), // Pass the intensity
                        (duration * 1000).toInt(), // Pass the duration in ms
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
