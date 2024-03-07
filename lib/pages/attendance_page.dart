import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:intl/intl.dart';
import '../components/export_excel.dart';
import '../components/show_snackbar_notification.dart';
import '../db/database_helper.dart';
import 'dart:async';

class AttendancePage extends StatefulWidget {
  const AttendancePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  final dbHelper = DatabaseHelper();
  List<Map<String, dynamic>> _qrDataList = [];
  List<Map<String, dynamic>> _originalData = [];
  final TextEditingController _searchController = TextEditingController();
  int selectedCardIndex = -1;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    final data = await dbHelper.getQRData();
    setState(() {
      _qrDataList = data;
      _originalData = List.from(_qrDataList); // Save a copy of original data
    });
  }

  void _clearData() async {
    if (_qrDataList.isEmpty) {
      showSnackBarNotification(
          context, 'Attendance list is currently empty.', Colors.red.shade800);
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'Confirm Deletion',
              style: TextStyle(fontSize: 18),
            ),
            content: const Text(
              'Are you sure you want to clear all data?',
              style: TextStyle(fontSize: 14),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 12),
                ),
              ),
              TextButton(
                onPressed: () async {
                  Navigator.pop(context); // Close the confirmation dialog
                  await _performClearData();
                  // ignore: use_build_context_synchronously
                  showSnackBarNotification(context, 'Clear list successfully.',
                      Colors.green.shade800);
                },
                child: const Text(
                  'Confirm',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> _performClearData() async {
    final db = await dbHelper.database;
    if (db != null) {
      await db.delete('qr_data');
      _loadData();
    }
  }

  Future<void> _exportToCSV() async {
    try {
      if (_qrDataList.isEmpty) {
        showSnackBarNotification(context, 'Attendance list is currently empty.',
            Colors.red.shade800);
        return; // Exit the function early if the list is empty
      }
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent users from dismissing the dialog
        builder: (BuildContext context) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(
                  valueColor:
                      AlwaysStoppedAnimation<Color>(Colors.green.shade800),
                ),
                const SizedBox(height: 16),
                Text(
                  "Exporting List",
                  style: TextStyle(color: Colors.green[600]),
                ),
              ],
            ),
          );
        },
      );
      await Future.delayed(const Duration(seconds: 2));
      // Perform export operation
      await ExportExcel.exportToExcel(_qrDataList);
      // Dismiss the loading dialog
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // Show success notification
      // ignore: use_build_context_synchronously
      showSnackBarNotification(
          context, 'Export file successfully.', Colors.green.shade800);
    } catch (e) {
      // Dismiss the loading dialog
      // ignore: use_build_context_synchronously
      Navigator.pop(context);
      // Show error notification
      // ignore: use_build_context_synchronously
      showSnackBarNotification(context, e.toString(), Colors.red.shade800);
    }
  }

  Widget _buildQRDataItem(Map<String, dynamic> qrData) {
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

    return Dismissible(
      key: Key(qrData['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 16),
        child: const Icon(
          Icons.delete,
          color: Colors.white,
        ),
      ),
      confirmDismiss: (direction) async {
        return await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text('Are you sure you want to delete this data?'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false); // Dismiss the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context,
                        true); // Dismiss the dialog and confirm deletion
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
      onDismissed: (direction) async {
        if (direction == DismissDirection.endToStart) {
          await _performDeleteData(qrData['id']);
          // ignore: use_build_context_synchronously
          showSnackBarNotification(
            context,
            'Deleted successfully.',
            Colors.red.shade800,
          );
        }
      },
      child: Card(
        color: Colors.grey[200],
        elevation: 3,
        child: GestureDetector(
          onTap: () {
            // Toggle the expanded state only for the selected card
            setState(() {
              selectedCardIndex =
                  selectedCardIndex == qrData['id'] ? -1 : qrData['id'];
            });
          },
          child: Column(
            children: [
              ListTile(
                title: AutoSizeText(
                  '${lastName.toUpperCase()}, ${firstName.toUpperCase()}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AutoSizeText('ID Number: $idNumber',
                        style: const TextStyle(fontSize: 12)),
                    if (selectedCardIndex == qrData['id'])
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText('Year: $yearLevel',
                              style: const TextStyle(fontSize: 12)),
                          AutoSizeText('Course: $course',
                              style: const TextStyle(fontSize: 12)),
                          AutoSizeText('Department: $department',
                              style: const TextStyle(fontSize: 12)),
                        ],
                      ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: AutoSizeText(
                            'TIME IN: ${_formatDateTime(timeIn)}',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: AutoSizeText(
                            'TIME OUT: ${timeOut != 0 ? _formatDateTime(timeOut) : '--:--'}',
                            style: const TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                            maxLines: 1,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _performDeleteData(int id) async {
    final db = await dbHelper.database;
    if (db != null) {
      await db.delete('qr_data', where: 'id = ?', whereArgs: [id]);
      _loadData();
    }
  }

  String _formatDateTime(int timestamp) {
    DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    return DateFormat('h:mm a').format(dateTime);
  }

  void _search(String searchText) {
    List<Map<String, dynamic>> filteredData = _originalData.where((qrData) {
      String idNumber = (qrData['data'] as String).toLowerCase();
      return idNumber.contains(searchText);
    }).toList();
    setState(() {
      _qrDataList = filteredData;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[400],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15.0, 5.0, 15.0, 5.0),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _search(value.toLowerCase());
              },
              decoration: InputDecoration(
                labelText: 'Search',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.red),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _qrDataList = List.from(_originalData);
                    });
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _qrDataList.isEmpty
                ? Center(
                    child: AutoSizeText(
                      _searchController.text.isEmpty
                          ? 'Scan QR Code'
                          : 'User not found',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                      maxLines: 1,
                    ),
                  )
                : ListView.builder(
                    itemCount: _qrDataList.length,
                    itemBuilder: (context, index) {
                      return _buildQRDataItem(_qrDataList[index]);
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        backgroundColor: Colors.red[700],
        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: const IconThemeData(color: Colors.white),
        overlayOpacity: 0.0,
        children: [
          SpeedDialChild(
            child: Icon(
              Icons.file_download,
              color: Colors.green[900],
            ),
            label: 'Export List',
            labelStyle: TextStyle(
              color: Colors.green[900],
              fontWeight: FontWeight.bold,
            ),
            onTap: _exportToCSV,
          ),
          SpeedDialChild(
            child: Icon(
              Icons.delete,
              color: Colors.red[900],
            ),
            label: 'Clear List',
            labelStyle: TextStyle(
              color: Colors.red[900],
              fontWeight: FontWeight.bold,
            ),
            onTap: _clearData,
          ),
        ],
      ),
    );
  }
}
