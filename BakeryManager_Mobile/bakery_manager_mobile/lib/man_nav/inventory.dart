import 'package:bakery_manager_mobile/widgets/manager_home_page.dart';
import 'package:bakery_manager_mobile/man_nav/clockinout.dart';
import 'package:bakery_manager_mobile/man_nav/timesheets.dart';
import 'package:bakery_manager_mobile/man_nav/settings.dart';
import 'package:bakery_manager_mobile/man_nav/recipes.dart';
import 'package:bakery_manager_mobile/man_nav/admin.dart';
import 'package:flutter/material.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({super.key});

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

  Widget _buildDrawerTile({
    required String title,
    required IconData icon,
    required Widget page,
  }) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: () => _navigateToPage(page),
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
            _buildDrawerTile(
              title: 'Dashboard',
              icon: Icons.house_outlined,
              page: const ManagerHomePage(),
            ),
            _buildExpansionTile(
              title: 'Recipes',
              icon: Icons.restaurant_menu,
              children: [
                _buildDrawerTile(
                  title: 'Cake',
                  icon: Icons.cake,
                  page: const RecipesPage(category: 'Cake'),
                ),
                _buildDrawerTile(
                  title: 'Bread',
                  icon: Icons.bakery_dining,
                  page: const RecipesPage(category: 'Bread'),
                ),
                _buildDrawerTile(
                  title: 'Muffins',
                  icon: Icons.cake_outlined,
                  page: const RecipesPage(category: 'Muffins'),
                ),
              ],
            ),
            _buildDrawerTile(
              title: 'Time Sheets',
              icon: Icons.access_time,
              page: const TimePage(),
            ),
            _buildDrawerTile(
              title: 'Clock In/Out',
              icon: Icons.lock_clock,
              page: const ClockPage(),
            ),
            _buildDrawerTile(
              title: 'Settings',
              icon: Icons.settings_outlined,
              page: const SettingsPage(),
            ),
            _buildDrawerTile(
              title: 'Admin',
              icon: Icons.admin_panel_settings_sharp,
              page: const AdminPage(),
            ),
          ],
        ),
      ),
      body: Container(
      color: Theme.of(context).primaryColor,  // Reverted to previous color
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Inventory List',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20.0),
          Expanded(
            child: ListView(
              children: const [
                InventoryTile(
                  itemName: 'Flour',
                  quantity: '50 kg',
                ),
                InventoryTile(
                  itemName: 'Sugar',
                  quantity: '30 kg',
                ),
                InventoryTile(
                  itemName: 'Butter',
                  quantity: '20 kg',
                ),
              ],
            ),
          ),
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
