import 'dart:convert';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:work_sync/Models/sites.dart';

final siteProvider =
    StateNotifierProvider<SiteNotifier, AsyncValue<List<Site>>>((ref) {
      return SiteNotifier();
    });

class SiteNotifier extends StateNotifier<AsyncValue<List<Site>>> {
  SiteNotifier() : super(const AsyncValue.loading());

  Future<void> fetchSites() async {
    try {
      state = const AsyncValue.loading();

      final url = Uri.parse("https://clockin.nexoratech.co.ke/api/staff/sites");
      final response = await http.get(url);
      debugPrint("Sites response: ${response.body}");

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);

        if (decoded is Map<String, dynamic> && decoded.containsKey("sites")) {
          final List sitesJson = decoded["sites"];
          final sites = sitesJson.map((e) => Site.fromJson(e)).toList();
          state = AsyncValue.data(sites);
        } else {
          state = AsyncValue.error(
            "Invalid response format",
            StackTrace.current,
          );
        }
      } else {
        state = AsyncValue.error(
          "Failed to fetch sites: ${response.statusCode}",
          StackTrace.current,
        );
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
