import 'package:open_shock/model/shockobjs/SharedUserShocker.dart';

class SharedUserHub {
  final String id;
  final String name;
  final List<SharedUserShocker> shockers;

  SharedUserHub({
    required this.id,
    required this.name,
    required this.shockers,
  });

  factory SharedUserHub.fromJson(Map<String, dynamic> json) {
    var shockersFromJson = json['shockers'] as List<dynamic>;
    List<SharedUserShocker> shockerList =
        SharedUserShocker.listFromJSON(shockersFromJson);

    return SharedUserHub(
      id: json['id'] as String,
      name: json['name'] as String,
      shockers: shockerList,
    );
  }

  static List<SharedUserHub> listFromJSON(List<dynamic> jsonList) {
    return jsonList
        .map((json) => SharedUserHub.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
