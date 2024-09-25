import 'package:bakery_manager_mobile/widgets/manager_home_page.dart';
import 'package:bakery_manager_mobile/man_nav/clockinout.dart';
import 'package:bakery_manager_mobile/man_nav/timesheets.dart';
import 'package:bakery_manager_mobile/man_nav/settings.dart';
import 'package:bakery_manager_mobile/man_nav/recipes.dart';
import 'package:bakery_manager_mobile/man_nav/admin.dart';
import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  final String category;
  const InventoryPage({super.key, required this.category});

  @override
  _InventoryPageState createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
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
  
  // Function for recipe tiles
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
            onPressed: () => Navigator.pop(context), // Add navigation to login
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
            _buildDrawerTile('Dashboard',Icons.house_outlined,const ManagerHomePage(),),
            _buildExpansionTile(title: 'Recipes',icon: Icons.restaurant_menu,
              children: [
                _buildRecipeTile('Cake',Icons.cake,'Cake', ),
                _buildRecipeTile('Bread',Icons.bakery_dining,'Bread',),
                _buildRecipeTile('Muffins',Icons.cake_outlined,'Muffins',),
                _buildRecipeTile('Cookie',Icons.cookie,'Cookie', ),
                _buildRecipeTile('Croissants',Icons.cookie,'Croissants',),
                _buildRecipeTile('Bagels',Icons.cookie,'Bagels',),
                _buildRecipeTile('Pies',Icons.cookie,'Pies',),
                _buildRecipeTile('Brownies',Icons.cookie,'Brownies',),
              ],
            ),
            _buildExpansionTile(title: 'Inventory',icon: Icons.inventory_2_outlined,
              children: [
                _buildRecipeTile('Raw Ingredients', Icons.egg, 'Raw Ingredients'),
                _buildRecipeTile('Finished Products', Icons.breakfast_dining_rounded, 'Finished Products'),
                _buildRecipeTile('Vendors', Icons.contact_emergency, 'Vendors'),
                _buildRecipeTile('Cleaning Products', Icons.clean_hands, 'Cleaning Products'),
              ],
            ),
            _buildDrawerTile('Time Sheets',Icons.access_time,const TimePage(),),
            _buildDrawerTile('Clock In/Out',Icons.lock_clock,const ClockPage(),),
            _buildDrawerTile('Settings',Icons.settings_outlined,const SettingsPage(),),
            _buildDrawerTile('Admin',Icons.admin_panel_settings_sharp,const AdminPage(),),
          ],
        ),
      ),
    );
  }
}

class InventoryTile extends StatelessWidget {
  final String itemName;
  final String quantity;

  const InventoryTile({
    required this.itemName,
    required this.quantity,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          itemName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: Text(quantity),
        leading: const Icon(Icons.inventory_2_outlined),
      ),
    );
  }
}
