import 'package:bakery_manager_mobile/widgets/manager_home_page.dart';
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

class IngredientInfo {
  final String vendorName;
  final String ingredientName;
  final String description;
  final String measurement;
  final bool allergen;
  final double totalQuantity;
  final String categoryName;

  const IngredientInfo({
    required this.vendorName,
    required this.ingredientName,
    required this.description,
    required this.measurement,
    required this.allergen,
    required this.totalQuantity,
    required this.categoryName,
  });

  factory IngredientInfo.fromJson(Map<String, dynamic> json) {
    return IngredientInfo(
      vendorName: json['VendorName'],
      ingredientName: json['IngredientName'],
      description: json['IngredientDescription'],
      measurement: json['measurement'],
      allergen: json['Allergen'],
      totalQuantity: double.parse(json['TotalQuantity']),
      categoryName: json['CategoryName'],
    );
  }
}

class ProductInfo {
  final String name;
  final String description;
  final int? shelfLife;

  const ProductInfo(
      {required this.name, required this.description, required this.shelfLife});

  factory ProductInfo.fromJson(Map<String, dynamic> json) {
    return ProductInfo(
      name: json['Name'],
      description: json['Description'],
      shelfLife: json['ShelfLife'],
    );
  }
}

class VendorInfo {
  final String vendorName;
  final String emailAddress;
  final bool emailValid;
  final String areaCode;
  final String phoneNumber;
  final bool phoneValid;
  final String address;
  final bool addressValid;
  final String state;
  final String ingredients;

  const VendorInfo(
      {required this.vendorName,
      required this.emailAddress,
      required this.emailValid,
      required this.areaCode,
      required this.phoneNumber,
      required this.phoneValid,
      required this.address,
      required this.addressValid,
      required this.state,
      required this.ingredients});

  factory VendorInfo.fromJson(Map<String, dynamic> json) {
    return VendorInfo(
      vendorName: json['VendorName'],
      emailAddress: json['emailAddress'],
      emailValid: json['EmailValid'],
      areaCode: json['AreaCode'],
      phoneNumber: json['Number'],
      phoneValid: json['PhoneValid'],
      address: json['Address'],
      addressValid: json['AddressValid'],
      state: json['StateDescription'],
      ingredients: json['Ingredients'],
    );
  }
}

class EquipmentInfo {
  final String name;
  final String status;
  final String serial;
  final String notes;

  const EquipmentInfo(
      {required this.name,
      required this.status,
      required this.serial,
      required this.notes});

  factory EquipmentInfo.fromJson(Map<String, dynamic> json) {
    return EquipmentInfo(
      name: json['Name'],
      status: json['Status'],
      serial: json['SerialNumber'],
      notes: json['Notes'],
    );
  }
}

class InventoryItem {
  final String itemID;
  final String itemName;
  double? quantity;
  String? category;
  InventoryItem(
      {required this.itemID,
      required this.itemName,
      this.quantity,
      this.category});

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
        category: json['Category'],
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
      category: json['Category'],
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
  VoidCallback? showModal;

  InventoryTile(
      {required this.itemName, this.quantity, super.key, this.showModal});

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
            showModal!();
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
  IngredientInfo? _ingredientInfo;
  ProductInfo? _productInfo;
  VendorInfo? _vendorInfo;
  EquipmentInfo? _equipmentInfo;

  final TextEditingController _searchController = TextEditingController();

  Future<void> _showFullScreenAddRecipeDialog(int index) async {
    // use inventoryItems along with "index" to call whichever get*Info we need :)
    InventoryItem invItem = inventoryItems[index];
    String? category = invItem.category;
    if (category == "Ingredients") {
      _getIngredientInfo(invItem.itemID);
    } else if (category == "Products") {
      _getProductInfo(invItem.itemID);
    } else if (category == "Vendors") {
      _getVendorInfo(invItem.itemID);
    } else if (category == "Equipment") {
      _getEquipmentInfo(invItem.itemID);
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.95,
          padding: const EdgeInsets.symmetric(vertical: 24.0, horizontal: 20.0),
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(30),
              topRight: Radius.circular(30),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                spreadRadius: 5,
                blurRadius: 15,
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
                const SizedBox(height: 15),
                const Text(
                  'Inventory Information',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                const Divider(
                  height: 40.0,
                  thickness: 2.0,
                  color: Colors.black,
                ),
                const SizedBox(height: 10),
                // Addison, you will need to use the classes I have made at the top of this file
                // to print out the contents in any way that you want. I just made the classes
                // so that I could keep them organized asf, and you wouldn't have to worry
                // about what all data you have. I am going to start the process of making
                // Widgets out of each of the *Info classes so you can simply call and build them.
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoRowWithBorder(String label, String value) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.black54, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.white.withOpacity(0.05),
            spreadRadius: 2,
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 22,
              color: Colors.black,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

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
        // USE INFO TO POPULATE MODAL
        _ingredientInfo = IngredientInfo.fromJson(parsed);
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
        // USE INFO TO POPULATE MODAL
        _productInfo = ProductInfo.fromJson(parsed);
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
        // USE INFO TO POPULATE MODAL
        _vendorInfo = VendorInfo.fromJson(parsed);
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
        // USE INFO TO POPULATE MODAL
        _equipmentInfo = EquipmentInfo.fromJson(parsed);
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
      await prefs.remove('SessionID');
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
                'Dashboard', Icons.house_outlined, const ManagerHomePage()),
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
                        showModal: () {
                          _showFullScreenAddRecipeDialog(index);
                        },
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
