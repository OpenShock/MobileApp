import 'package:open_shock/utils/OpenShockAPI.dart';
import 'package:open_shock/utils/OpenShockWS.dart';

abstract class BaseShocker {
  final String id;
  final String name;
  final bool isPaused;

  BaseShocker({
    required this.id,
    required this.name,
    required this.isPaused,
  });

  Future<bool> shock(Openshockapi api, int intensity, int duration) async {
    return api.sendControlSignal(this.id, intensity, duration, "Shock");
  }

  Future<bool> beep(Openshockapi api, int intensity, int duration) async {
    return api.sendControlSignal(this.id, intensity, duration, "Sound");
  }

  Future<bool> vibrate(Openshockapi api, int intensity, int duration) async {
    return api.sendControlSignal(this.id, intensity, duration, "Vibrate");
  }

  Future<bool> shockWS(OpenshockWS socket, int intensity, int duration) async {
    return socket.sendControlSignal(this.id, intensity, duration, 1);
  }

  Future<bool> beepWS(OpenshockWS socket, int intensity, int duration) async {
    return socket.sendControlSignal(this.id, intensity, duration, 3);
  }

  Future<bool> vibrateWS(
      OpenshockWS socket, int intensity, int duration) async {
    return socket.sendControlSignal(this.id, intensity, duration, 2);
  }
}
