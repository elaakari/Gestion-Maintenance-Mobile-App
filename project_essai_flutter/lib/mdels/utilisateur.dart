 
class Utilisateur {
  int id;
  int matricule;
  int idSite;
  int idGrade;
  int idAtelier;

  Utilisateur({
    required this.id,
    required this.matricule,
    required this.idSite,
    required this.idGrade,
    required this.idAtelier,
  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
  return Utilisateur(
    id: json['id'] ?? 0,
    matricule: json['matricule'] is int ? json['matricule'] : int.tryParse(json['matricule'].toString()) ?? 0,
    idSite: json['idSite'] ?? 0,
    idGrade: json['idGrade']  ?? 0 ,
    idAtelier: json['idAtelier'] ?? 0,
  );

}


   Map<String, dynamic> toJson() {
    return {
      'id': id,
      'matricule': matricule,
      'idSite': idSite,
      'idGrade': idGrade,
      'idAtelier': idAtelier,
    };
  }

   Utilisateur copyWith({
    int? id,
    int? matricule,
    int? idSite,
    int? idGrade,
    int? idAtelier,
  }) {
    return Utilisateur(
      id: id ?? this.id,
      matricule: matricule ?? this.matricule,
      idSite: idSite ?? this.idSite,
      idGrade: idGrade ?? this.idGrade,
      idAtelier: idAtelier ?? this.idAtelier,
    );
  }

  @override
  String toString() {
    return 'Utilisateur(id: $id, matricule: $matricule, idSite: $idSite, idGrade: $idGrade, idAtelier: $idAtelier)';
  }
}
