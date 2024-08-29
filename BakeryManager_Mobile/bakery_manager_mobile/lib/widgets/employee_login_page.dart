import 'package:flutter/material.dart';

class EmployeeLoginPage extends StatefulWidget {
  const EmployeeLoginPage({super.key});

  @override
  State<EmployeeLoginPage> createState() => _EmployeeLoginPageState();
}

class _EmployeeLoginPageState extends State<EmployeeLoginPage> {
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
              Text("Employee Login Page"),
              Text("Username"),
              Text("Password"),
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
