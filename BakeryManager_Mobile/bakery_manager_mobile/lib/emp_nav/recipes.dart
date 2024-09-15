import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:bakery_manager_mobile/emp_nav/clockinout.dart';
import 'package:bakery_manager_mobile/emp_nav/settings.dart';
import 'package:bakery_manager_mobile/widgets/employee_home_page.dart';

class RecipesPage extends StatefulWidget {
  final String category;

  const RecipesPage({super.key, required this.category});

  @override
  _RecipesPageState createState() => _RecipesPageState();
}

class _RecipesPageState extends State<RecipesPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final PageController _pageController = PageController();
  int currentPage = 0;
  bool isDoneEnabled = false;
  int quantity = 0; // Quantity controlled by plus and minus buttons

  void _navigateToPage(Widget page) {
    Navigator.pop(context); // Close the drawer
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

void _showRecipeOptions(String recipe) {
  int totalPages = 4; // Total number of pages (adjust based on actual content)
  
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
        ),
        child: StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              width: MediaQuery.of(context).size.width * 0.85, // Make the popup wider
              height: MediaQuery.of(context).size.height * 0.7, // Make the popup longer
              child: Stack(
                children: [
                  Column(
                    children: [
                      Center(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16.0),
                          child: Text(
                            recipe,
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
                          itemCount: totalPages,
                          onPageChanged: (int index) {
                            setState(() {
                              currentPage = index;
                              isDoneEnabled = currentPage == totalPages - 1; // Enable "Done" on last page
                            });
                          },
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.all(16.0),
                              color: Colors.grey[(index + 1) * 100], // Example colors for different pages
                              child: Center(
                                child: Text(
                                  'Page ${index + 1}', // Example page content
                                  style: const TextStyle(fontSize: 20),
                                ),
                              ),
                            );
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
                              iconSize: 40, // Increase the size of the minus button
                              onPressed: () {
                                setState(() {
                                  if (quantity > 0) quantity--; // Decrease quantity, cap at 0
                                });
                              },
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20.0), // Add space between buttons and number
                              child: Text(
                                '$quantity',
                                style: const TextStyle(fontSize: 28), // Make the count larger
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add_circle_outline),
                              iconSize: 40, // Increase the size of the plus button
                              onPressed: () {
                                setState(() {
                                  if (quantity < 10) quantity++; // Increase quantity, cap at 10
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size.fromHeight(50), // "Start Baking" button spans the bottom
                          backgroundColor: isDoneEnabled ? Colors.green : Colors.grey, // Button color
                        ),
                        onPressed: isDoneEnabled ? () => Navigator.pop(context) : null, // Only enable on last page
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
                  if (currentPage > 0) // Show left arrow if not on the first page
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
                  if (currentPage < totalPages - 1) // Show right arrow if not on the last page
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



  @override
  Widget build(BuildContext context) {
    final Map<String, List<String>> recipes = {
      'Cake': ['Chocolate Cake', 'Strawberry Shortcake', 'French Vanilla'],
      'Bread': ['Baguette', 'Sourdough', 'Whole Wheat Bread'],
      'Muffins': ['Pumpkin', 'Banana', 'Blueberry'],
    };

    final List<String> selectedRecipes = recipes[widget.category] ?? [];

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
                      _navigateToPage(const RecipesPage(category: 'Muffins'));
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
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
          ),
          itemCount: selectedRecipes.length,
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
                _showRecipeOptions(selectedRecipes[index]);
              },
              child: Text(selectedRecipes[index]),
            );
          },
        ),
      ),
    );
  }
}
