import 'dart:async';
import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:work_sync/Pages/loginpage.dart';

class Clockoutpage extends StatefulWidget {
  final DateTime clockInTime;
  const Clockoutpage({super.key, required this.clockInTime});

  @override
  State<Clockoutpage> createState() => _ClockoutpageState();
}

class _ClockoutpageState extends State<Clockoutpage> {
  late Timer _timer;
  late Duration _elapsedTime;

  @override
  void initState() {
    super.initState();
    _elapsedTime = DateTime.now().difference(widget.clockInTime);

    // Update every second
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = DateTime.now().difference(widget.clockInTime);
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  void _clockOut() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const Loginpage()));
    final snackBar = SnackBar(
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      content: AwesomeSnackbarContent(
        title: 'Clocked Out!',
        message:
            "You worked for ${_formatDuration(_elapsedTime)} hours today. Great job!",
        contentType: ContentType.warning,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Total Hours Worked",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),

            // Live Timer
            Text(
              _formatDuration(_elapsedTime),
              style: TextStyle(
                fontSize: 50,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),

            SizedBox(height: 50),

            // Clock Out Button
            GFButton(
              onPressed: _clockOut,
              text: "Clock Out",
              shape: GFButtonShape.pills,
              color: Colors.red,
              fullWidthButton: true,
              size: GFSize.LARGE,
            ),
          ],
        ),
      ),
    );
  }
}
