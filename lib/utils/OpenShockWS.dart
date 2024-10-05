import 'package:open_shock/main.dart';
import 'package:signalr_core/signalr_core.dart';

class OpenshockWS {
  String session_key, api_host;

  HubConnection? connection = null;

  // Constructor
  OpenshockWS(this.api_host, this.session_key);

  // Start the connection
  Future<void> startConnection() async {
    try {
      connection = HubConnectionBuilder()
          .withUrl(
              api_host + '/1/hubs/user',
              HttpConnectionOptions(
                  logging: (level, message) => print(message),
                  customHeaders: {
                    'Cookie': "openShockSession=" + this.session_key,
                    'User-Agent': GetUserAgent(),
                  },
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
}
