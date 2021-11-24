import 'package:niovar/model/QuarTravail.dart';

class Taches
{
  var id;
  var nom;
  List<QuarTravail>  quartTravail;

  Taches({
    required this.id,
    required  this.nom,
  required  this.quartTravail
  });

  factory Taches.fromJson(Map<String, dynamic> json) {
    var tagObjsJson = json['quartTravail'] as List;
    List<QuarTravail> _tags = tagObjsJson.map((tagJson) => QuarTravail.fromJson(tagJson)).toList();
    return Taches(
      id: json['id'],
      nom: json['nom'],
      quartTravail: _tags,
    );
  }

}

