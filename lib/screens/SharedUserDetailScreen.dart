import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_shock/model/shockobjs/SharedUser.dart';
import 'package:open_shock/model/shockobjs/SharedUserShocker.dart';
import 'package:open_shock/screens/SharedControlPage.dart'; // Import the new control page
import 'package:open_shock/utils/AppColors.dart';

class SharedUserDetailScreen extends StatelessWidget {
  final SharedUser user;

  SharedUserDetailScreen({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppScaffoldDarkColor, // Set background color to match the dashboard
      appBar: AppBar(
        title: Row(
          children: [
            // Display user's image in the AppBar
            CircleAvatar(
              backgroundImage: NetworkImage(user.image),
              radius: 20,
            ),
            16.width, // Add spacing between the image and the text
            Text(user.name, style: boldTextStyle(color: Colors.white)),
          ],
        ),
        backgroundColor:
            AppScaffoldDarkColor, // Ensure app bar color matches the dashboard
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,
              color: Colors.white), // Ensure back button is white
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: user.devices.length,
        itemBuilder: (context, index) {
          final hub = user.devices[index];

          return Card(
            color: AppContainerColor, // Manually set card background color
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  title:
                      Text(hub.name, style: boldTextStyle(color: Colors.white)),
                  subtitle: Text('Hub ID: ${hub.id}',
                      style: secondaryTextStyle(color: Colors.white)),
                ),
                Column(
                  children: hub.shockers.map((shocker) {
                    return Stack(
                      children: [
                        ListTile(
                          title: Text(shocker.name,
                              style: boldTextStyle(color: Colors.white)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildPermissionsRow(
                                  shocker), // Display permissions as colored icons
                              _buildLimitsRow(
                                  shocker), // Display intensity and duration limits
                            ],
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.control_camera,
                                color: shocker.isPaused
                                    ? Colors.grey
                                    : Colors.white),
                            onPressed: shocker.isPaused
                                ? null
                                : () {
                                    // Navigate to SharedControlPage with the correct permissions and limits
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SharedControlPage(
                                          sharedUser: user,
                                          shockerObj:
                                              shocker, // Pass the SharedUser object
                                          shockerName:
                                              shocker.name, // Shocker name
                                          canVibrate:
                                              shocker.permissions['vibrate'] ??
                                                  false,
                                          canSound:
                                              shocker.permissions['sound'] ??
                                                  false,
                                          canShock:
                                              shocker.permissions['shock'] ??
                                                  false,
                                          intensityLimit: (shocker
                                                      .limits['intensity'] ??
                                                  100)
                                              .toDouble(), // Convert to double
                                          durationLimit: (shocker
                                                      .limits['duration'] ??
                                                  30000)
                                              .toDouble(), // Convert to double
                                        ),
                                      ),
                                    );
                                  },
                          ),
                        ),
                        if (shocker.isPaused)
                          Positioned.fill(
                            child: Container(
                              color: Colors.grey.withOpacity(0.5),
                              child: Center(
                                child: Text('Paused',
                                    style: boldTextStyle(
                                        color: Colors.white, size: 24)),
                              ),
                            ),
                          ),
                      ],
                    );
                  }).toList(),
                )
              ],
            ),
          );
        },
      ),
    );
  }

  // Build the permissions row with colored icons
  Widget _buildPermissionsRow(SharedUserShocker shocker) {
    return Row(
      children: [
        _buildColoredIcon(
            Icons.vibration, shocker.permissions['vibrate'] ?? false),
        _buildColoredIcon(
            Icons.volume_up, shocker.permissions['sound'] ?? false),
        _buildColoredIcon(
            Icons.flash_on, shocker.permissions['shock'] ?? false),
      ],
    ).paddingTop(4);
  }

  // Helper widget for colored icons based on the permission status
  Widget _buildColoredIcon(IconData iconData, bool isEnabled) {
    return Icon(
      iconData,
      color: isEnabled
          ? Colors.green
          : Colors.red, // Green for enabled, Red for disabled
      size: 20,
    ).paddingRight(8);
  }

  // Build the limits row
  Widget _buildLimitsRow(SharedUserShocker shocker) {
    String intensity = shocker.limits['intensity'] == null
        ? "No limit"
        : "${shocker.limits['intensity']} / 100";
    String duration = shocker.limits['duration'] == null
        ? "No limit"
        : "${(shocker.limits['duration'] / 1000).toStringAsFixed(1)} secs";

    return Row(
      children: [
        Text("Intensity: $intensity",
            style: secondaryTextStyle(color: Colors.white)),
        16.width,
        Text("Duration: $duration",
            style: secondaryTextStyle(color: Colors.white)),
      ],
    ).paddingTop(4);
  }
}
