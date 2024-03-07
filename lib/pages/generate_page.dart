import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:pretty_qr_code_plus/pretty_qr_code_plus.dart';
import 'package:tribe_checker/components/show_alert_dialog.dart';
import 'package:tribe_checker/components/show_snackbar_notification.dart';
import 'package:tribe_checker/components/text_field.dart';
import 'package:encrypt_decrypt_plus/cipher/cipher.dart';

class GeneratorPage extends StatefulWidget {
  const GeneratorPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _GeneratorPageState createState() => _GeneratorPageState();
}

class _GeneratorPageState extends State<GeneratorPage> {
  final GlobalKey _globalKey = GlobalKey();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _firstNameController = TextEditingController();
  //Encrypt QR CODE Secret Key
  final Cipher _cipher = Cipher(secretKey: "Tribe_Checker");
  // New variables for storing the selected values from the popup menu
  String? _selectedYearLevel;
  String? _selectedCourse;
  String? _selectedDepartment;
  String _dataString = '';

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  // Method to check if the form is complete (mandatory fields are filled)
  bool _isFormComplete() {
    return _firstNameController.text.isNotEmpty &&
        _lastNameController.text.isNotEmpty &&
        _idNumberController.text.isNotEmpty &&
        _selectedYearLevel != null &&
        _selectedYearLevel != 'Year Level' &&
        _selectedCourse != null &&
        _selectedCourse != 'Your Course' &&
        _selectedDepartment != null &&
        _selectedDepartment != 'Your Department';
  }

  void _updateDataString() {
    setState(() {
      String plainText =
          '${_idNumberController.text}\n${_lastNameController.text}, ${_firstNameController.text}\n$_selectedYearLevel\n$_selectedCourse\n$_selectedDepartment';
      _dataString = _cipher.xorEncode(plainText);
    });
  }

