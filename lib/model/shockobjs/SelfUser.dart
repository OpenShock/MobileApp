// Definition of the SelfUser class
class SelfUser {
  final String id;
  final String name;
  final String email;
  final String image;
  final String rank;

  // Constructor with named parameters
  SelfUser({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
    required this.rank,
  });

  // Factory constructor to create an instance from JSON
  factory SelfUser.fromJson(Map<String, dynamic> json) {
    print('Image: ' + json['image']);
    return SelfUser(
      id: json['id'] as String,
      name: json['name'] as String,
      email: json['email'] as String,
      image: json['image'] as String,
      rank: json['rank'] as String,
    );
  }
}
