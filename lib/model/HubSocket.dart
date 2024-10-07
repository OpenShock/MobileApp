import 'dart:io';
import 'package:web_socket_channel/io.dart';

class HubSocket {
  IOWebSocketChannel? channel;

  Future<bool> connectToHub() async {
    try {
      await Socket.connect('10.10.10.10', 81, timeout: Duration(seconds: 2));
      channel = IOWebSocketChannel.connect('ws://10.10.10.10:81/ws');
      return true;
    } catch (e) {
      print('Error connecting to Hub WebSocket: $e');
      return false;
    }
  }

  void listenToMessages(Function(dynamic) onMessage) {
    channel?.stream.listen((message) {
      onMessage(message);
    });
  }

  void sendMessage(dynamic message) {
    channel?.sink.add(message);
  }

  void closeConnection() {
    channel?.sink.close();
  }
}
