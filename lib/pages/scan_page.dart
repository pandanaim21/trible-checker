import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'display_page.dart';
import '../db/database_helper.dart';
import 'package:encrypt_decrypt_plus/cipher/cipher.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _ScanPageState createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  //Decrypt QR CODE Secret Key
  final Cipher _cipher = Cipher(secretKey: "Tribe_Checker");
  QRViewController? controller;
  bool _isScanning = true;
  bool _isTimeIn = true; // A flag to determine if it's Time In or Time Out scan
  bool _isAlertDialogShowing = false;
  bool _isFlashOn = false; // Flag to track flashlight status

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.dispose();
      controller = null;
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
      this.controller!.scannedDataStream.listen((scanData) {
        if (_isScanning && mounted) {
          _isScanning = false;
          _processQRData(scanData.code!);
        }
      });
    });
  }

  void _processQRData(String qrData) async {
    try {
      final db = await DatabaseHelper().database;
      // Decrypt the QR data
      String decryptedQrData = _cipher.xorDecode(qrData);
      if (db == null) {
        // Database is not available, handle the error here.
        return;
      }
      // Check if the user data already exists in the database.
      final existingData = await db.query(
        'qr_data',
        where: 'data = ?',
        whereArgs: [decryptedQrData],
      );
      if (existingData.isNotEmpty) {
        final existingEntry = existingData.first;
        final int existingTimeIn = existingEntry['time_in'] as int;
        final int existingTimeOut = existingEntry['time_out'] as int;
        if (_isTimeIn) {
          // Check for duplicate Time In entry.
          if (existingTimeIn != 0 && existingTimeOut == 0) {
            // Duplicate Time In detected.
            _showAlertDialog("Already Time In", "You have already timed in.",
                () {
              // Resume scanning logic here.
              _isScanning = true;
            });
            return;
          } else if (existingTimeIn != 0 && existingTimeOut != 0) {
            // Already both Time In and Time Out.
            _showAlertDialog("Already Timed Out", "You have already timed out",
                () {
              // Resume scanning logic here.
              _isScanning = true;
            });
            return;
          }
        } else {
          // Check for valid Time Out entry.
          if (existingTimeIn == 0 || existingTimeOut != 0) {
            // Time Out without Time In or duplicate Time Out detected.
            _showAlertDialog("Already Timed Out", "You have already timed out",
                () {
              // Resume scanning logic here.
              _isScanning = true;
            });
            return;
          }
        }
      } else {
        // New user, add entry with Time In.
        if (!_isTimeIn) {
          // Invalid Time Out without Time In.
          _showAlertDialog("Time In first", "Please time in before timing out.",
              () {
            // Resume scanning logic here.
            _isScanning = true;
          });
          return;
        }
      }
      // Perform the database insertion here if necessary.
      // For simplicity, assume this is the point where the data is inserted.
      // If all validations pass, navigate to the QRCodeDisplayPage.
      // ignore: use_build_context_synchronously
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DisplayPage(
            qrData: decryptedQrData,
            isTimeIn: _isTimeIn,
          ),
        ),
      ).then((_) {
        // Resume scanning when back from QRCodeDisplayPage
        _isScanning = true;
      });
    } catch (e) {
      // Invalid QR Code
      _showAlertDialog("Invalid QR Code", "Please use the Official QR Code.",
          () {
        // Resume scanning logic here.
        _isScanning = true;
      });
      return;
    }
  }

  void _showAlertDialog(
      String title, String message, VoidCallback onOKPressed) {
    if (_isAlertDialogShowing) {
      return; // Do not show multiple alert dialogs simultaneously.
    }
    _isAlertDialogShowing = true;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _isAlertDialogShowing =
                    false; // Reset the flag on dialog dismiss.
                onOKPressed();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  // Function to toggle flashlight
  Future<void> _toggleFlash() async {
    if (controller != null) {
      if (_isFlashOn) {
        await controller!.toggleFlash();
      } else {
        await controller!.toggleFlash();
      }
      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 4,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                  overlay: QrScannerOverlayShape(
                    borderColor: _isTimeIn ? Colors.green : Colors.red,
                    borderRadius: 10,
                    borderLength: 30,
                    borderWidth: 10,
                    cutOutSize: 250,
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 50),
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isTimeIn ? Colors.green : Colors.grey,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _isTimeIn = true;
                              });
                            },
                            child: const AutoSizeText(
                              'TIME IN',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 50),
                        child: SizedBox(
                          height: 50,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  _isTimeIn ? Colors.grey : Colors.red,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            onPressed: () {
                              setState(() {
                                _isTimeIn = false;
                              });
                            },
                            child: const AutoSizeText(
                              'TIME OUT',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: IconButton(
                icon: Icon(
                  _isFlashOn ? Icons.flash_off : Icons.flash_on,
                  color: Colors.white,
                  size: 40,
                ),
                onPressed: _toggleFlash,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
