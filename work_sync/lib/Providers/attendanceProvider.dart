import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:work_sync/Models/attendance.dart';
import 'package:work_sync/Providers/login_provider.dart';

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AsyncValue<Attendance?>>((ref) {
      return AttendanceNotifier(ref);
    });

class AttendanceNotifier extends StateNotifier<AsyncValue<Attendance?>> {
  final Ref ref;

  AttendanceNotifier(this.ref) : super(const AsyncValue.data(null));

  Future<Attendance?> fetchAttendance() async {
    final loginState = ref.read(loginProvider);
    final staffId = loginState.value?.staff.id;

    if (staffId == null) {
      state = const AsyncValue.error(
        "No staffId found. Please login first.",
        StackTrace.empty,
      );
      return null;
    }

    debugPrint("Fetching attendance for staffId: $staffId ...");
    state = const AsyncValue.loading();

    try {
      final url = Uri.parse(
        "https://clockin.nexoratech.co.ke/api/staff/$staffId/attendance",
      );

      final resp = await http.get(url);
      debugPrint("Attendance response: ${resp.body}");

      if (resp.statusCode == 200) {
        final jsonMap = jsonDecode(resp.body) as Map<String, dynamic>;
        final attendance = Attendance.fromJson(jsonMap);
        state = AsyncValue.data(attendance);
        return attendance;
      } else {
        state = AsyncValue.error(
          "Error: ${resp.statusCode}",
          StackTrace.current,
        );
        return null;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}
