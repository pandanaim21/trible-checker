import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import '../components/show_alert_dialog.dart';
import 'generate_page.dart';
import 'terms_of_use_page.dart';
import 'scan_page.dart';
import 'user_page.dart';
import 'attendance_page.dart';
import '../components/contect_us.dart';
import '../db/database_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PageController _pageController =
      PageController(initialPage: 1); // Set initial page to 1 (Create QR)
  int _currentPage = 1;

  Future<void> _onSignOutPressed(BuildContext context) async {
    final qrData = await DatabaseHelper().getQRData();
    if (qrData.isEmpty) {
      await DatabaseHelper().deleteUser();
      // ignore: use_build_context_synchronously
      Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const UserPage(),
      ));
    } else {
      // ignore: use_build_context_synchronously
      showAlertDialog(context, "Export and Clear Attendance List.", "OK");
    }
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        // Show an alert or perform any action you want
        if (_currentPage == 0) {
          // showAlertDialog(context, "You are already logged in.", "OK");
          return false; // Block back navigation
        } else if (_currentPage == 1) {
          // showAlertDialog(context, "You are already logged in.", "OK");
          return false; // Block back navigation
        } else if (_currentPage == 2) {
          // showAlertDialog(context, "You are already logged in.", "OK");
          return false; // Block back navigation
        } else {
          return true; // Allow back navigation for other pages
        }
      },
      child: Scaffold(
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
        drawer: _buildDrawer(),
        body: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: const [
            GeneratorPage(),
            ScanPage(),
            AttendancePage(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          backgroundColor: Colors.grey[500],
          currentIndex: _currentPage,
          selectedItemColor: Colors.red[900],
          onTap: (index) {
            setState(() {
              _currentPage = index;
              _pageController.animateToPage(
                index,
                duration: const Duration(milliseconds: 500),
                curve: Curves.ease,
              );
            });
          },
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code),
              label: 'Create QR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.qr_code_scanner),
              label: 'Scan QR',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Attendance List',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader() {
    return DrawerHeader(
      decoration: BoxDecoration(
        color: Colors.grey[600],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/icon/app/icon3.png',
            height: 100,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: AutoSizeText(
              'TRIBE CHECKER',
              style: TextStyle(
                color: Colors.red[900],
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              maxLines: 1,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      backgroundColor: Colors.grey[400],
      child: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerHeader(),
                FutureBuilder<String?>(
                  future: DatabaseHelper().getUser(),
                  builder:
                      (BuildContext context, AsyncSnapshot<String?> snapshot) {
                    final userName = snapshot.data ?? 'User';
                    return ListTile(
                      leading: const Icon(
                        Icons.person,
                        color: Color.fromARGB(255, 160, 10, 0),
                      ),
                      title: Text(userName),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.help,
                    color: Color.fromARGB(255, 160, 10, 0),
                  ),
                  title: const Text('Terms of Use'),
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const TermsOfUsePage()));
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.info,
                    color: Color.fromARGB(255, 160, 10, 0),
                  ),
                  title: const Text('Contact Us'),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const AboutDialogPage();
                      },
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(
                    Icons.logout,
                    color: Color.fromARGB(255, 160, 10, 0),
                  ),
                  title: const Text(
                    'Sign Out',
                  ),
                  onTap: () => _onSignOutPressed(context),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Center(
              child: AutoSizeText(
                '© 2024 P&A. All Rights Reserved',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
