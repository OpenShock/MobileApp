import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:open_shock/main.dart';
import 'package:open_shock/model/shockobjs/OwnHub.dart';
import 'package:open_shock/model/shockobjs/SelfUser.dart';
import 'package:open_shock/model/shockobjs/SharedUser.dart';

class Openshockapi {
  String api_key, api_host;

  // The main constructor for this class.
  Openshockapi(this.api_host, this.api_key);

  Future<bool> validateKey() async {
    var res = await doRequest("GET", "/1/users/self", "");
    if (res == null) {
      return Future.value(false);
    }

    return Future.value(res.containsKey("data"));
  }

  Future<String> getPairCode(String deviceId) async {
    Map<String, dynamic>? parsedJson =
        await doRequest("GET", "/1/devices/${deviceId}/pair", "");

    if (parsedJson == null) {
      return Future.value(""); // If no response or error occurs
    }

    String msg = parsedJson['message'];
    if (msg == "") {
      return Future.value(parsedJson['data']);
    }
    return Future.value("");
  }

  // New login function that accepts username and password
  Future<bool> login(String username, String password) async {
    Map<String, dynamic>? parsedJson = await doRequest(
      "POST",
      "/1/account/login",
      jsonEncode({"email": username, "password": password}),
      false, // No need to authenticate for login
    );

    if (parsedJson == null) {
      return Future.value(false); // If no response or error occurs
    }

    String msg = parsedJson['message'];

    if (msg.contains("Successfully logged in")) {
      // Extract the set-cookie header and get the openShockSession value
      var dio = Dio();
      var response = await dio.post(
        this.api_host + "/1/account/login",
        data: {"email": username, "password": password},
        options: Options(
          headers: {'Content-Type': 'application/json'},
        ),
      );

      if (response.headers.map.containsKey("set-cookie")) {
        var cookies = response.headers['set-cookie'];
        for (var cookie in cookies!) {
          if (cookie.startsWith("openShockSession=")) {
            this.api_key = cookie.split(";")[0].split("=")[1];
            break;
          }
        }
        return Future.value(true); // Login successful and session key set
      }
    }

    return Future.value(false); // Login failed
  }

  Future<SelfUser> getSelfUser() async {
    Map<String, dynamic>? parsedJson =
        await doRequest("GET", "/1/users/self", "");
    // E1xtract the 'data' field from the parsed JSON
    Map<String, dynamic> dataJson = parsedJson!['data'];

    // Create a SelfUser instance from th e JSON data
    SelfUser user = SelfUser.fromJson(dataJson);
    return Future.value(user);
  }

  Future<List<OwnHub>> getOwnHubs() async {
    Map<String, dynamic>? parsedJson =
        await doRequest("GET", "/1/shockers/own", "");
    // E1xtract the 'data' field from the parsed JSON
    List<dynamic> dataJson = parsedJson!['data'];

    // Create a list of OwnHub instances from the JSON data
    List<OwnHub> hubs = OwnHub.listFromJSON(dataJson);
    return Future.value(hubs);
  }

  Future<List<SharedUser>> getSharedUsers() async {
    Map<String, dynamic>? parsedJson =
        await doRequest("GET", "/1/shockers/shared", "");
    List<dynamic> dataJson = parsedJson!['data'];

    // Create a list of SharedUser instances from the JSON data
    List<SharedUser> users = SharedUser.listFromJSON(dataJson);
    return Future.value(users);
  }

  Future<Map<String, dynamic>?> doRequest(
      String method, String endpoint, String data,
      [bool authenticate = true]) async {
    var headers = {
      'Content-Type': 'application/json',
      'User-Agent': GetUserAgent()
    };

    if (authenticate) {
      headers.addAll({
        'openShockSession': this.api_key,
      });
    }

    var dio = Dio();

    try {
      var response = await dio.request(
        this.api_host + endpoint,
        options: Options(
          method: method,
          headers: headers,
        ),
        data: data,
      );

      // If request is successful, response.data is already a Map<String, dynamic>
      if (response.statusCode == 200) {
        print(response.data);
        return response.data; // Return the data directly
      } else {
        // Handle non-200 status codes
        print('Request failed with status: ${response.statusCode}');
        return Future.value(null);
      }
    } on DioException catch (e) {
      // Handle Dio-specific errors
      print('Dio error: ${e.message}');
      if (e.response != null) {
        print('Error data: ${e.response?.data}');
        return e.response?.data; // Return the error data directly
      } else {
        print('Request failed before reaching the server.');
      }
    } catch (e) {
      // Handle any other errors
      print('Unexpected error: $e');
    }

    // Return null if any error occurs
    return Future.value(null);
  }

  Future<String> acceptShareCode(String code) async {
    Map<String, dynamic>? parsedJson =
        await doRequest("POST", "/1/shares/code/" + code, "");
    String msg = parsedJson!['message'];
    if (msg.contains('Successfully')) {
      return Future.value("");
    } else {
      return Future.value(msg);
    }
  }

  Future<bool> sendControlSignal(
      String id, int intensity, int duration, String action) async {
    Map<String, dynamic>? parsedJson = await doRequest(
        "POST",
        "/2/shockers/control",
        jsonEncode({
          "shocks": [
            {
              "id": id,
              "type": action,
              "intensity": intensity,
              "duration": duration
            }
          ],
          "customName": "Mobile App"
        }));
    String msg = parsedJson!['message'];
    return Future.value(msg.contains('Successfully'));
  }
}
