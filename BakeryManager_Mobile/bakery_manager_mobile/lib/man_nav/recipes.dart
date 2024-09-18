import 'package:flutter/material.dart';
import 'package:bakery_manager_mobile/man_nav/clockinout.dart';
import 'package:bakery_manager_mobile/man_nav/settings.dart';
import 'package:bakery_manager_mobile/man_nav/admin.dart';
import 'package:bakery_manager_mobile/man_nav/inventory.dart';
import 'package:bakery_manager_mobile/man_nav/timesheets.dart';
import 'package:bakery_manager_mobile/widgets/manager_home_page.dart';


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

  // Recipe popup that matches Employee popup
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
                width: MediaQuery.of(context).size.width * 0.85, // Popup width
                height: MediaQuery.of(context).size.height * 0.7, // Popup height
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
                        // PageView for recipe steps
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
                                color: Colors.grey[(index + 1) * 100], // Placeholder page content
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
                        // Plus and Minus Buttons for quantity selection
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove_circle_outline),
                                iconSize: 40, // Larger button size
                                onPressed: () {
                                  setState(() {
                                    if (quantity > 0) quantity--; // Decrease quantity, cap at 0
                                  });
                                },
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 20.0), // Space between buttons and number
                                child: Text(
                                  '$quantity',
                                  style: const TextStyle(fontSize: 28), // Larger quantity display
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle_outline),
                                iconSize: 40, // Larger button size
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
                        // Start Baking button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size.fromHeight(50), // Button spans width
                            backgroundColor: isDoneEnabled ? Colors.green : Colors.grey, // Enabled only on last page
                          ),
                          onPressed: isDoneEnabled ? () => Navigator.pop(context) : null, // Close dialog if enabled
                          child: const Text(
                            'Start Baking',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Left arrow navigation
                    if (currentPage > 0)
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
                    // Right arrow navigation
                    if (currentPage < totalPages - 1)
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
                      _navigateToPage(const RecipesPage(category: 'Muffins'));
                    },
                  ),
                ),
              ],
            ),
            ListTile(
              title: const Text('Inventory'),
              leading: const Icon(Icons.inventory_2_outlined),
              onTap: () {
                _navigateToPage(const InventoryPage());
              },
            ),
            ListTile(
              title: const Text('Time Sheets'),
              leading: const Icon(Icons.access_time),
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
              title: const Text('Admin'),
              leading: const Icon(Icons.admin_panel_settings_sharp),
              onTap: () {
                _navigateToPage(const AdminPage());
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
        color: Colors.grey[200], // Set background to match dashboard
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