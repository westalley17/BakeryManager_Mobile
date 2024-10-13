import 'package:bakery_manager_mobile/widgets/manager_home_page.dart';
import 'package:bakery_manager_mobile/man_nav/clockinout.dart';
import 'package:bakery_manager_mobile/man_nav/inventory.dart';
import 'package:bakery_manager_mobile/man_nav/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bakery_manager_mobile/man_nav/recipes.dart';
import 'package:bakery_manager_mobile/man_nav/admin.dart';

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
      totalNormalHours: double.parse(json['TotalNormalHours']),
      totalOvertimeHours: double.parse(json['TotalOvertimeHours']),
      totalHolidayHours: double.parse(json['TotalHolidayHours']),
    );
  }
}

class TimesheetTile extends StatelessWidget {
  final String firstName;
  final String lastName;
  VoidCallback? showModal;

  TimesheetTile(
      {super.key,
      required this.firstName,
      required this.lastName,
      this.showModal});

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
            showModal!();
          },
        ),
      ),
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

  List<EmpBiWeeks>? _employeeHours;

  void _showFullScreenAddRecipeDialog(int index) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true, 
    backgroundColor: Colors.transparent,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.95,
        padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 15,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ),
              const SizedBox(height: 15),
              const Text(
                'Employee Hours Summary',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              const Divider(
                height: 40.0,
                thickness: 2.0,
                color: Colors.black,
              ),
              const SizedBox(height: 10),
              _buildInfoRowWithBorder(
                'Total Normal Hours', 
                '${_employeeHours?[index].totalNormalHours.toStringAsFixed(2)}'
              ),
              _buildInfoRowWithBorder(
                'Total Overtime Hours', 
                '${_employeeHours?[index].totalOvertimeHours.toStringAsFixed(2)}'
              ),
              _buildInfoRowWithBorder(
                'Total Holiday Hours', 
                '${_employeeHours?[index].totalHolidayHours.toStringAsFixed(2)}'
              ),
            ],
          ),
        ),
      );
    },
  );
}

  Widget _buildInfoRowWithBorder(String label, String value) {
  return Container(
    margin: const EdgeInsets.symmetric(vertical: 8.0),
    padding: const EdgeInsets.all(16.0),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(color: Colors.black54, width: 1.5),
      boxShadow: [
        BoxShadow(
          color: Colors.white.withOpacity(0.05),
          spreadRadius: 2,
          blurRadius: 8,
        ),
      ],
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 22,
            color: Colors.black,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}


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
      final url =
          Uri.parse('$baseURL/api/manager/employeeHours?sessionID=$sessionID');
      final headers = {
        'Content-Type': 'application/json',
      };
      try {
        final response = await http.get(url, headers: headers);
        var parsed = jsonDecode(response.body) as List;
        if (response.statusCode == 200) {
          _employeeHours =
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

  @override
  Widget build(BuildContext context) {
    if (_employeeHours == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Timesheets"),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Image.asset('assets/images/leftcorner.png'),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Handle logout logic here
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: MediaQuery.of(context).size.height *
                              0.3, // Adjust height
                          child: Padding(
                            padding: const EdgeInsets.all(
                                16.0), // Padding around content
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 40.0,
                                  height: 40.0,
                                  child: Icon(Icons.error),
                                ),
                                const Text(
                                  'Are you sure you want to sign out?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const Divider(
                                  thickness: 0.8,
                                  color: Colors.black,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await _logout();
                                  },
                                  child: const Text(
                                    "Sign Out",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Theme.of(context).primaryColor),
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
                _buildRecipeTile('Cookies', Icons.cookie, 'Cookies'),
                _buildRecipeTile('Croissants', Icons.cookie, 'Croissants'),
                _buildRecipeTile('Bagels', Icons.cookie, 'Bagels'),
                _buildRecipeTile('Pies', Icons.cookie, 'Pies'),
                _buildRecipeTile('Brownies', Icons.cookie, 'Brownies'),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Inventory'),
              children: [
                _buildInventoryTile('Ingredients', Icons.egg, 'Ingredients'),
                _buildInventoryTile(
                    'Products', Icons.breakfast_dining_rounded, 'Products'),
                _buildInventoryTile('Vendors', Icons.local_shipping, 'Vendors'),
                _buildInventoryTile(
                    'Equipment', Icons.kitchen_outlined, 'Equipment'),
              ],
            ),
            _buildDrawerTile(
              'Time Sheets',
              Icons.access_time,
              const TimePage(),
            ),
            _buildDrawerTile(
              'Clock In/Out',
              Icons.lock_clock,
              const ClockPage(),
            ),
            _buildDrawerTile(
              'Settings',
              Icons.settings_outlined,
              const SettingsPage(),
            ),
            _buildDrawerTile(
              'Admin',
              Icons.admin_panel_settings_sharp,
              const AdminPage(),
            ),
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
              child: ListView.builder(
                physics:
                    const NeverScrollableScrollPhysics(), // Disable inner scroll for list
                shrinkWrap:
                    true, // Allow ListView to wrap inside the scrollable container
                itemBuilder: (context, index) {
                  final item = _employeeHours?[index];
                  return TimesheetTile(
                    firstName: item!.firstName,
                    lastName: item.lastName,
                    showModal: () {
                      _showFullScreenAddRecipeDialog(index);
                    },
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
