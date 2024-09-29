import 'package:flutter/material.dart';
import 'package:project_essai_flutter/mdels/user_model.dart';
 import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../mdels/element.dart' as elmt;

class UpdateElementPage extends StatefulWidget {
  final String token;
  final String? id;
  final String? code;

  const UpdateElementPage({required this.token, this.id, this.code, Key? key}) : super(key: key);

  @override
  _UpdateElementPageState createState() => _UpdateElementPageState();
}

class _UpdateElementPageState extends State<UpdateElementPage> {
  late elmt.Element _element;
  bool _isLoading = true;

  final _codeElementController = TextEditingController();
  final _observationController = TextEditingController();
  final _codeSectionController = TextEditingController();
  final _dureeInterventionController = TextEditingController();
  final _nbOccurenceController = TextEditingController();
  final _dateStartController = TextEditingController();
  final _dateFinController = TextEditingController();
  final _debutController = TextEditingController();
  final _finController = TextEditingController();
  final _typeOccurrenceController = TextEditingController();
  final _createUserController = TextEditingController();
  final _createMachineController = TextEditingController();
  final _alerteAvantController = TextEditingController();
  final _typePreventiveController = TextEditingController();
  final _codeFamilleController = TextEditingController();

  // Listes prédéfinies
  final List<String> _codeSections = [
    'Extincteurs', 'Local technique Incendie', 'Zone Charge Batteries',
    'R.I.A', 'Produits Chimiques', 'Atelier Confection', 'Atelier de Coupe',
    'Locaux Administratif', 'Magasin MP', 'Magasin PF', 'Atelier de Sérigraphie',
    'Stockages', 'Poste Livraison MT/BT', 'Armoires électrique et canalisation',
    'Compresseur d\'air', 'Groupe électrogène', 'CLARK', 'GERBEUR', 'Citerne d\'air',
    'Sécheurs d\'air', 'Forage', 'Réservoir eau de forage', 'Chaudière',
    'Installation Incendie', 'Evacuation', 'Locaux Sociaux', 'EQUIPEMENTS DE MANUTENTION'
  ];

  final List<String> _typeOccurrences = [
    'Monthly', 'Weekly', 'Yearly', 'Daily'
  ];

  final List<String> _typePreventives = [
    'Equipement', 'Inspection HY Sécurité Locaux'
  ];

  final List<String> _codeFamilles = [
    'Protection et Prévention contre l\'incendie', 'Local Technique',
    'Installation d\'air', 'EQUIPEMENTS DE MANUTENTION', 'Groupe Électrogène'
  ];

  @override
  void initState() {
    super.initState();
    _fetchElement();
  }

  Future<void> _fetchElement() async {
    try {
      final element = await Provider.of<ApiService>(context, listen: false).getElementByIdOrCode(
        widget.token,
        id: widget.id,
        code: widget.code,
      );

      if (element != null) {
        setState(() {
          _element = element;
          _codeElementController.text = element.codeElement ?? '';
          _observationController.text = element.observation ?? '';
          _codeSectionController.text = element.codeSection ?? '';
          _dureeInterventionController.text = element.dureeIntervention ?? '';
          _nbOccurenceController.text = element.nbOccurence?.toString() ?? '';
          _dateStartController.text = element.dateStart ?? '';
          _dateFinController.text = element.dateFin ?? '';
          _debutController.text = element.debut ?? '';
          _finController.text = element.fin ?? '';
          _typeOccurrenceController.text = element.typeOccurrence ?? '';
          _createUserController.text = element.createUser?.toString() ?? '';
          _createMachineController.text = element.createMachine ?? '';
          _alerteAvantController.text = element.alerteAvant?.toString() ?? '';
          _typePreventiveController.text = element.typePreventive ?? '';
          _codeFamilleController.text = element.codeFamille ?? '';
          _isLoading = false;
        });
      } else {
        _showErrorDialog('Élément non trouvé.');
      }
    } catch (e) {
      _showErrorDialog('Erreur lors de la recherche de l\'élément : $e');
    }
  }

  Future<void> _updateElement() async {
    try {
      final updatedElement = _element.copyWith(
        codeElement: _codeElementController.text,
        observation: _observationController.text,
        codeSection: _codeSectionController.text,
        dureeIntervention: _dureeInterventionController.text,
        nbOccurence: int.tryParse(_nbOccurenceController.text),
        dateStart: _parseDate(_dateStartController.text),
        dateFin: _parseDate(_dateFinController.text),
        debut: _parseTime(_debutController.text),
        fin: _parseTime(_finController.text),
        typeOccurrence: _typeOccurrenceController.text,
        createUser: int.tryParse(_createUserController.text),
        createMachine: _createMachineController.text,
        alerteAvant: int.tryParse(_alerteAvantController.text),
        typePreventive: _typePreventiveController.text,
        codeFamille: _codeFamilleController.text,
        lastUpdateUser: Provider.of<User>(context, listen: false).matricule,
      );

      await Provider.of<ApiService>(context, listen: false).updateElement(
        widget.token,
        updatedElement.idElement!,
        updatedElement,
      );

      _showSuccessDialog('Élément mis à jour avec succès.');
    } catch (e) {
      _showErrorDialog('Erreur lors de la mise à jour de l\'élément : $e');
    }
  }

  
  String? _parseDate(String dateString) {
    try {
      final dateTime = DateTime.parse(dateString).add(Duration(days: 1));
      return dateTime.toUtc().toIso8601String();
    } catch (e) {
      print('Error parsing date: $e');
      return null;
    }
  }

