import 'dart:convert';
import 'package:bakery_manager_mobile/env/env_config.dart';
import 'package:bakery_manager_mobile/widgets/employee_home_page.dart';
import 'package:bakery_manager_mobile/widgets/manager_home_page.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';


void main() {
  runApp(const BakeryManager());
}

class BakeryManager extends StatefulWidget {
  const BakeryManager({super.key});

  @override
  State<BakeryManager> createState() => _BakeryManagerState();
}

class _BakeryManagerState extends State<BakeryManager> {
  bool? _validSession;
  bool _isManager = false; // example of fail safe state

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? sessionID = prefs.getString('SessionID');
      if (sessionID == null) {
        setState(() {
          // update _validSession
          _validSession = false;
        });
        return;
      } else {
        final url = Uri.parse("$baseURL/api/sessions?sessionID=$sessionID");
        final headers = {
          'Content-Type': 'application/json',
        };
        final response = await http.get(
          url,
          headers: headers,
        );
        var parsed = jsonDecode(response.body);
        if (response.statusCode == 200) {
          setState(() {
            // update _validSession
            _validSession = true;
            _isManager = (parsed['isManager'] == 'false') ? false : true;
          });
        } else {
          await prefs.remove('SessionID');
          // If the server returns an error response, set the error to a string so box IS red.
          setState(() {
            // update _validSession
            _validSession = false;
          });
        }
      }
    } catch (error) {
      // error handle if POST fails entirely which it probably will
      print(error);
    }
  }

  Widget _dashboard() {
    return (_isManager == true)
        ? const ManagerHomePage()
        : const EmployeeHomePage();
  }

  @override
  Widget build(BuildContext context) {
    if (_validSession == null) {
      // Show a loading indicator while checking the session
      return const MaterialApp(
        home: Scaffold(
          body: Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
    return MaterialApp(
      // add comments to all this later, I'm eepy
      // no longer eepy, just need to test Azure pipeline :)
      debugShowCheckedModeBanner: false,
      // conditionally render homepage if Session is invalid, else render whichever dashboard they need to go to.
      home: (_validSession! == false) ? const EmployeeHomePage() : _dashboard(),
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
