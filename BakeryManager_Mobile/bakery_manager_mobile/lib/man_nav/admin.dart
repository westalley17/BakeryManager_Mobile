import 'package:bakery_manager_mobile/widgets/manager_home_page.dart';
import 'package:bakery_manager_mobile/man_nav/clockinout.dart';
import 'package:bakery_manager_mobile/man_nav/timesheets.dart';
import 'package:bakery_manager_mobile/man_nav/inventory.dart';
import 'package:bakery_manager_mobile/man_nav/settings.dart';
import 'package:bakery_manager_mobile/man_nav/recipes.dart';

import 'package:flutter/material.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
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
        title: const Text("Admin Page"),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Image.asset('assets/images/leftcorner.png'), // Use the stack image
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
            _buildDrawerTile('Dashboard',Icons.house_outlined,const ManagerHomePage()),
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
            _buildDrawerTile('Admin',Icons.admin_panel_settings,const AdminPage()),
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

// RecipeTile widget for displaying each recipe
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
