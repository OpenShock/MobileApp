import 'package:open_shock/utils/OpenShockAPI.dart';

class OwnShocker {
  final String id;
  final String name;
  final String createdOn;
  final bool isPaused;

  // Constructor with named parameters
  OwnShocker({
    required this.id,
    required this.name,
    required this.createdOn,
    required this.isPaused,
  });

  // Factory constructor to create an instance from JSON
  factory OwnShocker.fromJson(Map<String, dynamic> json) {
    return OwnShocker(
      id: json['id'] as String,
      name: json['name'] as String,
      createdOn: json['createdOn'] as String,
      isPaused: json['isPaused'] as bool,
    );
  }

  Future<bool> shock(Openshockapi api, int int, int dur) async {
    return api.sendControlSignal(this.id, int, dur, "Shock");
  }

  Future<bool> beep(Openshockapi api, int int, int dur) async {
    return api.sendControlSignal(this.id, int, dur, "Sound");
  }

  Future<bool> vibrate(Openshockapi api, int int, int dur) async {
    return api.sendControlSignal(this.id, int, dur, "Vibrate");
  }
}
