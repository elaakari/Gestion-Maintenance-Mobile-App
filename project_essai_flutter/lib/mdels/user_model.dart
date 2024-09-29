import 'package:flutter/material.dart';

class User with ChangeNotifier {
  int? _matricule;

  int? get matricule => _matricule;

 void setMatricule(String matricule) {
  _matricule = int.parse(matricule);
  notifyListeners();
}
}