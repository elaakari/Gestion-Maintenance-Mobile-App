import 'package:flutter/material.dart';
import 'package:project_essai_flutter/mdels/intervention.dart';
import 'package:project_essai_flutter/services/api_service.dart';

class InterventionsPage extends StatefulWidget {
  final String token;

  const InterventionsPage({required this.token});

  @override
  _InterventionsPageState createState() => _InterventionsPageState();
}

class _InterventionsPageState extends State<InterventionsPage> {
  String? _selectedInterventionOption;
  List<Intervention> _interventions = [];
  DateTime? _startDate;
  DateTime? _endDate;
   DateTime? _currentMonthStart;
  DateTime? _currentMonthEnd;

 @override
  void initState() {
    super.initState();
    _initCurrentMonthDates();
  }

  void _initCurrentMonthDates() {
    final now = DateTime.now();
    _currentMonthStart = DateTime(now.year, now.month, 1);
    _currentMonthEnd = DateTime(now.year, now.month + 1, 0);
    _startDate = _currentMonthStart;
    _endDate = _currentMonthEnd;
    _fetchInterventionsByDateRange();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 13, 18, 70),
        title: Text('Interventions', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: _selectedInterventionOption,
                hint: Text('Choisissez une option'),
                items: [
                  DropdownMenuItem(value: 'ByCode', child: Text('Par Code')),
                  DropdownMenuItem(value: 'ById', child: Text('Par ID')),
                  DropdownMenuItem(value: 'ByIntervenantId', child: Text('Par Intervenant')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedInterventionOption = value;
                    _fetchInterventions();
                  });
                },
              ),
            ),
            // Section de saisie des dates et bouton rechercher
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Date Début',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            final DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: _startDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setState(() {
                                _startDate = date;
                              });
                            }
                          },
                        ),
                      ),
                      controller: TextEditingController(
                          text: _startDate?.toString().split(' ')[0] ?? ''),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        labelText: 'Date Fin',
                        suffixIcon: IconButton(
                          icon: Icon(Icons.calendar_today),
                          onPressed: () async {
                            final DateTime? date = await showDatePicker(
                              context: context,
                              initialDate: _endDate ?? DateTime.now(),
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2030),
                            );
                            if (date != null) {
                              setState(() {
                                _endDate = date;
                              });
                            }
                          },
                        ),
                      ),
                      controller: TextEditingController(
                          text: _endDate?.toString().split(' ')[0] ?? ''),
                    ),
                  ),
                  SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_startDate != null && _endDate != null) {
                        _fetchInterventionsByDateRange();
                      } else {
                        _showErrorDialog(context, 'Veuillez sélectionner les dates.');
                      }
                    },
                    child: Text('Rechercher'),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: DataTable(
                    columns: [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Code')),
                      DataColumn(label: Text('Date Heure')),
                      DataColumn(label: Text('Intervenant')),
                      DataColumn(label: Text('Clôturé')),
                      DataColumn(label: Text('Date Clôture')),
                      DataColumn(label: Text('Origine Panne')),
                      DataColumn(label: Text('Remède')),
                      DataColumn(label: Text('Cause Panne')),
                      DataColumn(label: Text('Intervention Externe')),
                      DataColumn(label: Text('Code Demande')),
                      DataColumn(label: Text('Type Intervention')),
                      DataColumn(label: Text('Prestataire')),
                      DataColumn(label: Text('Changement Pièce')),
                      DataColumn(label: Text('Pause Intervention')),
                      DataColumn(label: Text('Terminer')),
                      DataColumn(label: Text('Titre')),
                      DataColumn(label: Text('Aide Intervenant')),
                      DataColumn(label: Text('Créé Par')),
                      DataColumn(label: Text('Date Création')),
                      DataColumn(label: Text('Dernière Mise à Jour')),
                      DataColumn(label: Text('Machine Création')),
                      DataColumn(label: Text('Date Création Réelle')),
                    ],
                    rows: _interventions.map((intervention) {
                      return DataRow(cells: [
                        DataCell(Text(intervention.idIntervention.toString())),
                        DataCell(Text(intervention.codeIntervention ?? '')),
                        DataCell(Text(intervention.dateHeureIntervention?.toString() ?? '')),
                        DataCell(Text(intervention.intervenant?.toString() ?? '')),
                        DataCell(Text(intervention.cloture?.toString() ?? '')),
                        DataCell(Text(intervention.dateHeureCloture?.toString() ?? '')),
                        DataCell(Text(intervention.originePanne ?? '')),
                        DataCell(Text(intervention.remede ?? '')),
                        DataCell(Text(intervention.causePanne ?? '')),
                        DataCell(Text(intervention.interventionExterne?.toString() ?? '')),
                        DataCell(Text(intervention.codeDemande ?? '')),
                        DataCell(Text(intervention.idTypeIntervention?.toString() ?? '')),
                        DataCell(Text(intervention.idPrestataire?.toString() ?? '')),
                        DataCell(Text(intervention.changementPiece?.toString() ?? '')),
                        DataCell(Text(intervention.interventionPause?.toString() ?? '')),
                        DataCell(Text(intervention.terminer?.toString() ?? '')),
                        DataCell(Text(intervention.titre ?? '')),
                        DataCell(Text(intervention.aideIntervenant?.toString() ?? '')),
                        DataCell(Text(intervention.createUser?.toString() ?? '')),
                        DataCell(Text(intervention.createDateTime?.toString() ?? '')),
                        DataCell(Text(intervention.lastUpdateUser?.toString() ?? '')),
                        DataCell(Text(intervention.lastUpdateDateTime?.toString() ?? '')),
                        DataCell(Text(intervention.createMachine)),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _fetchInterventionsByDateRange() async {
    try {
      final interventions = await ApiService().getInterventionsBetweenDates(
        widget.token,
        _startDate!,
        _endDate!,
      );
      setState(() {
        _interventions = interventions;
      });
    } catch (e) {
      print('Error fetching interventions by date range: $e');
      _showErrorDialog(context, 'Une erreur est survenue lors de la récupération des interventions.');
    }
  }

  void _fetchInterventions() async {
    try {
      if (_selectedInterventionOption == 'ByCode') {
        String? code = await _showCodeInputDialog(context, 'Entrez le code de l\'intervention');
        if (code != null) {
          final intervention = await ApiService().getInterventionByCode(widget.token, code);
          if (intervention != null) {
            setState(() {
              _interventions = [intervention];
            });
          } else {
            _showErrorDialog(context, 'Aucune intervention trouvée avec ce code.');
          }
        }
      } else if (_selectedInterventionOption == 'ById') {
        int? id = await _showIdInputDialog(context, 'Entrez l\'ID de l\'intervention');
        if (id != null) {
          final intervention = await ApiService().getInterventionById(widget.token, id);
          if (intervention != null) {
            setState(() {
              _interventions = [intervention];
            });
          } else {
            _showErrorDialog(context, 'Aucune intervention trouvée avec cet ID.');
          }
        }
      } else if (_selectedInterventionOption == 'ByIntervenantId') {
        int? intervenantId = await _showIdInputDialog(context, 'Entrez l\'ID de l\'intervenant');
        if (intervenantId != null) {
          final interventions = await ApiService().getInterventionsByIntervenant(
            widget.token, intervenantId);
          setState(() {
            _interventions = interventions;
          });
        }
      }
    } catch (e) {
      print('Error fetching interventions: $e');
      _showErrorDialog(context, 'Une erreur est survenue lors de la récupération des interventions.');
    }
  }

  Future<String?> _showCodeInputDialog(BuildContext context, String title) async {
    String? code;
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            onChanged: (value) {
              code = value;
            },
            decoration: InputDecoration(hintText: 'Code'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(code);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<int?> _showIdInputDialog(BuildContext context, String title) async {
    int? id;
    return await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            keyboardType: TextInputType.number,
            onChanged: (value) {
              id = int.tryParse(value);
            },
            decoration: InputDecoration(hintText: 'ID'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(id);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Erreur'),
          content: Text(message),
          actions: <Widget>[
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
}
