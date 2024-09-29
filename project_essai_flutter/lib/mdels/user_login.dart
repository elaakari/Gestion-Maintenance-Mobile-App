class UserLogin {
  final int matricule;
  final String password;

  UserLogin({required this.matricule, required this.password});

  Map<String, dynamic> toJson() {
    return {
      'matricule': matricule,
      'password': password,
    };
  }
}
