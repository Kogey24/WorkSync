import 'dart:convert';
import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:work_sync/Models/clockin.dart';

final clockInProvider =
    StateNotifierProvider<ClockInNotifier, AsyncValue<Map<String, dynamic>>>(
      (ref) => ClockInNotifier(),
    );

class ClockInNotifier extends StateNotifier<AsyncValue<Map<String, dynamic>>> {
  ClockInNotifier() : super(const AsyncValue.data({}));

  final String apiUrl = "https://clockin.sarl.co.ke/api/staff/clock-in";

  Future<Map<String, dynamic>?> clockIn(ClockIn request) async {
    state = const AsyncValue.loading();

    try {
      var uri = Uri.parse(apiUrl);
      var multipartReq = http.MultipartRequest("POST", uri);

      multipartReq.fields['mobile'] = request.mobile;
      multipartReq.fields['latitude'] = request.latitude.toString();
      multipartReq.fields['longitude'] = request.longitude.toString();

      if (request.image.isNotEmpty && File(request.image).existsSync()) {
        multipartReq.files.add(
          await http.MultipartFile.fromPath(
            "image",
            request.image,
            contentType: MediaType("image", "jpeg"),
          ),
        );
      } else {
        throw Exception("No valid image file found at ${request.image}");
      }

      var streamedResponse = await multipartReq.send();
      var responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody) as Map<String, dynamic>;
        state = AsyncValue.data(jsonResponse);
        return jsonResponse;
      } else {
        final error = "HTTP ${streamedResponse.statusCode}: $responseBody";
        state = AsyncValue.error(error, StackTrace.current);
        return null;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      return null;
    }
  }
}
