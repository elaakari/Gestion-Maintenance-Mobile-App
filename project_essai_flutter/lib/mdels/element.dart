class Element {
  final int? idElement;
  final String? codeElement;
  String? observation;
   final String? codeSection;
  final String? dureeIntervention;
  final int? nbOccurence;
  final String? dateStart;
  final String? dateFin;
  final String? debut;
  final String? fin;
  final String? typeOccurrence;
  final int? createUser;
  final String? createDateTime;
  final int? lastUpdateUser;
  final String? lastUpdateDateTime;
  final String? createMachine;
  final int? alerteAvant;
  final String? typePreventive;
  final String? codeFamille;

  Element({
    this.idElement,
    this.codeElement,
    this.observation,
    this.codeSection,
    this.dureeIntervention,
    this.nbOccurence,
    this.dateStart,
    this.dateFin,
    this.debut,
    this.fin,
    this.typeOccurrence,
    this.createUser,
    this.createDateTime,
    this.lastUpdateUser,
    this.lastUpdateDateTime,
    this.createMachine,
    this.alerteAvant,
    this.typePreventive,
    this.codeFamille,
  });

  Element copyWith({
    int? idElement,
    String? codeElement,
    String? observation,
    String? codeSection,
    String? dureeIntervention,
    int? nbOccurence,
    String? dateStart,
    String? dateFin,
    String? debut,
    String? fin,
    String? typeOccurrence,
    int? createUser,
    String? createDateTime,
    int? lastUpdateUser,
    String? lastUpdateDateTime,
    String? createMachine,
    int? alerteAvant,
    String? typePreventive,
    String? codeFamille,
  }) {
    return Element(
      idElement: idElement ?? this.idElement,
      codeElement: codeElement ?? this.codeElement,
      observation: observation ?? this.observation,
      codeSection: codeSection ?? this.codeSection,
      dureeIntervention: dureeIntervention ?? this.dureeIntervention,
      nbOccurence: nbOccurence ?? this.nbOccurence,
      dateStart: dateStart ?? this.dateStart,
      dateFin: dateFin ?? this.dateFin,
      debut: debut ?? this.debut,
      fin: fin ?? this.fin,
      typeOccurrence: typeOccurrence ?? this.typeOccurrence,
      createUser: createUser ?? this.createUser,
      createDateTime: createDateTime ?? this.createDateTime,
      lastUpdateUser: lastUpdateUser ?? this.lastUpdateUser,
      lastUpdateDateTime: lastUpdateDateTime ?? this.lastUpdateDateTime,
      createMachine: createMachine ?? this.createMachine,
      alerteAvant: alerteAvant ?? this.alerteAvant,
      typePreventive: typePreventive ?? this.typePreventive,
      codeFamille: codeFamille ?? this.codeFamille,
    );
  }

  factory Element.fromJson(Map<String, dynamic> json) {
    return Element(
      idElement: json['idElement'] as int?,
      codeElement: json['codeElement'] as String?,
      observation: json['observation'] as String?,
      codeSection: json['codeSection'] as String?,
      dureeIntervention: json['dureeIntervention'] as String?,
      nbOccurence: json['nbOccurence'] as int?,
      dateStart: json['dateStart'] as String?,
      dateFin: json['dateFin'] as String?,
      debut: json['debut'] as String?,
      fin: json['fin'] as String?,
      typeOccurrence: json['typeOccurrence'] as String?,
      createUser: json['createUser'] as int?,
      createDateTime: json['createDateTime'] as String?,
      lastUpdateUser: json['lastUpdateUser'] as int?,
      lastUpdateDateTime: json['lastUpdateDateTime'] as String?,
      createMachine: json['createMachine'] as String?,
      alerteAvant: json['alerteAvant'] as int?,
      typePreventive: json['typePreventive'] as String?,
      codeFamille: json['codeFamille'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idElement': idElement,
      'codeElement': codeElement,
      'observation': observation,
      'codeSection': codeSection,
      'dureeIntervention': dureeIntervention,
      'nbOccurence': nbOccurence,
      'dateStart': dateStart,
      'dateFin': dateFin,
      'debut': debut,
      'fin': fin,
      'typeOccurrence': typeOccurrence,
      'createUser': createUser,
      'createDateTime': createDateTime,
      'lastUpdateUser': lastUpdateUser,
      'lastUpdateDateTime': lastUpdateDateTime,
      'createMachine': createMachine,
      'alerteAvant': alerteAvant,
      'typePreventive': typePreventive,
      'codeFamille': codeFamille,
    };
  }
}
