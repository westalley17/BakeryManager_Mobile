import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // account info input controllers
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  // this will be an optional field that will automatically create a manager account
  // if presented with a valid manager ID
  final TextEditingController managerIDController =
      TextEditingController(text: "");

  String? _errorTextFirstName; // simple length checking
  String? _errorTextLastName; // simple length checking
  String? _errorTextUserName; // calls a GET to users to check availability
  String? _errorTextPassword; // RegEx matching to increase security
  String?
      _errorTextManagerID; // calls a GET to managers to check if ID is valid.

  // function to validate name length
  void _validateFirstName(String name) {
    setState(() {
      _errorTextFirstName = "";

      if (name.length < 3) {
        _errorTextFirstName =
            "${_errorTextFirstName!}First name must be 3 characters or more\n";
      }

      if (_errorTextFirstName!.isEmpty) {
        _errorTextFirstName = null;
      }
    });
  }

  // function to validate name length
  void _validateLastName(String name) {
    setState(() {
      _errorTextLastName = "";

      if (name.length < 3) {
        _errorTextLastName =
            "${_errorTextLastName!}Last name must be 3 characters or more\n";
      }

      if (_errorTextLastName!.isEmpty) {
        _errorTextLastName = null;
      }
    });
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
                  padding: const EdgeInsets.fromLTRB(40.0, 10.0, 0, 0),
                  width: 150.0,
                  height: 150.0,
                  child: Image.asset('assets/images/bakerHat.png'),
                ),
                Container(
                  margin: const EdgeInsets.fromLTRB(0, 0.0, 0, 10.0),
                  child: Text(
                    "Create Account",
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
                  margin: const EdgeInsets.fromLTRB(20, 15.0, 20, 10.0),
                  child: TextField(
                    controller: firstNameController,
                    onChanged: (value) {
                      _validateFirstName(value);
                    },
                    decoration: InputDecoration(
                      labelText: 'First Name',
                      errorText: _errorTextFirstName,
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
                  margin: const EdgeInsets.fromLTRB(20, 5.0, 20, 10.0),
                  child: TextField(
                    controller: lastNameController,
                    onChanged: (value) {
                      _validateLastName(value);
                    },
                    decoration: InputDecoration(
                      labelText: 'Last Name',
                      errorText: _errorTextLastName,
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
                  margin: const EdgeInsets.fromLTRB(20, 25.0, 20, 10.0),
                  child: TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      errorText: _errorTextUserName,
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
                  margin: const EdgeInsets.fromLTRB(20, 5.0, 20, 20.0),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      errorText: _errorTextPassword,
                      border: const OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: const Icon(Icons.lock),
                    ),
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 400.0,
                    maxHeight: 100.0,
                  ),
                  margin: const EdgeInsets.fromLTRB(20, 15.0, 20, 10.0),
                  child: TextField(
                    controller: managerIDController,
                    decoration: InputDecoration(
                      labelText: 'Manager ID (Optional)',
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
                        // Handle register logic here
                      },
                      style: ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                          Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                      child: const Text(
                        "Register",
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
