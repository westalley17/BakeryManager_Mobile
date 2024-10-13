import 'package:bakery_manager_mobile/widgets/employee_home_page.dart';
import 'package:bakery_manager_mobile/emp_nav/clockinout.dart';
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
      quantity = double.parse(json['Quantity']);
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
        subtitle: (quantity != null)
            ? Text('Quantity: ${quantity!.toStringAsFixed(2)}')
            : null,
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
    _searchController
        .removeListener(_filterItems); // Remove the listener on dispose
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
          filteredItems =
              List.from(inventoryItems); // Initialize with all items
        });
      }
    } catch (error) {
      print('Error retrieving inventory names: $error');
    }
  }

  void _filterItems() {
    final query = _searchController.text
        .trim()
        .toLowerCase(); // Trim spaces and convert to lowercase
    setState(() {
      if (query.isEmpty) {
        filteredItems =
            List.from(inventoryItems); // If the query is empty, show all items
      } else {
        filteredItems = inventoryItems.where((item) {
          final itemName =
              item.itemName.toLowerCase(); // Convert item name to lowercase
          return itemName
              .startsWith(query); // Match based on the start of the name
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
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return Dialog(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.0),
                    ),
                    child: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return SizedBox(
                          width: MediaQuery.of(context).size.width * 0.85,
                          height: MediaQuery.of(context).size.height *
                              0.3, // Adjust height
                          child: Padding(
                            padding: const EdgeInsets.all(
                                16.0), // Padding around content
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 40.0,
                                  height: 40.0,
                                  child: Icon(Icons.error),
                                ),
                                const Text(
                                  'Are you sure you want to sign out?',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const Divider(
                                  thickness: 0.8,
                                  color: Colors.black,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                  ),
                                  onPressed: () async {
                                    await _logout();
                                  },
                                  child: const Text(
                                    "Sign Out",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              );
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize:
              const Size.fromHeight(60.0), // Set the size of the search bar
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search Recipes...',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
        ),
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
            _buildDrawerTile(
                'Dashboard', Icons.house_outlined, const EmployeeHomePage()),
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
                _buildInventoryTile(
                    'Products', Icons.breakfast_dining_rounded, 'Products'),
                _buildInventoryTile('Vendors', Icons.local_shipping, 'Vendors'),
                _buildInventoryTile(
                    'Equipment', Icons.kitchen_outlined, 'Equipment'),
              ],
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
          ],
        ),
      ),
      body: SafeArea(
        child: Scrollbar(
          child: SingleChildScrollView(
            child: Container(
              color: Theme.of(context).primaryColor,
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20.0),
                  ListView.builder(
                    physics:
                        const NeverScrollableScrollPhysics(), // Disable inner scroll for list
                    shrinkWrap:
                        true, // Allow ListView to wrap inside the scrollable container
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index];
                      return InventoryTile(
                        itemName: item.itemName,
                        quantity:
                            (item.quantity != null) ? item.quantity : null,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    floatingActionButton: FloatingActionButton(
    onPressed: () {
    _showFullScreenAddRecipe(); },
    backgroundColor: Colors.white, // Button background color white
    child: const Icon(
      Icons.add,
      size: 36,  // Adjust the icon size
      color: Colors.black, // Icon color black
    ),
  ),
  floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
  );
}

// Define the full-screen pop-up function
void _showFullScreenAddRecipe() {
  final TextEditingController recipeNameController = TextEditingController();
  final TextEditingController ingredientController = TextEditingController();
  final TextEditingController equipmentController = TextEditingController();
  final TextEditingController instructionController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled: true, // Allows the sheet to take up the full screen - dark magic helped with this part :) 
    backgroundColor: Colors.transparent, 
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.95, 
        padding: const EdgeInsets.all(16.0), 
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 5,
              blurRadius: 10,
            ),
          ], 
        ),
        child: SingleChildScrollView( 
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    Navigator.of(context).pop(); 
                  },
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Add to the Inventory',
                style: TextStyle(
                  fontSize: 26, 
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20), 
              _buildInputField(
                controller: recipeNameController,label: 'What is it? ',hint: 'Enter the name here...',
              ),
              const SizedBox(height: 15), 
              _buildInputField(
                controller: ingredientController,label: 'Amount',hint: 'Enter amount here...',
              ),
              const SizedBox(height: 15), 
              const SizedBox(height: 20), 
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32.0,
                      vertical: 12.0,
                    ), // Larger button
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    _addNewRecipe(recipeNameController.text,ingredientController.text,equipmentController.text,instructionController.text,
                    );
                    Navigator.of(context).pop(); // Close dialog after adding
                  },
                  child: const Text('Finish!'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

// Build consistent input fields
Widget _buildInputField({
  required TextEditingController controller,
  required String label,
  required String hint,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      const SizedBox(height: 8), // Add space between label and input
      TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: hint,
          filled: true,
          fillColor: Colors.grey[200], // Light grey background for input
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.0),
            borderSide: BorderSide.none, // Remove default border
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14.0,
            horizontal: 16.0,
          ),
        ),
      ),
    ],
  );
}


// Define the function to handle adding the new recipe
void _addNewRecipe(String recipeName, String ingredients, String equipment, String instructions) {
}
}