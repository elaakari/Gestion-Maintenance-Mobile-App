import 'package:flutter/material.dart';
import 'package:project_essai_flutter/mdels/Intervenant.dart';
import 'package:project_essai_flutter/mdels/utilisateur.dart';
import 'package:project_essai_flutter/services/api_service.dart';
import 'package:provider/provider.dart';

class UserPage extends StatefulWidget {
  final String token;
  
  UserPage({required this.token});

  @override
  _UserPageState createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  final TextEditingController _matriculeController = TextEditingController();
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _idSiteController = TextEditingController();
   final TextEditingController _idAtelierController = TextEditingController();
   final TextEditingController _idGradecontroller = TextEditingController();
     String? _selectedOption;
      final ApiService _apiService = ApiService();
  List<Utilisateur>? _utilisateurs;
    late Stream<List<Utilisateur>> _utilisateurStream;
  @override
  void initState() {
    super.initState();
     _utilisateurStream = _fetchUser();

     }
  

  @override

Stream<List<Utilisateur>> _fetchUser() async* {
    try {
      final users = await Provider.of<ApiService>(context, listen: false).getUtilisateurs(widget.token);
      yield users;
    } catch (e) {
      print('Erreur lors de la récupération des éléments: $e');
      yield [];
    }
  }
 void _refreshData() {
  setState(() {
    _utilisateurStream = _fetchUser();
  });
}


  void _showAddDialog(String action, {Utilisateur? utilisateur}) {
  _matriculeController.text = utilisateur?.matricule?.toString() ?? '0';
  _idController.text = utilisateur?.id.toString() ?? '0';
  _idGradecontroller.text = utilisateur?.idGrade.toString() ?? '1'; // Valeur par défaut
  _idAtelierController.text = utilisateur?.idAtelier.toString() ?? '1'; // Valeur par défaut

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(action),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _matriculeController,
              decoration: InputDecoration(labelText: 'Matricule'),
              keyboardType: TextInputType.number,
            ),
            
