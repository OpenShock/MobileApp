import 'package:open_shock/model/shockobjs/OwnShocker.dart';

class OwnHub {
  final String id;
  final String name;
  final String createdOn;
  final List<OwnShocker> shockers;

  // Constructor with named parameters
  OwnHub({
    required this.id,
    required this.name,
    required this.createdOn,
    required this.shockers,
  });

  // Factory constructor to create an instance from JSON
  factory OwnHub.fromJson(Map<String, dynamic> json) {
    // Map the shockers array to a list of OwnShocker objects
    var shockersFromJson = json['shockers'] as List<dynamic>;
    List<OwnShocker> shockerList = shockersFromJson
        .map((shockerJson) => OwnShocker.fromJson(shockerJson))
        .toList();

    return OwnHub(
      id: json['id'] as String,
      name: json['name'] as String,
      createdOn: json['createdOn'] as String,
      shockers: shockerList,
    );
  }

  // Static method to create a list of OwnHub instances from JSON
  static List<OwnHub> listFromJSON(List<dynamic> jsonList) {
    return jsonList
        .map((json) => OwnHub.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
