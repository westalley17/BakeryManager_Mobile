import 'package:bakery_manager_mobile/widgets/employee_home_page.dart';
import 'package:bakery_manager_mobile/emp_nav/clockinout.dart';
import 'package:bakery_manager_mobile/emp_nav/inventory.dart';
import 'package:bakery_manager_mobile/emp_nav/settings.dart';
import 'package:bakery_manager_mobile/emp_nav/recipes.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/landing_page.dart';
import '../env/env_config.dart';
import 'dart:convert';



class EmpBiWeeks {
  final String userID;
  final String firstName;
  final String lastName;
  final String biWeekID;
  final int biWeekNum;
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

  Future<void> _retrieveEmpHours() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionID = prefs.getString('SessionID');
    if (sessionID == null) {
      // send back to home page?
    } else {
      final url = Uri.parse('$baseURL/api/manager/employeeHours?sessionID=$sessionID');
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
