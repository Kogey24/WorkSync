import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:work_sync/Pages/loginpage.dart';
import 'package:work_sync/Providers/login_provider.dart';

class Clockout extends ConsumerStatefulWidget {
  const Clockout({super.key});

  @override
  ConsumerState<Clockout> createState() => _ClockoutState();
}

class _ClockoutState extends ConsumerState<Clockout> {
  File? _image;
  bool _loading = false;

  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  /// Take picture
  Future<void> _takePicture() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  /// Get location
  Future<void> _getLocation() async {
    final status = await Permission.location.request();

    if (status.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
        });
      } catch (e) {
        debugPrint("Failed to get location: $e");
      }
    } else if (status.isPermanentlyDenied) {
      await openAppSettings();
    }
  }

  /// Perform clock-in request (multipart upload)
  Future<void> _clockIn() async {
    if (_image == null || _latitude == null || _longitude == null) {
      _showError("Please capture a picture and allow location first.");
      return;
    }

    setState(() => _loading = true);

    try {
      final dio = Dio();
      final loginState = ref.watch(loginProvider);

      final mobile = loginState.value?.staff.mobile ?? "";

      final formData = FormData.fromMap({
        "mobile": mobile,
        "latitude": _latitude.toString(),
        "longitude": _longitude.toString(),
        "image": await MultipartFile.fromFile(
          _image!.path,
          filename: _image!.path.split('/').last,
        ),
      });

      debugPrint("👉 Sending to API: ${formData.fields}");
      debugPrint("👉 File attached: ${_image!.path}");

      final response = await dio.post(
        "https://clockin.nexoratech.co.ke/api/staff/clock-out",
        data: formData,
        options: Options(
          headers: {"Accept": "application/json"},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      debugPrint("✅ API Raw Response: ${response.data}");

      if (response.statusCode == 200) {
        final data = response.data;
        final message = data["message"]?.toString() ?? "";

        if (message.toLowerCase().contains("successful")) {
          // ✅ Extract clock_in from API
          final apiClockIn = data["data"]?["clock_in"];
          DateTime? parsedClockIn;

          if (apiClockIn != null && apiClockIn.toString().isNotEmpty) {
            try {
              parsedClockIn = DateTime.parse(apiClockIn);
            } catch (e) {
              debugPrint("⚠️ Failed to parse clock_in, fallback to now");
              parsedClockIn = DateTime.now();
            }
          } else {
            parsedClockIn = DateTime.now();
          }

          final formattedTime =
              "${parsedClockIn.hour.toString().padLeft(2, '0')}:${parsedClockIn.minute.toString().padLeft(2, '0')}";

          // ✅ Show success Snackbar
          final snackBar = SnackBar(
            elevation: 0,
            behavior: SnackBarBehavior.floating,
            backgroundColor: Colors.transparent,
            content: AwesomeSnackbarContent(
              title: 'Success!',
              message: "Clock out successful at $formattedTime",
              contentType: ContentType.success,
            ),
          );

          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(snackBar);

          // ✅ Navigate to Clockoutpage with API clock_in time
          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => Loginpage()),
            );
          });
        } else {
          _showError(
            message.isNotEmpty
                ? message
                : "Clock-out failed. Please try again.",
          );
        }
      } else {
        _showError(
          "Clock-out failed [${response.statusCode}]: ${response.data}",
        );
      }
    } catch (e) {
      debugPrint("❌ Clock-out failed: $e");
      _showError("Error: $e");
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showError(String message) {
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Error!',
        message: message,
        contentType: ContentType.failure,
      ),
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Clock Out")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.purple, width: 4.0),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _image != null
                        ? Image.file(_image!, height: 200)
                        : const Icon(
                            Icons.camera_alt,
                            size: 100,
                            color: Colors.grey,
                          ),
                    GFButton(
                      onPressed: _takePicture,
                      text: "Take a picture",
                      shape: GFButtonShape.pills,
                      color: Colors.purple,
                      fullWidthButton: true,
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.only(top: 12),
              child: DataTable(
                headingRowColor: WidgetStateColor.resolveWith(
                  (states) => Colors.purple,
                ),
                border: TableBorder.all(color: Colors.purple, width: 1),
                columns: const [
                  DataColumn(
                    label: Text(
                      "Name",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      "Value",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFFFD700),
                      ),
                    ),
                  ),
                ],
                rows: [
                  DataRow(
                    cells: [
                      const DataCell(Text("Time")),
                      DataCell(
                        Text(
                          "${TimeOfDay.now().hour.toString().padLeft(2, '0')}:${TimeOfDay.now().minute.toString().padLeft(2, '0')}",
                        ),
                      ),
                    ],
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text("Latitude")),
                      DataCell(Text(_latitude?.toString() ?? "Not available")),
                    ],
                  ),
                  DataRow(
                    cells: [
                      const DataCell(Text("Longitude")),
                      DataCell(Text(_longitude?.toString() ?? "Not available")),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(30, 30, 30, 15),
              child: GFButton(
                onPressed: _loading ? null : _clockIn,
                text: _loading ? "Clocking out..." : "Clock out",
                shape: GFButtonShape.pills,
                color: Colors.purple,
                fullWidthButton: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
