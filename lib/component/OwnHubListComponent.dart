import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_shock/main.dart';
import 'package:open_shock/model/shockobjs/OwnHub.dart';
import 'package:open_shock/screens/OwnControlPage.dart';
import 'package:open_shock/utils/AppColors.dart';

class OwnHubListComponent extends StatefulWidget {
  const OwnHubListComponent({Key? key}) : super(key: key);

  @override
  _OwnHubListComponentState createState() => _OwnHubListComponentState();
}

class _OwnHubListComponentState extends State<OwnHubListComponent> {
  List<OwnHub> hubs = []; // List to store hubs

  @override
  void initState() {
    super.initState();
    fetchHubs(); // Fetch hubs when the widget is initialized
  }

  Future<void> fetchHubs() async {
    try {
      // Fetch hubs using the clientApi
      Map<String, dynamic>? parsedJson =
          await clientApi.doRequest("GET", "/1/shockers/own", "");
      List<dynamic> dataJson = parsedJson!['data'];

      // Parse the hubs and update state
      List<OwnHub> loadedHubs = OwnHub.listFromJSON(dataJson);

      setState(() {
        hubs = loadedHubs;
      });
    } catch (e) {
      print("Error fetching hubs: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return hubs.isEmpty
        ? Center(
            child:
                CircularProgressIndicator()) // Show loader if hubs are not loaded yet
        : ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: hubs.length,
            itemBuilder: (context, index) {
              final hub = hubs[index];

              return Card(
                color: AppContainerColor, // Manually set card background color
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(hub.name,
                          style: boldTextStyle(color: Colors.white)),
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
                              trailing: IconButton(
                                icon: Icon(Icons.control_camera,
                                    color: shocker.isPaused
                                        ? Colors.grey
                                        : Colors.white),
                                onPressed: shocker.isPaused
                                    ? null
                                    : () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                OwnControlPage(
                                              selfUser: user,
                                              shockerObj:
                                                  shocker, // Pass the SharedUser object
                                              shockerName:
                                                  shocker.name, // Shocker name
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
          );
  }
}
