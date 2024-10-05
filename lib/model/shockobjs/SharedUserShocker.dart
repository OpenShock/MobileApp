import 'package:open_shock/utils/OpenShockAPI.dart';

class SharedUserShocker {
  final String id;
  final String name;
  final bool isPaused;
  final Map<String, bool> permissions;
  final Map<String, dynamic> limits;

  SharedUserShocker({
    required this.id,
    required this.name,
    required this.isPaused,
    required this.permissions,
    required this.limits,
  });

  factory SharedUserShocker.fromJson(Map<String, dynamic> json) {
    return SharedUserShocker(
      id: json['id'] as String,
      name: json['name'] as String,
      isPaused: json['isPaused'] as bool,
      permissions: Map<String, bool>.from(json['permissions']),
      limits: Map<String, dynamic>.from(json['limits']),
    );
  }

  static List<SharedUserShocker> listFromJSON(List<dynamic> jsonList) {
    return jsonList
        .map((json) => SharedUserShocker.fromJson(json as Map<String, dynamic>))
        .toList();
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
