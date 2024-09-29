import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:project_essai_flutter/mdels/user_login.dart';
import 'package:project_essai_flutter/mdels/user_model.dart';
import 'package:project_essai_flutter/screens/home_page.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _matriculeController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false, 
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 13, 18, 70), 
        title: Text('Login', style: TextStyle(color: Colors.white)),
      ),
      body: Stack(
            alignment: Alignment.center, 
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5), 
            child: Container(
              color: Colors.white, 
            ),
          ),
          Center(
            child: Image.asset(
              'assets/logo.jfif',
              height: 200,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                //SizedBox(height: 30), 
                TextField(
                  controller: _matriculeController,
                  decoration: InputDecoration(labelText: 'Matricule'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: _passwordController,
                  decoration: InputDecoration(labelText: 'Password'),
                  obscureText: true,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 10, 14, 56),
                    textStyle: TextStyle(color: Colors.white), 
                  ),
                  onPressed: () async {
                    final matricule = int.parse(_matriculeController.text);
                    final password = _passwordController.text;
                    
                    
                    try {
                      final token = await Provider.of<ApiService>(context, listen: false)
                          .authenticate(UserLogin(matricule: matricule, password: password));
                      
                      if (token != null) {
                                                  Provider.of<User>(context, listen: false).setMatricule(_matriculeController.text);
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HomePage(token: token),
                          ),
                        );
                      } else {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Erreur'),
                              content: Text('Les informations de connexion sont incorrectes. Veuillez vérifier votre matricule et votre mot de passe.'),
                              actions: [
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color.fromARGB(255, 10, 14, 56),
                                    textStyle: TextStyle(color: Colors.white),
                                  ),
                                  child: Text('OK'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: Text('Erreur'),
                            content: Text('Erreur technique : $e'),
                            actions: [
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 10, 14, 56),
                                  textStyle: TextStyle(color: Colors.white),
                                ),
                                child: Text('OK'),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    }
                  },
                  child: Text('Login', style: TextStyle(color: Colors.white)), 
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}