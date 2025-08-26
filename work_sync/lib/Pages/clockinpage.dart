import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:image_picker/image_picker.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:dio/dio.dart';
import 'package:work_sync/Models/sites.dart';
import 'package:work_sync/Pages/clockoutpage.dart';
import 'package:work_sync/Providers/login_provider.dart';
import 'package:work_sync/Providers/sites_provider.dart';

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
  Site? selectedSite;

  @override
  void initState() {
    super.initState();
    _getLocation();

    Future.microtask(() => ref.read(siteProvider.notifier).fetchSites());
  }

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

  Future<void> _clockIn() async {
    if (_image == null ||
        _latitude == null ||
        _longitude == null ||
        selectedSite == null) {
      _showError(
        "Please capture a picture, select a site, and allow location first.",
      );
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
        "site_id": selectedSite!.id.toString(),
        "image": await MultipartFile.fromFile(
          _image!.path,
          filename: _image!.path.split('/').last,
        ),
      });

      debugPrint("👉 Sending to API: ${formData.fields}");
      debugPrint(
        "👉 Selected site: ${selectedSite?.id} - ${selectedSite?.name}",
      );
      debugPrint("👉 File attached: ${_image!.path}");

      final response = await dio.post(
        "https://clockin.nexoratech.co.ke/api/staff/clock-in",
        data: formData,
        options: Options(
          headers: {"Accept": "application/json"},
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      debugPrint("✅ API Raw Response: ${response.data}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = response.data;
        final message = data["message"]?.toString() ?? "";

        if (message.toLowerCase().contains("successful")) {
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

          Future.delayed(const Duration(seconds: 1), () {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => Clockoutpage(clockInTime: parsedClockIn!),
              ),
            );
          });
        } else {
          _showError(
            message.isNotEmpty ? message : "Clock-in failed. Please try again.",
          );
        }
      } else {
        _showError(
          "Clock-in failed [${response.statusCode}]: ${response.data}",
        );
      }
    } catch (e) {
      debugPrint("❌ Clock-in failed: $e");
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
    final sitesState = ref.watch(siteProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Clock In")),
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
              height: 50,
              width: MediaQuery.of(context).size.width,
              margin: const EdgeInsets.all(20),
              child: DropdownButtonHideUnderline(
                child: GFDropdown(
                  padding: const EdgeInsets.all(10),
                  borderRadius: BorderRadius.circular(5),
                  border: const BorderSide(color: Colors.black12, width: 1),
                  dropdownButtonColor: Colors.white,
                  hint: const Text("Select Site"),
                  value: selectedSite,
                  onChanged: (newValue) {
                    setState(() {
                      selectedSite = newValue;
                    });
                  },
                  items: sitesState.when(
                    data: (sites) => sites
                        .map(
                          (site) => DropdownMenuItem<Site>(
                            value: site,
                            child: Text(site.name),
                          ),
                        )
                        .toList(),
                    loading: () => [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("Loading sites..."),
                      ),
                    ],
                    error: (err, _) => [
                      const DropdownMenuItem(
                        value: null,
                        child: Text("Error loading sites"),
                      ),
                    ],
                  ),
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
                text: _loading ? "Clocking In..." : "Clock In",
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
