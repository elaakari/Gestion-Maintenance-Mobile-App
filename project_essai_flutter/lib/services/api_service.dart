import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:project_essai_flutter/mdels/Intervenant.dart';
import 'package:project_essai_flutter/mdels/demade_interventions.dart';
import 'package:project_essai_flutter/mdels/inspection.dart';
import 'package:project_essai_flutter/mdels/intervention.dart';
import 'package:project_essai_flutter/mdels/utilisateur.dart';
import '../mdels/element.dart';
import '../mdels/user_login.dart';

class ApiService {
  final String baseUrl = "https://192.168.1.70:7087"; 
 

  Future<String?> authenticate(UserLogin userLogin) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Auth/login'),
      headers: {
        'Content-Type': 'application/json',
      },
      body: jsonEncode(userLogin.toJson()),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body)['token'];
    } else {
      throw Exception("Failed to authenticate");
    }
  }
//GET element
  Future<List<Element>> getElements(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/Elements'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    print('Response status: ${response.statusCode}');
    //print('Response body: ${response.body}');

   if (response.statusCode == 200) {
  final List<dynamic> jsonData = jsonDecode(response.body);
  List<Element> elements = [];
  for (var innerList in jsonData) {
    for (var item in innerList) {
      if (item is Map<String, dynamic>) {
        elements.add(Element.fromJson(item));
      } else {
        throw Exception("Invalid JSON response");
      }
    }
  }
  return elements;
} else {
  throw Exception("Failed to load elements");
}}

//Get element by date
 Future<List<Element>> getElementsByDate(String token, DateTime date) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/Elements/date/${date.toIso8601String().split('T').first}'),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );
    
    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      List<Element> elements = [];
      for (var innerList in jsonData) {
        for (var item in innerList) {
          if (item is Map<String, dynamic>) {
            elements.add(Element.fromJson(item));
          } else {
            throw Exception("Invalid JSON response");
          }
        }
      }
      return elements;
    } else {
      throw Exception("Failed to load elements");
    }
  }

  //ADD element
 Future<int?> addElement(String token, Element element) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Elements'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(element.toJson()),
    );

    if (response.statusCode == 201) {
      final Map<String, dynamic> responseBody = jsonDecode(response.body);
      final int id = responseBody['idElement']; 
      return id;
    } else {
      print('Error adding element: ${response.statusCode}');
      throw Exception('Erreur lors de l\'ajout de l\'élément: ${response.body}');
    }
  } catch (e) {
    print('Error adding element: ${e.toString()}');
    throw Exception('Erreur lors de l\'ajout de l\'élément: ${e.toString()}');
  }
}
//GET element by codeelement or id
Future<Element?> getElementByIdOrCode(
  String token, {
  required String? id,
  required String? code,
}) async {
  try {
    if (id == null && code == null) {
      throw ArgumentError("Either id or code must be provided.");
    }

    if (id != null) {
      final response = await http.get(
        Uri.parse('$baseUrl/api/Elements/$id'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final elementJson = jsonDecode(response.body);
        return Element.fromJson(elementJson);
      } else if (response.statusCode == 404 && code != null) {
        final responseCode = await http.get(
          Uri.parse('$baseUrl/api/Elements/code/$code'),
          headers: {
            'Authorization': 'Bearer $token',
          },
        );

        if (responseCode.statusCode == 200) {
          final elementJson = jsonDecode(responseCode.body);
          return Element.fromJson(elementJson);
        } else {
          return null;
        }
      } else {
         throw Exception('Failed to load element by ID: ${response.statusCode}');
      }
    } else if (code != null) {
      final responseCode = await http.get(
        Uri.parse('$baseUrl/api/Elements/code/$code'),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (responseCode.statusCode == 200) {
        final elementJson = jsonDecode(responseCode.body);
        return Element.fromJson(elementJson);
      } else {
        return null;
      }
    }
  } catch (e) {
    print('Error: $e');
    throw Exception('Error fetching element: ${e.toString()}');
  }

  return null;
}

//UPDATE  element
Future<void> updateElement(String token, int id, Element element) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/api/Elements/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(element.toJson()),
    );

    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la mise à jour de l\'élément: ${response.body}');
    }
  } catch (e) {
    print('Error updating element: ${e.toString()}');
    throw Exception('Erreur lors de la mise à jour de l\'élément: ${e.toString()}');
  }
}

