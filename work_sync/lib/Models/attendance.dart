class Attendance {
  final int id;
  final String clockIn;
  final String clockInLat;
  final String clockInLng;
  final double secondsElapsed;
  final String timeElapsed;

  Attendance({
    required this.id,
    required this.clockIn,
    required this.clockInLat,
    required this.clockInLng,
    required this.secondsElapsed,
    required this.timeElapsed,
  });

  // Factory constructor to create Attendance from JSON
  factory Attendance.fromJson(Map<String, dynamic> json) {
    return Attendance(
      id: json['id'] as int,
      clockIn: json['clock_in'] as String,
      clockInLat: json['clock_in_lat'] as String,
      clockInLng: json['clock_in_lng'] as String,
      secondsElapsed: (json['seconds_elapsed'] as num).toDouble(),
      timeElapsed: json['time_elapsed'] as String,
    );
  }

  // Method to convert Attendance back to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clock_in': clockIn,
      'clock_in_lat': clockInLat,
      'clock_in_lng': clockInLng,
      'seconds_elapsed': secondsElapsed,
      'time_elapsed': timeElapsed,
    };
  }
}