            DropdownButton<int>(
              value: int.tryParse(_idGradecontroller.text),
              onChanged: (int? newValue) {
                setState(() {
                  _idGradecontroller.text = newValue.toString();
                });
              },
              items: _gradeOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('${value} (${_gradeDescriptions[value]})'),
                );
              }).toList(),
            ),
            DropdownButton<int>(
              value: int.tryParse(_idAtelierController.text),
              onChanged: (int? newValue) {
                setState(() {
                  _idAtelierController.text = newValue.toString();
                });
              },
              items: _atelierOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('${value} (${_atelierDescriptions[value]})'),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              if (action == 'Ajouter Utilisateur') {
                await _addUtilisateur();
              } 
            },
            child: Text('OK'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
        ],
      );
    },
  );
}


  Future<void> _addUtilisateur() async {
    final utilisateur = Utilisateur(
      id: int.parse(_idController.text),
      matricule: int.parse(_matriculeController.text),
      idSite: 1,
      idGrade: int.parse(_idGradecontroller.text),
      idAtelier: int.parse(_idAtelierController.text),
    );
    try {
      final createdUtilisateur = await ApiService().createUtilisateur(widget.token, utilisateur);
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Utilisateur ajouté: ${createdUtilisateur.matricule}')));

     } catch (e) {
                    _showResultDialog('Erreur', 'Erreur lors de la modification: $e');
    }
  }
 
 Future<int?> _showMatriculeDialog(String action) async {
  int? matricule;
  await showDialog(
    context: context,
    builder: (BuildContext context) {
      final matriculeController = TextEditingController();
      return AlertDialog(
        title: Text('Entrer Matricule'),
        content: TextField(
          controller: matriculeController,
          decoration: InputDecoration(labelText: 'Matricule'),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () async {
              if (matriculeController.text.isNotEmpty) {
                matricule = int.tryParse(matriculeController.text);
                if (matricule != null) {
                  Navigator.of(context).pop(); 
                  try {
                    final utilisateur = await ApiService().getUtilisateur(widget.token, matricule!);
                     if (action == 'Modifier Utilisateur') {
                      _showUpdateForm(utilisateur);
                    } else if (action == 'Supprimer Utilisateur') {
                       await _deleteUtilisateur(matricule);
                    } else if (action == 'Vérifier Utilisateur') {
                       _showGetForm(utilisateur);
                    }
                  } catch (e) {
                    _showResultDialog('Erreur', 'Erreur : $e');
                  }
                } else {
                _showResultDialog('Erreur', 'Matricule invalide');

                }
              } else {
                _showResultDialog('Erreur', 'Veuillez entrer un matricule');

              }
            },
            child: Text('OK'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
        ],
      );
    },
  );
  return matricule;
}

final List<int> _gradeOptions = [1, 2, 3, 4, 5, 6, 7];
final Map<int, String> _gradeDescriptions = {
  1: 'Administrateur System',
  2: 'Responsable Maintenance',
  3: 'Intrevenant',
  4: 'Chef d\'equipe',
  5: 'Demandeur',
  6: 'Création OM',
  7: 'RP'
};

final List<int> _atelierOptions = [1, 2, 3, 4, 5, 6, 7, 8, 9];
final Map<int, String> _atelierDescriptions = {
  1: 'Teinture',
  2: 'Tricotage',
  3: 'Finition',
  4: 'Déroulage',
  5: 'Finition mécanique',
  6: 'Impression',
  7: 'Manutention Gaz',
  8: 'Poste Livraison',
  9: 'Atelier Confection'
};


 void _showUpdateForm(Utilisateur utilisateur) async {
  // Récupérer les descriptions basées sur les IDs
  final gradeDescription = _gradeDescriptions[utilisateur.idGrade] ?? 'Inconnu';
  final atelierDescription = _atelierDescriptions[utilisateur.idAtelier] ?? 'Inconnu';

  // Obtenir les informations de l'intervenant
  Intervenant? intervenant;
  try {
    intervenant = await ApiService().getIntervenantById(widget.token, utilisateur.matricule);
  } catch (e) {
    print('Erreur lors de la récupération des informations de l\'intervenant: $e');
  }
  
  // Préparer les informations de l'intervenant
  final intervenantName = intervenant != null ? '${intervenant.firstName} ${intervenant.lastName}' : 'Inconnu';

  // Initialiser les contrôleurs
  _matriculeController.text = utilisateur.matricule.toString();
  _idController.text = utilisateur.id.toString();
  _idSiteController.text = '1';  
  _idGradecontroller.text = utilisateur.idGrade.toString();
  _idAtelierController.text = utilisateur.idAtelier.toString();

  final initialGradeValue = int.tryParse(_idGradecontroller.text);
  final initialAtelierValue = int.tryParse(_idAtelierController.text);

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Modifier Utilisateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Matricule: ${utilisateur.matricule} ($intervenantName)'),
            
            DropdownButton<int>(
              value: _gradeOptions.contains(initialGradeValue) ? initialGradeValue : null,
              onChanged: (int? newValue) {
                setState(() {
                  _idGradecontroller.text = newValue.toString();
                });
              },
              items: _gradeOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value (${_gradeDescriptions[value]})'),
                );
              }).toList(),
            ),
            DropdownButton<int>(
              value: _atelierOptions.contains(initialAtelierValue) ? initialAtelierValue : null,
              onChanged: (int? newValue) {
                setState(() {
                  _idAtelierController.text = newValue.toString();
                });
              },
              items: _atelierOptions.map((int value) {
                return DropdownMenuItem<int>(
                  value: value,
                  child: Text('$value (${_atelierDescriptions[value]})'),
                );
              }).toList(),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final matricule = int.tryParse(_matriculeController.text);
              final idGrade = int.tryParse(_idGradecontroller.text);
              final idAtelier = int.tryParse(_idAtelierController.text);

              if (matricule != null && idGrade != null && idAtelier != null) {
                final updatedUtilisateur = Utilisateur(
                  id: utilisateur.id,
                  matricule: matricule,
                  idSite: 1,
                  idGrade: idGrade,
                  idAtelier: idAtelier,
                );
                try {
                  await ApiService().updateUtilisateur(widget.token, utilisateur.matricule, updatedUtilisateur);
                  Navigator.of(context).pop();
                  _showResultDialog('Succès', 'Utilisateur modifié: ${utilisateur.matricule}');
                } catch (e) {
                  _showResultDialog('Erreur', 'Erreur lors de la modification: $e');
                }
              } else {
                _showResultDialog('Erreur', 'Veuillez entrer des valeurs valides');
              }
            },
            child: Text('OK'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Annuler'),
          ),
        ],
      );
    },
  );
}

 

 Future<void> _updateUtilisateur(Utilisateur utilisateur) async {
 

   int? idSite = _idSiteController.text.isNotEmpty ? int.tryParse(_idSiteController.text) : null;
  int? idGrade = _idGradecontroller.text.isNotEmpty ? int.tryParse(_idGradecontroller.text) : null;
  int? idAtelier = _idAtelierController.text.isNotEmpty ? int.tryParse(_idAtelierController.text) : null;

  if ( idSite != null && idGrade != null && idAtelier != null) {
    final updatedUtilisateur = Utilisateur(
      id: utilisateur.id,
      matricule: utilisateur.matricule,  
      idSite: 1,  
      idGrade: idGrade,  
      idAtelier: idAtelier, 
    );
    try {
      await ApiService().updateUtilisateur(widget.token, utilisateur.matricule, updatedUtilisateur);
                    _showResultDialog('Succès', 'Utilisateur modifié: ${utilisateur.matricule}');
    } catch (e) {
                    _showResultDialog('Erreur', 'Erreur lors de la modification: $e');
      print('Erreur: $e');
    }
  } else {
                  _showResultDialog('Erreur', 'Veuillez entrer des valeurs valides');
  }
}


