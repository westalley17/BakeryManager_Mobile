import 'package:bakery_manager_mobile/widgets/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

class ManagerLoginPage extends StatelessWidget {
  const ManagerLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Center(
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
              const Divider(
                height: 10,
                thickness: 0.5,
                indent: 25,
                endIndent: 25,
                color: Colors.black,
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 25.0, 20, 10.0),
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Username',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(20, 10.0, 20, 20.0),
                child: TextField(
                  obscureText: true,
                  decoration: InputDecoration(
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
                      backgroundColor: MaterialStatePropertyAll(
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
                margin: const EdgeInsets.fromLTRB(0, 15.0, 0, 0),
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
    );
  }
}
