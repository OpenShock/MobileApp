import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:open_shock/main.dart';
import 'package:open_shock/utils/AppColors.dart';
import 'package:open_shock/utils/AppComman.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  EditProfileScreenState createState() => EditProfileScreenState();
}

class EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController fNameController = TextEditingController();
  String email = user.email;
  String fName = user.name;
  String lName = user.name;

  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    emailController.text = user.email;
    fNameController.text = user.name;
  }

  @override
  void setState(fn) {
    if (mounted) super.setState(fn);
  }

  void setValue() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: button(
        context: context,
        textColor: white,
        width: context.width(),
        text: 'Update',
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(
                    "This feature is not yet available, please update your details on the website.")),
          );
        },
      ).paddingSymmetric(horizontal: 16, vertical: 24),
      appBar: appBarWidget(
        '',
        elevation: 0,
        showBack: false,
        color: AppScaffoldDarkColor,
        titleWidget: Row(
          children: [
            IconButton(
              onPressed: () {
                finish(context);
              },
              icon: Icon(Icons.close, color: white),
            ),
            16.width,
            Text('Edit Profile', style: boldTextStyle(color: white)),
          ],
        ),
      ),
      backgroundColor: AppScaffoldDarkColor,
      body: Form(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.topCenter,
                children: [
                  FittedBox(
                    fit: BoxFit.fill,
                    child: Image.network(
                      user.image,
                      height: 100,
                      width: 100,
                    ).cornerRadiusWithClipRRect(50),
                  ),
                ],
              ).center(),
              16.height,
              AppTextField(
                textStyle: primaryTextStyle(color: white),
                cursorColor: white,
                textFieldType: TextFieldType.NAME,
                controller: fNameController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 16),
                  labelText: 'Name',
                  labelStyle: secondaryTextStyle(color: white),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide(color: grey, width: 0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide(color: grey, width: 0.5),
                  ),
                ),
              ),
              16.height,
              AppTextField(
                textStyle: primaryTextStyle(color: white),
                cursorColor: white,
                textFieldType: TextFieldType.EMAIL,
                controller: emailController,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.only(left: 16),
                  labelText: 'Email',
                  labelStyle: secondaryTextStyle(color: white),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide(color: grey, width: 0.5),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16.0),
                    borderSide: BorderSide(color: grey, width: 0.5),
                  ),
                ),
              ),
              16.height,
            ],
          ),
        ),
      ),
    );
  }
}
