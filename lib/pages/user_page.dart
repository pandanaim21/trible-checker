import 'dart:ui'; // Import the dart:ui library
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'home_page.dart';
import '../components/show_alert_dialog.dart';
import '../db/database_helper.dart';

class UserPage extends StatefulWidget {
  const UserPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final TextEditingController _nameController = TextEditingController();
  final FocusNode _nameFocus = FocusNode();
  bool _isNameFocused = false;

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocus.dispose();
    super.dispose();
  }

  void _onContinuePressed() async {
    final String name = _nameController.text;
    if (name.isNotEmpty) {
      // Assuming DatabaseHelper() is correctly implemented
      await DatabaseHelper().insertUser(name);
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const HomePage(),
      ));
    } else {
      showAlertDialog(context, "Enter your name", 'OK');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/icon/Background.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/icon/app/icon3.png',
                          height: 135,
                        ),
                        const SizedBox(height: 10),
                        AutoSizeText(
                          'TRIBE CHECKER',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.red[900],
                          ),
                          maxLines: 1,
                        ),
                        const SizedBox(height: 30),
                        Container(
                          height: 50,
                          width: 200,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            color: Colors.grey[300],
                            border: Border.all(
                              color: _isNameFocused
                                  ? Colors.red
                                  : Colors.grey[700]!,
                              width: 1.5, // Set the border thickness
                            ),
                          ),
                          child: Focus(
                            onFocusChange: (hasFocus) {
                              setState(() {
                                _isNameFocused = hasFocus;
                              });
                            },
                            child: TextField(
                              controller: _nameController,
                              focusNode: _nameFocus,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: 'OFFICER IN CHARGE',
                                border: InputBorder.none,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        SizedBox(
                            height: 50,
                            width: 125,
                            child: ButtonTheme(
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: Colors.grey),
                                  ),
                                  backgroundColor: Colors.red[900],
                                ),
                                onPressed: _onContinuePressed,
                                child: const AutoSizeText(
                                  'CONTINUE',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                  maxLines: 1,
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
