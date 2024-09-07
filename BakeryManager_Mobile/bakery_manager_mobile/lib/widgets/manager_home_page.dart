import 'dart:convert';
import 'package:bakery_manager_mobile/man_nav/admin.dart';
import 'package:bakery_manager_mobile/man_nav/clockinout.dart';
import 'package:bakery_manager_mobile/man_nav/inventory.dart';
import 'package:bakery_manager_mobile/man_nav/recipes.dart';
import 'package:bakery_manager_mobile/man_nav/settings.dart';
import 'package:bakery_manager_mobile/man_nav/timesheets.dart';
import 'package:bakery_manager_mobile/widgets/home_page.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ManagerHomePage extends StatefulWidget {
  const ManagerHomePage({super.key});

  @override
  State<ManagerHomePage> createState() => _ManagerHomePageState();
}

class _ManagerHomePageState extends State<ManagerHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _logout() async {
    String? sessionID;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      sessionID = prefs.getString('SessionID');
    } catch (error) {
      // TODO
      print('Error logging out $error');
    }
    final url = Uri.parse('http://10.0.2.2:3000/api/sessions');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'sessionID': sessionID,
    });
    try {
      final response = await http.delete(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        // logout good
        if (mounted) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        }
      } else {
        // ?
      }
    } catch (error) {
      // error handle if DELETE just craps the bed
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Image.asset(
              'assets/images/leftcorner.png'), // Use the stack image
          onPressed: () {
            // Use the GlobalKey to open the drawer
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Maybe navigate back to the login page -- come back and do this later :)
              _logout();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              padding: const EdgeInsets.only(
                  top: 5.0, bottom: 0.0), // Adjusted padding
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Align(
                alignment: Alignment.center, // Center the content if needed
                child: Text(
                  'Menu',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            ListTile(
              title: const Text('Recipes'),
              leading: const Icon(Icons.bakery_dining),
              onTap: () {
                Navigator.pop(context); // Close the drawer
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const RecipesPage(), // Navigate to RecipesPage
                  ),
                );
              },
            ),
            ListTile(
              title: const Text('Inventory'),
              leading: const Icon(Icons.inventory_2_outlined),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const InventoryPage(), // Navigate to InventoryPage
                  ),
                );
                // Add navigation or functionality here -- Addison reminder
              },
            ),
            ListTile(
              title: const Text('Time Sheets'),
              leading: const Icon(Icons.access_time),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const TimePage(), // Navigate to TimePage
                  ),
                );
                // Add navigation or functionality here -- Addison reminder
              },
            ),
            ListTile(
              title: const Text('Clock In/Out'),
              leading: const Icon(Icons.lock_clock),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ClockPage(), // Navigate to ClockPage
                  ),
                );
                // Add navigation or functionality here -- Addison reminder
              },
            ),
            ListTile(
              title: const Text('Settings'),
              leading: const Icon(Icons.settings_outlined),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const SettingsPage(), // Navigate to SettingsPage
                  ),
                );
                // Add navigation or functionality here -- Addison reminder
              },
            ),
            ListTile(
              title: const Text('Admin'),
              leading: const Icon(Icons.admin_panel_settings_sharp),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const AdminPage(), // Navigate to AdminPage
                  ),
                );
                // Add navigation or functionality here -- Addison reminder
              },
            ),
            // Add more items after getting these first ones to work right - Addison reminder
          ],
        ),
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(
            horizontal: 10.0, vertical: 6.0), // Adjusted padding
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      vertical: 10.0), // Adjusted padding
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/bakerHat.png',
                        width: 175.0,
                        height: 175.0,
                      ),
                      const SizedBox(
                          height: 15.0), // Space between image and text
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0), // Bottom margin
                  child: Text(
                    'Welcome to your homepage, Manager!',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                    textScaleFactor: 1.3,
                  ),
                ),
                // Add more widgets if needed
              ],
            ),
          ),
        ),
      ),
    );
  }
}
