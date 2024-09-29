 
class Inspection {
  int idInspection;
  DateTime? dateInspection;
  String? observation;
  String codeElementSection;
  int? idIntervenant;
  String codeEquipement;
  DateTime? dateElement;
  String? resultats;
  String? urgence;
  String section;
  String codeFamille;
  String? typeMaintenance;
  String? numeroInter;
  int? createUser;
  DateTime? createDateTime;
  int? lastUpdateUser;
  DateTime? lastUpdateDateTime;
  String createMachine;

  Inspection({
    required this.idInspection,
    this.dateInspection,
    this.observation,
    required this.codeElementSection,
    this.idIntervenant,
    required this.codeEquipement,
    this.dateElement,
    this.resultats,
    this.urgence,
    required this.section,
    required this.codeFamille,
    this.typeMaintenance,
    this.numeroInter,
    this.createUser,
    this.createDateTime,
    this.lastUpdateUser,
    this.lastUpdateDateTime,
    required this.createMachine,
  });

  factory Inspection.fromJson(Map<String, dynamic> json) {
    return Inspection(
      idInspection: json['idInspection'],
      dateInspection: json['dateInspection'] != null ? DateTime.parse(json['dateInspection']) : null,
      observation: json['observation'],
      codeElementSection: json['codeElementSection'],
      idIntervenant: json['idIntervenant'],
      codeEquipement: json['codeEquipement'],
      dateElement: json['dateElement'] != null ? DateTime.parse(json['dateElement']) : null,
      resultats: json['resultats'],
      urgence: json['urgence'],
      section: json['section'],
      codeFamille: json['codeFamille'],
      typeMaintenance: json['typeMaintenance'],
      numeroInter: json['numeroInter'],
      createUser: json['createUser'],
      createDateTime: json['createDateTime'] != null ? DateTime.parse(json['createDateTime']) : null,
      lastUpdateUser: json['lastUpdateUser'],
      lastUpdateDateTime: json['lastUpdateDateTime'] != null ? DateTime.parse(json['lastUpdateDateTime']) : null,
      createMachine: json['createMachine'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idInspection': idInspection,
      'dateInspection': dateInspection?.toIso8601String(),
      'observation': observation,
      'codeElementSection': codeElementSection,
      'idIntervenant': idIntervenant,
      'codeEquipement': codeEquipement,
      'dateElement': dateElement?.toIso8601String(),
      'resultats': resultats,
      'urgence': urgence,
      'section': section,
      'codeFamille': codeFamille,
      'typeMaintenance': typeMaintenance,
      'numeroInter': numeroInter,
      'createUser': createUser,
      'createDateTime': createDateTime?.toIso8601String(),
      'lastUpdateUser': lastUpdateUser,
      'lastUpdateDateTime': lastUpdateDateTime?.toIso8601String(),
      'createMachine': createMachine,
    };
  }

  // Méthode copyWith pour créer une copie avec des modifications
  Inspection copyWith({
    int? idInspection,
    DateTime? dateInspection,
    String? observation,
    String? codeElementSection,
    int? idIntervenant,
    String? codeEquipement,
    DateTime? dateElement,
    String? resultats,
    String? urgence,
    String? section,
    String? codeFamille,
    String? typeMaintenance,
    String? numeroInter,
    int? createUser,
    DateTime? createDateTime,
    int? lastUpdateUser,
    DateTime? lastUpdateDateTime,
    String? createMachine,
  }) {
    return Inspection(
      idInspection: idInspection ?? this.idInspection,
      dateInspection: dateInspection ?? this.dateInspection,
      observation: observation ?? this.observation,
      codeElementSection: codeElementSection ?? this.codeElementSection,
      idIntervenant: idIntervenant ?? this.idIntervenant,
      codeEquipement: codeEquipement ?? this.codeEquipement,
      dateElement: dateElement ?? this.dateElement,
      resultats: resultats ?? this.resultats,
      urgence: urgence ?? this.urgence,
      section: section ?? this.section,
      codeFamille: codeFamille ?? this.codeFamille,
      typeMaintenance: typeMaintenance ?? this.typeMaintenance,
      numeroInter: numeroInter ?? this.numeroInter,
      createUser: createUser ?? this.createUser,
      createDateTime: createDateTime ?? this.createDateTime,
      lastUpdateUser: lastUpdateUser ?? this.lastUpdateUser,
      lastUpdateDateTime: lastUpdateDateTime ?? this.lastUpdateDateTime,
      createMachine: createMachine ?? this.createMachine,
    );
  }
}
