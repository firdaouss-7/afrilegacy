import 'package:cloud_firestore/cloud_firestore.dart';

class OeuvreModel {
  final String id;
  final String titre;
  final String artiste;
  final String pays;
  final String annee;
  final String description;
  final String imageUrl;
  final String audioUrl;
  final String categorie;
  final String statut;
  final String museeActuel;
  final String paysActuel;
  final bool isFeatured;
  final String model3dUrl;

  OeuvreModel({
    required this.id,
    required this.titre,
    required this.artiste,
    required this.pays,
    required this.annee,
    required this.description,
    required this.imageUrl,
    required this.audioUrl,
    required this.categorie,
    required this.statut,
    required this.museeActuel,
    required this.paysActuel,
    required this.isFeatured,
    required this.model3dUrl,
  });

  bool get has3D => model3dUrl.isNotEmpty;
  bool get isStolen => statut == 'volé';

  factory OeuvreModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return OeuvreModel(
      id: doc.id,
      titre: data['titre'] ?? '',
      artiste: data['artiste'] ?? '',
      pays: data['pays'] ?? '',
      annee: (data['annee'] ?? '').toString(),
      description: data['description'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      audioUrl: data['audioUrl'] ?? '',
      categorie: data['categorie'] ?? '',
      statut: data['statut'] ?? 'normal',
      museeActuel: data['museeActuel'] ?? '',
      paysActuel: data['paysActuel'] ?? '',
      isFeatured: data['isFeatured'] ?? false,
      model3dUrl: data['model3dUrl'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'titre': titre,
      'artiste': artiste,
      'pays': pays,
      'annee': annee,
      'description': description,
      'imageUrl': imageUrl,
      'audioUrl': audioUrl,
      'categorie': categorie,
      'statut': statut,
      'museeActuel': museeActuel,
      'paysActuel': paysActuel,
      'isFeatured': isFeatured,
      'model3dUrl': model3dUrl,
    };
  }
}