import 'package:bakery_manager_mobile/widgets/employee_login_page.dart';
import 'package:bakery_manager_mobile/widgets/manager_login_page.dart';
import 'package:bakery_manager_mobile/widgets/register_page.dart';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // add baker hat here :)
              Container(
                padding: const EdgeInsets.fromLTRB(40.0, 0, 0, 0),
                width: 200.0,
                height: 200.0,
                child: Image.asset('assets/images/bakerHat.png'),
              ),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 60.0, 0, 10.0),
                child: Text(
                  "Bakery Manager",
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
                margin: const EdgeInsets.fromLTRB(0, 25.0, 0, 0),
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const ManagerLoginPage(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    child: const Text(
                      "Manager Login",
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
                margin: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const EmployeeLoginPage(),
                        ),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                    child: const Text(
                      "Employee Login",
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
                margin: const EdgeInsets.fromLTRB(0, 10.0, 0, 0),
                child: SizedBox(
                  width: 130,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (context) => const RegisterPage(),
                        ),
                      );
                    },
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Color(0xFFF6F3F3),
                      ),
                    ),
                    child: Text(
                      "Add Account",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}