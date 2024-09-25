import 'package:bakery_manager_mobile/widgets/manager_home_page.dart';
import 'package:bakery_manager_mobile/man_nav/clockinout.dart';
import 'package:bakery_manager_mobile/man_nav/timesheets.dart';
import 'package:bakery_manager_mobile/man_nav/recipes.dart';
import 'package:bakery_manager_mobile/man_nav/admin.dart';
import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

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
        title: const Text("Settings"),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Image.asset('assets/images/leftcorner.png'), // Stack image for drawer
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              Navigator.pop(context); // Handle logout
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
            _buildDrawerTile('Dashboard', Icons.house_outlined, const ManagerHomePage()),
            ExpansionTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Recipes'),
              children: [
                _buildRecipeTile('Cake', Icons.cake, 'Cake'),
                _buildRecipeTile('Bread', Icons.bakery_dining,'Bread'),
                _buildRecipeTile('Muffins', Icons.cake_outlined, 'Muffins'),
                _buildRecipeTile('Cookies', Icons.cookie, 'Cookies'), // Adjust as per actual page
                _buildRecipeTile('Croissants', Icons.cookie_outlined, 'Croissants'), // Adjust as per actual page
                _buildRecipeTile('Bagels', Icons.cookie_rounded, 'Bagels'),
                _buildRecipeTile('Pies', Icons.cookie_sharp, 'Pies'),
                _buildRecipeTile('Brownies', Icons.cookie, 'Brownies'),
              ],
            ),
            ExpansionTile(
              leading: const Icon(Icons.inventory_2_outlined),
              title: const Text('Inventory'),
              children: [
                _buildRecipeTile('Raw Ingredients', Icons.egg, 'Raw Ingredients'),
                _buildRecipeTile('Finished Products', Icons.breakfast_dining_rounded, 'Finished Products'),
                _buildRecipeTile('Vendors', Icons.contact_emergency, 'Vendors'),
                _buildRecipeTile('Cleaning Products', Icons.clean_hands, 'Cleaning Products'),
              ],
            ),
            _buildDrawerTile('Time Sheets', Icons.access_time, const TimePage()),
            _buildDrawerTile('Clock In/Out', Icons.lock_clock, const ClockPage()),
            _buildDrawerTile('Admin', Icons.admin_panel_settings_sharp, const AdminPage()),
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
              'Recipe List',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20.0),
            Expanded(
              child: ListView(
                children: const [
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
