// providers/clockin_provider.dart
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:work_sync/Models/permissions.dart';

final clockInProvider =
    StateNotifierProvider<ClockInNotifier, AsyncValue<ClockInRequest?>>((ref) {
      return ClockInNotifier();
    });

class ClockInNotifier extends StateNotifier<AsyncValue<ClockInRequest?>> {
  ClockInNotifier() : super(const AsyncValue.data(null));

  void initialize(int staffId, int siteId) {
    state = AsyncValue.data(
      ClockInRequest(
        staffId: staffId,
        siteId: siteId,
        clockIn: DateTime.now().toIso8601String(),
        clockInLat: "",
        clockInLng: "",
        clockInImage: "",
        updatedAt: DateTime.now().toIso8601String(),
        createdAt: DateTime.now().toIso8601String(),
        id: 0,
        imagePath: "",
      ),
    );
  }

  Future<ClockInRequest?> sendClockIn(ClockInRequest request) async {
    state = const AsyncValue.loading();
    try {
      // 1. update with location
      var updatedRequest = await updateClockInWithLocation(request);

      // 2. update with image
      updatedRequest = await takePicture(updatedRequest);

      // 3. Now post to API
      final url = Uri.parse(
        "https://clockin.nexoratech.co.ke/api/staff/clock-in",
      );

      final resp = await http.post(
        url,
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(updatedRequest.toJson()),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        final jsonMap = jsonDecode(resp.body) as Map<String, dynamic>;
        final attendance = ClockInRequest.fromJson(jsonMap);
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

  Future<ClockInRequest> updateClockInWithLocation(
    ClockInRequest request,
  ) async {
    try {
      // ✅ Request permission if not granted
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.deniedForever ||
          permission == LocationPermission.denied) {
        throw Exception("Location permissions are denied");
      }

      // ✅ Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // ✅ Return updated request
      return request.copyWith(
        clockInLat: position.latitude.toString(),
        clockInLng: position.longitude.toString(),
      );
    } catch (e) {
      throw Exception("Failed to get location: $e");
    }
  }

  // Pick image from camera

  Future<ClockInRequest> takePicture(ClockInRequest request) async {
    try {
      // ✅ Request camera permission
      var status = await Permission.camera.status;
      if (status.isDenied) {
        status = await Permission.camera.request();
      }

      if (status.isPermanentlyDenied) {
        throw Exception(
          "Camera permission permanently denied. Please enable it in settings.",
        );
      }

      if (!status.isGranted) {
        throw Exception("Camera permission not granted");
      }

      // ✅ Open camera after permission granted
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.camera,
        imageQuality: 80, // optional: compress
      );

      if (pickedFile != null) {
        return request.copyWith(imagePath: pickedFile.path);
      }

      return request; // if no picture taken, return unchanged
    } catch (e) {
      throw Exception("Failed to take picture: $e");
    }
  }
}
