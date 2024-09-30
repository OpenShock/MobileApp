import 'package:open_shock/model/shockobjs/SharedUserHub.dart';

class SharedUser {
  final String id;
  final String name;
  final String image;
  final List<SharedUserHub> devices;

  SharedUser({
    required this.id,
    required this.name,
    required this.image,
    required this.devices,
  });

  factory SharedUser.fromJson(Map<String, dynamic> json) {
    var devicesFromJson = json['devices'] as List<dynamic>;
    List<SharedUserHub> hubList = SharedUserHub.listFromJSON(devicesFromJson);

    return SharedUser(
      id: json['id'] as String,
      name: json['name'] as String,
      image: json['image'] as String,
      devices: hubList,
    );
  }

  static List<SharedUser> listFromJSON(List<dynamic> jsonList) {
    return jsonList
        .map((json) => SharedUser.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
