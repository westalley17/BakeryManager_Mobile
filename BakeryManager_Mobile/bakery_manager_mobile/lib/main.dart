import 'package:bakery_manager_mobile/widgets/employee_home_page.dart';
import 'package:flutter/material.dart';
//import 'package:bakery_manager_mobile/widgets/home_page.dart';

void main() {
  runApp(const BakeryManager());
}

class BakeryManager extends StatelessWidget {
  const BakeryManager({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // add comments to all this later, I'm eepy
      // no longer eepy, just need to test Azure pipeline :)
      debugShowCheckedModeBanner: false,
      home: const EmployeeHomePage(),
      theme: ThemeData(
        primaryColor: const Color(0xFFFFFBED),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          secondary: const Color(0xFF493936),
        ),
        fontFamily: "BakeryManagerFont",
        textTheme: const TextTheme(
          titleLarge: TextStyle(
            color: Color(0xFF493936),
            fontSize: 34.0,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
