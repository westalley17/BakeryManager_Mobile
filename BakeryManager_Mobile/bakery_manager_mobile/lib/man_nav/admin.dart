import 'package:bakery_manager_mobile/widgets/manager_home_page.dart';
import 'package:bakery_manager_mobile/man_nav/inventory.dart';
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

  // Helper function to avoid redundancy in creating drawer tiles
  Widget _buildDrawerTile(String title, IconData icon, Widget page) {
    return ListTile(
      title: Text(title),
      leading: Icon(icon),
      onTap: () => _navigateToPage(page),
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
                _buildDrawerTile('Cake', Icons.cake, const RecipesPage(category: 'Cake')),
                _buildDrawerTile('Bread', Icons.bakery_dining, const RecipesPage(category: 'Bread')),
                _buildDrawerTile('Muffins', Icons.cake_outlined, const RecipesPage(category: 'Muffins')),
              ],
            ),
            _buildDrawerTile('Inventory', Icons.inventory_2_outlined, const InventoryPage()),
            _buildDrawerTile('Time Sheets', Icons.access_time, const ManagerHomePage()), // Adjust as per actual page
            _buildDrawerTile('Clock In/Out', Icons.lock_clock, const ManagerHomePage()), // Adjust as per actual page
            _buildDrawerTile('Settings', Icons.settings_outlined, const ManagerHomePage()), // Adjust as per actual page
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
