import 'package:bakery_manager_mobile/man_nav/admin.dart';
import 'package:bakery_manager_mobile/man_nav/clockinout.dart';
import 'package:bakery_manager_mobile/man_nav/recipes.dart';
import 'package:bakery_manager_mobile/man_nav/settings.dart';
import 'package:bakery_manager_mobile/widgets/manager_home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../env/env_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EmpBiWeeks {
  final String userID;
  final String firstName;
  final String lastName;
  final String biWeekID;
  final String biWeekNum;
  final double totalNormalHours;
  final double totalOvertimeHours;
  final double totalHolidayHours;

  const EmpBiWeeks({
    required this.userID,
    required this.firstName,
    required this.lastName,
    required this.biWeekID,
    required this.biWeekNum,
    required this.totalNormalHours,
    required this.totalOvertimeHours,
    required this.totalHolidayHours,
  });

  factory EmpBiWeeks.fromJson(Map<String, dynamic> json) {
    return EmpBiWeeks(
      userID: json['userID'],
      firstName: json['FirstName'],
      lastName: json['LastName'],
      biWeekID: json['biWeekID'],
      biWeekNum: json['biWeekNum'],
      totalNormalHours: json['TotalNormalHours'],
      totalOvertimeHours: json['TotalOvertimeHours'],
      totalHolidayHours: json['TotalHolidayHours'],
    );
  }
}

class TimePage extends StatefulWidget {
  const TimePage({super.key});

  @override
  State<TimePage> createState() => _TimePageState();
}

class _TimePageState extends State<TimePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<EmpBiWeeks> employeeHours = [];

  Future<void> _retrieveEmpHours() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionID = await prefs.getString('SessionID');
    if (sessionID == null) {
      // send back to home page?
    } else {
      final url = Uri.parse('$baseURL/api/employeeHours?sessionID=$sessionID');
      final headers = {
        'Content-Type': 'application/json',
      };
      try {
        final response = await http.get(url, headers: headers);
        var parsed = jsonDecode(response.body) as List;
        if (response.statusCode == 200) {
          employeeHours =
              parsed.map((json) => EmpBiWeeks.fromJson(json)).toList();
          setState(() {});
        } else {
          setState(() {});
        }
      } catch (error) {
        setState(() {});
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _retrieveEmpHours();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Inventory"),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Image.asset('assets/images/leftcorner.png'),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Handle logout logic here
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
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
              ),
              child: Center(
                child: Text(
                  'Menu',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: Colors.black,
                      ),
                ),
              ),
            ),
            _buildDrawerTile(
                'Dashboard', Icons.house_outlined, const ManagerHomePage()),
            ExpansionTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Recipes'),
              children: [
                _buildRecipeTile('Cake', Icons.cake, 'Cake'),
                _buildRecipeTile('Bread', Icons.bakery_dining, 'Bread'),
                _buildRecipeTile('Muffins', Icons.cake_outlined, 'Muffins'),
                _buildRecipeTile('Cookies', Icons.cookie,
                    'Cookies'), // Adjust as per actual page
                _buildRecipeTile('Croissants', Icons.cookie_outlined,
                    'Croissants'), // Adjust as per actual page
                _buildRecipeTile('Bagels', Icons.cookie_rounded, 'Bagels'),
                _buildRecipeTile('Pies', Icons.cookie_sharp, 'Pies'),
                _buildRecipeTile('Brownies', Icons.cookie, 'Brownies'),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Inventory'),
              children: [
                _buildRecipeTile(
                    'Raw Ingredients', Icons.egg, 'Raw Ingredients'),
                _buildRecipeTile('Finished Products',
                    Icons.breakfast_dining_rounded, 'Finished Products'),
                _buildRecipeTile('Vendors', Icons.contact_emergency, 'Vendors'),
                _buildRecipeTile('Cleaning Products', Icons.clean_hands,
                    'Cleaning Products'),
              ],
            ),
            _buildDrawerTile(
                'Clock In/Out', Icons.lock_clock, const ClockPage()),
            _buildDrawerTile(
                'Settings', Icons.settings_outlined, const SettingsPage()),
            _buildDrawerTile(
                'Admin', Icons.admin_panel_settings_sharp, const AdminPage()),
          ],
        ),
      ),
      body: SafeArea(
        child: Scrollbar(
          // Scrollbar here
          child: SingleChildScrollView(
            // Ensure scrollable content
            child: Container(
              color: Theme.of(context).primaryColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Timesheets',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 20.0),
                  ListView.builder(
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable inner scroll for list
                    shrinkWrap:
                        true, // Allow ListView to wrap inside the scrollable container
                    itemCount: employeeHours.length, //timesheets.length,
                    itemBuilder: (context, index) {
                      final item = employeeHours[index];
                      return TimesheetTile(
                        firstName: item.firstName,
                        lastName: item.lastName,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class TimesheetTile extends StatelessWidget {
  final String firstName;
  final String lastName;

  const TimesheetTile(
      {super.key, required this.firstName, required this.lastName});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: const Icon(Icons.person), // Display the icon here
        title: Text(
          "$firstName $lastName",
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            // Add navigation to item details
          },
        ),
      ),
    );
  }
}
