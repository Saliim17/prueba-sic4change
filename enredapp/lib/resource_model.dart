class Resource {
  String id;
  final String name;
  final String location;
  final String validity;
  final String type;
  final String? photo;
  final String? logo;

  Resource({
    this.id = '',
    required this.name,
    required this.location,
    required this.validity,
    required this.type,
    this.photo,
    this.logo,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      id: json['id'],
      name: json['name'],
      location: json['location'],
      validity: json['validity'],
      type: json['type'],
      photo: json['photo'] ?? '',
      logo: json['logo'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'location': location,
      'validity': validity,
      'type': type,
      'photo': photo ?? '',
      'logo': logo ?? '',
    };
  }

  @override
  String toString() {
    return 'Resource{name: $name, location: $location, validity: $validity, type: $type, photo: $photo, logo: $logo}';
  }
}