//DELETE element 

Future<void> deleteElement(String token, int id) async {
  try {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/Elements/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression de l\'élément: ${response.body}');
    }
  } catch (e) {
    print('Error deleting element: ${e.toString()}');
    throw Exception('Erreur lors de la suppression de l\'élément: ${e.toString()}');
  }
}

//Add inspection
 Future<int> saveInspection(String token, Inspection inspection) async {
  try {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Elements/saveInspection'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(inspection.toJson()),
    );

    if (response.statusCode == 201) {
      final responseBody = jsonDecode(response.body);
      final id = responseBody['idInspection'];  
      print('Inspection saved successfully with ID: $id');
      return id; 
    } else {
      print('Error saving inspection: ${response.statusCode}');
      throw Exception('Error saving inspection: ${response.body}');
    }
  } catch (e) {
    print('Error saving inspection: ${e.toString()}');
    throw Exception('Error saving inspection: ${e.toString()}');
  }
}

  // Get inspections with results not OK
  Future<List<Inspection>> getInspectionsWithResultNotOk(String token) async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/Elements/inspections/not-ok'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((item) => Inspection.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      return [];  // Return an empty list if no inspections are found
    } else {
      throw Exception("Failed to load inspections: ${response.statusCode}");
    }
  }
  // get inspection non ok par mois
   Future<List<Inspection>> getInspectionsWithResultNotOkForMonth(String token, String month) async {
     final response = await http.get(
      Uri.parse('$baseUrl/api/Elements/inspections/not-ok?month=$month'),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> jsonData = jsonDecode(response.body);
      return jsonData.map((item) => Inspection.fromJson(item)).toList();
    } else if (response.statusCode == 404) {
      return [];   
    } else {
      throw Exception("Failed to load inspections for month $month: ${response.statusCode}");
    }
  }

//Update inspection
Future<void> updateInspection(String token, int id, Inspection inspection) async {
  try {
    print('Updating inspection with ID: $id');
    print('Inspection details: ${inspection.toJson()}');

    final response = await http.put(
      Uri.parse('$baseUrl/api/Elements/inspection/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(inspection.toJson()),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 204) {
      print('Inspection updated successfully');
    } else {
      print('Failed to update inspection: ${response.statusCode}');
      throw Exception('Failed to update inspection: ${response.body}');
    }
  } catch (e) {
    print('Error updating inspection: ${e.toString()}');
    throw Exception('Error updating inspection: ${e.toString()}');
  }
}
//Get inspection by code element et date
Future<List<Inspection>> getInspectionsByElementAndDate(String token, String codeElement,String codeSection,DateTime date) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/Elements/inspections?codeElement=$codeElement&codeSection=$codeSection&date=${date.toIso8601String().split('T').first}'),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((item) => Inspection.fromJson(item)).toList();
  } else {
    return [];  
  }
}
//Get intervenant
Future<List<Intervenant>> getIntervenants(String token) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/Elements/itervenant'),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((item) => Intervenant.fromJson(item)).toList();
  } else {
    throw Exception("Failed to load intervenants");
  }
}

//Get intervenant by id
 Future<Intervenant?> getIntervenantById(String token, int id) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/Elements/intervenant/$id'),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final intervenantJson = jsonDecode(response.body);
    return Intervenant.fromJson(intervenantJson);
  } else if (response.statusCode == 404) {
    return null; 
  } else {
    throw Exception('Error fetching intervenant: ${response.statusCode}');
  }
}

