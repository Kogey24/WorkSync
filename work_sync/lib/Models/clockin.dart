class ClockIn {
  final String mobile;
  final double latitude;
  final double longitude;
  final String image;
  final int siteId;

  ClockIn({
    required this.mobile,
    required this.latitude,
    required this.longitude,
    required this.image,
    required this.siteId,
  });

  Map<String, dynamic> toJson() {
    return {
      "mobile": mobile,
      "latitude": latitude,
      "longitude": longitude,
      "image": image,
      "site_id": siteId,
    };
  }

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
      siteId: json["site_id"] is String
          ? int.tryParse(json["site_id"]) ?? 0
          : json["site_id"] ?? 0,
    );
  }

  ClockIn copyWith({
    String? mobile,
    double? latitude,
    double? longitude,
    String? image,
    int? siteId,
  }) {
    return ClockIn(
      mobile: mobile ?? this.mobile,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      image: image ?? this.image,
      siteId: siteId ?? this.siteId,
    );
  }

  @override
  String toString() {
    return "ClockIn(mobile: $mobile, latitude: $latitude, longitude: $longitude, image: $image, siteId: $siteId)";
  }
}
