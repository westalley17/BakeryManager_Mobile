import 'package:bakery_manager_mobile/widgets/employee_home_page.dart';
import 'package:bakery_manager_mobile/emp_nav/inventory.dart';
import 'package:bakery_manager_mobile/emp_nav/settings.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bakery_manager_mobile/emp_nav/recipes.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/landing_page.dart';
import 'package:intl/intl.dart';
import '../env/env_config.dart';
import 'dart:convert';
import 'dart:async';

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

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _currentTime = '';
  bool _clockedIn = false; // Toggle between clocked in and out
  Timer? _timer;
  EmpBiWeeks? _empBiWeeks;
  bool _noHours = true; // default true until we RETRIEVE hours from backend

  // Create a 2D list to keep track of selected cells
  List<List<bool>> selectedCells = List.generate(
    7,
    (index) => List.generate(2, (index) => false),
  );

  Future<void> _getClockStatus() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? sessionID = prefs.getString('SessionID');
      String? logID = prefs.getString('LogID');
      if (logID == null || sessionID == null) {
        // do nothing
      } else {
        final url =
            Uri.parse('$baseURL/api/clock?sessionID=$sessionID&logID=$logID');
        final response =
            await http.get(url, headers: {"Content-Type": "application/json"});
        final parsed = jsonDecode(response.body);
        if (response.statusCode == 200) {
          if (parsed["status"] == 1) {
            _clockedIn = true;
          } else {
            _clockedIn = false;
          }
          setState(() {});
        }
      }
    } catch (error) {
      print(error);
    }
  }

  @override
  void initState() {
    super.initState();
    _getEmpHours();
    _getClockStatus();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateFormat('hh:mm:ss a')
              .format(DateTime.now()); // Format the time
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }

  Future<void> _logout() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final sessionID = prefs.getString('SessionID');
      await prefs.remove('SessionID');
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

  Future<void> _toggleClockInOut() async {
    if (_clockedIn == false) {
      // call /api/clockin
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? sessionID = prefs.getString('SessionID');
        if (sessionID == null) {
          // somehow send them back to homescreen?
          print(sessionID);
        } else {
          final url = Uri.parse("$baseURL/api/clockin");
          final headers = {"Content-Type": "application/json"};
          final body = jsonEncode({'sessionID': sessionID});
          final response = await http.post(url, headers: headers, body: body);
          final parsed = jsonDecode(response.body);
          if (response.statusCode == 200) {
            // Confirm clock in
            await prefs.setString('LogID', parsed["logID"]);
          }
        }
      } catch (error) {
        print(error);
      }
    } else {
      // call /api/clockout
      try {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        String? sessionID = prefs.getString('SessionID');
        if (sessionID == null) {
          // somehow send them back to homescreen?
          print(sessionID);
        } else {
          final url = Uri.parse("$baseURL/api/clockout");
          final headers = {"Content-Type": "application/json"};
          final body = jsonEncode({'sessionID': sessionID});
          final response = await http.post(url, headers: headers, body: body);
          if (response.statusCode == 200) {
            // Confirm clock out
            await prefs.remove("LogID");
          }
        }
      } catch (error) {
        print(error);
      }
    }
    setState(() {
      _clockedIn = !_clockedIn; // Toggle clock in/out state
    });
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

  Future<void> _getEmpHours() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? sessionID = prefs.getString('SessionID');
    if (sessionID == null) {
      // send back to home page?
    } else {
      final url =
          Uri.parse('$baseURL/api/employee/employeeHours?sessionID=$sessionID');
      final headers = {
        'Content-Type': 'application/json',
      };
      try {
        final response = await http.get(url, headers: headers);
        var parsed = jsonDecode(response.body);
        if (response.statusCode == 200) {
          _empBiWeeks = EmpBiWeeks.fromJson(parsed);
          _noHours = false; // aka HAS hours
          setState(() {});
        } else if (response.statusCode == 404) {
          _noHours = true;
          setState(() {});
        }
      } catch (error) {
        setState(() {});
      }
    }
  }

  void _showAvailabilityPopup() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Change Availability'),
              content: SizedBox(
                width:
                    MediaQuery.of(context).size.width * 1.5, // Responsive width
                height: MediaQuery.of(context).size.height *
                    0.5, // Responsive height
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Table(
                        border: TableBorder.all(),
                        children: [
                          const TableRow(
                            children: [
                              TableCell(
                                  child: Center(
                                      child:
                                          Text(''))), // Empty cell at top-left
                              TableCell(child: Center(child: Text('Shift 1'))),
                              TableCell(child: Center(child: Text('Shift 2'))),
                            ],
                          ),
                          for (int day = 0; day < 7; day++)
                            TableRow(
                              children: [
                                TableCell(
                                    child: Center(
                                        child: Text([
                                  'Monday',
                                  'Tuesday',
                                  'Wednesday',
                                  'Thursday',
                                  'Friday',
                                  'Saturday',
                                  'Sunday'
                                ][day]))),
                                ...List.generate(2, (shift) {
                                  return TableCell(
                                    child: Center(
                                      child: Checkbox(
                                        value: selectedCells[day][shift],
                                        onChanged: (bool? value) {
                                          setState(() {
                                            selectedCells[day][shift] =
                                                value ?? false;
                                          });
                                        },
                                        activeColor: Colors
                                            .green, // Set checkbox color to green
                                      ),
                                    ),
                                  );
                                }),
                              ],
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                Row(
                  children: [
                    Container(
                      width: 110,
                      height: 40,
                      margin: const EdgeInsets.fromLTRB(0, 0, 50, 0),
                      child: ElevatedButton(
                        onPressed: () {
                          // need to send an update to the backend that updates all of the 14 shifts
                          // but do we REALLYYYY
                          Navigator.of(context).pop(); // Close the dialog
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(12), // Rounded corners
                          ),
                          elevation: 5, // Adds shadow for a lifted effect
                          padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 10), // Adds padding inside the button
                        ),
                        child: const Text(
                          'Update',
                          style: TextStyle(
                            fontSize: 16, // Larger text
                            fontWeight: FontWeight.bold, // Bold text
                            color:
                                Colors.white, // White text color for contrast
                          ),
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Close the dialog
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        foregroundColor: Colors.red, // Red color for the text
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600, // Slightly bolder text
                        ),
                      ),
                      child: const Text('Close'),
                    ),
                  ],
                )
              ],
            );
          },
        );
      },
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
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("Clock In/Out"),
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
            onPressed: () async {
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
                'Dashboard', Icons.house_outlined, const EmployeeHomePage()),
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
              'Clock In/Out',
              Icons.lock_clock,
              const ClockPage(),
            ),
            _buildDrawerTile(
              'Settings',
              Icons.settings_outlined,
              const SettingsPage(),
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity, // Ensure full width
        color: Theme.of(context).primaryColor,
        child: Column(
          children: [
            // Push the time display towards the top
            const SizedBox(height: 100), // Add some space at the top

            // Time display at the top
            Text(
              _currentTime, // Display the real-time clock
              style: const TextStyle(
                fontSize: 48,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            const SizedBox(
                height: 150), // This pushes everything below downwards

            // Clock In/Out button
            SizedBox(
              width: 300, // Adjust the width as needed
              child: ElevatedButton(
                onPressed:
                    _toggleClockInOut, // This function toggles the clock in/out state
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60), // Adjust height
                  backgroundColor: _clockedIn ? Colors.red : Colors.green,
                ),
                child: Text(
                  _clockedIn ? 'Clock Out' : 'Clock In',
                  style: const TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),

            const SizedBox(height: 20), // Spacing between buttons

            // Change Availability button
            SizedBox(
              width: 300, // Adjust the width as needed
              child: ElevatedButton(
                onPressed:
                    _showAvailabilityPopup, // Show the availability popup
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60), // Adjust height
                  backgroundColor: Colors.blue, // Customize the color
                ),
                child: const Text(
                  'Change Availability',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),

            const SizedBox(height: 10), // Add spacing between buttons

            // View Hours button
            SizedBox(
              width: 300, // Adjust the width as needed
              child: ElevatedButton(
                onPressed: () {
                  // Implement your View hours functionality
                  // same thing as the Timesheets view but just for the ONE user

                  showModalBottomSheet(
                    context: context,
                    isScrollControlled:
                        true, // Allows the sheet to take up the full screen - dark magic helped with this part :)
                    backgroundColor: Colors.transparent,
                    builder: (BuildContext context) {
                      return Container(
                        height: MediaQuery.of(context).size.height * 0.95,
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(20),
                            topRight: Radius.circular(20),
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 5,
                              blurRadius: 10,
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
                              const SizedBox(height: 10),
                              const Text(
                                textAlign: TextAlign.center,
                                'Clocked Hours',
                                style: TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const Divider(
                                height: 30.0,
                                color: Colors.black,
                              ),
                              // add EmpBiWeek info here
                              if (!_noHours)
                                _buildInfoRowWithBorder(
                                  'Total Normal Hours',
                                  _empBiWeeks!.totalNormalHours
                                      .toStringAsFixed(2),
                                )
                              else
                                _buildInfoRowWithBorder(
                                  'Total Normal Hours',
                                  '0.00',
                                ),
                              if (!_noHours)
                                _buildInfoRowWithBorder(
                                  'Total Overtime Hours',
                                  _empBiWeeks!.totalOvertimeHours
                                      .toStringAsFixed(2),
                                )
                              else
                                _buildInfoRowWithBorder(
                                  'Total Overtime Hours',
                                  '0.00',
                                ),
                              if (!_noHours)
                                _buildInfoRowWithBorder(
                                  'Total Holiday Hours',
                                  _empBiWeeks!.totalHolidayHours
                                      .toStringAsFixed(2),
                                )
                              else
                                _buildInfoRowWithBorder(
                                  'Total Holiday Hours',
                                  '0.00',
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60), // Adjust height
                  backgroundColor: Colors.orange, // Customize the color
                ),
                child: const Text(
                  'View Hours',
                  style: TextStyle(color: Colors.white, fontSize: 22),
                ),
              ),
            ),

            const SizedBox(
                height: 50), // Add some space at the bottom if needed
          ],
        ),
      ),
    );
  }
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
