import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // placeholder code, make this look good
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text("Account Creation"),
              Text("Username"),
              Text("Password"),
              Text("First Name"),
              Text("Last Name"),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text("Return to Home Page"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}