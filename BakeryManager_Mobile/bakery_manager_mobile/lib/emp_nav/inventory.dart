
import 'package:bakery_manager_mobile/widgets/employee_home_page.dart';
import 'package:bakery_manager_mobile/emp_nav/clockinout.dart';
import 'package:bakery_manager_mobile/emp_nav/timesheets.dart';
import 'package:bakery_manager_mobile/emp_nav/settings.dart';
import 'package:bakery_manager_mobile/emp_nav/recipes.dart';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../env/env_config.dart';
import 'dart:convert';

import '../widgets/landing_page.dart';

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


class _InventoryPageState extends State<InventoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  List<InventoryItem> inventoryItems = [];
  List<InventoryItem> filteredItems = []; 
  final TextEditingController _searchController = TextEditingController();

@override
  void initState() {
    super.initState();
    _retrieveInventoryNames(widget.category).then((_) {
      // Initialize filteredItems with the full inventoryItems list
      setState(() {
        filteredItems = List.from(inventoryItems); // Copy all items initially
      });
    });

    // Add a listener to dynamically filter items as the search text changes
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.removeListener(_filterItems); // Remove the listener on dispose
    _searchController.dispose();
    super.dispose();
  }

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
        setState(() {
          filteredItems = List.from(inventoryItems); // Initialize with all items
        });
      }
    } catch (error) {
      print('Error retrieving inventory names: $error');
    }
  }

 void _filterItems() {
  final query = _searchController.text.trim().toLowerCase(); // Trim spaces and convert to lowercase
  setState(() {
    if (query.isEmpty) {
      filteredItems = List.from(inventoryItems); // If the query is empty, show all items
    } else {
      filteredItems = inventoryItems.where((item) {
        final itemName = item.itemName.toLowerCase(); // Convert item name to lowercase
        return itemName.startsWith(query); // Match based on the start of the name
      }).toList();
    }
  });
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
            onPressed: () async {
              await _logout();
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
            _buildDrawerTile('Dashboard',Icons.house_outlined,const EmployeeHomePage()),
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
                _buildInventoryTile('Products',Icons.breakfast_dining_rounded, 'Products'),
                _buildInventoryTile('Vendors', Icons.local_shipping, 'Vendors'),
                _buildInventoryTile('Equipment', Icons.kitchen_outlined, 'Equipment'),
              ],
            ),
            _buildDrawerTile('Time Sheets',Icons.access_time,const TimePage(),),
            _buildDrawerTile('Clock In/Out',Icons.lock_clock,const ClockPage(),),
            _buildDrawerTile('Settings',Icons.settings_outlined,const SettingsPage(),),
          ],
        ),
      ),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Container(
              color: Theme.of(context).primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: TextField(
                      controller: _searchController,
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
                      style: const TextStyle(color: Colors.black),
                    ),
                  ),
                  const SizedBox(height: 20.0),
                  ListView.builder(
                    physics: const NeverScrollableScrollPhysics(), // Disable inner scroll for list
                    shrinkWrap: true, // Allow ListView to wrap inside the scrollable container
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      
                      final item = filteredItems[index];
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