 
import 'package:flutter/material.dart';
import 'package:project_essai_flutter/helpers/database_helpers.dart';
import 'package:project_essai_flutter/mdels/demade_interventions.dart';
import 'package:project_essai_flutter/mdels/user_model.dart';
  import 'package:provider/provider.dart';
import '../mdels/element.dart' as elmt;
import '../services/api_service.dart';
import '../mdels/inspection.dart'; 
 
class ElementDetailsScreen extends StatefulWidget {
  final elmt.Element element;
  final String token;
  Inspection? inspection; 
   final DateTime today = DateTime.now();


  ElementDetailsScreen({required this.element, required this.token, this.inspection});

  @override
  _ElementDetailsScreenState createState() => _ElementDetailsScreenState();
}

class _ElementDetailsScreenState extends State<ElementDetailsScreen> {
   bool isOkSelected = false;
  bool isNonOkSelected = false;
    String? _codeDemande;   

   //TextEditingController observationController = TextEditingController();
 TextEditingController inspectionObservationController = TextEditingController();
 TextEditingController  typeMaintenanceController = TextEditingController();
 TextEditingController numeroInterController = TextEditingController();

  String? selectedUrgency;

  bool _isNonOkButtonEnabled = true;
  bool _isObservationValidated = false; 

  @override
  void initState() {
    
    super.initState();
    if (widget.inspection != null) {
      //observationController.text = widget.inspection!.observation ??'';
    inspectionObservationController.text = widget.element.observation ?? ''; 
      typeMaintenanceController.text = widget.inspection?.typeMaintenance ?? '';
      numeroInterController.text = widget.inspection?.numeroInter ?? '';
       isOkSelected = widget.inspection!.resultats == "OK";
      isNonOkSelected = widget.inspection!.resultats == "Non OK";
      selectedUrgency = widget.inspection!.urgence;
    }
  }

  void updateObservation(String status) {
  setState(() {
    if (status == "OK") {
      isOkSelected = !isOkSelected;   
      if (isOkSelected) {
        isNonOkSelected = false;  
      }
    } else if (status == "Non OK") {
      isNonOkSelected = !isNonOkSelected;   
      if (isNonOkSelected) {
        isOkSelected = false;   
        _showUrgencyDialog();
      }
    }
  });
}


