import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:riverpod/riverpod.dart';
import 'package:work_sync/Models/Permissions.dart';

final userProvider = StateNotifierProvider<UserNotifier, user>(
  (ref) => UserNotifier(),
);

class UserNotifier extends StateNotifier<user> {
  UserNotifier()
    : super(
        user(phonenumber: "Error", latitude: 0, longitude: 0, granted: false),
      );

  Future<void> loginUser(String phonenumber) async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      await _updateLocation(phonenumber);
    } else {
      state = state.copyWith(
        phonenumber: phonenumber,
        latitude: null,
        longitude: null,
        granted: false,
      );

      if (status.isPermanentlyDenied) {
        openAppSettings();
      }
    }
  }

  Future<void> _updateLocation(String phonenumber) async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      state = state.copyWith(
        phonenumber: phonenumber,
        latitude: position.latitude,
        longitude: position.longitude,
        granted: true,
      );
    } catch (e) {
      // Handle location errors
      state = state.copyWith(phonenumber: phonenumber, granted: false);
    }
  }
}
