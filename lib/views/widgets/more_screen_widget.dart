import 'package:flutter/material.dart';

class MoreScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  title: Text('Home'),
                  onTap: () {
                    // Handle tapping on Home option
                  },
                ),
                ListTile(
                  title: Text('Option 1'),
                  onTap: () {
                    // Handle tapping on Option 1
                  },
                ),
                ListTile(
                  title: Text('Option 2'),
                  onTap: () {
                    // Handle tapping on Option 2
                  },
                ),
                ListTile(
                  title: Text('Option 3'),
                  onTap: () {
                    // Handle tapping on Option 3
                  },
                ),
                ListTile(
                  title: Text('Option 4'),
                  onTap: () {
                    // Handle tapping on Option 4
                  },
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog box
              },
              child: Text('Cancel'),
            ),
          ),
        ],
      ),
    );
  }
}