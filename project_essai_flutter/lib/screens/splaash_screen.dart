import 'dart:async';
import 'package:flutter/material.dart';
import 'login_page.dart';  

class SplashScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    _startSplashScreen(context);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Image.asset('assets/logo.jfif', height: 200),  
            SizedBox(height: 10),
          
            Text(
              'TENMAR | Petit bateau',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            Text(
              ' Durabilité, Qualité, Liberté',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            SizedBox(height: 20),
            CircularProgressIndicator(  valueColor: AlwaysStoppedAnimation(Color.fromARGB(255, 13, 18, 70)),  
),  
          ],
        ),
      ),
    );
  }

  void _startSplashScreen(BuildContext context) {
    Timer(Duration(seconds: 5), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }
}
