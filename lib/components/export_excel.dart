//xlsx with password
import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:intl/intl.dart';
import 'package:protect/protect.dart';
import '../db/database_helper.dart';

class ExportExcel {
  static Future<void> exportToExcel(
      List<Map<String, dynamic>> qrDataList) async {
    // Check if the Documents folder exists, create it if not
    Directory documentsDir = Directory('/storage/emulated/0/Documents');
    if (!await documentsDir.exists()) {
      documentsDir.createSync();
    }
    // Get the current user from the database
    String? officerInCharge = await DatabaseHelper().getUser();
    // Create a new Excel workbook and sheet
    var excel = Excel.createExcel();
    var sheet = excel['Sheet1'];
    // Add the "Officer in charge" line
    if (officerInCharge != null && officerInCharge.isNotEmpty) {
      sheet.appendRow(['Officer in charge:', officerInCharge]);
    }
    // Add the header row
    sheet.appendRow([
      'Time In',
      'Time Out',
      'ID Number',
      'Last Name',
      'First Name',
      'Year',
      'Course',
      'Department',
    ]);

    for (var qrData in qrDataList) {
      final data = qrData['data'];
      final timeIn = qrData['time_in'] ?? 0;
      final timeOut = qrData['time_out'] ?? 0;
      List<String> qrDataSplit = data.split('\n');
      // Extracting the information from qrDataSplit list
      String idNumber = '';
      String lastName = '';
      String firstName = '';
      String yearLevel = '';
      String course = '';
      String department = '';

      for (String data in qrDataSplit) {
        List<String> splitData = data.split(RegExp('[,]'));

        for (String splitValue in splitData) {
          String trimmedValue = splitValue.trim();
          if (trimmedValue.startsWith(idNumber)) {
            idNumber = trimmedValue.replaceFirst(idNumber, '').trim();
          } else if (trimmedValue.startsWith(lastName)) {
            lastName = trimmedValue.replaceFirst(lastName, '').trim();
          } else if (trimmedValue.startsWith(firstName)) {
            firstName = trimmedValue.replaceFirst(firstName, '').trim();
          } else if (trimmedValue.startsWith(yearLevel)) {
            yearLevel = trimmedValue.replaceFirst(yearLevel, '').trim();
          } else if (trimmedValue.startsWith(course)) {
            course = trimmedValue.replaceFirst(course, '').trim();
          } else if (trimmedValue.startsWith(department)) {
            department = trimmedValue.replaceFirst(department, '').trim();
          }
        }
      }

      sheet.appendRow([
        _formatDateTime(timeIn),
        (timeOut != 0) ? _formatDateTime(timeOut) : 'N/A',
        idNumber,
        lastName,
        firstName,
        yearLevel,
        course,
        department,
      ]);
    }
    // Save the workbook to bytes
    var excelBytes = excel.encode()!;
    // Convert to Uint8List before applying password protection
    Uint8List excelUint8List = Uint8List.fromList(excelBytes);
    // Apply password protection
    ProtectResponse encryptedResponse =
        Protect.encryptUint8List(excelUint8List, '2324sc');
    if (encryptedResponse.isDataValid) {
      // Save the protected Excel file
      String defaultDirectory = documentsDir.path;
      String timestamp = DateFormat('dd-MM-yyyy_HHMMss').format(DateTime.now());
      final protectedFile =
          File('$defaultDirectory/Attendance List ($timestamp)_protected.xlsx');
      await protectedFile
          .writeAsBytes(encryptedResponse.processedBytes as List<int>);
    }
  }

  static String _formatDateTime(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('h:mm a').format(dateTime);
  }
}
