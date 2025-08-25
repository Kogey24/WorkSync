import 'dart:io';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:work_sync/Models/clockin.dart';

final clockInProvider = StateNotifierProvider<ClockInNotifier, bool>(
  (ref) => ClockInNotifier(),
);

class ClockInNotifier extends StateNotifier<bool> {
  ClockInNotifier() : super(false);

  // ✅ use the correct endpoint
  final String apiUrl = "https://clockin.nexoratech.co.ke/api/staff/clock-in";

  Future<void> clockIn(ClockIn request) async {
    try {
      state = true;

      var uri = Uri.parse(apiUrl);
      var multipartReq = http.MultipartRequest("POST", uri);

      // Fields
      multipartReq.fields['mobile'] = request.mobile;
      multipartReq.fields['latitude'] = request.latitude.toString();
      multipartReq.fields['longitude'] = request.longitude.toString();

      // ✅ Attach image (jpg/png works automatically)
      if (request.image.isNotEmpty && File(request.image).existsSync()) {
        multipartReq.files.add(
          await http.MultipartFile.fromPath(
            "image",
            request.image,
            contentType: MediaType("image", "jpeg"), // force jpeg
          ),
        );
      } else {
        throw Exception("No valid image file found at ${request.image}");
      }

      var streamedResponse = await multipartReq.send();
      var responseBody = await streamedResponse.stream.bytesToString();

      if (streamedResponse.statusCode == 200 ||
          streamedResponse.statusCode == 201) {
        print("✅ Clock-in success!");
        print("Response: $responseBody");
      } else {
        print("❌ Clock-in failed. Status: ${streamedResponse.statusCode}");
        print("Response: $responseBody");
      }
    } catch (e) {
      print("⚠️ Error during clock-in: $e");
    } finally {
      state = false;
    }
  }
}
