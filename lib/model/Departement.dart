class Departement
{
  var id;
  var nom;

  Departement({
    required this.id,
    this.nom,

  });

  factory Departement.fromJson(Map<String, dynamic> json) {
    return Departement(
      id: json['id'],
      nom: json['nom'],
    );
  }

}