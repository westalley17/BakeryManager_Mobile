import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;

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
  String? _errorTextUsername; // calls a GET to users to check availability
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

  Future<void> _validateUsername(String username) async {
    _errorTextUsername = "";
    // idfk what the endpoint is that will let me know this...
    String url = "http://10.0.2.2:3000/users?email=$username";

    // make a GET to backend to see if username already exists
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      // If the server returns an OK response, set the error to null so box isn't red.
      _errorTextUsername = null;
    } else {
      // If the server returns an error response, set the error to a string so box IS red.
      _errorTextUsername = "Username taken";
    }

    setState(() {}); // updates the state of the context
  }

  void _validatePassword(String password) {
    setState(() {
      _errorTextPassword = null;

      // RegEx matching for length and proper character use.
      if (!RegExp(r'.{8,}').hasMatch(password)) {
        _errorTextPassword = (_errorTextPassword ?? '') +
            "Password must be at least 8 characters long.\n";
      }
      if (!RegExp(r'(?=.*[A-Z])').hasMatch(password)) {
        _errorTextPassword = (_errorTextPassword ?? '') +
            "Password must have at least one uppercase letter.\n";
      }
      if (!RegExp(r'(?=.*[a-z])').hasMatch(password)) {
        _errorTextPassword = (_errorTextPassword ?? '') +
            "Password must have at least one lowercase letter.\n";
      }
      if (!RegExp(r'(?=.*\d)').hasMatch(password)) {
        _errorTextPassword = (_errorTextPassword ?? '') +
            "Password must have at least one number.\n";
      }
      if (!RegExp(r'(?=.*[@$!%*?&])').hasMatch(password)) {
        _errorTextPassword = (_errorTextPassword ?? '') +
            "Password must have at least one special character.\n";
      }
    });
  }

  void _validateManagerID(String? managerID) {
    setState(() {
      _errorTextManagerID = null;

      if (managerID == null) return;

      if (managerID.length != 6) {
        _errorTextManagerID = (_errorTextManagerID ?? '') +
            "Manager ID must be exactly 6 digits.";
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
                    onSubmitted: (value) {
                      //_validateUsername(value);
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
                  margin: const EdgeInsets.fromLTRB(20, 5.0, 20, 20.0),
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
