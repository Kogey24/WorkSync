// lib/Models/Permissions.dart

class user {
  final String? phonenumber;
  final double? latitude;
  final double? longitude;
  final bool? granted;

  user({this.phonenumber, this.latitude, this.longitude, this.granted = false});
  user copyWith({
    String? phonenumber,
    double? latitude,
    double? longitude,
    bool? granted,
  }) {
    return user(
      phonenumber: phonenumber ?? this.phonenumber,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      granted: granted ?? this.granted,
    );
  }
}
