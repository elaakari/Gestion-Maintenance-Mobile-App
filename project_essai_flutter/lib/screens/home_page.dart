import 'package:flutter/material.dart';
import 'package:project_essai_flutter/interventions/intervenant_page.dart';
import 'package:project_essai_flutter/interventions/intervention_page.dart';
 import 'package:project_essai_flutter/mdels/inspection.dart';
import 'package:project_essai_flutter/screens/add_element_page.dart';
import 'package:project_essai_flutter/screens/seeting_page.dart';
import 'package:project_essai_flutter/screens/seeting_page2.dart';
import 'package:project_essai_flutter/screens/tableau_de_bord.dart';
import 'package:project_essai_flutter/screens/utilisateur_setting.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../mdels/element.dart' as elmt;
import 'package:intl/intl.dart';
import 'element_details_screen.dart';
import 'elements_by_date_screen.dart';
import 'login_page.dart';
import 'dart:async';

class HomePage extends StatefulWidget {
  final String token;

  const HomePage({required this.token, Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late Stream<List<elmt.Element>> _elementsStream;
   final _dateController = TextEditingController();
  late Timer _timeTimer;
  final _dateTime = DateFormat('dd/MM/yyyy HH:mm:ss');
  late final ValueNotifier<String> _timeController;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _elementsStream = _fetchElements();
    _timeController = ValueNotifier<String>(_dateTime.format(DateTime.now()));

    _timeTimer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      _timeController.value = _dateTime.format(DateTime.now());
    });
  }

  @override
  void dispose() {
    _timeTimer.cancel();
    super.dispose();
  }

  Stream<List<elmt.Element>> _fetchElements() async* {
    try {
      final elements = await Provider.of<ApiService>(context, listen: false).getElements(widget.token);
      yield elements;
    } catch (e) {
      print('Erreur lors de la récupération des éléments: $e');
      yield [];
    }
  }

