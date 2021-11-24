class Pays
{
  var pays_id;
  var pays_nom;

  Pays({
    this.pays_id,
    this.pays_nom,

  });

  factory Pays.fromJson(Map<String, dynamic> json) {
    return Pays(
      pays_id: json['pays_id'],
      pays_nom: json['pays_nom'],
    );
  }

}

class Province
{
  var province_id;
  var province_nom;

  Province({
    this.province_id,
    this.province_nom,

  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      province_id: json['province_id'],
      province_nom: json['province_nom'],
    );
  }

}

class Ville
{
  var ville_id;
  var ville_nom;

  Ville({
    this.ville_id,
    this.ville_nom,

  });

  factory Ville.fromJson(Map<String, dynamic> json) {
    return Ville(
      ville_id: json['ville_id'],
      ville_nom: json['ville_nom'],
    );
  }

}