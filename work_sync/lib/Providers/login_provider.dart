import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:work_sync/Models/staff.dart';

final loginProvider =
    StateNotifierProvider<LoginNotifier, AsyncValue<LoginResponse?>>(
      (ref) => LoginNotifier(),
    );

class LoginNotifier extends StateNotifier<AsyncValue<LoginResponse?>> {
  LoginNotifier() : super(const AsyncValue.data(null));

  Future<LoginResponse?> loginUser(String phone, {http.Client? client}) async {
    state = const AsyncValue.loading();
    final c = client ?? http.Client();

    try {
      final uri = Uri.parse(
        'https://clockin.nexoratech.co.ke/api/staff/check?mobile=$phone',
      );

      final resp = await c
          .get(uri, headers: {'Accept': 'application/json'})
          .timeout(const Duration(seconds: 15));
      debugPrint("Login response: ${resp.body}");

      if (resp.statusCode == 200) {
        final jsonMap = jsonDecode(resp.body) as Map<String, dynamic>;
        final login = LoginResponse.fromJson(jsonMap);
        state = AsyncValue.data(login);
        return login;
      } else {
        final message = 'HTTP ${resp.statusCode}: ${resp.reasonPhrase ?? ""}';
        state = AsyncValue.error(message, StackTrace.current);
        return null;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    } finally {
      if (client == null) c.close();
    }
  }

  void clear() => state = const AsyncValue.data(null);
}
