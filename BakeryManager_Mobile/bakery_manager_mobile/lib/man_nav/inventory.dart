import 'package:bakery_manager_mobile/widgets/manager_home_page.dart';
import 'package:bakery_manager_mobile/man_nav/clockinout.dart';
import 'package:bakery_manager_mobile/man_nav/timesheets.dart';
import 'package:bakery_manager_mobile/man_nav/settings.dart';
import 'package:bakery_manager_mobile/man_nav/recipes.dart';
import 'package:bakery_manager_mobile/man_nav/admin.dart';
import 'package:flutter/material.dart';

import '../env/env_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class InventoryItem {
  final String itemID;
  final String itemName;
  double? quantity;
  InventoryItem({required this.itemID, required this.itemName, this.quantity});

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    String itemID = "";
    double? quantity;
    if (json["ProductID"] != null) {
      itemID = json["ProductID"];
    } else if (json["IngredientID"] != null) {
      itemID = json["IngredientID"];
      quantity = json['Quantity'] as double;
    } else if (json["VendorID"] != null) {
      return InventoryItem(
        itemID: json["VendorID"],
        itemName: json['VendorName'],
      );
    } else if (json["EquipmentID"] != null) {
      itemID = json["EquipmentID"];
    } else {
      return InventoryItem(
        itemID: "",
        itemName: "",
      );
    }
    return InventoryItem(
      itemID: itemID,
      itemName: json['Name'],
      quantity: quantity,
    );
  }
}

class InventoryPage extends StatefulWidget {
  final String category;
  const InventoryPage({super.key, required this.category});

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<InventoryItem> inventoryItems = [];
  List<InventoryItem> filteredItems = [];  // This will store the filtered items
  final TextEditingController _searchController = TextEditingController();

  Future<void> _retrieveInventoryNames(String category) async {
    final url = Uri.parse('$baseURL/api/inventoryItems?category=$category');
    final headers = {
      'Content-Type': 'application/json',
    };
    try {
      final response = await http.get(url, headers: headers);
      var parsed = jsonDecode(response.body) as List;
      if (response.statusCode == 200) {
        inventoryItems =
            parsed.map((json) => InventoryItem.fromJson(json)).toList();
        setState(() {});
      } else {
        setState(() {});
      }
    } catch (error) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _retrieveInventoryNames(widget.category);
  }

  void _filterItems() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredItems = inventoryItems
          .where((item) => item.itemName.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getIngredientInfo(String ingredientID) async {
    try {
      final url =
          Uri.parse('$baseURL/api/ingredientInfo?ingredientID=$ingredientID');
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      var parsed = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // make pop-up here :)
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return const Dialog(
                child: Text('Could not load information'),
              );
            },
          );
        }
      }
    } catch (error) {
      print('Error logging out: $error');
    }
  }

  Future<void> _getProductInfo(String productID) async {
    try {
      final url = Uri.parse('$baseURL/api/productInfo?productID=$productID');
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      var parsed = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // make pop-up here :)
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return const Dialog(
                child: Text('Could not load information'),
              );
            },
          );
        }
      }
    } catch (error) {
      print('Error logging out: $error');
    }
  }

  Future<void> _getVendorInfo(String vendorID) async {
    try {
      final url = Uri.parse('$baseURL/api/vendorInfo?vendorID=$vendorID');
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      var parsed = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // make pop-up here :)
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return const Dialog(
                child: Text('Could not load information'),
              );
            },
          );
        }
      }
    } catch (error) {
      print('Error logging out: $error');
    }
  }

  Future<void> _getEquipmentInfo(String equipmentID) async {
    try {
      final url =
          Uri.parse('$baseURL/api/equipmentInfo?equipmentID=$equipmentID');
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      var parsed = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // make pop-up here :)
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return const Dialog(
                child: Text('Could not load information'),
              );
            },
          );
        }
      }
    } catch (error) {
      print('Error logging out: $error');
    }
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
            onPressed: () => Navigator.pop(context),
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
            _buildDrawerTile('Dashboard',Icons.house_outlined,const ManagerHomePage(),
            ),
            _buildExpansionTile(
              title: 'Recipes',
              icon: Icons.restaurant_menu,
              children: [
                _buildRecipeTile('Cake', Icons.cake, 'Cake'),
                _buildRecipeTile('Bread', Icons.bakery_dining, 'Bread'),
                _buildRecipeTile('Muffins', Icons.cake_outlined, 'Muffins'),
                _buildRecipeTile('Cookie', Icons.cookie, 'Cookie'),
              ],
            ),
            _buildExpansionTile(
              title: 'Inventory',
              icon: Icons.inventory_2_outlined,
              children: [
                _buildInventoryTile(
                    'Raw Ingredients', Icons.egg, 'Ingredients'),
                _buildInventoryTile('Finished Products',
                    Icons.breakfast_dining_rounded, 'Products'),
                _buildInventoryTile('Vendors', Icons.local_shipping, 'Vendors'),
                _buildInventoryTile(
                    'Equipment', Icons.kitchen_outlined, 'Equipment'),
              ],
            ),
            _buildDrawerTile(
              'Timesheets',
              Icons.watch_later,
              const TimePage(),
            ),
            _buildDrawerTile(
              'Clock In/Out',
              Icons.access_time_outlined,
              const ClockPage(),
            ),
            _buildDrawerTile(
              'Admin',
              Icons.admin_panel_settings,
              const AdminPage(),
            ),
            _buildDrawerTile(
              'Settings',
              Icons.settings,
              const SettingsPage(),
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                    Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) => _filterItems(), // Filters items as you type
                      decoration: InputDecoration(
                        hintText: 'Search',
                        filled: true,
                        fillColor: Colors.white, // White background for the search bar
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none, // Remove the border
                        ),
                        prefixIcon: const Icon(Icons.search, color: Colors.black),
                      ),
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ListView.builder(
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable inner scroll for list
                    shrinkWrap:
                        true, // Allow ListView to wrap inside the scrollable container
                    itemCount: inventoryItems.length,
                    itemBuilder: (context, index) {
                      final item = inventoryItems[index];
                      return InventoryTile(
                        itemName: item.itemName,
                        quantity: (item.quantity != null) ? item.quantity : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ignore: must_be_immutable
class InventoryTile extends StatelessWidget {
  final String itemName;
  double? quantity;

  InventoryTile({
    required this.itemName,
    this.quantity,
    super.key,
  });

  // Function to map inventory item names to icons
  IconData _getIconForItem(String itemName) {
    switch (itemName.toLowerCase()) {
      case 'egg':
        return Icons.egg;
      case 'flour':
        return Icons.bakery_dining;
      case 'milk':
        return Icons.local_drink;
      case 'sugar':
        return Icons.cookie;
      case 'butter':
        return Icons.cake;
      case 'cheese':
        return Icons.emoji_food_beverage;
      default:
        return Icons.inventory; // Default icon for other items
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        leading: Icon(_getIconForItem(itemName)), // Display the icon here
        title: Text(
          itemName,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        subtitle: (quantity != null) ? Text('Quantity: $quantity') : null,
        trailing: IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () {
            // Add navigation to item details
          },
        ),
      ),
    );
  }
}
