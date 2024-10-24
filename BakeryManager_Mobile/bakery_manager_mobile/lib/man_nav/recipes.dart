import 'package:bakery_manager_mobile/widgets/manager_home_page.dart';
import 'package:bakery_manager_mobile/man_nav/timesheets.dart';
import 'package:bakery_manager_mobile/man_nav/clockinout.dart';
import 'package:bakery_manager_mobile/man_nav/inventory.dart';
import 'package:bakery_manager_mobile/man_nav/settings.dart';
import 'package:bakery_manager_mobile/env/env_config.dart';
import 'package:bakery_manager_mobile/man_nav/admin.dart';
import 'package:flutter/cupertino.dart';

import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../widgets/landing_page.dart';

class Recipe {
  final String recipeID;
  final String recipeName;
  List<String> recipeIngredients = [];
  List<String> recipeEquipment = [];
  List<String> recipeInstructions = [];

  Recipe({
    required this.recipeID,
    required this.recipeName,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) {
    return Recipe(
      recipeID: json['RecipeID'],
      recipeName: json['Name'],
    );
  }
}

class RecipesPage extends StatefulWidget {
  final String category;

  const RecipesPage({super.key, required this.category});

  @override
  State<RecipesPage> createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  final PageController _pageController = PageController();

  int currentPage = 0;
  int totalPages = 3; // Total number of pages (adjust based on actual content)

  bool isDoneEnabled = false;
  int quantity = 1; // Quantity controlled by plus and minus buttons

  List<String> pageHeaders = ["Ingredients", "Equipment", "Instructions"];
  List<Recipe> recipeNames = [];
  List<Recipe> filteredRecipes = []; // List to hold filtered recipes

  bool? available;

  @override
  void initState() {
    super.initState();
    _retrieveRecipeNames(widget.category).then((_) {
      setState(() {
        filteredRecipes = List.from(recipeNames);
      });
    });
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController
        .removeListener(_filterItems); // Remove the listener on dispose
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text
        .trim()
        .toLowerCase(); // Trim spaces and convert to lowercase
    setState(() {
      if (query.isEmpty) {
        filteredRecipes =
            List.from(recipeNames); // If the query is empty, show all items
      } else {
        filteredRecipes = recipeNames.where((item) {
          final itemName =
              item.recipeName.toLowerCase(); // Convert item name to lowercase
          return itemName
              .startsWith(query); // Match based on the start of the name
        }).toList();
      }
    });
  }

