import 'BaseShocker.dart';

class OwnShocker extends BaseShocker {
  final String createdOn;

  OwnShocker({
    required String id,
    required String name,
    required this.createdOn,
    required bool isPaused,
  }) : super(id: id, name: name, isPaused: isPaused);

  factory OwnShocker.fromJson(Map<String, dynamic> json) {
    return OwnShocker(
      id: json['id'] as String,
      name: json['name'] as String,
      createdOn: json['createdOn'] as String,
      isPaused: json['isPaused'] as bool,
    );
  }
}
