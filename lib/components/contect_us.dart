import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutDialogPage extends StatelessWidget {
  const AboutDialogPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[400],
      title: const Text('Contact Us'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'NAIM A. PANDA\n'
            'JALAL H.A H.AMEN',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 60, // Set an appropriate width
                height: 60, // Set an appropriate height
                child: IconButton(
                  iconSize: 30, // Adjust icon size as needed
                  icon: Image.asset('assets/icon/social/facebook.png'),
                  onPressed: () {
                    // ignore: deprecated_member_use
                    launch('https://www.facebook.com/pandanaim.1234');
                  },
                ),
              ),
              SizedBox(
                width: 50, // Set an appropriate width
                height: 50, // Set an appropriate height
                child: IconButton(
                  iconSize: 30, // Adjust icon size as needed
                  icon: Image.asset('assets/icon/social/messenger.png'),
                  onPressed: () {
                    // ignore: deprecated_member_use
                    launch('https://m.me/pandanaim.1234');
                  },
                ),
              ),
              SizedBox(
                width: 50, // Set an appropriate width
                height: 50, // Set an appropriate height
                child: IconButton(
                  iconSize: 30, // Adjust icon size as needed
                  icon: Image.asset('assets/icon/social/gmail.png'),
                  onPressed: () {
                    // ignore: deprecated_member_use
                    launch('mailto:pandanaim06@gmail.com');
                  },
                ),
              )
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Close'),
        ),
      ],
    );
  }
}