void _showGetForm(Utilisateur utilisateur) async {
  // Récupérer les descriptions basées sur les IDs
  final gradeDescription = _gradeDescriptions[utilisateur.idGrade] ?? 'Inconnu';
  final atelierDescription = _atelierDescriptions[utilisateur.idAtelier] ?? 'Inconnu';
  
  // Obtenir les informations de l'intervenant
  Intervenant? intervenant;
  try {
    intervenant = await ApiService().getIntervenantById(widget.token, utilisateur.matricule);
  } catch (e) {
    print('Erreur lors de la récupération des informations de l\'intervenant: $e');
  }
  
  // Préparer les informations de l'intervenant
  final intervenantName = intervenant != null ? '${intervenant.firstName} ${intervenant.lastName}' : 'Inconnu';

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Vérifier Utilisateur'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Matricule: ${utilisateur.matricule} ($intervenantName)'),
            Text('ID: ${utilisateur.id}'),
            Text('ID Site: ${utilisateur.idSite}'),
            Text('ID Grade: ${utilisateur.idGrade} (${gradeDescription})'),
            Text('ID Atelier: ${utilisateur.idAtelier} (${atelierDescription})'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Fermer'),
          ),
        ],
      );
    },
  );
}


 

 

 void _showResultDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }
Future<void> _deleteUtilisateur(int? matricule) async {
  if (matricule != null) {
    try {
      // Obtenir les informations de l'utilisateur
      final intervenant = await ApiService().getIntervenantById(widget.token, matricule);
      final intervenantName = intervenant != null ? '${intervenant.firstName} ${intervenant.lastName}' : 'Inconnu';

      // Afficher la boîte de dialogue de confirmation
      bool? confirmDelete = await showDialog<bool>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmer la Suppression'),
            content: Text('Êtes-vous sûr de vouloir supprimer l\'utilisateur $matricule ($intervenantName) ?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),  // Confirmer
                child: Text('Supprimer'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),  // Annuler
                child: Text('Annuler'),
              ),
            ],
          );
        },
      );

      // Si la suppression est confirmée, procéder à la suppression
      if (confirmDelete == true) {
        await ApiService().deleteUtilisateur(widget.token, matricule);
        _showResultDialog('Succès', 'Utilisateur supprimé: $matricule');
      }
    } catch (e) {
      _showResultDialog('Erreur', 'Erreur lors de la suppression: $e');
    }
  } else {
    _showResultDialog('Erreur', 'Matricule invalide');
  }
}


