import 'package:bakery_manager_mobile/widgets/manager_home_page.dart';
import 'package:bakery_manager_mobile/man_nav/timesheets.dart';
import 'package:bakery_manager_mobile/man_nav/inventory.dart';
import 'package:bakery_manager_mobile/man_nav/settings.dart';
import 'package:bakery_manager_mobile/man_nav/recipes.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bakery_manager_mobile/env/env_config.dart';
import 'package:bakery_manager_mobile/man_nav/admin.dart';


import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../widgets/landing_page.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'dart:async';




class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  State<ClockPage> createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _currentTime = '';
  bool? _clockedIn; // Toggle between clocked in and out
  Timer? _timer;

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
      if (sessionID == null) {
        // somehow send them back to homescreen?
      } else if (logID == null) {
        _clockedIn = false;
      } else {
        final url =
            Uri.parse('$baseURL/api/clock?sessionID=$sessionID&logID=$logID');
        final response =
            await http.get(url, headers: {'Content-Type': 'application/json'});
        var parsed = jsonDecode(response.body);
        if (response.statusCode == 200) {
          // set _clockedIn to true ONLY IF STATUS RETURNS TRUE TO MAKE SURE
          // THAT WE GENERATE A NEW LOGID FOR A NEW CLOCK TIME :)
          if (parsed['status'] == 1) {
            // aka they ARE clocked in because clockOutTime is null
            _clockedIn = true;
          } else {
            // they are clocked out and we need to be able to generate a new log instance
            _clockedIn = false;
          }
        } else {
          // idk
        }
      }
    } catch (error) {
      print('Error logging out: $error');
    }
  }

  @override
  void initState() {
    super.initState();
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
        } else {
          final url = Uri.parse("$baseURL/api/clockin");
          final headers = {"Content-Type": "application/json"};
          final body = jsonEncode({'sessionID': sessionID});
          final response = await http.post(url, headers: headers, body: body);
          var parsed = jsonDecode(response.body);
          if (response.statusCode == 200) {
            // Confirm clock in
            await prefs.setString('LogID', parsed['logID']);
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
            // remove logID from prefs
            await prefs.remove('LogID');
          }
        }
      } catch (error) {
        print(error);
      }
    }
    setState(() {
      _clockedIn = !_clockedIn!; // Toggle clock in/out state
    });
  }

  void _navigateToPage(Widget page) {
    Navigator.pop(context); // Close the drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
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
                    MediaQuery.of(context).size.width * 0.8, // Responsive width
                height: MediaQuery.of(context).size.height *
                    0.6, // Responsive height
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
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Close'),
                ),
                // Optionally remove the Save button if not needed
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_clockedIn == null) {
      // Show a loading indicator while checking the clock status
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
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
              await _logout();
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              padding: const EdgeInsets.only(top: 10.0, bottom: 0.0),
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
            ListTile(
              title: const Text('Dashboard'),
              leading: const Icon(Icons.house_outlined),
              onTap: () {
                _navigateToPage(const ManagerHomePage());
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Recipes'),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Cake'),
                    leading: const Icon(Icons.cake),
                    onTap: () {
                      _navigateToPage(const RecipesPage(category: 'Cake'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Bread'),
                    leading: const Icon(Icons.bakery_dining),
                    onTap: () {
                      _navigateToPage(const RecipesPage(category: 'Bread'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Muffins'),
                    leading: const Icon(Icons.cake_outlined),
                    onTap: () {
                      _navigateToPage(const RecipesPage(category: 'Muffins'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Cookies'),
                    leading: const Icon(Icons.cookie_outlined),
                    onTap: () {
                      _navigateToPage(const RecipesPage(category: 'Cookies'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Croissants'),
                    leading: const Icon(Icons.cookie_sharp),
                    onTap: () {
                      _navigateToPage(
                          const RecipesPage(category: 'Croissants'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Bagels'),
                    leading: const Icon(Icons.cookie_sharp),
                    onTap: () {
                      _navigateToPage(const RecipesPage(category: 'Bagels'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Pies'),
                    leading: const Icon(Icons.pie_chart_outline_outlined),
                    onTap: () {
                      _navigateToPage(const RecipesPage(category: 'Pies'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Brownies'),
                    leading: const Icon(Icons.cookie_sharp),
                    onTap: () {
                      _navigateToPage(const RecipesPage(category: 'Brownies'));
                    },
                  ),
                ),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Inventory'),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Ingredients'),
                    leading: const Icon(Icons.egg),
                    onTap: () {
                      _navigateToPage(
                          const InventoryPage(category: 'Ingredients'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Finished Products'),
                    leading: const Icon(Icons.breakfast_dining_rounded),
                    onTap: () {
                      _navigateToPage(
                          const InventoryPage(category: 'Finished Products'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Vendors'),
                    leading: const Icon(Icons.contact_emergency),
                    onTap: () {
                      _navigateToPage(const InventoryPage(category: 'Vendors'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Cleaning Products'),
                    leading: const Icon(Icons.clean_hands),
                    onTap: () {
                      _navigateToPage(
                          const InventoryPage(category: 'Cleaning Products'));
                    },
                  ),
                ),
              ],
            ),
            ListTile(
              title: const Text('Timesheets'),
              leading: const Icon(Icons.time_to_leave),
              onTap: () {
                _navigateToPage(const TimePage());
              },
            ),
            ListTile(
              title: const Text('Settings'),
              leading: const Icon(Icons.settings_outlined),
              onTap: () {
                _navigateToPage(const SettingsPage());
              },
            ),
            ListTile(
              title: const Text('Admin'),
              leading: const Icon(Icons.admin_panel_settings),
              onTap: () {
                _navigateToPage(const AdminPage());
              },
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
                  backgroundColor: (_clockedIn != null && _clockedIn! == true)
                      ? Colors.red
                      : Colors.green,
                ),
                child: Text(
                  (_clockedIn != null && _clockedIn! == true)
                      ? 'Clock Out'
                      : 'Clock In',
                  style: const TextStyle(color: Colors.white, fontSize: 20),
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
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ),
            ),

            const SizedBox(height: 10), // Add spacing between buttons

            // Change Hours button
            SizedBox(
              width: 300, // Adjust the width as needed
              child: ElevatedButton(
                onPressed: () {
                  // Implement your change hours functionality
                },
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 60), // Adjust height
                  backgroundColor: Colors.orange, // Customize the color
                ),
                child: const Text(
                  'Change Hours',
                  style: TextStyle(color: Colors.white, fontSize: 20),
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
