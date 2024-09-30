import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_shock/main.dart';
import 'package:open_shock/model/shockobjs/SharedUser.dart';
import 'package:open_shock/screens/SharedUserDetailScreen.dart'; // Add this new screen
import 'package:open_shock/utils/AppColors.dart';

class SharedUsersFragment extends StatefulWidget {
  static String tag = '/SharedUsersFragment';

  @override
  SharedUsersFragmentState createState() => SharedUsersFragmentState();
}

class SharedUsersFragmentState extends State<SharedUsersFragment> {
  List<SharedUser> sharedUsers = [];

  @override
  void initState() {
    super.initState();
    fetchSharedUsers();
  }

  Future<void> fetchSharedUsers() async {
    try {
      List<SharedUser> users = await clientApi.getSharedUsers();
      setState(() {
        sharedUsers = users;
      });
    } catch (e) {
      print("Error fetching shared users: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppScaffoldDarkColor.withOpacity(0.1),
      appBar: AppBar(
        title: Text("Shared Users", style: boldTextStyle(color: white)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppScaffoldDarkColor,
        automaticallyImplyLeading: false,
        actions: [
          PopupMenuButton(
            color: AppContainerColor,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            icon: Icon(Icons.add, color: white),
            onSelected: (int value) async {
              if (value == 1) {
                _showEnterCodeDialog();
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                child: Text("Enter share code",
                    style: boldTextStyle(color: white)),
                value: 1,
              ),
            ],
          ),
        ],
      ),
      body: sharedUsers.isEmpty
          ? Center(
              child:
                  CircularProgressIndicator()) // Show loader while fetching data
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: sharedUsers.length,
              itemBuilder: (context, index) {
                SharedUser user = sharedUsers[index];

                // Calculate total hubs and shockers
                int totalHubs = user.devices.length;
                int totalShockers = user.devices.fold(
                    0,
                    (previousValue, element) =>
                        previousValue + element.shockers.length);

                return Card(
                  color: AppContainerColor,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundImage: NetworkImage(user.image),
                      radius: 30,
                    ),
                    title: Text(user.name, style: boldTextStyle(color: white)),
                    subtitle: Text('Hubs: $totalHubs, Shockers: $totalShockers',
                        style: secondaryTextStyle(color: white)),
                    trailing: Icon(Icons.arrow_forward_ios, color: white),
                    onTap: () {
                      // Navigate to detailed view when tapped
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              SharedUserDetailScreen(user: user),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }

  void _showEnterCodeDialog() {
    String code = '';
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Enter Share Code'),
          backgroundColor: AppScaffoldDarkColor,
          content: TextField(
            onChanged: (value) {
              code = value;
            },
            decoration: InputDecoration(hintText: "Enter code"),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.pink,
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text('Submit'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
              ),
              onPressed: () async {
                Navigator.of(context).pop(); // Dismiss the dialog
                String success = await clientApi.acceptShareCode(code);
                if (success == "") {
                  // Code was accepted
                  fetchSharedUsers();
                } else {
                  // Show error message
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(success)),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
