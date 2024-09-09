import 'dart:convert';
import 'package:bakery_manager_mobile/widgets/employee_home_page.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EmployeeLoginPage extends StatefulWidget {
  const EmployeeLoginPage({super.key});

  @override
  State<EmployeeLoginPage> createState() => _EmployeeLoginPageState();
}

class _EmployeeLoginPageState extends State<EmployeeLoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  String? _errorTextUsername; // calls a GET to users to check availability
  String? _errorTextPassword; // RegEx matching to increase security

  void _validateUsername(String username) {
    setState(() {
      _errorTextUsername = null;

      if (usernameController.text == "") {
        _errorTextUsername = "Username cannot be blank";
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

  bool _checkInputs() {
    _validateUsername(usernameController.text);
    _validatePassword(passwordController.text);

    if (!(_errorTextUsername == null) || !(_errorTextPassword == null)) {
      setState(() {});
      return false; // this block just makes the register button do nothing while errors are showing
    }

    return true;
  }

  Future<void> _loginUser() async {
    if (_checkInputs()) {
      final url = Uri.parse('http://10.0.2.2:3000/api/sessions/employee');
      final headers = {
        'Content-Type': 'application/json',
      };
      final body = jsonEncode({
        'username': usernameController.text,
        'password': passwordController.text,
      });
      try {
        final response = await http.post(url, headers: headers, body: body);
        if (response.statusCode == 200) {
          var parsed = jsonDecode(response.body);
          // login good, take them to the dashboard and store their SessionID in SharedPreferences
          try {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('SessionID', parsed['session']);
          } catch (error) {
            print('Error saving SessionID: $error');
          }

          if (mounted) {
            Navigator.pushReplacement(
              context,
              CupertinoPageRoute(
                builder: (context) => const EmployeeHomePage(),
              ),
            );
          }
        } else {
          _errorTextPassword = response.statusCode.toString();
        }
      } catch (error) {
        // error handle if POST fails entirely which it probably will
        _errorTextPassword = error.toString();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Center(
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
                    "Employee Login",
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
                    onSubmitted: (value) {
                      _validateUsername(value);
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