  void _showUrgencyDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Sélectionner l\'urgence'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildUrgencyOption('Normal'),
              _buildUrgencyOption('Moyen'),
              _buildUrgencyOption('Grave'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                if (selectedUrgency != null) {
                  setState(() {
                    widget.element.observation = "Urgence: $selectedUrgency";
                  });
                  Navigator.of(context).pop();
                }
              },
              child: Text('Valider'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildUrgencyOption(String urgency) {
    return Container(
      color: selectedUrgency == urgency ? Colors.blue[100] : null,
      child: RadioListTile<String>(
        title: Text(urgency),
        value: urgency,
        groupValue: selectedUrgency,
        onChanged: (value) {
          setState(() {
            selectedUrgency = value;
          });
        },
        selected: selectedUrgency == urgency,
      ),
    );
  }

Future<void> _showInspectionForm({bool isUpdate = false}) async {
  final apiService = Provider.of<ApiService>(context, listen: false);
  final _formKey = GlobalKey<FormState>();

  if (isUpdate) {
     inspectionObservationController.text = widget.inspection?.observation ?? '';
    typeMaintenanceController.text = widget.inspection?.typeMaintenance ?? '';
    numeroInterController.text = widget.inspection?.numeroInter ?? '';
  }

  return showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(isUpdate ? 'Mettre à jour l\'observation' : 'Remplir le formulaire d\'inspection'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: isOkSelected ? "OK" : isNonOkSelected ? "Non OK" : isUpdate ? (widget.inspection?.resultats) :null,
                  decoration: InputDecoration(labelText: 'Résultat'),
                  items: [
                    DropdownMenuItem(
                      value: "OK",
                      child: Text("OK"),
                    ),
                    DropdownMenuItem(
                      value: "Non OK",
                      child: Text("Non OK"),
                    ),
                  ],
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        updateObservation(newValue);
                        if (newValue == "OK") {
                          selectedUrgency = null;  
                        }
                      });
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez sélectionner un résultat';
                    }
                    return null;
                  },
                ),
                
                 if (isNonOkSelected)
                 DropdownButtonFormField<String>(
                  value: selectedUrgency,
                  decoration: InputDecoration(labelText: 'Urgence'),
                  items: [
                    DropdownMenuItem(value: 'Normal', child: Text('Normal')),
                    DropdownMenuItem(value: 'Moyen', child: Text('Moyen')),
                    DropdownMenuItem(value: 'Grave', child: Text('Grave')),
                    //DropdownMenuItem(value: '', child: Text('')),  
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedUrgency = newValue;
                    });
                  },
                  validator: (value) {
                    if (isNonOkSelected && (value == null || value.isEmpty)) {
                      return 'Veuillez sélectionner une urgence';
                    }
                    return null;   
                  },
                ),
                
                TextFormField(
                  controller: inspectionObservationController,
                  decoration: InputDecoration(labelText: 'Observation'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une observation';
                    }
                    return null;
                  },
                ),
                
                 TextFormField(
                  initialValue: widget.element.codeSection ?? '',
                  decoration: InputDecoration(labelText: 'Code Section'),
                  readOnly: true,
                ),
                TextFormField(
                  initialValue: widget.element.codeFamille ?? '',
                  decoration: InputDecoration(labelText: 'Code Famille'),
                  readOnly: true,
                ),
                TextFormField(
                  controller: typeMaintenanceController,
                  decoration: InputDecoration(labelText: 'Type Maintenance'),
                ),
                TextFormField(
                  controller: numeroInterController,
                  decoration: InputDecoration(labelText: 'Numéro Inter'),
                ),
              ],
            ),
          ),
        ),
       actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                final inspection = Inspection(
                  idInspection: isUpdate ? (widget.inspection?.idInspection ?? 0) : 0,
                  dateInspection: DateTime.now(),
                   observation: inspectionObservationController.text.trim(), 
                  codeElementSection: widget.element.codeElement ?? '',
                  idIntervenant:Provider.of<User>(context, listen: false).matricule,
                  codeEquipement: widget.element.codeSection ?? '',
                  dateElement: DateTime.now(),
                  resultats: isOkSelected ? "OK" : "Non OK",
                  urgence: selectedUrgency ?? '',
                  section: widget.element.codeSection ?? '',
                  codeFamille: widget.element.codeFamille ?? '',
                  typeMaintenance: typeMaintenanceController.text.trim(),
                  numeroInter: numeroInterController.text.trim(),
                  createUser: isUpdate ? (widget.inspection?.createUser ):Provider.of<User>(context, listen: false).matricule,
                  createDateTime: isUpdate ? (widget.inspection?.createDateTime ): DateTime.now(),
                  lastUpdateUser:  isUpdate ? Provider.of<User>(context, listen: false).matricule: widget.element.lastUpdateUser,
                  lastUpdateDateTime: DateTime.now(),
                  createMachine: widget.element.createMachine ?? '',
                );
                final apiService = Provider.of<ApiService>(context, listen: false); 

              
              try {
                if (isUpdate) {
                  await apiService.updateInspection(widget.token, inspection.idInspection, inspection);
                } else {
                  final id = await apiService.saveInspection(widget.token, inspection);
                  setState(() {
                    widget.inspection = inspection.copyWith(idInspection: id);
                  });
                }
                                 Navigator.of(context).pop();

               

                 _showSuccessDialog(isUpdate ? 'Inspection mise à jour avec succès' : 'Inspection ajoutée avec succès');
              } catch (e) {
                print('Erreur lors de la sauvegarde de l\'inspection: ${e.toString()}');
              }

             }
            },
            child: Text('Soumettre'),
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
            onPressed: () {
              Navigator.of(context).pop(); 
               String resultText = 'Résultat : ${isOkSelected ? "OK" : "Non OK"} | Urgence : $selectedUrgency | Observation: ${inspectionObservationController.text.trim()}';
                _showResultDialog(resultText);
             },
            child: Text('OK'),
          ),  
        ],
      );
    },
  );
}

void validateObservation() async {
    DateTime today = DateTime.now();

  final apiService = Provider.of<ApiService>(context, listen: false);

  try {
     List<Inspection> inspections = await apiService.getInspectionsByElementAndDate(
      widget.token,
      widget.element.codeElement ?? '',
      widget.element.codeSection ?? '',
      today,
    );

    if (inspections.isNotEmpty) {
       _showAlertDialog(
        'Inspection existante',
        'Une inspection existe déjà pour cet élément et cette date. Veuillez la mettre à jour.',
      );

       setState(() {
        _isObservationValidated = true;  
      });
    } else {
       _showInspectionForm(isUpdate: false);
    }
  } catch (e) {
    print('Erreur lors de la validation de l\'observation: ${e.toString()}');
     _showAlertDialog(
      'Erreur',
      'Une erreur s\'est produite lors de la vérification des inspections. Veuillez réessayer.',
    );
  }
}
void _showAlertDialog(String title, String content) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
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

void updateObservationButton() async {
  final apiService = Provider.of<ApiService>(context, listen: false);
  DateTime today = DateTime.now();

  try {
    List<Inspection> inspections = await apiService.getInspectionsByElementAndDate(
      widget.token,
      widget.element.codeElement ?? '',
            widget.element.codeSection ?? '',

      today,
    );

    if (inspections.isNotEmpty) {
       Inspection inspectionToUpdate = inspections.first;

       setState(() {
        widget.inspection = inspectionToUpdate;
      });

       await _showInspectionForm(isUpdate: true);
    } else {
      _showSuccessDialog('Aucune inspection trouvée pour la date et le code élément spécifiés');
    }
  } catch (e) {
    print('Erreur lors de la mise à jour de l\'observation: ${e.toString()}');
  }
}


