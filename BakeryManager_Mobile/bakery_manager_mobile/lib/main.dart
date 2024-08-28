import 'package:bakery_manager_mobile/widgets/login_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const BakeryManager());
}

class BakeryManager extends StatelessWidget {
  const BakeryManager({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: LoginPage(),
    );
  }
}
