class Site {
  final int id;
  final String name;
  final String address;
  final String latitude;
  final String longitude;
  final int radius;
  final DateTime createdAt;
  final DateTime updatedAt;

  Site({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.radius,
    required this.createdAt,
    required this.updatedAt,
  });

  Site copyWith({
    int? id,
    String? name,
    String? address,
    String? latitude,
    String? longitude,
    int? radius,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Site(
      id: id ?? this.id,
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      radius: radius ?? this.radius,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
      id: json['id'] as int,
      name: json['name'] as String,
      address: json['address'] as String,
      latitude: json['latitude'] as String,
      longitude: json['longitude'] as String,
      radius: json['radius'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'radius': radius,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
