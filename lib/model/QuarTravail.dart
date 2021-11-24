
class WeekCalendar
{
  var id;
  var nom;
  var photo;
  var couleur;
  var departement;
  var taux;
  var fin_semaine;
  var debut_semaine;
  var heures_proposees;
  var heures_validees;
  var total_salaire_brut;
  var total_salaire_net;

  Jour Dimanche;
  Jour Lundi;
  Jour Mardi;
  Jour Mercredi;
  Jour Jeudi;
  Jour Vendredi;
  Jour Samedi;

  WeekCalendar({
     this.id,
     this.nom,
    this.photo,
    this.couleur,
    this.departement,
    this.taux,
    this.debut_semaine,
    this.fin_semaine,
    this.heures_proposees,
    this.heures_validees,
    this.total_salaire_brut,
    this.total_salaire_net,
    required this.Dimanche,
    required this.Lundi,
    required this.Mardi,
    required this.Mercredi,
    required this.Jeudi,
    required this.Vendredi,
    required this.Samedi,
  });

  factory WeekCalendar.fromJson(Map<String, dynamic> json) {

    return WeekCalendar(
      id: json['id'],
      nom: json['nom'],
      photo: json['photo'],
      couleur: json['couleur'],
      departement: json['departement'],
      taux: json['taux'],
      debut_semaine: json['debut_semaine'],
       fin_semaine: json['fin_semaine'],
      heures_proposees: json['heures_proposees'],
      heures_validees: json['heures_validees'],
      total_salaire_brut: json['total_salaire_brut'],
      total_salaire_net: json['total_salaire_net'],
      Dimanche: Jour.fromJson(json['Dimanche']) ,
      Lundi: Jour.fromJson(json['Lundi']),
      Mardi: Jour.fromJson(json['Mardi']),
      Mercredi: Jour.fromJson(json['Mercredi']),
      Jeudi: Jour.fromJson(json['Jeudi']),
      Vendredi: Jour.fromJson(json['Vendredi']),
      Samedi: Jour.fromJson(json['Samedi']),
    );
  }
}


class Jour
{
  var jour;
  var ferier;
  List<QuarTravail> horaires;

  Jour({
    this.jour,
    this.ferier,
    required this.horaires,
  });

  factory Jour.fromJson(Map<String, dynamic> json) {
    var tagObjsJson= json['horaires'] as List;
    List<QuarTravail> _tags = tagObjsJson.map((tagJson) => QuarTravail.fromJson(tagJson)).toList();

    return Jour(
      jour: json['jour'],
      ferier: json['ferier'],
      horaires: _tags,
    );
  }

}



class QuarTravail
{
  var horaireId;
  var titre;
  var startDate;
  var endDate;
  var description;
  var start_time;
  var end_time;
  var duree;
  var poincon;
  var rapport;
  var isvalidated;
  var taux;
  var status;
  var pause_str;
  var shift_type;
  var ferier;
  var is_pointable;



  QuarTravail({
      this.horaireId,
      this.titre,
      this.startDate,
      this.endDate,
      this.description,
      this.start_time,
      this.end_time,
      this.duree,
      this.poincon,
      this.rapport,
      this.isvalidated,
      this.taux,
      this.status,
      this.pause_str,
      this.shift_type,
      this.ferier,
      this.is_pointable
  });

  factory QuarTravail.fromJson(Map<String, dynamic> json) {

    return QuarTravail(
      horaireId: json['horaireId'],
      titre: json['titre'],
      startDate: json['startDate'],
      endDate: json['endDate'],
      description: json['description'],
      start_time: json['start_time'],
      end_time: json['end_time'],
      duree: json['duree'],
      poincon: json['poincon'],
      rapport: json['rapport'],
      isvalidated: json['isvalidated'],
      status: json['status'],
      pause_str: json['pause_str'],
      shift_type: json['shift_type'],
      ferier: json['ferier'],
      is_pointable: json['is_pointable'],
    );
  }
}


class Week
{
  var dimanche;
  var samedi;

  Week({
    this.dimanche,
    this.samedi,
  });

  factory Week.fromJson(Map<String, dynamic> json) {
    return Week(
      dimanche: json['dimanche'],
      samedi: json['samedi'],
    );
  }

}