import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:work_sync/Models/clockin.dart';

final clockInProvider = StateNotifierProvider<ClockInNotifier, bool>(
  (ref) => ClockInNotifier(),
);

class ClockInNotifier extends StateNotifier<bool> {
  ClockInNotifier() : super(false);

  final String apiUrl = "https://clockin.nexoratech.co.ke/api/staff/clock-in";

  Future<void> clockIn(ClockIn request) async {
    try {
      state = true; // loading

      var uri = Uri.parse(apiUrl);
      var multipartReq = http.MultipartRequest("POST", uri);

      // Add text fields
      multipartReq.fields['mobile'] = request.mobile;
      multipartReq.fields['latitude'] = request.latitude.toString();
      multipartReq.fields['longitude'] = request.longitude.toString();

      // Attach the image file
      if (request.image.isNotEmpty && File(request.image).existsSync()) {
        multipartReq.files.add(
          await http.MultipartFile.fromPath("image", request.image),
        );
      } else {
        throw Exception("No valid image file found at ${request.image}");
      }

      // Send the request
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
      state = false; // stop loading
    }
  }
}
