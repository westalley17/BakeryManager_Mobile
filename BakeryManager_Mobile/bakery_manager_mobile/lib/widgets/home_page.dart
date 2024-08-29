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
              // add baker hat here :),
              Container(
                margin: const EdgeInsets.fromLTRB(0, 100.0, 0, 10.0),
                child: Text(
                  "Bakery Manager",
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
                margin: const EdgeInsets.fromLTRB(0, 25.0, 0, 0),
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {},
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
                margin: const EdgeInsets.fromLTRB(0, 5.0, 0, 0),
                child: SizedBox(
                  width: 150,
                  child: ElevatedButton(
                    onPressed: () {},
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
                margin: const EdgeInsets.fromLTRB(0, 15.0, 0, 0),
                child: SizedBox(
                  width: 100,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll(
                        Color(0xFFF6F3F3),
                      ),
                    ),
                    child: Text(
                      "Register",
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
