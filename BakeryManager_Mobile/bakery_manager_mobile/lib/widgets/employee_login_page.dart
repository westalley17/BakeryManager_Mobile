import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class EmployeeLoginPage extends StatefulWidget {
  const EmployeeLoginPage({super.key});

  @override
  State<EmployeeLoginPage> createState() => _EmployeeLoginPageState();
}

class _EmployeeLoginPageState extends State<EmployeeLoginPage> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

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
                    decoration: const InputDecoration(
                      labelText: 'Username',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                ),
                Container(
                  constraints: const BoxConstraints(
                    maxWidth: 400.0,
                    maxHeight: 100.0,
                  ),
                  margin: const EdgeInsets.fromLTRB(20, 10.0, 20, 20.0),
                  child: TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
                      prefixIcon: Icon(Icons.lock),
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
