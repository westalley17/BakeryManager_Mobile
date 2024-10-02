import 'package:bakery_manager_mobile/widgets/employee_home_page.dart';
import 'package:bakery_manager_mobile/emp_nav/clockinout.dart';
import 'package:bakery_manager_mobile/emp_nav/settings.dart';
import 'package:bakery_manager_mobile/env/env_config.dart';
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

class SearchBarApp extends StatefulWidget {
  const SearchBarApp({super.key});

  @override
  State<SearchBarApp> createState() => _SearchBarAppState();
}

class _SearchBarAppState extends State<SearchBarApp> {
  bool isDark = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = ThemeData(
        useMaterial3: true,
        brightness: isDark ? Brightness.dark : Brightness.light);

    return MaterialApp(
      theme: themeData,
      home: Scaffold(
        appBar: AppBar(title: const Text('Search Bar Sample')),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SearchAnchor(
              builder: (BuildContext context, SearchController controller) {
            return SearchBar(
              controller: controller,
              padding: const WidgetStatePropertyAll<EdgeInsets>(
                  EdgeInsets.symmetric(horizontal: 16.0)),
              onTap: () {
                controller.openView();
              },
              onChanged: (_) {
                controller.openView();
              },
              leading: const Icon(Icons.search),
              trailing: <Widget>[
                Tooltip(
                  message: 'Change brightness mode',
                  child: IconButton(
                    isSelected: isDark,
                    onPressed: () {
                      setState(() {
                        isDark = !isDark;
                      });
                    },
                    icon: const Icon(Icons.wb_sunny_outlined),
                    selectedIcon: const Icon(Icons.brightness_2_outlined),
                  ),
                )
              ],
            );
          }, suggestionsBuilder:
                  (BuildContext context, SearchController controller) {
            return List<ListTile>.generate(5, (int index) {
              final String item = 'item $index';
              return ListTile(
                title: Text(item),
                onTap: () {
                  setState(() {
                    controller.closeView(item);
                  });
                },
              );
            });
          }),
        ),
      ),
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
    _retrieveRecipeNames(widget.category);
    _searchController.addListener(() {
      _filterRecipes(_searchController.text);
    });
  }

 

  void _navigateToPage(Widget page) {
    Navigator.pop(context); // Close the drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
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

  void _filterRecipes(String query) {
    if (query.isEmpty) {
      filteredRecipes = recipeNames;
    } else {
      filteredRecipes = recipeNames
          .where((recipe) =>
              recipe.recipeName.toLowerCase().contains(query.toLowerCase()))
          .toList();
    }
    setState(() {});
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
      
      final body = jsonEncode({
        'recipeID': recipe.recipeID,
        'num': quantity
      });
      final response =
          await http.post(url, headers: headers, body: body);
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
      var parsed = jsonDecode(response.body);
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
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
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
                                List<String> currentList = getListForPage(index);
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
                _navigateToPage(const EmployeeHomePage());
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
                    leading: const Icon(Icons.cake_sharp),
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
                      _navigateToPage(const RecipesPage(category: 'Muffins'));
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
                      _navigateToPage(
                          const RecipesPage(category: 'Croissants'));
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
          ],
        ),
      ),
      body: Container(
        color: Colors.grey[200], // Set to the background color of the dashboard
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
                        borderRadius: BorderRadius.circular(8.0),
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
    );
  }
}