Future<void> _checkIfAllElementsInspected() async {
  final elements = await Provider.of<ApiService>(context, listen: false).getElements(widget.token);

  final inspectedElements = await Future.wait(elements.map((element) async {
    final inspections = await _fetchInspections(element.codeElement ?? '', element.codeSection ?? '',DateTime.now());
    return inspections.isNotEmpty;
  }));

  if (inspectedElements.every((inspected) => inspected)) {
    // All elements are inspected, show success dialog
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Succès'),
          content: Text('Tous les éléments sont inspectés'),
          actions: [
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  } else {
    // Not all elements are inspected, show analysis dialog
    final nonInspectedElements = elements.where((element) => !inspectedElements[elements.indexOf(element)]);
    final inspectedPercentage = (inspectedElements.where((inspected) => inspected).length / elements.length) * 100;
    final nonOkInspections = await Future.wait(elements.map((element) async {
      final inspections = await _fetchInspections(element.codeElement ?? '', element.codeSection ?? '',DateTime.now());
      return inspections.any((inspection) => inspection.resultats != 'OK');
    }));

   await showDialog(
  context: context,
  builder: (context) {
    return AlertDialog(
      title: Text('Analyse de jour'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10), 
            Text('Éléments inspectés: ',
            style: TextStyle(fontWeight: FontWeight.bold , ),
            ),
            Text('${inspectedElements.where((inspected) => inspected).length} / ${elements.length}', style: TextStyle(
                fontSize: 16,
                color: inspectedElements.where((inspected) => inspected).length < elements.length / 2
                  ? Colors.red
                  : inspectedElements.where((inspected) => inspected).length == elements.length
                    ? Colors.green
                    : const Color.fromARGB(255, 255, 136, 0),
              ),),
            SizedBox(height: 12), 
            Text('Pourcentage d\'éléments inspectées :' ,style: TextStyle(fontWeight: FontWeight.bold , ),
              ),
             ClipRRect(
  borderRadius: BorderRadius.circular(8), 
  child: LinearProgressIndicator(
    value: inspectedPercentage / 100,
    backgroundColor: Color.fromARGB(255, 197, 29, 29),
    valueColor: AlwaysStoppedAnimation(Color.fromARGB(255, 4, 105, 4)),
      minHeight: 15, 

  ),
             ),
              SizedBox(height: 2),
              Center(
                child: Text(
                  '${inspectedPercentage.round()}%',
                  style: TextStyle(fontSize: 16,color: inspectedElements.where((inspected) => inspected).length < elements.length / 2
                  ? Colors.red
                  : inspectedElements.where((inspected) => inspected).length == elements.length
                    ? Colors.green
                    : const Color.fromARGB(255, 255, 136, 0),
              ),),
                ),
              
            SizedBox(height: 10), 
            Text('Inspections non OK:',style: TextStyle(fontWeight: FontWeight.bold , ),),

             Text('${nonOkInspections.where((nonOk) => nonOk).length}'),
              SizedBox(height: 10),
              Text('Éléments non inspectés: ',style: TextStyle(fontWeight: FontWeight.bold , ),),
              Text('${nonInspectedElements.map((element) => '- ${element.codeElement}').join('\n')}'),       
                  ],
        ),
      ),
          actions: [
            ElevatedButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
               );
          },
        ),
      ],
    );
  },
);}}
void _logout() async {
   await _checkIfAllElementsInspected();
}


 Future<List<Inspection>> _fetchInspections(String codeElement,String codeSection, DateTime date) async {
    try {
      return await Provider.of<ApiService>(context, listen: false).getInspectionsByElementAndDate(widget.token, codeElement,codeSection, date);
    } catch (e) {
      print('Erreur lors de la récupération des inspections: $e');
      return [];
    }
  }


  void _refreshData() {
    setState(() {
      _elementsStream = _fetchElements();
    });
  }
 Future<void> _showAnalysisDialog() async {
  final elements = await Provider.of<ApiService>(context, listen: false).getElements(widget.token);
  final inspectedElements = await Future.wait(elements.map((element) async {
    final inspections = await _fetchInspections(element.codeElement ?? '',element.codeSection ?? '', DateTime.now());
    return inspections.isNotEmpty;
  }));

  final inspectedPercentage = (inspectedElements.where((inspected) => inspected).length / elements.length) * 100;

  final nonOkInspections = await Future.wait(elements.map((element) async {
    final inspections = await _fetchInspections(element.codeElement ?? '',element.codeSection ?? '', DateTime.now());
    return inspections.any((inspection) => inspection.resultats != 'OK');
  }));

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text('Analyse de jour'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 10), 
            Text('Éléments inspectés: ',
            style: TextStyle(fontWeight: FontWeight.bold , ),
            ),
            Text('${inspectedElements.where((inspected) => inspected).length} / ${elements.length}', style: TextStyle(
                fontSize: 16,
                color: inspectedElements.where((inspected) => inspected).length < elements.length / 2
                  ? Colors.red
                  : inspectedElements.where((inspected) => inspected).length == elements.length
                    ? Colors.green
                    : const Color.fromARGB(255, 255, 136, 0),
              ),),
            SizedBox(height: 12), 
            Text('Pourcentage d\'éléments inspectées :' ,style: TextStyle(fontWeight: FontWeight.bold , ),
              ),
             ClipRRect(
  borderRadius: BorderRadius.circular(8), 
  child: LinearProgressIndicator(
    value: inspectedPercentage / 100,
    backgroundColor: Color.fromARGB(255, 197, 29, 29),
    valueColor: AlwaysStoppedAnimation(Color.fromARGB(255, 4, 105, 4)),
      minHeight: 15, 

  ),
             ),
              SizedBox(height: 2),
              Center(
                child: Text(
                  '${inspectedPercentage.round()}%',
                  style: TextStyle(fontSize: 16,color: inspectedElements.where((inspected) => inspected).length < elements.length / 2
                  ? Colors.red
                  : inspectedElements.where((inspected) => inspected).length == elements.length
                    ? Colors.green
                    : const Color.fromARGB(255, 255, 136, 0),
              ),),
                ),
              
            SizedBox(height: 10), 
            Text('Inspections non OK:',style: TextStyle(fontWeight: FontWeight.bold , ),),

             Text('${nonOkInspections.where((nonOk) => nonOk).length}'),
          ],
        ),
        actions: [
          ElevatedButton(
              style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 10, 14, 56),
                                 ),
                            child: Text('OK' , style: TextStyle(color: Colors.white)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
        backgroundColor: const Color.fromARGB(255, 245, 246, 248),  
      );
    },
  );
}
  @override
  Widget build(BuildContext context) {
     final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final fontSize = screenWidth * 0.04;
    return SafeArea(
    child:Scaffold(
      appBar: AppBar(
                backgroundColor: Color.fromARGB(255, 13, 18, 70), 

        title:LayoutBuilder(
          builder: (context, constraints) {
            double iconSize = constraints.maxWidth /15;  
            return Row(
           children: [
            ValueListenableBuilder(
              valueListenable: _timeController,
              builder: (context, value, child) {
 
                return Text(value, style: TextStyle(color: Colors.white, fontSize:fontSize) );
              },
            ),
            
             Expanded(
              child: TextField(
                controller: _dateController,
                    style: TextStyle(color: Colors.white, fontSize:fontSize ),  

                decoration: InputDecoration(
                  labelText: 'Rechercher par date',
                              labelStyle: TextStyle(color: Colors.white, fontSize:fontSize), 

                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
              icon: Icon(Icons.calendar_today, color: Colors.white ,size: iconSize), 
                    onPressed: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2025),
                      );
                      if (pickedDate != null) {
                        setState(() {
                          _selectedDate = pickedDate;
                          _dateController.text = DateFormat('yyyy-MM-dd').format(pickedDate);
                        });
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ElementsByDatePage(token: widget.token, date: pickedDate)),
                        );
                      }
                    },
                  ),
                ),
              ),
            ),
            IconButton(
        icon: Icon(Icons.search, color: Colors.white,size: iconSize), 
              onPressed: () async {
                try {
                  final date = DateTime.parse(_dateController.text);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ElementsByDatePage(token: widget.token, date: date)),
                  );
                } catch (e) {
                  showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: Text('Erreur'),
                        content: Text('La date entrée est incorrecte. Veuillez entrer une date au format yyyy-MM-dd.'),
                        actions: [
                          ElevatedButton(
                             style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color.fromARGB(255, 10, 14, 56),
                                 ),
                            child: Text('OK' , style: TextStyle(color: Colors.white)),
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
            ),
             IconButton(
      icon: Icon(Icons.analytics, color: Colors.white ,size: iconSize),
      onPressed: () async {
        await _showAnalysisDialog();
      },
    ),
  
           PopupMenuButton<int>(
  icon: Icon(Icons.menu, color: Colors.white,size: iconSize), 
  onSelected: (value) {
    if (value == 1) {
       
    } 
    else if (value == 3) {
      _logout();
    }else if (value == 5) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => InspectionsNotOkPage(token: widget.token)),
      );                
    } 
    else if (value == 6) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserPage(token: widget.token)),
      );                
    } 
    
  },
  itemBuilder: (context) => [
    PopupMenuItem(
      value: 0, 
      child:Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 10, 14, 56), 
          ),
         child: Row(
      children: [
        Icon(Icons.settings, color: Colors.white),
        SizedBox(width: 8),
        PopupMenuButton<int>(
          child: Text("Paramètres Element", style: TextStyle(color: Colors.white)),
          onSelected: (value) {
            if (value == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddElementPage(token: widget.token)),
              );
            } else if (value == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage(token: widget.token)),
              );
            } else if (value == 3) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SettingsPage2(token: widget.token)),
              );
            }  
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 1,
              child: Text("Ajouter Element"),
            ),
            PopupMenuItem(
              value: 2,
              child: Text("Modifier Element"),
            ),
            PopupMenuItem(
              value: 3,
              child: Text("Supprimer Element"),
            ),
          ],
        ),
      ],
    ),
  ),
),
 PopupMenuItem(
      value: 6,
      child: Container( 
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 10, 14, 56), 
        ),
        child: Row(
          children: [
            Icon(Icons.person, color: Colors.white),
            SizedBox(width: 8),
            Text("Paramètres User", style: TextStyle(color: Colors.white)),
          ],
        ),),
    ),
 PopupMenuItem(
      value: 0, 
      child:Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 10, 14, 56), 
          ),
         child: Row(
      children: [
        Icon(Icons.info, color: Colors.white),
        SizedBox(width: 8),
        PopupMenuButton<int>(
          child: Text("Informations", style: TextStyle(color: Colors.white)),
          onSelected: (value) {
            if (value == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => InterventionsPage(token: widget.token)),
              );
            } else if (value == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => IntervenantsPage(token: widget.token)),
              );
            } 
          },
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 1,
              child: Text("Interventions"),
            ),
            PopupMenuItem(
              value: 2,
              child: Text("Intervenants"),
            ),
           
          ],
        ),
      ],
    ),
  ),
),

   
    
    PopupMenuItem(
      value: 5,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 10, 14, 56), 
        ),
        child: Row(
          children: [
            Icon(Icons.dashboard, color: Colors.white),
            SizedBox(width: 8),
            Text("Tableau de bord", style: TextStyle(color: Colors.white)),
          ],
        ),),
    ),
    PopupMenuItem(
      value: 3,
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 10, 14, 56), 
        ),
        child: Row(
          children: [
            Icon(Icons.logout, color: Colors.white),
            SizedBox(width: 8),
            Text("Déconnecter", style: TextStyle(color: Colors.white)),
           ],
              ),),
            ),
            
          ],
        ),
      ]
    );}
    ),),
      body: Container(
    decoration: BoxDecoration(
      color: Colors.white,  
    ),
    child:StreamBuilder<List<elmt.Element>>(
        stream: _elementsStream,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List<elmt.Element> equipements = snapshot.data!
                .where((element) => element.typePreventive == 'Equipement')
                .toList();
            List<elmt.Element> inspections = snapshot.data!
                .where((element) => element.typePreventive == 'Inspection HY Sécurité Locaux')
                .toList();

            return SingleChildScrollView(
              child: Column(
                children: [
                   
                  _buildEquipementSection(equipements),
                  _buildInspectionSection(inspections),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Text('Erreur: ${snapshot.error}');
          } else {
            return Center(child: CircularProgressIndicator());
         }
      },
    ),
  ),

      floatingActionButton: FloatingActionButton(
  backgroundColor:  Color.fromARGB(255, 13, 18, 70), 
  onPressed: _refreshData,
  child: Icon(Icons.refresh, color: Colors.white), 
  tooltip: 'Rafraîchir',
      ),),);
  }

