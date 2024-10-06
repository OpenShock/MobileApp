import 'BaseShocker.dart';

class SharedUserShocker extends BaseShocker {
  final Map<String, bool> permissions;
  final Map<String, dynamic> limits;

  SharedUserShocker({
    required String id,
    required String name,
    required bool isPaused,
    required this.permissions,
    required this.limits,
  }) : super(id: id, name: name, isPaused: isPaused);

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
}
