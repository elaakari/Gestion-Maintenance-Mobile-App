import 'package:flutter/material.dart';
import 'package:project_essai_flutter/mdels/Intervenant.dart';
import 'package:project_essai_flutter/services/api_service.dart';

class IntervenantsPage extends StatefulWidget {
  final String token;

  const IntervenantsPage({required this.token});

  @override
  _IntervenantsPageState createState() => _IntervenantsPageState();
  
}

class _IntervenantsPageState extends State<IntervenantsPage> {
  String? _selectedIntervenantOption = 'All';  
  List<Intervenant> _intervenants = [];
   @override
  void initState() {
    super.initState();
    _fetchIntervenants(); 
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 13, 18, 70),
        title: Text('Intervenants', style: TextStyle(color: Colors.white)),
      ),
      body: Container(
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: DropdownButton<String>(
                value: _selectedIntervenantOption,
                hint: Text('Choisissez une option'),
                items: [
                  DropdownMenuItem(value: 'All', child: Text('Tous les Intervenants')),
                  DropdownMenuItem(value: 'ById', child: Text('Par ID Intervenant')),
                  DropdownMenuItem(value: 'ByName', child: Text('Par Nom Complet')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedIntervenantOption = value;
                    _fetchIntervenants();
                  });
                },
              ),
            ),
            if (_intervenants != null) ...[
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: DataTable(
                      columns: [
                        DataColumn(label: Text('ID')),
                        DataColumn(label: Text('Prénom')),
                        DataColumn(label: Text('Nom')),
                        DataColumn(label: Text('Fonction')),
                        DataColumn(label: Text('Équipe')),
                        DataColumn(label: Text('Actif')),
                        DataColumn(label: Text('Supprimé')),
                        DataColumn(label: Text('Aide Intervenant')),
                        DataColumn(label: Text('Créé Par')),
                        DataColumn(label: Text('Date Création')),
                        DataColumn(label: Text('Dernière Mise à Jour')),
                        DataColumn(label: Text('Machine Création')),
                        DataColumn(label: Text('Site')),
                      ],
                      rows: _intervenants!.map((intervenant) {
                        return DataRow(cells: [
                          DataCell(Text(intervenant.idIntervenant.toString())),
                          DataCell(Text(intervenant.firstName ?? '')),
                          DataCell(Text(intervenant.lastName ?? '')),
                          DataCell(Text(intervenant.fonction ?? '')),
                          DataCell(Text(intervenant.idEquipe?.toString() ?? '')),
                          DataCell(Text(intervenant.isActive?.toString() ?? '')),
                          DataCell(Text(intervenant.aideIntervenant?.toString() ?? '')),
                          DataCell(Text(intervenant.createUser?.toString() ?? '')),
                          DataCell(Text(intervenant.createDateTime?.toString() ?? '')),
                          DataCell(Text(intervenant.lastUpdateUser?.toString() ?? '')),
                          DataCell(Text(intervenant.lastUpdateDateTime?.toString() ?? '')),
                          DataCell(Text(intervenant.createMachine ?? '')),
                          DataCell(Text(intervenant.idSite?.toString() ?? '')),
                        ]);
                      }).toList(),
                    ),
                  ),
                ),
              ),
            ] else if (_intervenants != null && _intervenants!.isEmpty) ...[
              Center(child: Text('Aucun intervenant trouvé')),
            ],
          ],
        ),
      ),
    );
  }

  void _fetchIntervenants() async {
    try {
      if (_selectedIntervenantOption == 'All') {
        print('Fetching all intervenants...');
      final List<Intervenant> intervenants = await ApiService().getIntervenants(widget.token);
        setState(() {
          _intervenants = intervenants;
        });
      } else if (_selectedIntervenantOption == 'ById') {
        int? id = await _showIdInputDialog(context, 'Entrez l\'ID de l\'intervenant');
        if (id != null) {
          print('Fetching intervenant by ID: $id');
        final Intervenant? intervenant = await ApiService().getIntervenantById(widget.token, id) as Intervenant?;
          if (intervenant != null) {
            setState(() {
              _intervenants = [intervenant];
            });
          } else {
            _showErrorDialog(context, 'Aucun intervenant trouvé avec cet ID.');
          }
        }
      } else if (_selectedIntervenantOption == 'ByName') {
        final input = await _showTextInputDialog(context, 'Entrez le nom complet de l\'intervenant');
        if (input != null) {
          final parts = input.split(' ');
          String? firstName = parts.isNotEmpty ? parts.first : null;
          String? lastName = parts.length > 1 ? parts.sublist(1).join(' ') : null;
          print('Fetching intervenant by name: $firstName $lastName');
    final Intervenant? intervenant = await ApiService().getIntervenantByName(widget.token, firstName!, lastName!);
          if (intervenant != null) {
            setState(() {
              _intervenants = [intervenant];
            });
          } else {
            _showErrorDialog(context, 'Aucun intervenant trouvé avec ce nom.');
          }
        }
      }
    } catch (e) {
      print('Error fetching intervenants: $e');
      _showErrorDialog(context, 'Une erreur est survenue lors de la récupération des intervenants.');
    }
  }

  Future<int?> _showIdInputDialog(BuildContext context, String title) async {
    final TextEditingController controller = TextEditingController();
    return showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: 'ID'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(int.tryParse(controller.text));
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Annuler'),
            ),
          ],
        );
      },
    );
  }

  Future<String?> _showTextInputDialog(BuildContext context, String title) async {
    final TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: 'Nom complet'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(controller.text);
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Annuler'),
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
