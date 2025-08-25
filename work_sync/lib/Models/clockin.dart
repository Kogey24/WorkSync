class ClockIn {
  final String mobile;
  final double latitude;
  final double longitude;
  final String image;

  ClockIn({
    required this.mobile,
    required this.latitude,
    required this.longitude,
    required this.image,
  });

  /// Convert to JSON for API
  Map<String, dynamic> toJson() {
    return {
      "mobile": mobile,
      "latitude": latitude,
      "longitude": longitude,
      "image": image,
    };
  }

  /// Parse from JSON response
  factory ClockIn.fromJson(Map<String, dynamic> json) {
    return ClockIn(
      mobile: json["mobile"] ?? "",
      latitude: (json["latitude"] is String)
          ? double.tryParse(json["latitude"]) ?? 0.0
          : json["latitude"]?.toDouble() ?? 0.0,
      longitude: (json["longitude"] is String)
          ? double.tryParse(json["longitude"]) ?? 0.0
          : json["longitude"]?.toDouble() ?? 0.0,
      image: json["image"] ?? "",
    );
  }

  /// CopyWith for immutability
  ClockIn copyWith({
    String? mobile,
    double? latitude,
    double? longitude,
    String? image,
  }) {
    return ClockIn(
      mobile: mobile ?? this.mobile,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      image: image ?? this.image,
    );
  }

  @override
  String toString() {
    return "ClockIn(mobile: $mobile, latitude: $latitude, longitude: $longitude, image: $image)";
  }
}
