import 'dart:io';

import 'package:open_shock/main.dart';
import 'package:signalr_core/signalr_core.dart';
import 'package:http/http.dart' as http;

class _HttpClient extends http.BaseClient {
  final _httpClient = http.Client();
  final Map<String, String> defaultHeaders;

  _HttpClient({required this.defaultHeaders});

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(defaultHeaders);
    return _httpClient.send(request);
  }
}

class OpenshockWS {
  String session_key, api_host;

  HubConnection? connection = null;

  // Constructor
  OpenshockWS(this.api_host, this.session_key);

  // Start the connection
  Future<void> startConnection() async {
    try {
      final httpClient = _HttpClient(defaultHeaders: {
        'OpenShockSession': this.session_key,
        'User-Agent': GetUserAgent(),
      });

      connection = HubConnectionBuilder()
          .withAutomaticReconnect()
          .withUrl(
              api_host + '/1/hubs/user',
              HttpConnectionOptions(
                  logging: (level, message) => print(message),
                  client: httpClient,
                  skipNegotiation: true,
                  transport: HttpTransportType.webSockets,
                  logMessageContent: true))
          .build();

      connection!.start();
      print('Connection started');
    } catch (e) {
      print(e);
    }
  }

  // Add a message handler for a specific event
  void addMessageHandler(String methodName, MethodInvocationFunc handler) {
    if (connection != null) {
      connection!.on(methodName, handler);
      print('Handler added for $methodName');
    } else {
      print('Connection not established yet.');
    }
  }

  // Remove a message handler for a specific event
  void removeMessageHandler(String methodName) {
    if (connection != null) {
      connection!.off(methodName);
      print('Handler removed for $methodName');
    } else {
      print('Connection not established yet.');
    }
  }

  // Stop the connection
  Future<void> stopConnection() async {
    if (connection != null) {
      await connection!.stop();
      print('Connection stopped');
    } else {
      print('Connection is not established.');
    }
  }

  Future<bool> sendControlSignal(
      String id, int intensity, int duration, int action) {
    var data = <String, dynamic>{
      "Id": id,
      "Type": action,
      "Duration": duration,
      "Intensity": intensity,
    };

    try {
      // Wrap the Map in a List
      connection!.send(methodName: 'ControlV2', args: [
        [data],
        null
      ]);
      print('Sent control Signal ${data}');
    } catch (e) {
      return Future.value(false);
    }

    return Future.value(true);
  }
}
