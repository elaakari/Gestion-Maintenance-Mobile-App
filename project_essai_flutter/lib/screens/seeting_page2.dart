import 'package:flutter/material.dart';
 import 'package:project_essai_flutter/screens/delete_element.dart';
 
class SettingsPage2 extends StatefulWidget {
  final String token;

  const SettingsPage2({required this.token, Key? key}) : super(key: key);

  @override
  _SettingsPage2State createState() => _SettingsPage2State();
}

class _SettingsPage2State extends State<SettingsPage2> {
  final _idController = TextEditingController();
  final _codeController = TextEditingController();

 

void _navigateToDeleteElementPage() {
    final id = _idController.text.isNotEmpty ? _idController.text : null;
    final code = _codeController.text.isNotEmpty ? _codeController.text : null;

    if (id == null && code == null) {
      _showErrorDialog('Veuillez entrer un ID ou un code.');
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DeleteEelementPage(
          token: widget.token,
          id: id,
          code: code,
        ),
      ),
    );
  }
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: [
            TextButton(
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         backgroundColor: Color.fromARGB(255, 13, 18, 70), 
        title: Text('Paramètres', style: TextStyle(color: Colors.white)),  
      
      ),
      body: Container(
    color: Colors.white, 
    child:Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _idController,
              decoration: InputDecoration(labelText: 'ID de l\'élément'),
            ),
            TextField(
              controller: _codeController,
              decoration: InputDecoration(labelText: 'Code de l\'élément'),
            ),
           
             SizedBox(height: 16),
            ElevatedButton(
               style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 10, 14, 56),
                                  textStyle: TextStyle(color: Colors.white),  
                                ),
              onPressed: _navigateToDeleteElementPage,
              child: Text('Supprimer' , style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
      ),);
  }
}