  Future<void> _retrieveRecipeNames(String category) async {
    final url = Uri.parse('$baseURL/api/recipeNames?category=$category');
    final headers = {
      'Content-Type': 'application/json',
    };
    try {
      final response = await http.get(url, headers: headers);
      var parsed = jsonDecode(response.body) as List;
      if (response.statusCode == 200) {
        recipeNames = parsed.map((json) => Recipe.fromJson(json)).toList();
        filteredRecipes = recipeNames; // Initially show all recipes
        setState(() {});
      } else {
        setState(() {});
      }
    } catch (error) {
      recipeNames = [Recipe(recipeID: "", recipeName: error.toString())];
      filteredRecipes = recipeNames; // Handle error by showing message
      setState(() {});
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

  Future<void> _getRecipeInfo(Recipe recipe) async {
    try {
      final url =
          Uri.parse('$baseURL/api/recipeInfo?recipeID=${recipe.recipeID}');
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      var parsed = jsonDecode(response.body);
      String ingredients = parsed['Ingredients'] as String;
      String equipment = parsed['Equipment'] as String;
      String instructions = parsed['Instructions'] as String;

      if (response.statusCode == 200) {
        recipe.recipeIngredients = ingredients.split(', ');
        recipe.recipeEquipment = equipment.split(', ');
        recipe.recipeInstructions = instructions.split(', ');
        _showRecipeOptions(recipe);
      } else {
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: Text('Could not load ${recipe.recipeName} information'),
              );
            },
          );
        }
      }
    } catch (error) {
      print('Error logging out: $error');
    }
  }

  Future<void> _startBaking(Recipe recipe, int quantity) async {
    try {
      final url = Uri.parse('$baseURL/api/startBaking');
      final headers = {'Content-Type': 'application/json'};
      //var parsed = jsonDecode(response.body);

      final body = jsonEncode({'recipeID': recipe.recipeID, 'num': quantity});
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        print('YIPPEEE');
        setState(() {});
      } else {
        print(response.statusCode);
        setState(() {});
      }
    } catch (error) {
      print(error);
      setState(() {});
    }
  }

  Future<void> _checkRecipeIngredients(Recipe recipe, int quantity) async {
    try {
      final url = Uri.parse(
          '$baseURL/api/checkRecipeIngredients?recipeID=${recipe.recipeID}&quantity=$quantity');
      final response =
          await http.get(url, headers: {'Content-Type': 'application/json'});
      var parsed = jsonDecode(response.body) as List;
      if (response.statusCode == 200) {
        for (int i = 0; i < parsed.length; i++) {
          if (parsed[i]['available'] == 0) {
            available = false;
            setState(() {});
            return;
          }
        }
        available = true;
        setState(() {});
      } else {
        setState(() {
          available = false;
        });
      }
    } catch (error) {
      print(error);
      setState(() {
        available = false;
      });
    }
  }

  void _showRecipeOptions(Recipe recipe) {
    List<String> getListForPage(index) {
      if (index == 0) {
        return recipe.recipeIngredients;
      } else if (index == 1) {
        return recipe.recipeEquipment;
      } else if (index == 2) {
        return recipe.recipeInstructions;
      }
      return [];
    }

    if (mounted) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
                return SizedBox(
                  width: MediaQuery.of(context).size.width * 0.85,
                  height: MediaQuery.of(context).size.height * 0.7,
                  child: Stack(
                    children: [
                      Column(
                        children: [
                          Center(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16.0),
                              child: Text(
                                recipe.recipeName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          Expanded(
                            child: PageView.builder(
                              controller: _pageController,
                              itemCount: 3,
                              onPageChanged: (int index) {
                                setState(() {
                                  currentPage = index;
                                  isDoneEnabled = currentPage == totalPages - 1;
                                });
                              },
                              itemBuilder: (context, index) {
                                List<String> currentList =
                                    getListForPage(index);
                                return Container(
                                    margin: const EdgeInsets.all(16.0),
                                    color: Theme.of(context).primaryColor,
                                    child: SingleChildScrollView(
                                        child: Column(children: [
                                      Text(
                                        pageHeaders[index],
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const Divider(),
                                      ...currentList.map((item) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Text(
                                            item,
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ))),
                                    ])));
                              },
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back),
                                onPressed: currentPage == 0
                                    ? null
                                    : () {
                                        setState(() {
                                          currentPage--;
                                          _pageController.previousPage(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        });
                                      },
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward),
                                onPressed: currentPage == totalPages - 1
                                    ? null
                                    : () {
                                        setState(() {
                                          currentPage++;
                                          _pageController.nextPage(
                                            duration: const Duration(
                                                milliseconds: 300),
                                            curve: Curves.easeInOut,
                                          );
                                        });
                                      },
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: quantity > 1
                                    ? () {
                                        setState(() {
                                          quantity--;
                                        });
                                        _checkRecipeIngredients(
                                            recipe, quantity);
                                      }
                                    : null,
                              ),
                              Text(
                                quantity.toString(),
                                style: const TextStyle(fontSize: 18),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: quantity < 10
                                    ? () {
                                        setState(() {
                                          quantity++;
                                        });
                                        _checkRecipeIngredients(
                                            recipe, quantity);
                                      }
                                    : null,
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          available == null
                              ? Container()
                              : available == true
                                  ? const Text(
                                      'Available!',
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold),
                                    )
                                  : const Text(
                                      'Not available',
                                      style: TextStyle(
                                          fontSize: 24,
                                          color: Colors.red,
                                          fontWeight: FontWeight.bold),
                                    ),
                          const SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: available == true
                                ? () {
                                    _startBaking(recipe, quantity);
                                  }
                                : null,
                            child: const Text('Start Baking'),
                          ),
                          const SizedBox(height: 10),
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('Close'),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
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

  @override
  Widget build(BuildContext context) {
    if (recipeNames.isEmpty) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text('${widget.category} Recipes'),
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Image.asset('assets/images/leftcorner.png'),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
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
        color: Theme.of(context).primaryColor,
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                ),
                itemCount: filteredRecipes.length, // Use filtered list
                itemBuilder: (context, index) {
                  return ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.black,
                      side: const BorderSide(color: Colors.black),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(7.0),
                      ),
                    ),
                    onPressed: () {
                      _getRecipeInfo(filteredRecipes[index]);
                    },
                    child: Text(filteredRecipes[index].recipeName),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // FloatingActionButton for the 'add recipe' full-page pop-up
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showFullScreenAddRecipe();
        },
        backgroundColor: Colors.white, // Button background color white
        child: const Icon(
          Icons.add,
          size: 36, // Adjust the icon size
          color: Colors.black, // Icon color black
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  void _showFullScreenAddRecipe() {
    final TextEditingController recipeNameController = TextEditingController();
    final TextEditingController ingredientController = TextEditingController();
    final TextEditingController equipmentController = TextEditingController();
    final TextEditingController instructionController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Allows the sheet to take up the full screen - dark magic helped with this part :)
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
                  'Add New Recipe',
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                _buildInputField(
                  controller: recipeNameController,
                  label: 'Recipe Name',
                  hint: 'Enter the recipe name...',
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  controller: ingredientController,
                  label: 'Ingredients',
                  hint: 'Enter ingredients...',
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  controller: equipmentController,
                  label: 'Equipment',
                  hint: 'Enter equipment...',
                ),
                const SizedBox(height: 15),
                _buildInputField(
                  controller: instructionController,
                  label: 'Instructions',
                  hint: 'Enter instructions...',
                ),
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
                      _addNewRecipe(
                        recipeNameController.text,
                        ingredientController.text,
                        equipmentController.text,
                        instructionController.text,
                      );

                      Navigator.of(context).pop(); // Close dialog after adding
                    },
                    child: const Text('Add Recipe'),
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
  void _addNewRecipe(String recipeName, String ingredients, String equipment,
      String instructions) {
    final newRecipe = Recipe(
      recipeID: DateTime.now()
          .millisecondsSinceEpoch
          .toString(), // Unique ID generation
      recipeName: recipeName,
    );

    setState(() {
      recipeNames.add(newRecipe);
      filteredRecipes.add(newRecipe); // Add to filtered list as well
    });
  }
}
