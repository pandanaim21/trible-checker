import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../db/database_helper.dart';

class DisplayPage extends StatefulWidget {
  final String qrData;
  final bool isTimeIn;

  const DisplayPage({super.key, required this.qrData, required this.isTimeIn});

  @override
  // ignore: library_private_types_in_public_api
  _DisplayPageState createState() => _DisplayPageState();
}

class _DisplayPageState extends State<DisplayPage> {
  final dbHelper = DatabaseHelper();

  @override
  Widget build(BuildContext context) {
    final currentTime = DateTime.now();
    final formattedTime = DateFormat('hh:mm a').format(currentTime);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'TRIBE CHECKER',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
          ),
        ),
        backgroundColor: Colors.red[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[400],
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  widget.isTimeIn ? 'TIME IN' : 'TIME OUT',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 5),
                AutoSizeText(
                  formattedTime,
                  style: TextStyle(
                      fontSize: 25,
                      color:
                          widget.isTimeIn ? Colors.green[800] : Colors.red[800],
                      fontWeight: FontWeight.bold),
                  maxLines: 1,
                ),
                const SizedBox(height: 30),
                const AutoSizeText(
                  'Scanned QR Code',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  maxLines: 1,
                ),
                const SizedBox(height: 10),
                AutoSizeText(
                  widget.qrData,
                  style: const TextStyle(fontSize: 18),
                  maxLines: 5,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                SizedBox(
                  height: 50,
                  width: 130,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      int currentTime = DateTime.now().millisecondsSinceEpoch;
                      int qrDataId = await dbHelper.insertQRData(
                          widget.qrData, currentTime, 0);

                      if (!widget.isTimeIn) {
                        await dbHelper.updateQRDataTimeOut(
                            qrDataId, currentTime);
                      }
                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    child: AutoSizeText(
                      widget.isTimeIn ? 'CONFIRM' : 'CONFIRM',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