Widget _buildEquipementSection(List<elmt.Element> equipements) {
  Map<String, List<elmt.Element>> groupedEquipements = {
    'Daily': [],
    'Weekly': [],
    'Monthly': [],
    'Yearly': [],
  };

  for (var element in equipements) {
    switch (element.typeOccurrence) {
      case 'Daily':
        groupedEquipements['Daily']!.add(element);
        break;
      case 'Weekly':
        groupedEquipements['Weekly']!.add(element);
        break;
      case 'Monthly':
        groupedEquipements['Monthly']!.add(element);
        break;
      case 'Yearly':
        groupedEquipements['Yearly']!.add(element);
        break;
      default:
        break;
    }
  }

 
  return Column(
    children: [
   
     FutureBuilder(
      future: Future.wait([
        ...groupedEquipements.values.map((equipements) async {
          final inspectedCount = await Future.wait(equipements.map((element) async {
            final inspections = await _fetchInspections(element.codeElement ?? '',element.codeSection ?? '', DateTime.now());
            return inspections.isNotEmpty;
          })).then((results) => results.where((result) => result).length);
          return inspectedCount;
        }),
      ]).then((results) => results.reduce((a, b) => a + b)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Chargement...');
        } else if (snapshot.hasError) {
          return Text('Erreur: ${snapshot.error}');
        } else {
          final totalInspectedCount = snapshot.data;
          final totalEquipmentCount = groupedEquipements.values.fold(0, (acc, equipements) => acc + equipements.length);
          final percentage = (totalInspectedCount !/ totalEquipmentCount) * 100;
return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical: 3.0,), 
  child: Stack(
  children: [
    
    Container(
      height: 40, 
      decoration: BoxDecoration(
        color: Colors.red, 
        borderRadius: BorderRadius.circular(30), 
      ),
    ),
    FractionallySizedBox(
      widthFactor: (totalInspectedCount / totalEquipmentCount),  
      child: Container(
        height: 40,  
        decoration: BoxDecoration(
          color: Colors.green,  
          borderRadius: BorderRadius.circular(30),  
        ),
      ),
    ),
    Center(
      child: Text('Equipement (${totalInspectedCount} / ${totalEquipmentCount} - ${((totalInspectedCount / totalEquipmentCount) * 100).round()}%)', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, )),
    ),
  ],
),);
    }
      },
    ),
    ...['Daily', 'Weekly', 'Monthly', 'Yearly'].map((type) {
        if (groupedEquipements[type]!.isEmpty) return Container();
        return FutureBuilder(
          future: Future.wait(groupedEquipements[type]!.map((element) async {
            final inspections = await _fetchInspections(element.codeElement ?? '', element.codeSection ?? '',DateTime.now());
            return inspections.isNotEmpty;
          })).then((results) => results.where((result) => result).length),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Chargement...');
            } else if (snapshot.hasError) {
              return Text('Erreur: ${snapshot.error}');
            } else {
              final inspectedCount = snapshot.data;
               return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
child: Container(
  decoration: BoxDecoration(
    color: Colors.grey[200], // background color
    borderRadius: BorderRadius.circular(10), // optional
  ),
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // optional
  child: Text('$type (${inspectedCount} / ${groupedEquipements[type]!.length})', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
),                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: groupedEquipements[type]!.length,
                    itemBuilder: (context, index) {
                      final element = groupedEquipements[type]![index];
                 return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
                  child: Container(
                    decoration: BoxDecoration(
                       color: Color.fromARGB(255, 222, 231, 244),  
                    borderRadius: BorderRadius.circular(30),  
                    border: Border.all(color: Color.fromARGB(255, 163, 199, 245), width: 1),  
                    ),
                    child: ListTile(
                      title: RichText(
                        text: TextSpan(
                          text: element.codeElement ?? '',
                          style:  TextStyle(                  
                           fontSize: 15,
                           color: Colors.black
                        ), 
                        children: <TextSpan>[
                          TextSpan(
                            text: element.codeSection != null
                                ? ' (${element.codeSection})'
                                : '',
                            style: TextStyle(fontWeight: FontWeight.bold , color: Colors.black),
                          ),
                          ],
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(height: 1, color: Colors.grey), 
                          FutureBuilder<List<Inspection>>(
                        future: _fetchInspections(element.codeElement ?? '',element.codeSection ?? '', DateTime.now()),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return Text('Chargement des inspections...');
                          } else if (snapshot.hasError) {
                            return Text('Erreur: ${snapshot.error}');
                          } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                            final inspection = snapshot.data!.firstWhere(
                              (inspection) => inspection.codeElementSection == element.codeElement,
                              orElse: () => Inspection(
                                idInspection: 0,
                                codeElementSection: '',
                                codeEquipement: '',
                                section: '',
                                codeFamille: '',
                                createMachine: '',
                              ),
                            );

                            return RichText(
                              text: TextSpan(
                              style:  TextStyle(                  
                           fontSize: 15, color: Colors.black,
                      ),                                
                         children: <TextSpan>[
                                  TextSpan(
                                    text: 'Résultat: ',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: '${inspection.resultats ?? 'N/A'}\n'),
                                  TextSpan(
                                    text: 'Urgence: ',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: '${inspection.urgence ?? 'N/A'}\n'),
                                  TextSpan(
                                    text: 'Observation: ',
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(text: '${inspection.observation ?? 'N/A'}'),
                                ],
                              ),
                            );
                          } else {
                            return Text(
                              'Pas encore inspecté!',
                              style: TextStyle(color: Colors.red),
                            );
                          }
                         },
                          ),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ElementDetailsScreen(element: element, token: widget.token),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
       ],
       );}},);
      }).toList()
    ],
  );
  
}

 Widget _buildInspectionSection(List<elmt.Element> inspections) {
  Map<String, List<elmt.Element>> groupedInspections = {
    'Daily': [],
    'Weekly': [],
    'Monthly': [],
    'Yearly': [],
  };

  for (var element in inspections) {
    switch (element.typeOccurrence) {
      case 'Daily':
        groupedInspections['Daily']!.add(element);
        break;
      case 'Weekly':
        groupedInspections['Weekly']!.add(element);
        break;
      case 'Monthly':
        groupedInspections['Monthly']!.add(element);
        break;
      case 'Yearly':
        groupedInspections['Yearly']!.add(element);
        break;
      default:
        break;
    }
  }

  return Column(
    children: [
     FutureBuilder(
      future: Future.wait([
        ...groupedInspections.values.map((equipements) async {
          final inspectedCount = await Future.wait(equipements.map((element) async {
            final inspections = await _fetchInspections(element.codeElement ?? '',element.codeSection ?? '', DateTime.now());
            return inspections.isNotEmpty;
          })).then((results) => results.where((result) => result).length);
          return inspectedCount;
        }),
      ]).then((results) => results.reduce((a, b) => a + b)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Text('Chargement...');
        } else if (snapshot.hasError) {
          return Text('Erreur: ${snapshot.error}');
        } else {
          final totalInspectedCount = snapshot.data;
          final totalEquipmentCount = groupedInspections.values.fold(0, (acc, equipements) => acc + equipements.length);
          final percentage = (totalInspectedCount !/ totalEquipmentCount) * 100;
          return Padding(
  padding: const EdgeInsets.symmetric(horizontal: 5.0,vertical:3.0), 
  child: Stack(
  children: [
    
    Container(
      height: 40, 
      decoration: BoxDecoration(
        color: Colors.red, 
        borderRadius: BorderRadius.circular(30), 
      ),
    ),
    FractionallySizedBox(
      widthFactor: (totalInspectedCount / totalEquipmentCount),  
      child: Container(
        height: 40,  
        decoration: BoxDecoration(
          color: Colors.green,  
          borderRadius: BorderRadius.circular(30),  
        ),
      ),
    ),
    Center(
      child: Text('HY Sécurité Locaux (${totalInspectedCount} / ${totalEquipmentCount} - ${percentage.round()}%)', 
  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,),
    ),
  )],
),);
    }
      },
    ),
  
    ...['Daily', 'Weekly', 'Monthly', 'Yearly'].map((type) {
        if (groupedInspections[type]!.isEmpty) return Container();
         return FutureBuilder(
          future: Future.wait(groupedInspections[type]!.map((element) async {
            final inspections = await _fetchInspections(element.codeElement ?? '', element.codeSection ?? '',DateTime.now());
            return inspections.isNotEmpty;
          })).then((results) => results.where((result) => result).length),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Text('Chargement...');
            } else if (snapshot.hasError) {
              return Text('Erreur: ${snapshot.error}');
            } else {
              final inspectedCount = snapshot.data;
              //final percentage = (inspectedCount !/ groupedInspections[type]!.length) * 100;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
child: Container(
  decoration: BoxDecoration(
    color: Colors.grey[200], // background color
    borderRadius: BorderRadius.circular(10), // optional
  ),
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), 
  child: Text('$type (${inspectedCount} / ${groupedInspections[type]!.length} )', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
),                  ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: groupedInspections[type]!.length,
              itemBuilder: (context, index) {
                final element = groupedInspections[type]![index];
               return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 5.0),
                  child: Container(
                    decoration: BoxDecoration(
                       color: Color.fromARGB(255, 222, 231, 244),  
                    borderRadius: BorderRadius.circular(30),  
                    border: Border.all(color:Color.fromARGB(255, 170, 194, 226), width: 1),  
                  ),
                  child: ListTile(
                    title: RichText(
                      text: TextSpan(
                        text: element.codeElement ?? '',
                        
                        style:  TextStyle(                  
                           fontSize: 15,
                        color: Colors.black,), 
                        children: <TextSpan>[
                          TextSpan(
                            text: element.codeSection != null
                                ? ' (${element.codeSection})'
                                : '',
                            style: TextStyle(fontWeight: FontWeight.bold ,color: Colors.black, ),
                          ),
                        ],
                      ),
                    ),
                    subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Divider(height: 1, color: Colors.grey), 
                          FutureBuilder<List<Inspection>>(
                      future: _fetchInspections(element.codeElement ?? '',element.codeSection ?? '', DateTime.now()),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return Text('Chargement des inspections...');
                        } else if (snapshot.hasError) {
                          return Text('Erreur: ${snapshot.error}');
                        } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                          final inspection = snapshot.data!.firstWhere(
                            (inspection) => inspection.codeElementSection == element.codeElement,
                            orElse: () => Inspection(
                              idInspection: 0,
                              codeElementSection: '',
                              codeEquipement: '',
                              section: '',
                              codeFamille: '',
                              createMachine: '',
                            ),
                          );

                          return RichText(
                            text: TextSpan(
                            style:  TextStyle(                  
                           fontSize: 15,
                           color: Colors.black,),                               
                           children: <TextSpan>[
                                TextSpan(
                                  text: 'Résultat: ',
                                  style: TextStyle(fontWeight: FontWeight.bold , color: Colors.black, ),
                                ),
                                TextSpan(
                                  text: '${inspection.resultats ?? 'N/A'}\n',
                                ),
                                TextSpan(
                                  text: 'Urgence: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '${inspection.urgence ?? 'N/A'}\n',
                                ),
                                TextSpan(
                                  text: 'Observation: ',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                TextSpan(
                                  text: '${inspection.observation ?? 'N/A'}',
                                ),
                              ],
                            ),
                          );
                        } else {
                          return Text(
                            'Pas encore inspecté!',
                            style: TextStyle(color: Colors.red),
                          );
                        }
                       },
                          ),
                        ],
                      ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ElementDetailsScreen(
                            element: element,
                            token: widget.token,
                          ),
                        ),
                      );
                    },
                  ),
                ),);
              },
            ),
          ],
           );}},);
      }).toList()
    ],
  );
  
}}