//Get intervenant by name
Future<Intervenant?> getIntervenantByName(String token, String firstName, String lastName) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/Elements/$firstName/$lastName'),  
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final intervenantJson = jsonDecode(response.body);
    return Intervenant.fromJson(intervenantJson);
  } else {
    return null;
  }
}
 /*
  // Get all interventions
Future<List<Intervention>> getInterventions(String token) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/Elements/intervention'),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((item) => Intervention.fromJson(item)).toList();
  } else {
    throw Exception("Failed to load interventions");
  }
}
*/
// Get intervention by ID
Future<Intervention?> getInterventionById(String token, int id) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/Elements/ids/$id'),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final interventionJson = jsonDecode(response.body);
    return Intervention.fromJson(interventionJson);
  } else {
    return null; 
  }
}
// Get intervention by ID
Future<Intervention?> getDemandeInterventionById(String token, int id) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/Elements/demandeintervention/$id'),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final demandeinterventionJson = jsonDecode(response.body);
    return demandeinterventionJson.fromJson(demandeinterventionJson);
  } else {
    return null; 
  }
}

 // Get intervention by code
 Future<Intervention?> getInterventionByCode(String token, String codeIntervention) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/Elements/codes/$codeIntervention'),
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final interventionJson = jsonDecode(response.body);
    return Intervention.fromJson(interventionJson);
  } else if (response.statusCode == 404) {
    return null; 
  } else {
    throw Exception('Error fetching intervention by code: ${response.statusCode}');
  }
}

// Get interventions by intervenant ID
Future<List<Intervention>> getInterventionsByIntervenant(String token, int intervenantId) async {
  final response = await http.get(
    Uri.parse('$baseUrl/api/Elements/intervenants/$intervenantId/interventions'),
 
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((item) => Intervention.fromJson(item)).toList();
  } else {
    return [];
  }
}

