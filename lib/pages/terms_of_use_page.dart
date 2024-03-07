import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class TermsOfUsePage extends StatelessWidget {
  const TermsOfUsePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Terms of Use',
          style: TextStyle(fontSize: 18.0, color: Colors.white),
        ),
        backgroundColor: Colors.red[900],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      backgroundColor: Colors.grey[300],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AutoSizeText(
                'Welcome to the TRIBE CHECKER App. The App is designed and developed for educational purposes to facilitate attendance management for the College of Natural Science and Mathematics (CNSM) at Mindanao State University - Main Campus. By using the App, you agree to comply with the following Terms of Use. If you do not agree with any of these terms, please refrain from using the App.',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16.0),
              const AutoSizeText(
                '1. Usage and Purpose',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const AutoSizeText(
                'The TRIBE CHECKER App is intended for exclusive use by the officers of CNSM to efficiently manage attendance records. It provides features such as offline mode, QR code scanning for attendance, QR code generation based on student information, and saving attendance data in Excel format.',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16.0),
              const AutoSizeText(
                '2. Data Collection and Usage',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const AutoSizeText(
                'The App collects and stores student information for the sole purpose of managing attendance records within CNSM. This data includes but is not limited to first name, last name, ID number, year, course, and department. We do not require users to create accounts or share personal information beyond the specified attendance data.',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16.0),
              const AutoSizeText(
                '3. Data Security and Privacy',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const AutoSizeText(
                'We are committed to protecting your data and ensuring its security. We will not share or sell any personal information to third parties. The attendance data collected will be stored locally on the device and can be exported by the officers for administrative purposes.',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16.0),
              const AutoSizeText(
                '4. QR Code generation and Scanning',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const AutoSizeText(
                'The App enables QR code generation based on the student\'s information, which can be used for attendance purposes. Likewise, the App allows scanning of QR codes for attendance tracking. It is the responsibility of the officers to ensure the integrity and accuracy of the QR codes created and scanned.',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16.0),
              const AutoSizeText(
                '5. Offline Mode and Data Synchronization',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const AutoSizeText(
                'The TRIBE CHECKER App features an offline mode, which means it operates without an internet connection. As a result, all attendance lists are stored locally on the device. Users are solely responsible for managing data synchronization between their devices and ensuring that attendance records are regularly backed up to prevent data loss.',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16.0),
              const AutoSizeText(
                '6. Responsibilities of Users (CNSM Officers)',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const AutoSizeText(
                'As an officer using the TRIBE CHECKER App, you are responsible for:\n'
                '- Ensuring that the App is used solely for educational purposes and attendance management within CNSM.\n'
                '- Maintaining the confidentiality and security of the attendance data stored on your device.\n'
                '- Ensuring the accuracy of the student information used for creating QR codes.\n'
                '- Adhering to all applicable laws and regulations regarding data protection and privacy.',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16.0),
              const AutoSizeText(
                '7. Copyright and Intellectual Property',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const AutoSizeText(
                'The TRIBE CHECKER App and all associated content, including but not limited to the source code, design, and documentation, are the property of Mr. Naim A. Panda. All rights are reserved. You may not distribute, modify, or reproduce any part of the App without prior written permission.',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16.0),
              const AutoSizeText(
                '8. Limitation of Liability',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const AutoSizeText(
                'The TRIBE CHECKER App is provided on an "as-is" basis. While we strive to ensure the accuracy and functionality of the App, we do not guarantee its uninterrupted operation or absence of errors. We shall not be liable for any direct, indirect, incidental, consequential, or special damages arising out of or in connection with the use of the App.',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16.0),
              const AutoSizeText(
                '9. Changes to the Terms',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const AutoSizeText(
                'We reserve the right to modify or update these Terms of Use from time to time. Any changes will be effective upon posting within the App. Your continued use of the App after the posting of any changes constitutes your acceptance of such changes.',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16.0),
              const AutoSizeText(
                'By using the TRIBE CHECKER App, you acknowledge that you have read, understood, and agreed to these Terms of Use. If you do not agree to these terms, please discontinue the use of the App.',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16.0),
              const AutoSizeText(
                'For any questions or concerns regarding these Terms of Use or the App, please contact the developer below.',
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 16.0),
              AutoSizeText(
                'Naim Panda\n'
                'pandanaim06@gmail.com\n',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
