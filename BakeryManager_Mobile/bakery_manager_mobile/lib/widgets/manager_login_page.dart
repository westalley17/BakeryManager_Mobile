import 'package:flutter/material.dart';

class ManagerLoginPage extends StatefulWidget {
  const ManagerLoginPage({super.key});

  @override
  State<ManagerLoginPage> createState() => _ManagerLoginPageState();
}

class _ManagerLoginPageState extends State<ManagerLoginPage> {
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
              Text("Manager Login Page"),
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
