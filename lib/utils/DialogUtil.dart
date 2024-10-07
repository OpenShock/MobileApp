import 'package:flutter/material.dart';
import 'package:open_shock/utils/AppColors.dart';

class DialogUtil {
  static void showWifiPasswordDialog(
      BuildContext context, String ssid, Function(String) onSubmit) {
    TextEditingController passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Enter Wi-Fi Password for $ssid',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: AppScaffoldDarkColor,
          content: TextField(
            controller: passwordController,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: "Password",
              hintStyle: TextStyle(color: Colors.white),
              border: OutlineInputBorder(
                borderSide: BorderSide(color: SHOCKPrimColor),
              ),
              labelStyle: TextStyle(color: Colors.white),
            ),
            style: TextStyle(color: Colors.white),
          ),
          actions: [
            TextButton(
              child: Text('Cancel'),
              style: TextButton.styleFrom(foregroundColor: Colors.pink),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Submit'),
              style: TextButton.styleFrom(foregroundColor: Colors.white),
              onPressed: () {
                onSubmit(passwordController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
