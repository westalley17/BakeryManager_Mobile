import 'package:bakery_manager_mobile/widgets/landing_page.dart';
import 'package:bakery_manager_mobile/emp_nav/clockinout.dart';
import 'package:bakery_manager_mobile/emp_nav/timesheets.dart';
import 'package:bakery_manager_mobile/emp_nav/inventory.dart';
import 'package:bakery_manager_mobile/emp_nav/settings.dart';
import 'package:bakery_manager_mobile/emp_nav/recipes.dart';
import 'package:bakery_manager_mobile/env/env_config.dart';


import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeHomePage extends StatefulWidget {
  const EmployeeHomePage({super.key});

  @override
  State<EmployeeHomePage> createState() => _EmployeeHomePageState();
}

class _EmployeeHomePageState extends State<EmployeeHomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  //bool _isRecipesExpanded = false; // To manage the expansion state

  Future<void> _logout() async {
    String? sessionID;
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      sessionID = prefs.getString('SessionID');
      await prefs.remove('SessionID');
    } catch (error) {
      print('Error logging out $error');
    }
    final url = Uri.parse('$baseURL/api/sessions');
    final headers = {
      'Content-Type': 'application/json',
    };
    final body = jsonEncode({
      'sessionID': sessionID,
    });
    try {
      final response = await http.delete(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            CupertinoPageRoute(
              builder: (context) => const HomePage(),
            ),
          );
        }
      } else {
        // Handle error
      }
    } catch (error) {
      // Handle error if DELETE fails
    }
  }

  void _navigateToPage(Widget page) {
    Navigator.pop(context); // Close the drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  Widget _buildDrawerTile(String title, IconData icon, Widget page) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: () => _navigateToPage(page),
    );
  }

  Widget _buildRecipeTile(String title, IconData icon, String category) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: ListTile(
        title: Text(title),
        leading: Icon(icon),
        onTap: () => _navigateToPage(RecipesPage(category: category)),
      ),
    );
  }

  Widget _buildInventoryTile(String title, IconData icon, String category) {
    return Padding(
      padding: const EdgeInsets.only(left: 16.0),
      child: ListTile(
        title: Text(title),
        leading: Icon(icon),
        onTap: () => _navigateToPage(InventoryPage(category: category)),
      ),
    );
  }

  Widget _buildExpansionTile({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return ExpansionTile(
      leading: Icon(icon),
      title: Text(title),
      children: children,
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Dashboard"),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Image.asset('assets/images/leftcorner.png'),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              padding: const EdgeInsets.only(top: 5.0),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Menu',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            _buildDrawerTile('Dashboard',Icons.house_outlined,const EmployeeHomePage()),
            _buildExpansionTile(title: 'Recipes',icon: Icons.restaurant_menu,
              children: [
                _buildRecipeTile('Cake', Icons.cake, 'Cake'),
                _buildRecipeTile('Bread', Icons.bakery_dining, 'Bread'),
                _buildRecipeTile('Muffins', Icons.cake_outlined, 'Muffins'),
                _buildRecipeTile('Cookie', Icons.cookie, 'Cookie'),
              ],
            ),
            _buildExpansionTile(title: 'Inventory',icon: Icons.inventory_2_outlined,
              children: [
                _buildInventoryTile('Raw Ingredients', Icons.egg, 'Ingredients'),
                _buildInventoryTile('Finished Products',Icons.breakfast_dining_rounded, 'Products'),
                _buildInventoryTile('Vendors', Icons.local_shipping, 'Vendors'),
                _buildInventoryTile('Equipment', Icons.kitchen_outlined, 'Equipment'),
              ],
            ),
            _buildDrawerTile('Timesheets',Icons.watch_later,const TimePage()),
            _buildDrawerTile('Clock In/Out',Icons.access_time_outlined,const ClockPage()),
            _buildDrawerTile('Settings',Icons.settings,const SettingsPage()),
          ],
        ),
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  child: Column(
                    children: [
                      Image.asset(
                        'assets/images/bakerHat.png',
                        width: 175.0,
                        height: 175.0,
                      ),
                      const SizedBox(height: 15.0),
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(bottom: 10.0),
                  child: Text(
                    'Welcome to your homepage, Employee!',
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



