 
import 'package:project_essai_flutter/mdels/demade_interventions.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:async';

// Modèle LocalDemandeIntervention
class LocalDemandeIntervention {
  final int? idDemande;
  final String? codeDemande;
  final String? chaine;
  final String? etatMachine;
  final int? codeUrgence;
  final String? resumePanne;
  final int? etatDemande;
  final DateTime? dateHeureDemande;
  final int? idTypeDemande;
  final int? idPanne;
  final int? idUtilisateur;
  final String? codeEquipement;
  final int? terminer;
  final String? observation;
  final String? typeMaintenance;
  final String? codeOrdre;
  final int? priorite;
  final int? createUser;
  final DateTime? createDateTime;
  final int? lastUpdateUser;
  final DateTime? lastUpdateDateTime ;
  final String? createMachine;
  final DateTime? dateCreateReel;
  final bool? maintenanceTSV;
  final String? codeElement;

  LocalDemandeIntervention({
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
    this.lastUpdateDateTime ,
    this.createMachine,
    this.dateCreateReel,
    this.maintenanceTSV,
    this.codeElement,
  });

  Map<String, dynamic> toMap() {
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
      'lastUpdateDateTime ': lastUpdateDateTime ?.toIso8601String(),
      'createMachine': createMachine,
      'dateCreateReel': dateCreateReel?.toIso8601String(),
      'maintenanceTSV': maintenanceTSV == true ? 1 : 0,
      'codeElement': codeElement,
    };
  }

  factory LocalDemandeIntervention.fromMap(Map<String, dynamic> map) {
    return LocalDemandeIntervention(
      idDemande: map['idDemande'],
      codeDemande: map['codeDemande'],
      chaine: map['chaine'],
      etatMachine: map['etatMachine'],
      codeUrgence: map['codeUrgence'],
      resumePanne: map['resumePanne'],
      etatDemande: map['etatDemande'],
      dateHeureDemande: map['dateHeureDemande'] != null
          ? DateTime.parse(map['dateHeureDemande'])
          : null,
      idTypeDemande: map['idTypeDemande'],
      idPanne: map['idPanne'],
      idUtilisateur: map['idUtilisateur'],
      codeEquipement: map['codeEquipement'],
      terminer: map['terminer'],
      observation: map['observation'],
      typeMaintenance: map['typeMaintenance'],
      codeOrdre: map['codeOrdre'],
      priorite: map['priorite'],
      createUser: map['createUser'],
      createDateTime: map['createDateTime'] != null
          ? DateTime.parse(map['createDateTime'])
          : null,
      lastUpdateUser: map['lastUpdateUser'],
      lastUpdateDateTime : map['lastUpdateDateTime '] != null
          ? DateTime.parse(map['lastUpdateDateTime '])
          : null,
      createMachine: map['createMachine'],
      dateCreateReel: map['dateCreateReel'] != null
          ? DateTime.parse(map['dateCreateReel'])
          : null,
      maintenanceTSV: map['maintenanceTSV'] == 1,
      codeElement: map['codeElement'],
    );
  }
}
//extention 
extension LocalDemandeInterventionToDemandeIntervention on LocalDemandeIntervention {
  DemandeInterventions toDemandeIntervention() {
    return DemandeInterventions(
    idDemande :idDemande,
    codeDemande:codeDemande,
    chaine:chaine,
    etatMachine:etatMachine,
    codeUrgence:codeUrgence,
    resumePanne:resumePanne,
    etatDemande:etatDemande,
    dateHeureDemande:dateHeureDemande,
    idTypeDemande:idTypeDemande,
    idPanne:idPanne,
    idUtilisateur:idUtilisateur,
    codeEquipement:codeEquipement,
    terminer:terminer,
    observation:observation,
    typeMaintenance:typeMaintenance ,
    codeOrdre:codeOrdre,
    priorite:priorite,
    createUser:createUser,
    createDateTime:createDateTime,
    lastUpdateUser:lastUpdateUser,
    lastUpdateDateTime:lastUpdateDateTime ,
    createMachine:createMachine,
    dateCreateReel:dateCreateReel,
    maintenanceTSV:maintenanceTSV,
      );
  }
}
//classe
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init() {
    _initDB('local_demande_interventions.db');
  }

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('local_demande_interventions.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE local_demandes_intervention (
            idDemande INTEGER PRIMARY KEY AUTOINCREMENT,
            codeDemande TEXT,
            chaine TEXT,
            etatMachine TEXT,
            codeUrgence INTEGER,
            resumePanne TEXT,
            etatDemande INTEGER,
            dateHeureDemande TEXT,
            idTypeDemande INTEGER,
            idPanne INTEGER,
            idUtilisateur INTEGER,
            codeEquipement TEXT,
            terminer INTEGER,
            observation TEXT,
            typeMaintenance TEXT,
            codeOrdre TEXT,
            priorite INTEGER,
            createUser INTEGER,
            createDateTime TEXT,
            lastUpdateUser INTEGER,
            lastUpdateDateTime  TEXT,
            createMachine TEXT,
            dateCreateReel TEXT,
            maintenanceTSV INTEGER,
            codeElement TEXT
          )
        ''');
      },
    );
  }

 
     
  Future<int> insertDemande(LocalDemandeIntervention demande) async {
  final db = await instance.database;
  final existingDemande = await getDemande(demande.idDemande);

  if (existingDemande != null) {
    print('Updating existing demande with id: ${demande.idDemande}');
    return await updateDemande(demande);
  } else {
    print('Creating new demande with id: ${demande.idDemande}');
    return await db.insert('local_demandes_intervention', demande.toMap());
  }
}


  Future<int> updateDemande(LocalDemandeIntervention demande) async {
    final db = await instance.database;
    return await db.update(
      'local_demandes_intervention',
      demande.toMap(),
      where: 'idDemande = ?',
      whereArgs: [demande.idDemande],
    );
  }

  Future<LocalDemandeIntervention?> getDemande(int? idDemande) async {
    final db = await instance.database;
    final maps = await db.query(
      'local_demandes_intervention',
      columns: [
         'idDemande',
      'codeDemande',
      'chaine',
      'etatMachine',
      'codeUrgence',
      'resumePanne',
      'etatDemande',
      'dateHeureDemande',
      'idTypeDemande',
      'idPanne',
      'idUtilisateur',
      'codeEquipement',
      'terminer',
      'observation',
      'typeMaintenance',
      'codeOrdre',
      'priorite',
      'createUser',
      'createDateTime',
      'lastUpdateUser',
      'lastUpdateDateTime ',
      'createMachine',
      'dateCreateReel',
      'maintenanceTSV',
      'codeElement',
      ],
      where: 'idDemande = ?',
      whereArgs: [idDemande],
    );
    if (maps.isNotEmpty) {
      return LocalDemandeIntervention.fromMap(maps.first);
    } else {
      return null;
    }
  }

  Future<List<LocalDemandeIntervention>> getDemandeInterventionsByCodeDemandeAndDateAndCodeElement(
    String codeDemande,
    DateTime date,
    String codeElement,
  ) async {
    final db = await instance.database;
    final formattedDate = date.toIso8601String().substring(0, 10); 

     print('Querying database with:');
    print('codeDemande: $codeDemande');
    print('formattedDate: $formattedDate');
    print('codeElement: $codeElement');

    final maps = await db.query(
      'local_demandes_intervention',
        columns: [
         'idDemande',
      'codeDemande',
      'chaine',
      'etatMachine',
      'codeUrgence',
      'resumePanne',
      'etatDemande',
      'dateHeureDemande',
      'idTypeDemande',
      'idPanne',
      'idUtilisateur',
      'codeEquipement',
      'terminer',
      'observation',
      'typeMaintenance',
      'codeOrdre',
      'priorite',
      'createUser',
      'createDateTime',
      'lastUpdateUser',
      'lastUpdateDateTime ',
      'createMachine',
      'dateCreateReel',
      'maintenanceTSV',
      'codeElement',
      ],
       
      where: 'codeDemande = ? AND DATE(dateHeureDemande) = ? AND codeElement = ?',
      whereArgs: [codeDemande, formattedDate, codeElement],
    );

     print('Raw data retrieved from database: $maps');

    final localDemandeInterventions = maps.map((map) => LocalDemandeIntervention.fromMap(map)).toList();

     print('Mapped LocalDemandeInterventions: $localDemandeInterventions');

    return localDemandeInterventions;
  }
}