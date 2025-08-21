import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:work_sync/Models/clockin.dart';
import 'package:work_sync/Providers/permission_provider.dart';
import 'clockoutpage.dart';

class ClockInPage extends ConsumerStatefulWidget {
  const ClockInPage({super.key});

  @override
  ConsumerState<ClockInPage> createState() => _ClockInPageState();
}

class _ClockInPageState extends ConsumerState<ClockInPage> {
  File? _image;
  bool _loading = false;

  double? _latitude;
  double? _longitude;

  @override
  void initState() {
    super.initState();
    _getLocation(); // fetch as soon as page loads
  }

  // Take picture
  Future<void> _takePicture() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
        debugPrint("Image selected: ${_image!.path}");
      });
    }
  }

  // Request location permission and get coordinates
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

  /// Bundle into ClockInRequest
  ClockInRequest _createClockInRequest() {
    if (_image == null || _latitude == null || _longitude == null) {
      throw Exception("Image or location not available yet");
    }

    final now = DateTime.now();

    return ClockInRequest(
      id: 0, // or whatever type your backend expects
      staffId: 1,
      siteId: 1,
      clockIn: now.toIso8601String(), // convert DateTime → String
      clockInLat: _latitude.toString(), // convert double → String
      clockInLng: _longitude.toString(),
      clockInImage: _image!.path,
      updatedAt: now.toIso8601String(),
      createdAt: now.toIso8601String(),
    );
  }

  // Clock in
  Future<void> _clockIn() async {
    setState(() => _loading = true);

    try {
      final request = _createClockInRequest();
      debugPrint("ClockInRequest prepared: ${request.toJson()}");

      // Post the clock-in request using provider
      await ref.read(clockInProvider.notifier).postClockIn(request);

      final clockInState = ref.read(clockInProvider);

      clockInState.when(
        data: (data) {
          if (data != null) {
            // Navigate when success
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) =>
                    Clockoutpage(clockInTime: DateTime.parse(request.clockIn)),
              ),
            );

            // Show snackbar
            final clockInDate = DateTime.parse(request.clockIn);
            final formattedTime =
                "${clockInDate.hour.toString().padLeft(2, '0')}:${clockInDate.minute.toString().padLeft(2, '0')}";

            final snackBar = SnackBar(
              elevation: 0,
              behavior: SnackBarBehavior.floating,
              backgroundColor: Colors.transparent,
              content: AwesomeSnackbarContent(
                title: 'Success!',
                message: "Clock in successful at $formattedTime",
                contentType: ContentType.success,
              ),
            );

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(snackBar);
          }
        },
        error: (err, _) {
          _showError(err.toString());
        },
        loading: () {
          debugPrint("Clocking in...");
        },
      );
    } catch (e) {
      debugPrint("Clock-in failed: $e");
      _showError(e.toString());
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
      appBar: AppBar(title: const Text("Clock In")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                margin: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.purple,
                    style: BorderStyle.solid,
                    width: 4.0,
                  ),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                margin: const EdgeInsets.fromLTRB(0, 12, 0, 0),
                child: DataTable(
                  headingRowColor: WidgetStateColor.resolveWith(
                    (states) => Colors.purple,
                  ),
                  border: TableBorder.all(
                    color: Colors.purple,
                    style: BorderStyle.solid,
                    width: 1,
                  ),
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
                        "Coordinates",
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
                        DataCell(
                          Text(
                            _latitude != null
                                ? _latitude.toString()
                                : "Not available",
                          ),
                        ),
                      ],
                    ),
                    DataRow(
                      cells: [
                        const DataCell(Text("Longitude")),
                        DataCell(
                          Text(
                            _longitude != null
                                ? _longitude.toString()
                                : "Not available",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(30, 30, 30, 15),
                child: GFButton(
                  onPressed: _loading ? null : _clockIn,
                  text: _loading ? "Clocking In..." : "Clock In",
                  shape: GFButtonShape.pills,
                  color: Colors.purple,
                  fullWidthButton: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
