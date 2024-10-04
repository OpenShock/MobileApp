import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_shock/main.dart';
import 'package:open_shock/screens/EditProfileScreen.dart';
import 'package:open_shock/utils/AppColors.dart';
import 'package:open_shock/utils/AppComman.dart';

class SettingScreen extends StatefulWidget {
  @override
  SettingScreenState createState() => SettingScreenState();
}

class SettingScreenState extends State<SettingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Image.network(
            user.image + "&s=512",
            fit: BoxFit.fill,
            width: context.width(),
          ),
          Container(width: context.width(), color: Colors.black38),
          Container(
            alignment: Alignment.topRight,
            margin: EdgeInsets.only(top: 40, right: 16),
            child: IconButton(
              onPressed: () {
                finish(context);
              },
              icon: Icon(Icons.close, color: white, size: 30),
            ),
          ),
          Positioned(
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16)),
                color: AppScaffoldDarkColor,
              ),
              padding: EdgeInsets.symmetric(vertical: 16),
              width: context.width(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  settIngContainer(
                    icon: Icons.edit,
                    title: 'Edit Profile',
                    textColor: white,
                    onTap: () {
                      EditProfileScreen().launch(context,
                          pageRouteAnimation: PageRouteAnimation.SlideBottomTop,
                          duration: Duration(milliseconds: 150));
                    },
                  ),
                  settIngContainer(
                    icon: Icons.person,
                    title: 'Member',
                    textColor: white,
                    onTap: () {},
                  ),
                  settIngContainer(
                      icon: Icons.settings, title: 'Setting', textColor: white),
                  16.height,
                  64.height,
                  64.height,
                  16.height,
                  16.height,

                  // settIngContainer(
                  //     icon: Icons.chat,
                  //     title: 'Terms of use',
                  //     textColor: white),
                  // settIngContainer(
                  //     icon: Icons.send, title: 'Contact', textColor: white),
                  settIngContainer(
                    icon: Icons.logout,
                    title: 'Logout',
                    textColor: Colors.deepOrange,
                    onTap: () {
                      preformLogout(context);
                    },
                  ),
                  Text(
                    'Version ' + appVersion,
                    style: secondaryTextStyle(size: 12),
                  ).paddingLeft(16)
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
