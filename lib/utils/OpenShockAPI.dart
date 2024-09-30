import 'package:dio/dio.dart';
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
      String method, String endpoint, String data) async {
    var headers = {
      'OpenShockToken': this.api_key,
      'Content-Type': 'application/json',
    };

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
      String id, int int, int dur, String action) async {
    //{\"shocks\": [{\"id\": \"0e83b6b4-e1ac-4cc8-a583-efd0f5704099\",\"type\": \"SHOCK\",\"intensity\": "+String(strength)+",\"duration\": "+String(duration)+"}]}
    Map<String, dynamic>? parsedJson = await doRequest(
        "POST",
        "/2/shockers/control",
        "{\"shocks\": [{\"id\": \"${id}\",\"type\": \"${action}\",\"intensity\": ${int.toString()},\"duration\": ${dur.toString()} }], \"customName\": \"Mobile App\"}");
    String msg = parsedJson!['message'];
    return Future.value(msg.contains('Successfully'));
  }
}
