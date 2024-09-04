import 'package:bakery_manager_mobile/man_nav/admin.dart';
import 'package:bakery_manager_mobile/man_nav/clockinout.dart';
import 'package:bakery_manager_mobile/man_nav/inventory.dart';
import 'package:bakery_manager_mobile/man_nav/recipes.dart';
import 'package:bakery_manager_mobile/man_nav/settings.dart';
import 'package:bakery_manager_mobile/widgets/manager_home_page.dart';
import 'package:flutter/material.dart';

class TimePage extends StatefulWidget {
  const TimePage ({super.key});

  @override
  _TimePageState createState() => _TimePageState();
}

class _TimePageState extends State<TimePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _navigateToPage(Widget page) {
    Navigator.pop(context); // Close the drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: const Text("TimeSheets"),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Image.asset('assets/images/leftcorner.png'), // Use the stack image
          onPressed: () {
            // Open the drawer using the ScaffoldKey
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              // Maybe navigate back to the login page -- come back and do this later :)
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
              padding: const EdgeInsets.only(top: 10.0, bottom: 0.0), // Adjusted padding
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
              title: const Text('Dashboard'),
              leading: const Icon(Icons.house_outlined),
              onTap: () {
                _navigateToPage(const ManagerHomePage()); // Navigate to ManagerHomePage
              },
            ),
            ListTile(
              title: const Text('Recipes'),
              leading: const Icon(Icons.bakery_dining),
              onTap: () {
                _navigateToPage(const RecipesPage()); // Navigate to TimePage
              },
            ),
            ListTile(
              title: const Text('Inventory'),
              leading: const Icon(Icons.inventory_2_outlined),
              onTap: () {
                _navigateToPage(const InventoryPage()); // Navigate to InventoryPage
              },
            ),
            ListTile(
              title: const Text('Clock In/Out'),
              leading: const Icon(Icons.lock_clock),
              onTap: () {
                _navigateToPage(const ClockPage()); // Navigate to ClockPage
              },
            ),
            ListTile(
              title: const Text('Settings'),
              leading: const Icon(Icons.settings_outlined),
              onTap: () {
                _navigateToPage(const SettingsPage()); // Navigate to ClockPage
              },
            ),
            ListTile(
              title: const Text('Admin'),
              leading: const Icon(Icons.admin_panel_settings_sharp),
              onTap: () {
                _navigateToPage(const AdminPage()); // Navigate to ClockPage
                // Add navigation or functionality here -- Addison reminder
              },
            ),
            // Add more items after getting these first ones to work right
          ],
        ),
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0), // Adjusted padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recipe List',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView(
                children: [
                  RecipeTile(
                    title: 'Chocolate Cake',
                    description: 'Delicious and rich chocolate cake recipe.',
                  ),
                  RecipeTile(
                    title: 'Apple Pie',
                    description: 'Classic apple pie with a flaky crust.',
                  ),
                  RecipeTile(
                    title: 'Cheese Pizza',
                    description: 'Simple cheese pizza with tomato sauce and mozzarella.',
                  ),
                  // Add more recipes here
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class RecipeTile extends StatelessWidget {
  final String title;
  final String description;

  const RecipeTile({
    required this.title,
    required this.description,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(description),
        leading: const Icon(Icons.restaurant_menu),
        onTap: () {
          // Handle recipe tap if needed
        },
      ),
    );
  }
}