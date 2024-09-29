import 'package:flutter/material.dart';
import 'package:project_essai_flutter/mdels/user_model.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../mdels/element.dart' as elmt;   

class AddElementPage extends StatefulWidget {
  final String token;

  const AddElementPage({required this.token, Key? key}) : super(key: key);

  @override
  _AddElementPageState createState() => _AddElementPageState();
}

class _AddElementPageState extends State<AddElementPage> {

  final _formKey = GlobalKey<FormState>();
  final _codeElementController = TextEditingController();
  final _observationController = TextEditingController();
   final _dureeInterventionController = TextEditingController();
  final _nbOccurenceController = TextEditingController();
    final _createUserController = TextEditingController();
  final _createMachineController = TextEditingController();
  final _alerteAvantController = TextEditingController();
 
  String? _selectedCodeSection;
  String? _selectedTypeOccurrence;
  String? _selectedTypePreventive;
  String? _selectedCodeFamille;

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
  
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 13, 18, 70), 
        title: Text('Ajouter un élément', style: TextStyle(color: Colors.white)),  
      
      ),
      body:Container(
    color: Colors.white, 
    child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _codeElementController,
                  decoration: InputDecoration(labelText: 'Code Élément'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le code de l\'élément';
                    }
                    return null;
                  },
                ),
                 
                DropdownButtonFormField<String>(
                  value: _selectedCodeSection,
                  items: _codeSections.map((section) {
                    return DropdownMenuItem(
                      value: section,
                      child: Text(section),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCodeSection = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Code Section'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner une section';
                    }
                    return null;
                  },
                ),
                
                TextFormField(
                  controller: _nbOccurenceController,
                  decoration: InputDecoration(labelText: 'Nombre d\'Occurrence'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer le nombre d\'occurrences';
                    }
                    return null;
                  },
                ),
                
            
                DropdownButtonFormField<String>(
                  value: _selectedTypeOccurrence,
                  items: _typeOccurrences.map((occurrence) {
                    return DropdownMenuItem(
                      value: occurrence,
                      child: Text(occurrence),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTypeOccurrence = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Type d\'Occurrence'),
                ),
                
                TextFormField(
                  controller: _createMachineController,
                  decoration: InputDecoration(labelText: 'Créé par (Machine)'),
                ),
                TextFormField(
                  controller: _alerteAvantController,
                  decoration: InputDecoration(labelText: 'Alerte Avant (jours)'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButtonFormField<String>(
                  value: _selectedTypePreventive,
                  items: _typePreventives.map((preventive) {
                    return DropdownMenuItem(
                      value: preventive,
                      child: Text(preventive),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedTypePreventive = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Type Préventif'),
                ),
                DropdownButtonFormField<String>(
                  value: _selectedCodeFamille,
                  items: _codeFamilles.map((famille) {
                    return DropdownMenuItem(
                      value: famille,
                      child: Text(famille),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedCodeFamille = value;
                    });
                  },
                  decoration: InputDecoration(labelText: 'Code Famille'),
                ),
                SizedBox(height: 20),
                ElevatedButton(                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 10, 14, 56),
                                  textStyle: TextStyle(color: Colors.white),  
                                ),
  onPressed: () async {
   if (_formKey.currentState!.validate()) {
                        // Check if the codeElement already exists
                        bool exists = await _checkElementExists(_codeElementController.text);
                        if (exists) {
                          _showErrorDialog('Le code élément existe déjà. Veuillez choisir un autre nom.');
                        } else {
                          // If the code doesn't exist, add the element
                          final newElement = elmt.Element(
        idElement: 0,  
        codeElement: _codeElementController.text,
        observation: '',
        codeSection: _selectedCodeSection ?? '',
        dureeIntervention: _parseDuration(_dureeInterventionController.text),
        nbOccurence: int.tryParse(_nbOccurenceController.text) ?? 0,
        dateStart: _parseDate(DateTime.now()),
        dateFin: _parseDate(DateTime.now()),
        debut: _parseTime('00:00:00'),
        fin: _parseTime('00:00:00'),
        typeOccurrence: _selectedTypeOccurrence ?? '',
        createUser: Provider.of<User>(context, listen: false).matricule,
createDateTime: DateTime.now().toUtc().toIso8601String(),
 lastUpdateUser: Provider.of<User>(context, listen: false).matricule,
lastUpdateDateTime: DateTime.now().toUtc().toIso8601String(),       
        createMachine: _createMachineController.text,
        alerteAvant: int.tryParse(_alerteAvantController.text) ?? 0,
        typePreventive: _selectedTypePreventive ?? '',
        codeFamille: _selectedCodeFamille ?? '',
       );

     try {
  final id = await Provider.of<ApiService>(context, listen: false).addElement(widget.token, newElement);
  if (id != null) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Élément ajouté avec succès !'),
        content: Text('ID: $id'),
        actions: [
          ElevatedButton(
            child: Text('OK'),
            onPressed: () {
              Navigator.pop(context);  
              Navigator.pop(context, true);  
            },
          ),
        ],
      ),
    );
  }
} catch (e) {
  print('Error adding element: ${e.toString()}');
   print('Error adding element: ${e.toString()}');
         _showErrorDialog('Erreur lors de l\'ajout de l\'élément: ${e.toString()}');

}
    }
  }},
  child: Text('Ajouter' , style: TextStyle(color: Colors.white)),
)
              ],
            ),
          ),
        ),
      ),
    ),);
  }

Future<bool> _checkElementExists(String codeElement) async {
  try {
    final apiService = Provider.of<ApiService>(context, listen: false);

     final element = await apiService.getElementByIdOrCode(
      widget.token,
      id: null,    
      code: codeElement,
    );

     return element != null;
  } catch (e) {
    print('Error checking element existence: $e');
    return false;
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
 String _parseDate(DateTime date) {
  return date.toIso8601String().split('T')[0];
}

String _parseDuration(String duration) {
  try {
    final parts = duration.split(':');
    if (parts.length == 3) {
      final hours = int.parse(parts[0]);
      final minutes = int.parse(parts[1]);
      final seconds = int.parse(parts[2]);
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}.0000000';
    }
    return '00:00:00.0000000';
  } catch (e) {
    print('Error parsing duration: $e');
    return '00:00:00.0000000';
  }
}

   
 String _parseDateTime(DateTime date) {
  return date.toIso8601String().replaceFirst('T', ' ').replaceFirst('Z', '');
}
String _parseTime(String timeString) {
  try {
    final now = DateTime.now();
    final time = DateTime(now.year, now.month, now.day,
        int.parse(timeString.split(':')[0]),
        int.parse(timeString.split(':')[1]),
        int.parse(timeString.split(':')[2]));
    
     return time.toIso8601String().split('T')[1].substring(0, 8) + '.0000000';
  } catch (e) {
    print('Error parsing time: $e');
    return '00:00:00.0000000';
  }
}
}