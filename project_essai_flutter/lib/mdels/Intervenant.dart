 
class Intervenant {
  final int idIntervenant;
  final String? fonction;
  final int? idEquipe;
  final int? isActive;
  final int? isDelete;
  final String? firstName;
  final String? lastName;
  final bool? aideIntervenant;
  final int? createUser;
  final DateTime? createDateTime;
  final int? lastUpdateUser;
  final DateTime? lastUpdateDateTime;
  final String ?createMachine;
  final int? idSite;

  Intervenant({
    required this.idIntervenant,
    required this.fonction,
    this.idEquipe,
    this.isActive,
    this.isDelete,
    required this.firstName,
    required this.lastName,
    this.aideIntervenant,
    this.createUser,
    this.createDateTime,
    this.lastUpdateUser,
    this.lastUpdateDateTime,
    required this.createMachine,
    this.idSite,
  });

  factory Intervenant.fromJson(Map<String, dynamic> json) {
    return Intervenant(
      idIntervenant: json['idIntervenant'],
      fonction: json['fonction'],
      idEquipe: json['idEquipe'],
      isActive: json['isActive'],
      isDelete: json['isDelete'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      aideIntervenant: json['aideIntervenant'],
      createUser: json['createUser'],
      createDateTime: json['createDateTime'] != null
          ? DateTime.parse(json['createDateTime'])
          : null,
      lastUpdateUser: json['lastUpdateUser'],
      lastUpdateDateTime: json['lastUpdateDateTime'] != null
          ? DateTime.parse(json['lastUpdateDateTime'])
          : null,
      createMachine: json['createMachine'],
      idSite: json['idSite'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idIntervenant': idIntervenant,
      'fonction': fonction,
      'idEquipe': idEquipe,
      'isActive': isActive,
      'isDelete': isDelete,
      'firstName': firstName,
      'lastName': lastName,
      'aideIntervenant': aideIntervenant,
      'createUser': createUser,
      'createDateTime': createDateTime?.toIso8601String(),
      'lastUpdateUser': lastUpdateUser,
      'lastUpdateDateTime': lastUpdateDateTime?.toIso8601String(),
      'createMachine': createMachine,
      'idSite': idSite,
    };
  }
}
