class Utilisateur
{
  var nom;
  var email;
  var telephon01;
  var telephon02;
  var date_naissance;
  var date_embauche;
  var date_depart;
  var departement;
  var poste;
  var pays;
  var province;
  var ville;
  var type_salaire;
  var salaire;
  var taux;
  var sexe;
  var jours;

  Utilisateur({
    this.nom,
    this.email,
    this.telephon01,
    this.telephon02,
    this.date_naissance,
    this.date_embauche,
    this.date_depart,
    this.departement,
    this.poste,
    this.pays,
    this.province,
    this.ville,
    this.type_salaire,
    this.salaire,
    this.taux,
    this.sexe,
    this.jours,

  });

  factory Utilisateur.fromJson(Map<String, dynamic> json) {
    return Utilisateur(
      nom: json['nom'],
      email: json['email'],
      telephon01: json['telephon01'],
      telephon02: json['telephon02'],
      date_naissance: json['date_naissance'],
      date_embauche: json['date_embauche'],
      date_depart: json['date_depart'],
      departement: json['departement'],
      poste: json['poste'],
      pays: json['pays'],
      province: json['province'],
      ville: json['ville'],
      type_salaire: json['type_salaire'],
      salaire: json['salaire'],
      taux:  json['taux'],
      sexe:  json['sexe'],
      jours:  json['jours'],
    );
  }
}