void _showResultDialog(String resultText) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Résultat'),
        content: Text(resultText),
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

void _handleInterventionButton() async {
  final apiService = Provider.of<ApiService>(context, listen: false);
  final dbHelper = DatabaseHelper.instance;
  DateTime today = DateTime.now();
  final String codeDemande = _codeDemande ?? '';
  final String codeElement = widget.element.codeElement ?? '';

  try {
     List<LocalDemandeIntervention> localDemandeInterventions = await dbHelper.getDemandeInterventionsByCodeDemandeAndDateAndCodeElement(
      codeDemande,
      today,
      codeElement,
    );


    if (localDemandeInterventions.isNotEmpty) {
       final demandeintervention = localDemandeInterventions.first.toDemandeIntervention();
      await _showInterventionForm(isUpdate: true, existingDemande: demandeintervention);
 
    } else {
       await _showInterventionForm(isUpdate: false);
    }
  } catch (e) {
    print('Erreur lors de la gestion de l\'intervention: ${e.toString()}');
    _showAlertDialog('Erreur', 'Une erreur s\'est produite lors de la gestion de l\'intervention. Veuillez réessayer.');
  }
}



Future<void> _showInterventionForm({required bool isUpdate, DemandeInterventions? existingDemande}) async {
  final _formKey = GlobalKey<FormState>();
   TextEditingController resumePannneController = TextEditingController();
   TextEditingController idPanneController = TextEditingController();
  TextEditingController codeEquipementController = TextEditingController();
  TextEditingController terminerController = TextEditingController();
  TextEditingController observationController = TextEditingController();
  
  // Liste des IDs d'intervenants
  final List<int> utilisateurIds = [
    807, 835, 890, 896, 898, 900, 904, 907, 1021, 1097, 1137, 1517, 1673, 1727, 1800
  ];
   
  final List<String> typeMaintenanceOptions = [
    'Ordre Maintenance'
  ];

  final List<String> chaineOptions = [
    'Teinture',
    'Tricotage',
    'Finition',
    'Impression',
    'Poste Livraison'
  ];

  final List<String> etatMachineOptions = [
    'En arrêt',
    'En dysfonctionnement'
  ];

  final List<int> _urgenceOptions = [1, 2, 3];
  final Map<int, String> _urgenceDescriptions = {
    1: 'Immédiate',
    2: 'dans la Semaine',
    3: 'A planifier',
  };

  final List<int> _etatdemandeOptions = [1, 2, 3, 4, 5, 6];
  final Map<int, String> _etatdemandeDescriptions = {
    1: 'Nouveau',
    2: 'Traitement',
    3: 'Attente',
    4: 'Terminé',
    5: 'Refusé',
    6: 'Annulé',
  };

  final List<int> _idtypedemandeOptions = [1, 2];
  final Map<int, String> _idtypedemandeDescriptions = {
    1: 'Travaux urgents traités',
    2: 'Travaux différés',
  };

  final List<int> _priorityOptions = [1, 2, 3, 4];
  final Map<int, String> _priorityDescriptions = {
    1: 'Urgent',
    2: 'Haute',
    3: 'Moyenne',
    4: 'Basse',
  };
   final List<int> _idPanneOptions = [
  for (int i = 1; i <= 205; i++) i,
];

final Map<int, String> _idPanneDescriptions = {
  1: 'Fuite Chaudière',
  2: 'Origine non identifié',
  3: 'Manque d\'eau pour les appareils à vapeur',
  4: 'Défauts d\'engraissement',
  5: 'Faille des dispositifs de régulation',
  6: 'Pignon cassé',
  7: 'Température trop élevée',
  8: 'Bruit Machine',
  9: 'Coupure d’électricité',
  10: 'Moteurs pompe de circulation grillé',
  11: 'Moteur pompe d’injection grillé',
  12: 'Moteur malaxeur grillé',
  13: 'Moteur tournette grillé',
  14: 'Moteurs pompe de circulation ne tourne pas',
  15: 'Moteur pompe d’injection ne tourne pas',
  16: 'Moteur malaxeur ne tourne pas',
  17: 'Moteur tournette ne tourne pas',
  18: 'Moteur déchargement ne tourne pas',
  19: 'Moteur déchargement grillé',
  20: 'Vanne d’eau de refroidissement ne s’ouvre pas',
  21: 'Vanne d’eau de remplissage ne s’ouvre pas',
  22: 'Vanne de vapeur ne s’ouvre pas',
  23: 'Vanne d’air ne s’ouvre',
  24: 'Compteur/Transmetteur d’eau ne s’allume pas',
  25: 'Lampe d’éclairage intérieur ne s’allume pas',
  26: 'Lampe de signalisation ne s’allume pas',
  27: 'Système d’urgence blocage tricot ne marche pas',
  28: 'Détecteur couture tricot',
  29: 'Pompe de circulation bloquée',
  30: 'Pompe d’injection bloquée',
  31: 'Malaxeur bloqué',
  32: 'Palier tournette bloquée/ usée',
  33: 'Axe tournette usé',
  34: 'Bruit anormal pompe de circulation',
  35: 'Bruit anormal pompe d’injection',
  36: 'Bruit anormal malaxeur',
  37: 'Compteur d’eau bloquée',
  38: 'Bruit anormal moteur déchargement',
  39: 'Moteur déchargement bloqué',
  40: 'Système passage tricot bloqué',
  41: 'Système Flow/jet bloqué',
  42: 'Courroie tournette Coupé / Usé',
  43: 'Blocage vanne d’injection',
  44: 'Blocage vanne vapeur',
  45: 'Blocage vanne eau de refroidissement',
  46: 'Blocage vanne de remplissage',
  47: 'Blocage vanne retour condensat',
  48: 'Blocage vanne remplissage cuve',
  49: 'Blocage vanne de vidange',
  50: 'Blocage vanne de débordement',
  51: 'Fuite système d’air machine',
  52: 'Fuite vapeur',
  53: 'Fuite d’eau',
  54: 'Fuite huile pompe de circulation',
  55: 'Fuite d’huile réducteur déchargement',
  56: 'Blocage vanne de vidange',
  57: 'Blocage vanne de débordement',
  58: 'Fuite système d’air machine',
  59: 'Fuite vapeur',
  60: 'Fuite d’eau',
  61: 'Fuite huile pompe de circulation',
  62: 'Fuite d’huile réducteur déchargement',
  63: 'Fuite d’air',
  64: 'Fuite d’huile au niveau de la boite d’engrenage',
  65: 'Fuite au niveau de la pompe d’huile',
  66: 'Moteur ne tourne pas',
  67: 'Moteur grillé',
  68: 'Usure au niveau des paliers',
  69: 'Usure au niveau de la courroie moteur',
  70: 'Usure au niveau de la courroie plieur',
  71: 'Usure roulement plieur',
  72: 'Éclairage grillé',
  73: 'Moteur cylindres ne tourne pas / Grillé',
  74: 'Moteur entrainement fournisseur ne tourne pas / Grillé',
  75: 'Moteur tapis ne tourne pas / Grillé',
  76: 'Moteur de déplacement élargisseur ne tourne pas / Grillé',
  77: 'Moteur de détorsion automatique ne tourne pas / Grillé',
  78: 'Moteur d’exprimeuse en boyau ne tourne pas / Grillé',
  79: 'Moteur du plateau tournant ne tourne pas / Grillé',
  80: 'Sécurités tricot tendu',
  81: 'Sécurités du bac',
  82: 'Coupure d’électricité',
  83: 'Détecteur de présence d’élargisseur',
  84: 'Fermetures du cylindre',
  85: 'Détecteur de trou droit et gauche',
  86: 'Ballon dégonflé',
  87: 'Éclairage grillé',
  88: 'Lampe de signalisation ne s’allume pas',
  89: 'Moteur cylindres bloqué',
  90: 'Moteur tapis bloqué',
  91: 'Moteur fournisseur bloqué',
  92: 'Moteur du déplacement d’élargisseur bloqué',
  93: 'Moteur de détorsion automatique bloqué',
  94: 'Moteur d’exprimeuse en boyau bloqué',
  95: 'Moteur du plateau tournant bloqué',
  96: 'Palier tournette bloquée/ usée',
  97: 'Fuite système d’air machine',
  98: 'Fuite d’huile au niveau de réducteur cylindres',
  99: 'Fuite d’huile au niveau de réducteur tapis',
  100: 'Fuite d’huile au niveau de réducteur détorsion automatique',
  101: 'Fuite d’huile au niveau de réducteur de la motorisation de détorsion',
  102: 'Fuite d’huile au niveau de réducteur du plateau tournant',
  103: 'Moteur cylindre ne tourne pas / Grillé',
  104: 'Moteur entrainement fournisseur ne tourne pas / Grillé',
  105: 'Moteur du déplacement élargisseur ne tourne pas / Grillé',
  106: 'Moteur du motorisation détorsion ne tourne pas / Grillé',
  107: 'Moteur d’exprimeuse en boyau ne tourne pas / Grillé',
  108: 'Moteur du plateau tournant ne tourne pas / Grillé',
  109: 'Sécurités tricot tendu',
  110: 'Moteur de détorsion automatique ne tourne pas / Grillé',
  111: 'Sécurités du bac',
  112: 'Coupure d’électricité',
  113: 'Présence d’élargisseur',
  114: 'Fermeture du cylindre',
  115: 'Détecteur de trou droit et gauche',
  116: 'Ballon dégonflé',
  117: 'Éclairage grillé',
  118: 'Lampe de signalisation ne s’allume pas',
  119: 'Moteur du trainage ne tourne pas / Grillé',
  120: 'Moteur du double élargisseur ne tourne pas / Grillé',
  121: 'Moteur du élargisseur contraste ne tourne pas / Grillé',
  122: 'Moteur du trainage plieur ne tourne pas / Grillé',
  123: 'Moteur arm plieur ne tourne pas / Grillé',
  124: 'Moteur du foulard ne tourne pas / Grillé',
  125: 'Moteur du batteur ne tourne pas / Grillé',
  126: 'Moteur batteur bloqué',
  127: 'Moteur détorsion bloqué',
  128: 'Moteur double élargisseur bloqué',
  129: 'Moteur double élargisseur contrasse bloqué',
  130: 'Moteur motorisation détorsion bloqué',
  131: 'Moteur plateforme bloqué',
  132: 'Moteur trainage bloqué',
  133: 'Moteur du plieur bloqué',
  134: 'Moteur de l’arm plieur bloqué',
  135: 'Moteur du foulard bloqué',
  136: 'Usure du foulard',
  137: 'Usure de la courroie foulard',
  138: 'Usure de la courroie plieur',
  139: 'Usure du plieur',
  140: 'Fuite d’huile au niveau du motorisation élargisseur contraste',
  141: 'Fuite d’huile au niveau du motorisation foulard',
  142: 'Usure du palier foulard',
  143: 'Fuite d’huile au niveau de foulard',
  144: 'Piston de foulard ne fonctionne pas',
  145: 'Fuite d’air au niveau de piston foulard',
  146: 'Fuite huile au niveau du réducteur de foulard',
  147: 'Grippage moteur foulard',
  148: 'Bruit au niveau du foulard',
  149: 'Fuite d’huile au niveau du foulard',
  150: 'Moteur foulard bloqué',
  151: 'Foulard bloqué',
  152: 'Fuite d’huile au niveau du plieur',
  153: 'Grippage au niveau du foulard',
  154: 'Fuite air au niveau du foulard',
  155: 'Déformation de la bande foulard',
  156: 'Palier foulard usé',
  157: 'Palier foulard défectueux',
  158: 'Grippage au niveau du foulard',
  159: 'Grippage du moteur de foulard',
  160: 'Usure des courroies du foulard',
  161: 'Palier plieur usé',
  162: 'Palier foulard usé',
  163: 'Usure foulard',
  164: 'Échauffement foulard',
  165: 'Grippage du foulard',
  166: 'Fuite d’air au niveau du foulard',
  167: 'Grippage au niveau du foulard',
  168: 'Grippage moteur foulard',
  169: 'Grippage du foulard',
  170: 'Grippage au niveau du foulard',
  171: 'Usure foulard',
  172: 'Échauffement foulard',
  173: 'Grippage du foulard',
  174: 'Grippage du foulard',
  175: 'Usure foulard',
  176: 'Grippage foulard',
  177: 'Usure foulard',
  178: 'Grippage du foulard',
  179: 'Fuite d’air au niveau du foulard',
  180: 'Grippage du foulard',
  181: 'Fuite foulard',
  182: 'Usure foulard',
  183: 'Grippage foulard',
  184: 'Fuite foulard',
  185: 'Usure foulard',
  186: 'Grippage foulard',
  187: 'Usure foulard',
  188: 'Grippage foulard',
  189: 'Grippage foulard',
  190: 'Grippage foulard',
  191: 'Grippage foulard',
  192: 'Grippage foulard',
  193: 'Usure foulard',
  194: 'Grippage foulard',
  195: 'Grippage foulard',
  196: 'Grippage foulard',
  197: 'Grippage foulard',
  198: 'Grippage foulard',
  199: 'Grippage foulard',
  200: 'Grippage foulard',
  201: 'Grippage foulard',
  202: 'Grippage foulard',
  203: 'Grippage foulard',
  204: 'Grippage foulard',
  205: 'Grippage foulard',
};



  String? selectedChaine;
  String? selectedEtatMachine;
  String? selectedTypeMaintenance;
  int? selectedUser;
  int? selectedCreateUser;
  int? selectedLastUpdateUser;
  int? selectedPriority;
  bool? selectedMaintenace;
  int? selectedUrgence;
  int? selectedEtatDemande;
  int? selectedIdTypeDemande;
  int? selectedIdPanne;

  if (isUpdate && existingDemande != null) {
    selectedTypeMaintenance = existingDemande.typeMaintenance;
    selectedChaine = existingDemande.chaine;
    selectedEtatMachine = existingDemande.etatMachine;
    selectedUser = existingDemande.idUtilisateur;
    selectedCreateUser = existingDemande.createUser;
    selectedLastUpdateUser = existingDemande.lastUpdateUser;
    selectedUrgence = existingDemande.codeUrgence;
    selectedEtatDemande = existingDemande.etatDemande;
    selectedIdTypeDemande = existingDemande.idTypeDemande;
    selectedIdPanne = existingDemande.idPanne;
    selectedPriority = existingDemande.priorite;
    selectedMaintenace = existingDemande.maintenanceTSV;
  }

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(isUpdate ? 'Modifier Demande Intervention' : 'Ajouter Demande Intervention'),
        content: Form(
          key: _formKey,
          child: SingleChildScrollView(
            
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                DropdownButtonFormField<String>(
                  value: selectedChaine,
                  decoration: InputDecoration(labelText: 'Chaine'),
                  items: chaineOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    selectedChaine = newValue;
                  },
                  validator: (value) => value == null ? 'Ce champ est requis' : null,
                ),
                DropdownButtonFormField<String>(
                  value: selectedEtatMachine,
                  decoration: InputDecoration(labelText: 'Etat Machine'),
                  items: etatMachineOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    selectedEtatMachine = newValue;
                  },
                  validator: (value) => value == null ? 'Ce champ est requis' : null,
                ),
                DropdownButtonFormField<String>(
                  value: selectedTypeMaintenance,
                  decoration: InputDecoration(labelText: 'Type Maintenance'),
                  items: typeMaintenanceOptions.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    selectedTypeMaintenance = newValue;
                  },
                  validator: (value) => value == null ? 'Ce champ est requis' : null,
                ),
                DropdownButtonFormField<int>(
                  value: selectedUser,
                  decoration: InputDecoration(labelText: 'Utilisateur'),
                  items: utilisateurIds.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('$value'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    selectedUser = newValue;
                  },
                  validator: (value) => value == null ? 'Ce champ est requis' : null,
                ),
                
                
                DropdownButtonFormField<int>(
                  value: selectedUrgence,
                  decoration: InputDecoration(labelText: 'Code Urgence'),
                  items: _urgenceOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('${_urgenceDescriptions[value]} ($value)'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    selectedUrgence = newValue;
                  },
                  validator: (value) => value == null ? 'Ce champ est requis' : null,
                ),
                DropdownButtonFormField<int>(
                  value: selectedEtatDemande,
                  decoration: InputDecoration(labelText: 'Etat Demande'),
                  items: _etatdemandeOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('${_etatdemandeDescriptions[value]} ($value)'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    selectedEtatDemande = newValue;
                  },
                  validator: (value) => value == null ? 'Ce champ est requis' : null,
                ),
                DropdownButtonFormField<int>(
                  value: selectedIdTypeDemande,
                  decoration: InputDecoration(labelText: 'ID Type Demande'),
                  items: _idtypedemandeOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('${_idtypedemandeDescriptions[value]} ($value)'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    selectedIdTypeDemande = newValue;
                  },
                  validator: (value) => value == null ? 'Ce champ est requis' : null,
                ), DropdownButtonFormField<int>(
                  value: selectedEtatDemande,
                  decoration: InputDecoration(labelText: 'Etat Demande'),
                  items: _etatdemandeOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('${_etatdemandeDescriptions[value]} ($value)'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    selectedEtatDemande = newValue;
                  },
                  validator: (value) => value == null ? 'Ce champ est requis' : null,
                ), DropdownButtonFormField<int>(
                  value: selectedPriority,
                  decoration: InputDecoration(labelText: 'Priorité'),
                  items: _priorityOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text('${_priorityDescriptions[value]} ($value)'),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    selectedPriority = newValue;
                  },
                  validator: (value) => value == null ? 'Ce champ est requis' : null,
                ),
              DropdownButtonFormField<int>(
                value: selectedIdPanne,
                decoration: InputDecoration(labelText: 'ID Panne'),
                items: _idPanneOptions.map((int value) {
                  return DropdownMenuItem<int>(
                    value: value,
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal, 
                      child: Row(
                        children: [
                          Text('${_idPanneDescriptions[value]} ($value)'),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                onChanged: (newValue) {
                  selectedIdPanne = newValue;
                },
                validator: (value) => value == null ? 'Ce champ est requis' : null,
              ),
                TextFormField(
                  controller: resumePannneController,
                  decoration: InputDecoration(labelText: 'Résumé Panne'),
                ),
                TextFormField(
                  controller: observationController,
                  decoration: InputDecoration(labelText: 'Observation'),
                ),
                
                TextFormField(
                  controller: codeEquipementController,
                  decoration: InputDecoration(labelText: 'Code Equipement'),
                ),
                TextFormField(
                  controller: terminerController,
                  decoration: InputDecoration(labelText: 'Terminer'),
                ),
                   
              ],
            ),
          ),
        ),
        actions: <Widget>[
          TextButton(
            child: Text('Annuler'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            onPressed: () async {
              if (_formKey.currentState?.validate() ?? false) {
                final demandeintervention = DemandeInterventions(
                       idDemande: isUpdate ? existingDemande?.idDemande ?? 0 : 0,
                  codeDemande: isUpdate ? existingDemande?.codeDemande ?? '' : '',
                  chaine :selectedChaine,
                  etatMachine:selectedEtatMachine,
                  codeUrgence:selectedUrgence,
                    resumePanne:resumePannneController.text.trim(),
                   etatDemande:selectedEtatDemande,
                  dateHeureDemande: DateTime.now(),
                  idTypeDemande:selectedIdTypeDemande,
                 idPanne:int.tryParse(idPanneController.text.trim()),
                  idUtilisateur:selectedUser,
                codeEquipement:codeEquipementController.text.trim(),
                  terminer:int.tryParse(terminerController.text.trim()),
                  observation:observationController.text.trim(),
                  typeMaintenance:selectedTypeMaintenance,
                   codeOrdre:isUpdate ? existingDemande?.codeOrdre ?? '' : '',
                    priorite:selectedPriority,
                  createUser: isUpdate ? existingDemande?.createUser : Provider.of<User>(context, listen: false).matricule,
                  createDateTime: DateTime.now(),
                  lastUpdateUser: Provider.of<User>(context, listen: false).matricule,
                   lastUpdateDateTime: isUpdate ? existingDemande?.createDateTime : DateTime.now(),
                  createMachine:widget.element.createMachine,
                  dateCreateReel: DateTime.now(),
                  maintenanceTSV:selectedMaintenace,
                      );
                      try {
                  final apiService = Provider.of<ApiService>(context, listen: false);
                  final dbHelper = DatabaseHelper.instance;

                  if (isUpdate && existingDemande != null) {
                    await apiService.updateDemandeIntervention(widget.token, existingDemande.idDemande!, demandeintervention);
                    await dbHelper.updateDemande(LocalDemandeIntervention(
                    idDemande: existingDemande.idDemande,
                      codeDemande: existingDemande.codeDemande,
                       chaine:demandeintervention.chaine,
    etatMachine:demandeintervention.etatMachine,
    codeUrgence:demandeintervention.codeUrgence,
    resumePanne:demandeintervention.resumePanne,
    etatDemande:demandeintervention.etatDemande,
    dateHeureDemande:existingDemande.dateHeureDemande,
    idTypeDemande:demandeintervention.idTypeDemande,
    idPanne:demandeintervention.idPanne,
    idUtilisateur:demandeintervention.idUtilisateur,
    codeEquipement:demandeintervention.codeEquipement,
    terminer:demandeintervention.terminer,
    observation:demandeintervention.observation,
    typeMaintenance:demandeintervention.typeMaintenance ,
    codeOrdre:existingDemande.codeOrdre,
    priorite:demandeintervention.priorite,
    createUser:demandeintervention.createUser,
    createDateTime:existingDemande.createDateTime,
    lastUpdateUser:demandeintervention.lastUpdateUser,
    lastUpdateDateTime:demandeintervention.lastUpdateDateTime,
    createMachine:demandeintervention.createMachine,
    dateCreateReel:demandeintervention.dateCreateReel,
    maintenanceTSV:demandeintervention.maintenanceTSV,
                      codeElement: widget.element.codeElement,   
                    ));
                     Navigator.of(context).pop();  
        _showSuccessDialog('Demande mise à jour avec succès.');  
                  } else {
                    final idDemande = await apiService.createDemandeIntervention(widget.token, demandeintervention);
                    await dbHelper.insertDemande(LocalDemandeIntervention(
                      idDemande: idDemande,
                      codeDemande: demandeintervention.codeDemande,
                      chaine:demandeintervention.chaine,
                      etatMachine:demandeintervention.etatMachine,
                      codeUrgence:demandeintervention.codeUrgence,
                      resumePanne:demandeintervention.resumePanne,
                      etatDemande:demandeintervention.etatDemande,
                      dateHeureDemande:demandeintervention.dateHeureDemande,
                      idTypeDemande:demandeintervention.idTypeDemande,
                      idPanne:demandeintervention.idPanne,
                      idUtilisateur:demandeintervention.idUtilisateur,
                      codeEquipement:demandeintervention.codeEquipement,
                      terminer:demandeintervention.terminer,
                      observation:demandeintervention.observation,
                      typeMaintenance:demandeintervention.typeMaintenance ,
                      codeOrdre:demandeintervention.codeOrdre,
                      priorite:demandeintervention.priorite,
                      createUser:demandeintervention.createUser,
                      createDateTime:demandeintervention.createDateTime,
                      lastUpdateUser:demandeintervention.lastUpdateUser,
                      lastUpdateDateTime:demandeintervention.lastUpdateDateTime,
                      createMachine:demandeintervention.createMachine,
                      dateCreateReel:demandeintervention.dateCreateReel,
                      maintenanceTSV:demandeintervention.maintenanceTSV,
                      codeElement: widget.element.codeElement, 
                    ));
                  }
 Navigator.of(context).pop();  
        _showSuccessDialog('Demande ajoutée avec succès.');  

                 } catch (e) {
                  _showAlertDialog('Erreur', 'Une erreur s\'est produite lors de la sauvegarde de la demande. Veuillez réessayer.');
      
      print('Erreur lors de la gestion de la demande: ${e.toString()}');
    } 
              }
            },
  child: Text(isUpdate ? 'Modifier' : 'Ajouter'),
          ),
        ],
      );
    },
  );
}



  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (BuildContext context) {  },
      child: Scaffold(
        appBar: AppBar( backgroundColor: Color.fromARGB(255, 13, 18, 70), 
        title: Text('Détails de l\'élément', style: TextStyle(color: Colors.white)),  
         ),
        body: Container(
    color: Colors.white, 
    child:Padding(
          padding: EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
              Container(
                width: double.infinity,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('Propriété')),
                      DataColumn(label: Text('Valeur')),
                    ],
                    rows: [
                      DataRow(cells: [
                        DataCell(Text('Code Element')),
                        DataCell(Text(widget.element.codeElement ?? '')),
                      ]),
                     
                     
                      DataRow(cells: [
                        DataCell(Text('Code Section')),
                        DataCell(Text(widget.element.codeSection ?? '')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Durée Intervention')),
                        DataCell(Text(widget.element.dureeIntervention ?? '')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Nombre d\'occurrences')),
                        DataCell(Text(widget.element.nbOccurence != null ? widget.element.nbOccurence.toString() : '')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Date de début')),
                        DataCell(Text(widget.element.dateStart ?? '')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Date de fin')),
                        DataCell(Text(widget.element.dateFin ?? '')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Début')),
                        DataCell(Text(widget.element.debut ?? '')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Fin')),
                        DataCell(Text(widget.element.fin ?? '')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Type d\'occurrence')),
                        DataCell(Text(widget.element.typeOccurrence ?? '')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Créé par')),
                        DataCell(Text(widget.element.createUser != null ? widget.element.createUser.toString() : '')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Date de création')),
                        DataCell(Text(widget.element.createDateTime ?? '')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Mis à jour par')),
                        DataCell(Text(widget.element.lastUpdateUser != null ? widget.element.lastUpdateUser.toString() : '')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Date de mise à jour')),
                        DataCell(Text(widget.element.lastUpdateDateTime ?? '')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Machine de création')),
                        DataCell(Text(widget.element.createMachine ?? '')),
                      ]),
                      DataRow(cells: [
                        DataCell(Text('Alerte avant')),
                        DataCell(Text(widget.element.alerteAvant != null ? widget.element.alerteAvant.toString() : '')),
                      ]),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () => updateObservation('OK'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isOkSelected ? Colors.green : Color.fromARGB(255, 10, 14, 56),
                    ),
                    child: Text('OK', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: _isNonOkButtonEnabled ? () => updateObservation('Non OK') : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isNonOkSelected ? Colors.red :  Color.fromARGB(255, 10, 14, 56),
                    ),
                    child: Text('Non OK', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () => _handleInterventionButton(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isNonOkSelected ? Colors.orange : Color.fromARGB(255, 10, 14, 56),
                    ),
                    child: Text('Demande Intervention', style: TextStyle(color: Colors.white)),
                  ),

                ],
              ),
              SizedBox(height: 16.0),
              Column(
                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,

         children: [
              ElevatedButton(
                 style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 10, 14, 56),
                                  textStyle: TextStyle(color: Colors.white),  
                                ),
                onPressed: validateObservation,
                child: Text('Valider l\'observation', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                
                onPressed: updateObservationButton,
                child: Text('Mettre à jour mon observation' , style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isObservationValidated ? Colors.blue : Colors.grey,
                ),
                
              ), 
                            SizedBox(height: 16.0),
ElevatedButton(
                  style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 10, 14, 56),
                                  textStyle: TextStyle(color: Colors.white),  
                                ),
      onPressed: () async {
        final apiService = Provider.of<ApiService>(context, listen: false);
          DateTime today = DateTime.now();

        try {
           List<Inspection> inspections = await apiService.getInspectionsByElementAndDate(
            widget.token,
            widget.element.codeElement ?? '',
                  widget.element.codeSection ?? '',

             today ,
          );

          if (inspections.isNotEmpty) {
             
          String resultText = 'Résultat : ${isOkSelected ? "OK" : "Non OK"} | Urgence : ${inspections.first.urgence} | Observation: ${inspections.first.observation}';
            _showResultDialog(resultText);

          } else {
                             // Navigator.pop(context, 'Aucune inspection trouvée');

            _showAlertDialog('Aucune inspection trouvée', 'Veuillez vérifier la date et le code élément spécifiés');

          }
        } catch (e) {
          print('Erreur lors de la vérification de l\'inspection: ${e.toString()}');
              //Navigator.pop(context, 'Erreur lors de la vérification de l\'inspection');

        }
      },
      child: Text('Vérifier l\'inspection' , style: TextStyle(color: Colors.white)),
    ),
    
    
  
              ],
              ),
            ],
          ),
        ),
      ),
    )),);
  }
}