  // Function to show the custom popup
  void _showCustomPopup(String title, List<String> items, String? currentValue,
      void Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: AlertDialog(
            backgroundColor: Colors.grey[300],
            title: Text(title),
            content: SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final value = items[index];
                  return ListTile(
                    title: Text(value),
                    onTap: () {
                      onSelect(value);
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25.0),
              side: const BorderSide(color: Colors.red, width: 4.0),
            ),
          ),
        );
      },
    );
  }

  Future<void> _requestPermissions() async {
    if (await Permission.storage.request().isGranted) {
      // Permission Granted
    }
  }

  Future<void> _saveQrCode(String lastname, String firstname) async {
    RenderRepaintBoundary boundary =
        _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage(pixelRatio: 5.0);
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData != null) {
      // Filename of QR Code Image
      String fileName = '$lastname, $firstname';
      Uint8List pngBytes = byteData.buffer.asUint8List();

      // Create a new image with padding
      ui.Codec codec = await ui.instantiateImageCodec(pngBytes);
      ui.FrameInfo frameInfo = await codec.getNextFrame();
      ui.Image qrImage = frameInfo.image;
      int padding = 20; // Adjust the padding as needed

      // Calculate position for centering the QR code within the padded area
      double paddedWidth = qrImage.width.toDouble() + (2 * padding);
      double paddedHeight = qrImage.height.toDouble() + (2 * padding);
      double x = (paddedWidth - qrImage.width.toDouble()) / 2;
      double y = (paddedHeight - qrImage.height.toDouble()) / 2;

      ui.PictureRecorder recorder = ui.PictureRecorder();
      Canvas canvas = Canvas(recorder);
      canvas.drawColor(Colors.white, BlendMode.srcOver); // Set background color
      canvas.drawImageRect(
        qrImage,
        Rect.fromLTWH(
            0, 0, qrImage.width.toDouble(), qrImage.height.toDouble()),
        Rect.fromLTWH(
            x, y, qrImage.width.toDouble(), qrImage.height.toDouble()),
        Paint(),
      );

      // Convert the new image to bytes
      ui.Image paddedImage = await recorder.endRecording().toImage(
            qrImage.width + (2 * padding),
            qrImage.height + (2 * padding),
          );
      ByteData? paddedByteData =
          await paddedImage.toByteData(format: ui.ImageByteFormat.png);
      if (paddedByteData != null) {
        // ignore: unused_local_variable
        final result = await ImageGallerySaver.saveImage(
          paddedByteData.buffer.asUint8List(),
          quality: 100,
          name: fileName,
        );
        // Clear text fields and reset selected values after successful save
        _firstNameController.clear();
        _lastNameController.clear();
        _idNumberController.clear();
        setState(() {
          _selectedYearLevel = null;
          _selectedCourse = null;
          _selectedDepartment = null;
          // _dataString = ""; // Clear out the generated QR code
        });
        //SnackBar Noification
        // ignore: use_build_context_synchronously
        showSnackBarNotification(
            context, 'Save to gallery', Colors.green.shade800);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // New variables for storing the available courses for each department
    Map<String, List<String>> departmentCourses = {
      'Biology Department': ['BS Biology'],
      'Chemistry Department': ['BS Chemistry'],
      'Math/Stat Department': ['BS Mathematics', 'BS Statistics'],
      'Physics Department': ['BS Physics'],
    };
    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                RepaintBoundary(
                  key: _globalKey,
                  child: PrettyQrPlus(
                    image: const AssetImage('assets/icon/cnsmlogo.png'),
                    size: 100,
                    data: _dataString,
                    errorCorrectLevel: QrErrorCorrectLevel.M,
                    roundEdges: true,
                  ),
                ),
                Text(
                  'Preview',
                  style: TextStyle(color: Colors.red[900]),
                ),
                const SizedBox(height: 30),
                // Firstname TextField
                CustomTextField(
                  controller: _firstNameController,
                  hintText: 'Firstname',
                ),
                const SizedBox(height: 15),
                // Lastname TextField
                CustomTextField(
                  controller: _lastNameController,
                  hintText: 'Lastname',
                ),
                const SizedBox(height: 15),
                // ID Number TextField (only numbers)
                CustomTextField(
                  controller: _idNumberController,
                  hintText: 'ID Number',
                  onlyNumbers: true,
                ),
                const SizedBox(height: 30),
                GestureDetector(
                  onTap: () {
                    FocusScope.of(context).unfocus();
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 50,
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          child: ButtonTheme(
                            minWidth: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  _selectedCourse = null;
                                });

                                _showCustomPopup(
                                  'Select Department',
                                  [
                                    'Biology Department',
                                    'Chemistry Department',
                                    'Math/Stat Department',
                                    'Physics Department',
                                  ],
                                  _selectedDepartment,
                                  (value) {
                                    setState(() {
                                      _selectedDepartment = value;
                                    });
                                  },
                                );
                              },
                              child: AutoSizeText(
                                _selectedDepartment ?? 'DEPARTMENT',
                                style: const TextStyle(
                                  color: Colors.white,
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
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(left: 15),
                        child: SizedBox(
                          height: 50,
                          child: ButtonTheme(
                            minWidth: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                _showCustomPopup(
                                  'Select Year Level',
                                  [
                                    '1st Year',
                                    '2nd Year',
                                    '3rd Year',
                                    '4th Year',
                                  ],
                                  _selectedYearLevel,
                                  (value) {
                                    setState(() {
                                      _selectedYearLevel = value;
                                    });
                                  },
                                );
                              },
                              child: AutoSizeText(
                                _selectedYearLevel ?? 'YEAR',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 15),
                        child: SizedBox(
                          height: 50,
                          child: ButtonTheme(
                            minWidth: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                backgroundColor: Colors.red,
                              ),
                              onPressed: () {
                                FocusScope.of(context).unfocus();
                                if (_selectedDepartment != null) {
                                  _showCustomPopup(
                                    'Select Course',
                                    departmentCourses[_selectedDepartment] ??
                                        [],
                                    _selectedCourse,
                                    (value) {
                                      setState(() {
                                        _selectedCourse = value;
                                      });
                                    },
                                  );
                                } else {
                                  showAlertDialog(
                                      context, 'Select Department', 'OK');
                                }
                              },
                              child: AutoSizeText(
                                _selectedCourse ?? 'COURSE',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 50,
                      width: double.infinity,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 50),
                        child: ButtonTheme(
                          minWidth: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.red[700],
                            ),
                            onPressed: () {
                              if (!_isFormComplete()) {
                                showAlertDialog(
                                    context, 'Complete the form', 'OK');
                                return;
                              } else {
                                _updateDataString();
                                Future.delayed(
                                    const Duration(milliseconds: 500), () {
                                  _saveQrCode(_lastNameController.text,
                                      _firstNameController.text);
                                });
                              }
                            },
                            child: const AutoSizeText(
                              'CREATE QR CODE',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
