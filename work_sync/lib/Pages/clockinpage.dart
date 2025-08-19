import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:getwidget/getwidget.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:work_sync/Pages/clockoutpage.dart';
import 'package:work_sync/Providers/permission_provider.dart';

class ClockInPage extends ConsumerStatefulWidget {
  const ClockInPage({super.key});

  @override
  ConsumerState<ClockInPage> createState() => _ClockInPageState();
}

class _ClockInPageState extends ConsumerState<ClockInPage> {
  bool _loading = false;

  // Clock in
  Future<void> _clockIn() async {
    setState(() => _loading = true);

    final notifier = ref.read(clockInProvider.notifier);
    final state = ref.read(clockInProvider);

    final request = state.value;
    if (request == null) {
      setState(() => _loading = false);
      return;
    }

    // Update with location before sending
    final updatedRequest = await notifier.updateClockInWithLocation(request);
    final result = await notifier.sendClockIn(updatedRequest);

    if (result != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => Clockoutpage(clockInTime: DateTime.now()),
        ),
      );

      // Show success message
      final now = TimeOfDay.now();
      final formattedTime =
          "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";

      setState(() => _loading = false);

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
    } else {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userState = ref.watch(clockInProvider); // 👈 Watch provider state
    final request = userState.value;

    return Scaffold(
      appBar: AppBar(title: const Text("Clock In")),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              // Camera and preview
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
                      request?.imagePath != null &&
                              request!.imagePath.isNotEmpty
                          ? Image.file(File(request.imagePath), height: 200)
                          : const Icon(
                              Icons.camera_alt,
                              size: 100,
                              color: Colors.grey,
                            ),
                      GFButton(
                        onPressed: () async {
                          try {
                            final updatedRequest = await ref
                                .read(clockInProvider.notifier)
                                .takePicture(request!);

                            // ✅ Safe: updatedRequest is always a valid ClockInRequest
                            print("Image path: ${updatedRequest.imagePath}");
                          } catch (e) {
                            // Handle gracefully
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(e.toString())),
                            );
                          }
                        },
                        text: "Take a picture",
                        shape: GFButtonShape.pills,
                        color: Colors.purple,
                        fullWidthButton: true,
                      ),
                    ],
                  ),
                ),
              ),

              // DataTable with coords
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
                        DataCell(
                          Text(
                            request?.clockInLat.isNotEmpty == true
                                ? request!.clockInLat
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
                            request?.clockInLng.isNotEmpty == true
                                ? request!.clockInLng
                                : "Not available",
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Submit button
              Container(
                margin: const EdgeInsets.fromLTRB(30, 30, 30, 15),
                child: GFButton(
                  onPressed: () async {
                    await _clockIn();
                  },
                  text: _loading ? "Loading..." : "Clock In",
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
