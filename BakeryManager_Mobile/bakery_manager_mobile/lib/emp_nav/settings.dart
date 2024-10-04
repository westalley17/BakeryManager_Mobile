import 'package:bakery_manager_mobile/widgets/employee_home_page.dart';
import 'package:bakery_manager_mobile/emp_nav/clockinout.dart';
import 'package:bakery_manager_mobile/emp_nav/timesheets.dart';
import 'package:bakery_manager_mobile/emp_nav/inventory.dart'; 
import 'package:bakery_manager_mobile/emp_nav/recipes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../widgets/landing_page.dart';
import '../env/env_config.dart';
import 'dart:convert';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Future<void> _logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final sessionID = prefs.getString('SessionID');
      final url = Uri.parse('$baseURL/api/sessions');
      final response = await http.delete(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'sessionID': sessionID}),
      );
      await prefs.remove('SessionID');
      if (response.statusCode == 200 && mounted) {
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        print('Failed to log out. Status code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error logging out: $error');
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
        title: const Text("Settings"),
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
            onPressed: () {
              _logout();
              Navigator.pop(context);
            },
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
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Settings',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            // Add your settings functionality here
          ],
        ),
      ),
    );
  }
}
