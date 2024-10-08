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
  List<Recipe> filteredItems = []; //me dunno if this worky yet:) 

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
  final PageController _pageController = PageController();

  int currentPage = 0;
  int totalPages = 3; // Total number of pages (adjust based on actual content)

  bool isDoneEnabled = false;
  int quantity = 1; // Quantity controlled by plus and minus buttons

  List<String> pageHeaders = ["Ingredients", "Equipment", "Instructions"];
  List<Recipe> recipeNames = [];
  List<Recipe> filteredRecipes = []; // List to hold filtered recipes

  bool? available;

  Future<void> _retrieveRecipeNames(String category) async {
    final url = Uri.parse('$baseURL/api/recipeNames?category=$category');
    final headers = {
      'Content-Type': 'application/json',
    };
    try {
      final response = await http.get(url, headers: headers);
      var parsed = jsonDecode(response.body) as List;
      if (response.statusCode == 200) {
        // populate the recipeNames list of Recipes.
        recipeNames = parsed.map((json) => Recipe.fromJson(json)).toList();
        setState(() {});
      } else {
        setState(() {});
      }
    } catch (error) {
      // error handle
      recipeNames = [Recipe(recipeID: "", recipeName: error.toString())];
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    _retrieveRecipeNames(widget.category);
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
        // adds all the info needed for the 3 pages of the recipe pop-up
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
      final body = jsonEncode({'recipeID': recipe.recipeID, 'num': quantity});
      final response = await http.post(url, headers: headers, body: body);
      //var parsed = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // iterate through the JSON to check all availabilities
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
      var parsed = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // iterate through the JSON to check all availabilities
        print(parsed);
        for (int i = 0; i < parsed.length; i++) {
          if (parsed[i]['available'] == 0) {
            // if any ONE of the ingredients has insufficient amounts
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
                  width: MediaQuery.of(context).size.width *
                      0.85, // Make the popup wider
                  height: MediaQuery.of(context).size.height *
                      0.7, // Make the popup longer
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
                              itemCount:
                                  3, // constant 3 pages (ing, equip, inst)
                              onPageChanged: (int index) {
                                setState(() {
                                  currentPage = index;
                                  isDoneEnabled = currentPage ==
                                      totalPages -
                                          1; // Enable "Done" on last page
                                });
                              },
                              itemBuilder: (context, index) {
                                List<String> currentList =
                                    getListForPage(index);
                                return Container(
                                    margin: const EdgeInsets.all(16.0),
                                    color: Theme.of(context)
                                        .primaryColor, // Example colors for different pages
                                    child: SingleChildScrollView(
                                        child: Column(children: [
                                      Text(
                                        pageHeaders[
                                            index], // Example page content
                                        style: const TextStyle(fontSize: 24),
                                      ),
                                      const Divider(),
                                      // black magic from ChatGPT to do what I need :)
                                      // had to sell my soul to the devil for this one
                                      ...currentList.map((item) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 4.0),
                                          child: Text(
                                            item,
                                            style:
                                                const TextStyle(fontSize: 18),
                                          )))
                                    ])));
                              },
                            ),
                          ),
                          available == false
                              ? const Text(
                                  'One or more ingredients are unavailable!',
                                  style: TextStyle(
                                    color: Colors.red,
                                    fontSize: 16,
                                  ),
                                )
                              : Container(), //
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  iconSize:
                                      40, // Increase the size of the minus button
                                  onPressed: () {
                                    setState(() {
                                      if (quantity > 1) {
                                        quantity--; // Decrease quantity, cap at 0
                                      }
                                    });
                                  },
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal:
                                          20.0), // Add space between buttons and number
                                  child: Text(
                                    '$quantity',
                                    style: const TextStyle(
                                        fontSize: 28), // Make the count larger
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  iconSize:
                                      40, // Increase the size of the plus button
                                  onPressed: () async {
                                    await _checkRecipeIngredients(
                                        recipe, quantity);
                                    setState(() {
                                      if (available != null) {
                                        if (available == true &&
                                            quantity < 10) {
                                          quantity++; // Increase quantity, cap at 10
                                        }
                                      }
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              minimumSize: const Size.fromHeight(
                                  50), // "Start Baking" button spans the bottom
                              backgroundColor: isDoneEnabled
                                  ? Colors.green
                                  : Colors.grey, // Button color
                            ),
                            onPressed: isDoneEnabled
                                ? () => _startBaking(recipe, quantity)
                                : null, // Only enable on last page
                            child: const Text(
                              'Start Baking',
                              style: TextStyle(
                                fontSize: 18, // Increase font size
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (currentPage >
                          0) // Show left arrow if not on the first page
                        Positioned(
                          left: 0,
                          top: MediaQuery.of(context).size.height * 0.25,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_left, size: 40),
                            onPressed: () {
                              _pageController.previousPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
                        ),
                      if (currentPage <
                          totalPages -
                              1) // Show right arrow if not on the last page
                        Positioned(
                          right: 0,
                          top: MediaQuery.of(context).size.height * 0.25,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_right, size: 40),
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 300),
                                curve: Curves.easeInOut,
                              );
                            },
                          ),
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
      // Show a loading indicator while checking the session
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
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
              // Handle logout logic here
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
            _buildDrawerTile('Dashboard',Icons.house_outlined,const ManagerHomePage()),
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
            _buildDrawerTile('Admin',Icons.admin_panel_settings_sharp,const AdminPage(),),
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
          itemCount: recipeNames.length,
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
                // pass in the ID here so we can immediately GET recipeInfo.
                _getRecipeInfo(recipeNames[index]);
              },
              child: Text(recipeNames[index].recipeName),
            );
          },
        ),
      ),
    );
  }
}