Future<void> _getUtilisateur(int? matricule) async {
  if (matricule != null) {
    try {
      
      final utilisateur = await ApiService().getUtilisateur(widget.token, matricule);
                                //_showResultDialog('Succès', 'Utilisateur trouvé: ${utilisateur.matricule}');


     } catch (e) {
                    _showResultDialog('Erreur', 'Erreur : $e');
    }
  } else {
                    _showResultDialog('Erreur', 'Matricule invalide');
  }
}
 
 @override
Widget build(BuildContext context) {
  return Scaffold(
    appBar: AppBar(
      backgroundColor: Color.fromARGB(255, 13, 18, 70),
      title: Text('Gestion des Utilisateurs', style: TextStyle(color: Colors.white)),
    ),
    body: Container(
      color: Colors.white,
      child: Center(
        child: SingleChildScrollView(   
          scrollDirection: Axis.horizontal,
 child: SingleChildScrollView(   
          scrollDirection: Axis.vertical,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              DropdownButton<String>(
                value: _selectedOption,
                onChanged: (value) {
                  setState(() {
                    _selectedOption = value;
                  });
                },
                items: [
                  'Ajouter Utilisateur',
                  'Modifier Utilisateur',
                  'Supprimer Utilisateur',
                  'Vérifier Utilisateur',
                ].map((option) {
                  return DropdownMenuItem<String>(
                    value: option,
                    child: Text(option),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_selectedOption != null) {
                    _showDialog(_selectedOption!);
                  }
                },
                child: Text('Choisir Option'),
              ),
              SizedBox(height: 20),
              
              FutureBuilder(
                future: _apiService.getUtilisateurs(widget.token),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    _utilisateurs = snapshot.data;
                    return DataTable(
                      
                      columns: [
                        DataColumn(label: Text('Matricule')),
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('ID Site')),
                        DataColumn(label: Text('ID Grade')),
                        DataColumn(label: Text('ID Atelier')),
                      ],
                      rows: _utilisateurs!.map((utilisateur) {
                        return DataRow(
                          cells: [
                            DataCell(Text(utilisateur.matricule.toString())),
                            DataCell(Text(utilisateur.id.toString())),
                            DataCell(Text(utilisateur.idSite.toString())),
                            DataCell(Text(utilisateur.idGrade.toString())),
                            DataCell(Text(utilisateur.idAtelier.toString())),
                          ],
                        );
                      }).toList(),
                    );
                  } else if (snapshot.hasError) {
                    return Text('Erreur: ${snapshot.error}');
                  } else {
                    return Center(child: CircularProgressIndicator());
                  }
                },
              ),
            ],
          ),
        ),
      ),
    ),),
    floatingActionButton: FloatingActionButton(
      backgroundColor: Color.fromARGB(255, 13, 18, 70),
      onPressed: _refreshData,
      child: Icon(Icons.refresh, color: Colors.white),
      tooltip: 'Rafraîchir',
    ),
  );
}
void _showDialog(String action) {
  if (action == 'Ajouter Utilisateur') {
    _showAddDialog(action);
  } else if (action == 'Modifier Utilisateur') {
    _showMatriculeDialog(action);
  } else if (action == 'Supprimer Utilisateur') {
    _showMatriculeDialog(action);
  } else if (action == 'Vérifier Utilisateur') {
    _showMatriculeDialog(action);
  }
}}
