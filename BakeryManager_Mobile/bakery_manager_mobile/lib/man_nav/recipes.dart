import 'package:bakery_manager_mobile/widgets/manager_home_page.dart';
import 'package:bakery_manager_mobile/man_nav/timesheets.dart';
import 'package:bakery_manager_mobile/man_nav/clockinout.dart';
import 'package:bakery_manager_mobile/man_nav/clockinout.dart';
import 'package:bakery_manager_mobile/man_nav/inventory.dart';
import 'package:bakery_manager_mobile/man_nav/settings.dart';
import 'package:bakery_manager_mobile/env/env_config.dart';
import 'package:bakery_manager_mobile/man_nav/admin.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';


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
  final PageController _pageController = PageController();

  int currentPage = 0;
  int totalPages = 3; // Total number of pages (adjust based on actual content)

  bool isDoneEnabled = false;
  int quantity = 0; // Quantity controlled by plus and minus buttons

  List<String> pageHeaders = ["Ingredients", "Equipment", "Instructions"];
  List<Recipe> recipeNames = [];

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
                                      if (quantity > 0) {
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
                                  onPressed: () {
                                    setState(() {
                                      if (quantity < 10) {
                                        quantity++; // Increase quantity, cap at 10
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
                                ? () => Navigator.pop(context)
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
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              padding: const EdgeInsets.only(top: 10.0, bottom: 0.0),
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
            ListTile(
              title: const Text('Dashboard'),
              leading: const Icon(Icons.house_outlined),
              onTap: () {
                _navigateToPage(const ManagerHomePage());
              },
            ),
            ExpansionTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Recipes'),
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Cake'),
                    leading: const Icon(Icons.cake),
                    onTap: () {
                      _navigateToPage(const RecipesPage(category: 'Cake'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Bread'),
                    leading: const Icon(Icons.bakery_dining),
                    onTap: () {
                      _navigateToPage(const RecipesPage(category: 'Bread'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Muffins'),
                    leading: const Icon(Icons.cake_outlined),
                    onTap: () {
                      _navigateToPage(const RecipesPage(category: 'Muffin'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Cookies'),
                    leading: const Icon(Icons.cookie_outlined),
                    onTap: () {
                      _navigateToPage(const RecipesPage(category: 'Cookies'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Croissants'),
                    leading: const Icon(Icons.cookie_sharp),
                    onTap: () {
                      _navigateToPage(const RecipesPage(category: 'Croissants'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Bagels'),
                    leading: const Icon(Icons.cookie_sharp),
                    onTap: () {
                      _navigateToPage(const RecipesPage(category: 'Bagels'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Pies'),
                    leading: const Icon(Icons.pie_chart_outline_outlined),
                    onTap: () {
                      _navigateToPage(const RecipesPage(category: 'Pies'));
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 16.0),
                  child: ListTile(
                    title: const Text('Brownies'),
                    leading: const Icon(Icons.cookie_sharp),
                    onTap: () {
                      _navigateToPage(const RecipesPage(category: 'Brownies'));
                    },
                  ),
                ),
              ],
            ),
            ListTile(
              title: const Text('Inventory'),
              leading: const Icon(Icons.inventory),
              onTap: () {
                _navigateToPage(const InventoryPage());
              },
            ),
            ListTile(
              title: const Text('Timesheets'),
              leading: const Icon(Icons.timer_sharp),
              onTap: () {
                _navigateToPage(const TimePage());
              },
            ),
            ListTile(
              title: const Text('Clock In/Out'),
              leading: const Icon(Icons.lock_clock),
              onTap: () {
                _navigateToPage(const ClockPage());
              },
            ),
            ListTile(
              title: const Text('Settings'),
              leading: const Icon(Icons.settings_outlined),
              onTap: () {
                _navigateToPage(const SettingsPage());
              },
            ),
            ListTile(
              title: const Text('Admin'),
              leading: const Icon(Icons.admin_panel_settings),
              onTap: () {
                _navigateToPage(const AdminPage());
              },
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