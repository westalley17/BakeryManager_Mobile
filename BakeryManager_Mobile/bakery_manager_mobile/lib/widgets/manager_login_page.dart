import 'dart:convert';
import 'package:bakery_manager_mobile/widgets/manager_home_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ManagerLoginPage extends StatefulWidget {
  const ManagerLoginPage({super.key});

  @override
  State<ManagerLoginPage> createState() => _ManagerLoginPageState();
}

class _ManagerLoginPageState extends State<ManagerLoginPage> {
  // controllers are needed to manage state of input fields needed to log in
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController managerIDController = TextEditingController();

  String? _errorTextUsername; // calls a GET to users to check availability
  String? _errorTextPassword; // RegEx matching to increase security
  String?
      _errorTextManagerID; // calls a GET to managers to check if ID is valid.

  void _validateUsername(String username) {
    setState(() {
      _errorTextUsername = "";

      // make a GET to backend to see if username already exists

      if (_errorTextUsername!.isEmpty) {
        _errorTextUsername = null;
      }
    });
  }

  void _validatePassword(String password) {
    setState(() {
      _errorTextPassword = null;

      // RegEx matching for length and proper character use.
      if (!RegExp(r'.{8,}').hasMatch(password)) {
        _errorTextPassword = "${_errorTextPassword ?? ''}Password must be at least 8 characters long.\n";
      }
      if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
        _errorTextPassword = "${_errorTextPassword ?? ''}Password must have at least one uppercase letter.\n";
      }
      if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
        _errorTextPassword = "${_errorTextPassword ?? ''}Password must have at least one lowercase letter.\n";
      }
      if (!RegExp(r'(?=.*\d)').hasMatch(password)) {
        _errorTextPassword = "${_errorTextPassword ?? ''}Password must have at least one number.\n";
      }
      if (!RegExp(r'(?=.*[@$!%*?&])').hasMatch(password)) {
        _errorTextPassword = "${_errorTextPassword ?? ''}Password must have at least one special character.\n";
      }
    });
  }

  void _validateManagerID(String? managerID) {
    setState(() {
      _errorTextManagerID = null;

      if (managerID == null) return;

      if (managerID.length != 6) {
        _errorTextManagerID = "${_errorTextManagerID ?? ''}Manager ID must be exactly 6 digits.";
      }
    });
  }

  bool _checkInputs() {
    _validateUsername(usernameController.text);
    _validatePassword(passwordController.text);
    _validateManagerID(managerIDController.text);

    if (!(_errorTextUsername == null) ||
        !(_errorTextPassword == null) ||
        !(_errorTextManagerID == null)) {
      setState(() {});
      return false; // this block just makes the register button do nothing while errors are showing
    }

    return true;
  }

  Future<void> _loginUser() async {
    if (_checkInputs()) {
      final url = Uri.parse('http://10.0.2.2:3000/api/sessions/manager');
      final headers = {
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
        'managerID': managerIDController.text,
      });
      try {
        final response = await http.post(url, headers: headers, body: body);
        if (response.statusCode == 200) {
          var parsed = jsonDecode(response.body);
          // login good, take them to the dashboard and store their SessionID in SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('SessionID', parsed['session']);
          if (mounted) {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => const ManagerHomePage(),
              ),
            );
          }
        } else {
          _errorTextPassword = response.body;
          setState(() {});
        }
      } catch (error) {
        // error handle if POST fails entirely which it probably will
        _errorTextPassword = error.toString();
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Center(
          // scrollview makes our page... scrollable :D
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // baker hat added again cause I liked it here :)
                Container(
                  padding: const EdgeInsets.fromLTRB(40.0, 0, 0, 0),
                  width: 200.0,
                  height: 200.0,
                  child: Image.asset('assets/images/bakerHat.png'),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 60.0, 0, 10.0),
                  child: Text(
                    "Manager Login",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 450.0,
                    maxHeight: 100.0,
                  ),
                  child: const Divider(
                    height: 10,
                    thickness: 0.5,
                    indent: 25,
                    endIndent: 25,
                    color: Colors.black,
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 400.0,
                    maxHeight: 100.0,
                  ),
                  margin: const EdgeInsets.fromLTRB(20, 25.0, 20, 10.0),
                  child: TextField(
                    controller: usernameController,
                    onEditingComplete: () {
                      _validateUsername(usernameController.text);
                    },
                    decoration: InputDecoration(
                      labelText: 'Username',
                      errorText: _errorTextUsername,
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.person),
                    ),
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 400.0,
                    maxHeight: 100.0,
                  ),
                  margin: const EdgeInsets.fromLTRB(20, 10.0, 20, 0.0),
                  child: TextField(
                    controller: passwordController,
                    onChanged: (value) {
                      _validatePassword(value);
                    },
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: _errorTextPassword != null ? '' : null,
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                ),
                // error field below the password
                if (_errorTextPassword !=
                    null) // Only show if there is an error
                  Text(
                    _errorTextPassword!,
                    style: const TextStyle(color: Colors.red, fontSize: 13.0),
                  ),
                // error field end
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 400.0,
                    maxHeight: 100.0,
                  ),
                  margin: const EdgeInsets.fromLTRB(20, 15.0, 20, 10.0),
                  child: TextField(
                    controller: managerIDController,
                    onChanged: (value) {
                      _validateManagerID(value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Manager ID (Required)',
                      errorText: _errorTextManagerID,
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.settings),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 20.0, 0, 0),
                  child: SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () {
                        // Handle login logic here
                        _loginUser();
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      child: const Text(
                        "Login",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14.0,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 5.0, 0, 0),
                  child: TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Back to Home",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
