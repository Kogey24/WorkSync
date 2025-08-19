class Staff {
  final int id;
  final String name;
  final String mobile;

  Staff({required this.id, required this.name, required this.mobile});

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
    id: json['id'] as int,
    name: json['name'] as String,
    mobile: json['mobile'] as String,
  );
}

class LoginResponse {
  final bool hasActiveClockin;
  final Staff staff;

  LoginResponse({required this.hasActiveClockin, required this.staff});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    hasActiveClockin: json['has_active_clockin'] as bool,
    staff: Staff.fromJson(json['staff'] as Map<String, dynamic>),
  );
}
