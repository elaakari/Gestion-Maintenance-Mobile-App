import 'package:flutter/material.dart';
import 'package:project_essai_flutter/mdels/inspection.dart';
import 'package:project_essai_flutter/screens/element_details_bydate_screen.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../mdels/element.dart' as elmt;
import 'package:intl/intl.dart';  

class ElementsByDatePage extends StatefulWidget {
  final String token;
  final DateTime date;

  const ElementsByDatePage({required this.token, required this.date, Key? key}) : super(key: key);

  @override
  _ElementsByDatePageState createState() => _ElementsByDatePageState();
}

class _ElementsByDatePageState extends State<ElementsByDatePage> {
  late Future<List<elmt.Element>> _elementsFuture;

  @override
  void initState() {
    super.initState();
    _elementsFuture = _fetchElements();
    
  }

  Future<List<elmt.Element>> _fetchElements() async {
    try {
      final elements = await Provider.of<ApiService>(context, listen: false).getElementsByDate(widget.token, widget.date);
      return elements;
    } catch (e) {
      print('Erreur lors de la récupération des éléments: $e');
      return [];
    }
  }

Future<List<Inspection>> _fetchInspections(String codeElement,String codeSection, DateTime date) async {
    try {
      return await Provider.of<ApiService>(context, listen: false).getInspectionsByElementAndDate(widget.token, codeElement,codeSection, date);
    } catch (e) {
      print('Erreur lors de la récupération des inspections: $e');
      return [];
    }
  }
  Future<void> _refresh() async {
    setState(() {
      _elementsFuture = _fetchElements();  
    });
  }

Future<void> _showAnalysisDialog() async {
  final elements = await Provider.of<ApiService>(context, listen: false).getElementsByDate(widget.token ,widget.date);
  final inspectedElements = await Future.wait(elements.map((element) async {
    final inspections = await _fetchInspections(element.codeElement ?? '',element.codeSection ?? '',widget.date);
    return inspections.isNotEmpty;
  }));

  final inspectedPercentage = (inspectedElements.where((inspected) => inspected).length / elements.length) * 100;

  final nonOkInspections = await Future.wait(elements.map((element) async {
    final inspections = await _fetchInspections(element.codeElement ?? '',element.codeSection ?? '',widget.date);
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 13, 18, 70),  
         title: Text('Éléments du ${DateFormat('dd/MM/yyyy').format(widget.date)}' , style: TextStyle(color: Colors.white)),
         actions: [  
        IconButton(
          icon: Icon(Icons.analytics, color: Colors.white),
          onPressed: () async {
            await _showAnalysisDialog();
          },
        ),
      ],
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,  
        child: FutureBuilder<List<elmt.Element>>(
          future: _elementsFuture,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<elmt.Element> equipements = snapshot.data!.where((element) => element.typePreventive == 'Equipement').toList();
              List<elmt.Element> inspections = snapshot.data!.where((element) => element.typePreventive == 'Inspection HY Sécurité Locaux').toList();

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
        onPressed: _refresh,  
        child: Icon(Icons.refresh, color: Colors.white), 
        tooltip: 'Rafraîchir',
      ),
    );
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
            final inspections = await _fetchInspections(element.codeElement ?? '',element.codeSection ?? '', widget.date);
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
  padding: const EdgeInsets.symmetric(horizontal: 5.0), 
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
            final inspections = await _fetchInspections(element.codeElement ?? '',element.codeSection ?? '', widget.date);
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
  future: _fetchInspections(element.codeElement ?? '',element.codeSection ?? '', widget.date),
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
          style: DefaultTextStyle.of(context).style, 
          children: <TextSpan>[
            TextSpan(
              text: 'Résultat: ',
              style: TextStyle(fontWeight: FontWeight.bold),  
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

                  onTap: () async {
                      final updatedObservation = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ElementDetailsByDateScreen(element: element, token: widget.token, inspectionDate: widget.date, ),
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
      }).toList(),
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
            final inspections = await _fetchInspections(element.codeElement ?? '', element.codeSection ?? '',widget.date);
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
  padding: const EdgeInsets.symmetric(horizontal: 5.0), 
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
            final inspections = await _fetchInspections(element.codeElement ?? '', element.codeSection ?? '',widget.date);
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
  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), // optional
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
                          Divider(height: 1, color: Colors.grey),                    FutureBuilder<List<Inspection>>(
  future: _fetchInspections(element.codeElement ?? '', element.codeSection ?? '',widget.date),
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
          style: DefaultTextStyle.of(context).style, 
          children: <TextSpan>[
            TextSpan(
              text: 'Résultat: ',
              style: TextStyle(fontWeight: FontWeight.bold),  
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

                  onTap: () async {
                      final updatedObservation = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ElementDetailsByDateScreen(element: element, token: widget.token, inspectionDate: widget.date, ),
                        ),
                      );

                    },
                  ),),);
                },
              ),
            ],
           );}},);
        }).toList(),
      ],
    );
  }}