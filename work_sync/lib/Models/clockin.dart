class ClockInRequest {
  final int staffId;
  final int siteId;
  final String clockIn; // ISO8601 string
  final String clockInLat;
  final String clockInLng;
  final String clockInImage;
  final String updatedAt; // ISO8601 string
  final String createdAt; // ISO8601 string
  final int id;

  ClockInRequest({
    required this.staffId,
    required this.siteId,
    required this.clockIn,
    required this.clockInLat,
    required this.clockInLng,
    required this.clockInImage,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
  });

  /// Factory to create a ClockIn object from JSON
  factory ClockInRequest.fromJson(Map<String, dynamic> json) {
    return ClockInRequest(
      staffId: json['staff_id'] ?? 0,
      siteId: json['site_id'] ?? 0,
      clockIn: json['clock_in'] ?? "",
      clockInLat: json['clock_in_lat'] ?? "",
      clockInLng: json['clock_in_lng'] ?? "",
      clockInImage: json['clock_in_image'] ?? "",
      updatedAt: json['updated_at'] ?? "",
      createdAt: json['created_at'] ?? "",
      id: json['id'] ?? 0,
    );
  }

  /// Convert ClockIn object back to JSON
  Map<String, dynamic> toJson() {
    return {
      'staff_id': staffId,
      'site_id': siteId,
      'clock_in': clockIn,
      'clock_in_lat': clockInLat,
      'clock_in_lng': clockInLng,
      'clock_in_image': clockInImage,
      'updated_at': updatedAt,
      'created_at': createdAt,
      'id': id,
    };
  }

  ClockInRequest copyWith({
    int? staffId,
    int? siteId,
    String? clockIn,
    String? clockInLat,
    String? clockInLng,
    String? clockInImage,
    String? updatedAt,
    String? createdAt,
    int? id,
  }) {
    return ClockInRequest(
      staffId: staffId ?? this.staffId,
      siteId: siteId ?? this.siteId,
      clockIn: clockIn ?? this.clockIn,
      clockInLat: clockInLat ?? this.clockInLat,
      clockInLng: clockInLng ?? this.clockInLng,
      clockInImage: clockInImage ?? this.clockInImage,
      updatedAt: updatedAt ?? this.updatedAt,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
    );
  }
}
