import 'dart:convert';

import 'package:bakery_manager_mobile/widgets/manager_home_page.dart';
import 'package:bakery_manager_mobile/man_nav/clockinout.dart';
import 'package:bakery_manager_mobile/man_nav/timesheets.dart';
import 'package:bakery_manager_mobile/man_nav/settings.dart';
import 'package:bakery_manager_mobile/man_nav/recipes.dart';
import 'package:bakery_manager_mobile/man_nav/admin.dart';
import 'package:flutter/material.dart';

import '../env/env_config.dart';
import 'package:http/http.dart' as http;

class InventoryItem {
  final String itemID;
  final String itemName;
  const InventoryItem({required this.itemID, required this.itemName});

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    String itemID = "";
    if (json["ProductID"] != null) {
      itemID = json["ProductID"];
    } else if (json["IngredientID"] != null) {
      itemID = json["IngredientID"];
    } else if (json["VendorID"] != null) {
      return InventoryItem(
        itemID: json["VendorID"],
        itemName: json['VendorName'],
      );
    } else if (json["EquipmentID"] != null) {
      itemID = json["EquipmentID"];
    } else {
      return const InventoryItem(
        itemID: "",
        itemName: "",
      );
    }
    return InventoryItem(
      // could be ProductID, IngredientID, VendorID, etc... need to filter regardless
      itemID: itemID,
      itemName: json['Name'],
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
      // error handle
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _retrieveInventoryNames(widget.category);
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

  // Function for inventory tiles
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
              'Dashboard',
              Icons.house_outlined,
              const ManagerHomePage(),
            ),
            _buildExpansionTile(
              title: 'Recipes',
              icon: Icons.restaurant_menu,
              children: [
                _buildRecipeTile(
                  'Cake',
                  Icons.cake,
                  'Cake',
                ),
                _buildRecipeTile(
                  'Bread',
                  Icons.bakery_dining,
                  'Bread',
                ),
                _buildRecipeTile(
                  'Muffins',
                  Icons.cake_outlined,
                  'Muffins',
                ),
                _buildRecipeTile(
                  'Cookie',
                  Icons.cookie,
                  'Cookie',
                ),
                _buildRecipeTile(
                  'Croissants',
                  Icons.cookie,
                  'Croissants',
                ),
                _buildRecipeTile(
                  'Bagels',
                  Icons.cookie,
                  'Bagels',
                ),
                _buildRecipeTile(
                  'Pies',
                  Icons.cookie,
                  'Pies',
                ),
                _buildRecipeTile(
                  'Brownies',
                  Icons.cookie,
                  'Brownies',
                ),
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
                _buildInventoryTile(
                    'Vendors', Icons.contact_emergency, 'Vendors'),
                _buildInventoryTile('Cleaning Products', Icons.clean_hands,
                    'CleaningEquipment'),
              ],
            ),
            _buildDrawerTile(
              'Time Sheets',
              Icons.access_time,
              const TimePage(),
            ),
            _buildDrawerTile(
              'Clock In/Out',
              Icons.lock_clock,
              const ClockPage(),
            ),
            _buildDrawerTile(
              'Settings',
              Icons.settings_outlined,
              const SettingsPage(),
            ),
            _buildDrawerTile(
              'Admin',
              Icons.admin_panel_settings_sharp,
              const AdminPage(),
            ),
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[200], // Set to the background color of the dashboard
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: inventoryItems.length,
          itemBuilder: (context, index) {
            return ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.black,
                side: const BorderSide(color: Colors.black),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              onPressed: () {
                //################################### Forbidden code
                if (widget.category == "Ingredients") {
                  _getIngredientInfo(inventoryItems[index].itemID);
                } else if (widget.category == "Products") {
                  _getProductInfo(inventoryItems[index].itemID);
                } else if (widget.category == "Vendors") {
                  _getVendorInfo(inventoryItems[index].itemID);
                }
                // else CleaningEquipment
                else {
                  _getEquipmentInfo(inventoryItems[index].itemID);
                }
              },
              child: Text(inventoryItems[index].itemName),
            );
          },
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