  String? _parseTime(String timeString) {
    try {
      final now = DateTime.now();
      final time = DateTime(now.year, now.month, now.day,
          int.parse(timeString.split(':')[0]),
          int.parse(timeString.split(':')[1]),
          int.parse(timeString.split(':')[2]));

      return time.toIso8601String().split('T')[1].substring(0, 8);
    } catch (e) {
      print('Error parsing time: $e');
      return null;
    }
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

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Succès'),
          content: Text(message),
          actions: [
            TextButton(
              child: Text('OK'),
              onPressed: () {
                         Navigator.pop(context, true);
                         Navigator.pop(context, true);
                                         Navigator.of(context).pop();

                                      // Navigator.pushReplacementNamed(context, '/home'); 


              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
            backgroundColor: Color.fromARGB(255, 13, 18, 70), 
        title: Text('Recherche d\'élément', style: TextStyle(color: Colors.white)),  
         ),
        body: Container(
    color: Colors.white, 
    child:Center(
          child: CircularProgressIndicator(),
        ),
      ),);
    }

    return Scaffold(
      appBar: AppBar(
         backgroundColor: Color.fromARGB(255, 13, 18, 70), 
        title: Text('Détails de l\'élément', style: TextStyle(color: Colors.white)),  
      ),
      body:Container(
    color: Colors.white, 
    child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextFormField(
                controller: _codeElementController,
                decoration: InputDecoration(labelText: 'Code Élément'),
              ),
              TextFormField(
                controller: _observationController,
                decoration: InputDecoration(labelText: 'Observation'),
              ),
          DropdownButtonFormField<String>(
  value: _codeSectionController.text.isNotEmpty && _codeSections.contains(_codeSectionController.text) 
      ? _codeSectionController.text 
      : _codeSections.first,  
  decoration: InputDecoration(labelText: 'Code Section'),
  items: _codeSections.map((section) {
    return DropdownMenuItem(
      value: section,
      child: Text(section),
    );
  }).toList(),
  onChanged: (newValue) {
    setState(() {
      _codeSectionController.text = newValue ?? '';
    });
  },
),

DropdownButtonFormField<String>(
  value: _typeOccurrenceController.text.isNotEmpty && _typeOccurrences.contains(_typeOccurrenceController.text) 
      ? _typeOccurrenceController.text 
      : null,  
  decoration: InputDecoration(labelText: 'Type d\'Occurrence'),
  items: _typeOccurrences.map((occurrence) {
    return DropdownMenuItem<String>(
      value: occurrence,
      child: Text(occurrence),
    );
  }).toList(),
  onChanged: (newValue) {
    setState(() {
      _typeOccurrenceController.text = newValue ?? '';
    });
  },
),

DropdownButtonFormField<String>(
  value: _codeFamilleController.text.isNotEmpty && _codeFamilles.contains(_codeFamilleController.text) 
      ? _codeFamilleController.text 
      : _codeFamilles.first,  
  decoration: InputDecoration(labelText: 'Code Famille'),
  items: _codeFamilles.toSet().map((famille) { 
    return DropdownMenuItem<String>(
      value: famille,
      child: Text(famille),
    );
  }).toList(),
  onChanged: (newValue) {
    setState(() {
      _codeFamilleController.text = newValue ?? '';
    });
  },
),

              TextFormField(
                controller: _dureeInterventionController,
                decoration: InputDecoration(labelText: 'Durée Intervention'),
              ),
              TextFormField(
                controller: _nbOccurenceController,
                decoration: InputDecoration(labelText: 'Nombre d\'Occurrence'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _dateStartController,
                decoration: InputDecoration(labelText: 'Date de Début'),
              ),
              TextFormField(
                controller: _dateFinController,
                decoration: InputDecoration(labelText: 'Date de Fin'),
              ),
              TextFormField(
                controller: _debutController,
                decoration: InputDecoration(labelText: 'Heure de Début'),
              ),
              TextFormField(
                controller: _finController,
                decoration: InputDecoration(labelText: 'Heure de Fin'),
              ),
            
              TextFormField(
                controller: _createUserController,
                decoration: InputDecoration(labelText: 'Utilisateur Créateur'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: _createMachineController,
                decoration: InputDecoration(labelText: 'Machine Créatrice'),
              ),
              TextFormField(
                controller: _alerteAvantController,
                decoration: InputDecoration(labelText: 'Alerte Avant (en jours)'),
                keyboardType: TextInputType.number,
              ),
              DropdownButtonFormField<String>(
                value: _typePreventiveController.text.isEmpty ? null : _typePreventiveController.text,
                decoration: InputDecoration(labelText: 'Type Préventive'),
                items: _typePreventives.map((preventive) {
                  return DropdownMenuItem<String>(
                    value: preventive,
                    child: Text(preventive),
                  );
                }).toList(),
                onChanged: (newValue) {
                  setState(() {
                    _typePreventiveController.text = newValue!;
                  });
                },
              ),
             
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                     style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  textStyle: TextStyle(color: Colors.white),  
                                ),
                    onPressed: _updateElement,
                    child: Text('Mettre à Jour', style: TextStyle(color: Colors.white)),
                  ),
                  
                ],
              ),
            ],
          ),
        ),
      ),
    ),);
  }
}





 