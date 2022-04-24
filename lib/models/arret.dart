import 'dart:ffi';

class Arret {
  final String codeLieu;
  final String libelle;
  final String distance;
  final List<String>  lignes;

  Arret({required this.codeLieu, required this.libelle, required this.distance, required this.lignes});

  factory Arret.fromJson(dynamic json) {
    return Arret(
        codeLieu: json['codeLieu'] as String,
        libelle: json['libelle'] as String,
        distance: json['distance'] as String,
        lignes: json['lignes'] as List<String>);
  }

  static List<Arret> recipesFromSnapshot(List snapshot) {
    return snapshot.map((data) {
      return Arret.fromJson(data);
    }).toList();
  }

  @override
  String toString(){
    return 'Recipe {codeLieu: $codeLieu, libelle: $libelle, distance: $distance, lignes: $lignes}';
  }
}