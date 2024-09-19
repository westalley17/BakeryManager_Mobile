import 'package:bakery_manager_mobile/widgets/employee_home_page.dart';
import 'package:bakery_manager_mobile/emp_nav/settings.dart';
import 'package:bakery_manager_mobile/emp_nav/recipes.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

class ClockPage extends StatefulWidget {
  const ClockPage({super.key});

  @override
  _ClockPageState createState() => _ClockPageState();
}

class _ClockPageState extends State<ClockPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  String _currentTime = '';
  bool _clockedIn = false; // Toggle between clocked in and out

  // Create a 2D list to keep track of selected cells
  List<List<bool>> selectedCells = List.generate(
    7,
    (index) => List.generate(2, (index) => false),
  );

  @override
  void initState() {
    super.initState();
    _startClock(); // Start the real-time clock
  }

  void _startClock() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateFormat('hh:mm:ss a')
              .format(DateTime.now()); // Format the time
        });
      }
    });
  }

  void _toggleClockInOut() {
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
            onPressed: () {
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
                _navigateToPage(const EmployeeHomePage());
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
              ],
            ),
            ListTile(
              title: const Text('Clock In/Out'),
              leading: const Icon(Icons.lock_clock),
              onTap: () {
                _navigateToPage(const ClockPage());
              },
            ),
            ListTile(
              title: const Text('Settings'),
              leading: const Icon(Icons.settings_outlined),
              onTap: () {
                _navigateToPage(const SettingsPage());
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
                  backgroundColor: _clockedIn ? Colors.red : Colors.green,
                ),
                child: Text(
                  _clockedIn ? 'Clock Out' : 'Clock In',
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
