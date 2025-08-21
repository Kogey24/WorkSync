import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:work_sync/Models/clockin.dart';

final clockInProvider =
    StateNotifierProvider<ClockInNotifier, AsyncValue<ClockInRequest?>>(
      (ref) => ClockInNotifier(),
    );

class ClockInNotifier extends StateNotifier<AsyncValue<ClockInRequest?>> {
  ClockInNotifier() : super(const AsyncValue.data(null));

  Future<void> postClockIn(ClockInRequest request) async {
    state = const AsyncValue.loading();

    try {
      // Example API endpoint (replace with your real one)
      final url = Uri.parse(
        "https://clockin.nexoratech.co.ke/api/staff/clock-in",
      );

      final response = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Successfully clocked in
        state = AsyncValue.data(request);
      } else {
        state = AsyncValue.error(
          "Failed: ${response.statusCode} - ${response.body}",
          StackTrace.current,
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
