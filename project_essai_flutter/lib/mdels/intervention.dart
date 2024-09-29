 
class Intervention {
  final String ?codeIntervention;
    int idIntervention;
  final DateTime? dateHeureIntervention;
  final int? intervenant;
  final bool? cloture;
  final DateTime? dateHeureCloture;
  final String? originePanne;
  final String? remede;
  final String? causePanne;
  final bool? interventionExterne;
  final String? codeDemande;
  final int? idTypeIntervention;
  final int? idPrestataire;
  final bool? changementPiece;
  final bool? interventionPause;
  final int? terminer;
  final String? titre;
  final bool? aideIntervenant;
  final int? createUser;
  final DateTime? createDateTime;
  final int? lastUpdateUser;
  final DateTime? lastUpdateDateTime;
  final String createMachine;
  final DateTime? dateCreateReel;
 

  Intervention({
    required this.codeIntervention,
        required this.idIntervention,
    this.dateHeureIntervention,
    this.intervenant,
    this.cloture,
    this.dateHeureCloture,
    required this.originePanne,
    required this.remede,
    required this.causePanne,
    this.interventionExterne,
    required this.codeDemande,
    this.idTypeIntervention,
    this.idPrestataire,
    this.changementPiece,
    this.interventionPause,
    this.terminer,
    required this.titre,
    this.aideIntervenant,
    this.createUser,
    this.createDateTime,
    this.lastUpdateUser,
    this.lastUpdateDateTime,
    required this.createMachine,
    this.dateCreateReel,
  });

  factory Intervention.fromJson(Map<String, dynamic> json) {
    return Intervention(
      codeIntervention: json['codeIntervention'],
            idIntervention: json['idIntervention'],

      dateHeureIntervention: json['dateHeureIntervention'] != null
          ? DateTime.parse(json['dateHeureIntervention'])
          : null,
      intervenant: json['intervenant'],
      cloture: json['cloture'],
      dateHeureCloture: json['dateHeureCloture'] != null
          ? DateTime.parse(json['dateHeureCloture'])
          : null,
      originePanne: json['originePanne'],
      remede: json['remede'],
      causePanne: json['causePanne'],
      interventionExterne: json['interventionExterne'],
      codeDemande: json['codeDemande'],
      idTypeIntervention: json['idTypeIntervention'],
      idPrestataire: json['idPrestataire'],
      changementPiece: json['changementPiece'],
      interventionPause: json['interventionPause'],
      terminer: json['terminer'],
      titre: json['titre'],
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
      dateCreateReel: json['dateCreateReel'] != null
          ? DateTime.parse(json['dateCreateReel'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'codeIntervention': codeIntervention,
            'idIntervention': idIntervention,
      'dateHeureIntervention': dateHeureIntervention?.toIso8601String(),
      'intervenant': intervenant,
      'cloture': cloture,
      'dateHeureCloture': dateHeureCloture?.toIso8601String(),
      'originePanne': originePanne,
      'remede': remede,
      'causePanne': causePanne,
      'interventionExterne': interventionExterne,
      'codeDemande': codeDemande,
      'idTypeIntervention': idTypeIntervention,
      'idPrestataire': idPrestataire,
      'changementPiece': changementPiece,
      'interventionPause': interventionPause,
      'terminer': terminer,
      'titre': titre,
      'aideIntervenant': aideIntervenant,
      'createUser': createUser,
      'createDateTime': createDateTime?.toIso8601String(),
      'lastUpdateUser': lastUpdateUser,
      'lastUpdateDateTime': lastUpdateDateTime?.toIso8601String(),
      'createMachine': createMachine,
      'dateCreateReel': dateCreateReel?.toIso8601String(),
    };
  }
}