/*//Add intervention
Future<int> createIntervention(String token, Intervention intervention) async {
  try {
    Map<String, dynamic> interventionJson = intervention.toJson();
    interventionJson.remove('codeIntervention');
    interventionJson.remove('idIntervention');
    interventionJson.remove('codeDemande');
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/Elements/intervention'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(interventionJson),
    );

    print('Request body CREAAATE : ${jsonEncode(interventionJson)}');

    if (response.statusCode == 201) {
      print('Intervention created successfully');
      return jsonDecode(response.body)['idIntervention'];
    } else {
      print('Failed to create intervention: ${response.statusCode}');
      throw Exception('Failed to create intervention: ${response.body}');
    }
  } catch (e) {
    print('Error creating intervention: ${e.toString()}');
    throw Exception('Error creating intervention: ${e.toString()}');
  }
}
*/
//Add intervention
Future<int> createDemandeIntervention(String token, DemandeInterventions demandeintervention) async {
  try {
    Map<String, dynamic> demandeinterventionJson = demandeintervention.toJson();
      demandeinterventionJson.remove('idDemande');
      demandeinterventionJson.remove('codeOrdre');
      demandeinterventionJson.remove('codeDemande');
    
    final response = await http.post(
      Uri.parse('$baseUrl/api/Elements/demandeintervention'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(demandeinterventionJson),
    );

    print('Request body CREAAATE : ${jsonEncode(demandeinterventionJson)}');

    if (response.statusCode == 201) {
      print('demande Intervention created successfully');
      return jsonDecode(response.body)['idDemande'];
    } else {
      print('Failed to create intervention: ${response.statusCode}');
      throw Exception('Failed to create intervention: ${response.body}');
    }
  } catch (e) {
    print('Error creating demande: ${e.toString()}');
    throw Exception('Error creating demande: ${e.toString()}');
  }
}


Future<List<Intervention>> getInterventionsBetweenDates(String token, DateTime startDate, DateTime endDate) async {
  final startDateFormatted = DateFormat('yyyy-MM-dd').format(startDate);
final endDateFormatted = DateFormat('yyyy-MM-dd').format(endDate);

 final url = Uri.parse('$baseUrl/api/Elements/interventions/dates/${Uri.encodeComponent(startDateFormatted)}/${Uri.encodeComponent(endDateFormatted)}');
   final response = await http.get(
    url,  
    headers: {
      'Content-Type': 'application/json; charset=UTF-8',
      'Authorization': 'Bearer $token',
    },
  );

  if (response.statusCode == 200) {
    final List<dynamic> jsonData = jsonDecode(response.body);
    return jsonData.map((item) => Intervention.fromJson(item)).toList();
  } else {
    return [];
  }
}
 /* // Update Intervention
  Future<void> updateIntervention(String token, int id, Intervention intervention) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/api/Elements/Interv/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(intervention.toJson()),
    );

    print('Request body UPDAAAATE : ${jsonEncode(intervention.toJson())}'); 

    if (response.statusCode == 204) {
      print('Intervention updated successfully');
    } else {
      print('Failed to update intervention: ${response.statusCode}');
      throw Exception('Failed to update intervention: ${response.body}');
    }
  } catch (e) {
    print('Error updating intervention: ${e.toString()}');
    throw Exception('Error updating intervention: ${e.toString()}');
  }
}
*/ Future<void> updateDemandeIntervention(String token, int id, DemandeInterventions demandeintervention) async {
  try {
    final response = await http.put(
      Uri.parse('$baseUrl/api/Elements/demandeintervention/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(demandeintervention.toJson()),
    );

    print('Request body UPDAAAATE : ${jsonEncode(demandeintervention.toJson())}'); 

    if (response.statusCode == 204) {
      print('Intervention updated successfully');
    } else {
      print('Failed to update intervention: ${response.statusCode}');
      throw Exception('Failed to update intervention: ${response.body}');
    }
  } catch (e) {
    print('Error updating intervention: ${e.toString()}');
    throw Exception('Error updating intervention: ${e.toString()}');
  }
}
  
 /* // get intervention by date and codedemande
 Future<List<Intervention>> getInterventionsByDateAndCodeDemande(
  String token,
  DateTime date,
  String? codeDemande,
) async {
  try {
    final formattedDate = date.toIso8601String();
    final uri = Uri.parse('$baseUrl/api/Elements/InterventionBycodeDemande')
        .replace(
          queryParameters: {
            'date': formattedDate,
            'codeDemande': codeDemande ?? '',
          },
        );

    print('Sending request to: $uri');

    final response = await http.get(
      uri,
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      final responseBody = jsonDecode(response.body) as List;
      return responseBody.map((data) => Intervention.fromJson(data)).toList();
    } else {
      throw Exception('Failed to fetch interventions: ${response.statusCode}');
    }
  } catch (e) {
    throw Exception('Error fetching interventions: $e');
  }
}

  */
  // GET: /api/Elements/utilisateur
  Future<List<Utilisateur>> getUtilisateurs(String token) async {
    final response = await http.get(Uri.parse('$baseUrl/api/Elements/utilisateur'), headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },);
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Utilisateur.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load utilisateurs');
    }
  }

  Future<Utilisateur> getUtilisateur(String token, int matricule) async {
  final url = Uri.parse('$baseUrl/api/Elements/utilisateur/$matricule');
   
  final response = await http.get(url, headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $token',
  });

   print('Response body: ${response.body}');

  if (response.statusCode == 200) {
    return Utilisateur.fromJson(json.decode(response.body));
  } else if (response.statusCode == 404) {
    throw Exception('Utilisateur not found');
  } else {
    throw Exception('Failed to load utilisateur');
  }
}


  // POST: /api/Elements/utilisateur
  Future<Utilisateur> createUtilisateur(String token ,Utilisateur utilisateur) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/Elements/utilisateur'),
     headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode(utilisateur.toJson()),
    );

   print(response.body);
    if (response.statusCode == 201) {
      return Utilisateur.fromJson(json.decode(response.body));
    } else if (response.statusCode == 409) {
      throw Exception('Utilisateur with this matricule already exists');
    } else {
      throw Exception('Failed to create utilisateur');
    }
  }

  // PUT: /api/Elements/utilisateur/{matricule}
 Future<void> updateUtilisateur(String token, int matricule, Utilisateur utilisateur) async {
  final response = await http.put(
    Uri.parse('$baseUrl/api/Elements/utilisateur/$matricule'),
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    },
    body: json.encode(utilisateur.toJson()),
  );

   print(response.body);
  if (response.statusCode == 204) {
    // Successful update
  } else if (response.statusCode == 400) {
    throw Exception('Bad request');
  } else if (response.statusCode == 404) {
    throw Exception('Utilisateur not found');
  } else {
    throw Exception('Failed to update utilisateur');
  }
}

  // DELETE: /api/Elements/utilisateur/{matricule}
  Future<void> deleteUtilisateur(String token ,int matricule) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/Elements/utilisateur/$matricule'),
headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },    );

   print(response.body);
    if (response.statusCode == 204) {
     } else if (response.statusCode == 404) {
      throw Exception('Utilisateur not found');
    } else {
      throw Exception('Failed to delete utilisateur');
    }
  }

}