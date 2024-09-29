class DemandeInterventions {
  int? idDemande;
  String? codeDemande;
  String? chaine;
  String? etatMachine;
  int? codeUrgence;
  String? resumePanne;
  int? etatDemande;
  DateTime? dateHeureDemande;
  int? idTypeDemande;
  int? idPanne;
  int? idUtilisateur;
  String? codeEquipement;
  int? terminer;
  String? observation;
  String? typeMaintenance;
  String? codeOrdre;
  int? priorite;
  int? createUser;
  DateTime? createDateTime;
  int? lastUpdateUser;
  DateTime? lastUpdateDateTime;
  String? createMachine;
  DateTime? dateCreateReel;
  bool? maintenanceTSV;

  DemandeInterventions({
    this.idDemande,
    this.codeDemande,
    this.chaine,
    this.etatMachine,
    this.codeUrgence,
    this.resumePanne,
    this.etatDemande,
    this.dateHeureDemande,
    this.idTypeDemande,
    this.idPanne,
    this.idUtilisateur,
    this.codeEquipement,
    this.terminer,
    this.observation,
    this.typeMaintenance,
    this.codeOrdre,
    this.priorite,
    this.createUser,
    this.createDateTime,
    this.lastUpdateUser,
    this.lastUpdateDateTime,
    this.createMachine,
    this.dateCreateReel,
    this.maintenanceTSV,
  });
   

  Map<String, dynamic> toJson() {
    return {
      'idDemande': idDemande,
      'codeDemande': codeDemande,
      'chaine': chaine,
      'etatMachine': etatMachine,
      'codeUrgence': codeUrgence,
      'resumePanne': resumePanne,
      'etatDemande': etatDemande,
      'dateHeureDemande': dateHeureDemande?.toIso8601String(),
      'idTypeDemande': idTypeDemande,
      'idPanne': idPanne,
      'idUtilisateur': idUtilisateur,
      'codeEquipement': codeEquipement,
      'terminer': terminer,
      'observation': observation,
      'typeMaintenance': typeMaintenance,
      'codeOrdre': codeOrdre,
      'priorite': priorite,
      'createUser': createUser,
      'createDateTime': createDateTime?.toIso8601String(),
      'lastUpdateUser': lastUpdateUser,
      'lastUpdateDateTime': lastUpdateDateTime?.toIso8601String(),
      'createMachine': createMachine,
      'dateCreateReel': dateCreateReel?.toIso8601String(),
      'maintenanceTSV': maintenanceTSV,
    };
  }
}
