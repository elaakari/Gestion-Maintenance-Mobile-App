 import 'package:flutter/material.dart';
import 'package:project_essai_flutter/mdels/inspection.dart';
import 'package:project_essai_flutter/services/api_service.dart';
import 'package:intl/intl.dart';

class InspectionsNotOkPage extends StatefulWidget {
  final String token;
  

  InspectionsNotOkPage({required this.token});

  @override
  _InspectionsNotOkPageState createState() => _InspectionsNotOkPageState();
}

class _InspectionsNotOkPageState extends State<InspectionsNotOkPage> {
  late Future<List<Inspection>> _inspectionsFuture;
   late Map<String, List<Inspection>> _sortedGroupedInspections;  

  String _selectedMonth = DateFormat('MM-yyyy').format(DateTime.now());
  final List<String> _monthsList = List.generate(12, (index) {
    DateTime date = DateTime(DateTime.now().year, index + 1, 1);
    return DateFormat('MM-yyyy').format(date);
  });
  TextEditingController _monthController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _monthController.text = _selectedMonth;
    _fetchInspectionsForMonth(_selectedMonth);
  }

  void _fetchInspectionsForMonth(String month) {
    setState(() {
      _inspectionsFuture = ApiService().getInspectionsWithResultNotOkForMonth(widget.token, month);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 13, 18, 70),
        title: Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: _selectedMonth,
                icon: Icon(Icons.arrow_downward, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Sélectionner un mois',
                  hintStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                ),
                dropdownColor: Color.fromARGB(255, 13, 18, 70),
                style: TextStyle(color: Colors.white),
                items: _monthsList.map((String month) {
                  return DropdownMenuItem<String>(
                    value: month,
                    child: Text(month, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
                onChanged: (newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedMonth = newValue;
                      _monthController.text = newValue;
                      _fetchInspectionsForMonth(newValue);
                    });
                  }
                },
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _monthController,
                decoration: InputDecoration(
                  labelText: 'Mois (MM-yyyy)',
                  labelStyle: TextStyle(color: Colors.white70),
                  border: InputBorder.none,
                  filled: true,
                  fillColor: Color.fromARGB(255, 13, 18, 70),
                ),
                style: TextStyle(color: Colors.white),
                onChanged: (value) {
                  // Optionally handle changes
                },
              ),
            ),
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                String inputMonth = _monthController.text;
                if (_validateMonthFormat(inputMonth)) {
                  _fetchInspectionsForMonth(inputMonth);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Format de mois invalide')));
                }
              },
            ),
            IconButton(
        icon: Icon(Icons.analytics, color: Colors.white),
        onPressed: () {
          _showAnalysisDialog(context);
        },
      ),
            
          ],
        ),
      ),
      body: Container(
        color: Colors.white,
        child: FutureBuilder<List<Inspection>>(
          future: _inspectionsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Erreur: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('Aucune inspection trouvée.'));
            }

            final inspections = snapshot.data!;
            final groupedInspections = groupByCodeElementSection(inspections);
            final sortedGroupedInspections = sortByInspectionCount(groupedInspections);
                _sortedGroupedInspections = sortByInspectionCount(groupedInspections); // assign value to _sortedGroupedInspections


            // Calculate the number of non-OK inspections for each element
            final nonOkInspections = sortedGroupedInspections.values
                .map((inspections) => inspections.where((i) => i.resultats != "OK").length)
                .toList();

           

            return ListView(
  children: sortedGroupedInspections.entries.map((entry) {
    final codeElementSection = entry.key;
    final sectionInspections = entry.value;
    final totalMachines = sectionInspections.length;
    final nonOkMachines = sectionInspections.where((i) => i.resultats != "OK").length;

    // Find the maximum number of non-OK machines across all elements
    final maxNonOkMachines = sortedGroupedInspections.entries.map((entry) => entry.value.where((i) => i.resultats != "OK").length).reduce((a, b) => a > b ? a : b);
        final minNonOkMachines = sortedGroupedInspections.entries.map((entry) => entry.value.where((i) => i.resultats != "OK").length).reduce((a, b) => a < b ? a : b);


    Color backgroundColor;

    if (nonOkMachines == maxNonOkMachines) {
      backgroundColor = Color.fromARGB(255, 178, 39, 29);
    } else if (nonOkMachines > maxNonOkMachines / 2 && nonOkMachines < maxNonOkMachines) {
      backgroundColor = const Color.fromARGB(255, 221, 134, 3);
    } else if (nonOkMachines > minNonOkMachines && nonOkMachines <= maxNonOkMachines / 2) {
      backgroundColor = const Color.fromARGB(255, 236, 214, 8);
    } else {
      backgroundColor = const Color.fromARGB(255, 47, 165, 50);
    }

    return Card(
      margin: EdgeInsets.all(8),
      color: backgroundColor,
      child: ExpansionTile(
        title: Text('$codeElementSection (Non OK: $nonOkMachines)'),
        children: sectionInspections.map((inspection) {
          return ListTile(
            title: Text('Inspection ID: ${inspection.idInspection}'),
            subtitle: Text('Observation: ${inspection.observation}'),
            onTap: () => _showInspectionDetails(context, inspection),
          );
        }).toList(),
      ),
    );
  }).toList(),
);
          },
        ),
      ),
    );
  }

  bool _validateMonthFormat(String value) {
    final regex = RegExp(r'^\d{2}-\d{4}$');
    return regex.hasMatch(value);
  }

  Map<String, List<Inspection>> groupByCodeElementSection(List<Inspection> inspections) {
    return {
      for (var inspection in inspections)
        inspection.codeElementSection: (inspections
            .where((i) => i.codeElementSection == inspection.codeElementSection)
            .toList())
    };
  }

  Map<String, List<Inspection>> sortByInspectionCount(Map<String, List<Inspection>> groupedInspections) {
    final sortedEntries = groupedInspections.entries.toList()
      ..sort((a, b) => b.value.length.compareTo(a.value.length));
    return Map.fromEntries(sortedEntries);
  }

 void _showAnalysisDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Analyse des résultats'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Répartition des résultats:'),
              _buildProgressBar(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProgressBar() {
    final nonOkInspections = _sortedGroupedInspections.values
        .map((inspections) => inspections.where((i) => i.resultats != "OK").length)
        .toList();

  final maxNonOkMachines = nonOkInspections.reduce((a, b) => a > b ? a : b);
  final minNonOkMachines = nonOkInspections.reduce((a, b) => a < b ? a : b);

  final redRate = nonOkInspections.where((x) => x == maxNonOkMachines).length / nonOkInspections.length;
  final orangeRate = nonOkInspections.where((x) => x > maxNonOkMachines / 2 && x < maxNonOkMachines).length / nonOkInspections.length;
  final yellowRate = nonOkInspections.where((x) => x > minNonOkMachines && x <= maxNonOkMachines / 2).length / nonOkInspections.length;
  final greenRate = nonOkInspections.where((x) => x == minNonOkMachines).length / nonOkInspections.length;

  return Row(
    children: [
      _buildProgressBarItem(Colors.red, redRate),
      _buildProgressBarItem(Colors.orange, orangeRate),
      _buildProgressBarItem(Colors.yellow, yellowRate),
      _buildProgressBarItem(Colors.green, greenRate),
    ],
  );
}

Widget _buildProgressBarItem(Color color, double rate) {
  return Expanded(
    child: Column(
      children: [
        Container(
          height: 20,
          width: double.infinity,
          color: color,
        ),
        Text('${(rate * 100).toStringAsFixed(2)}%'),
      ],
    ),
  );
}
  void _showInspectionDetails(BuildContext context, Inspection inspection) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Détails de l\'Inspection'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('ID Inspection: ${inspection.idInspection}'),
                Text('Date Inspection: ${inspection.dateInspection}'),
                Text('Observation: ${inspection.observation}'),
                Text('Code Element Section: ${inspection.codeElementSection}'),
                Text('Code Equipement: ${inspection.codeEquipement}'),
                Text('Résultat: ${inspection.resultats}'),
                Text('Urgence: ${inspection.urgence}'),
                Text('ID Intervenant: ${inspection.idIntervenant}'),
              ],
            ),
          ),
          actions: <Widget>[
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
}