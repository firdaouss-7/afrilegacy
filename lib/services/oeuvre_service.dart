import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afrilegacy/models/oeuvre_model.dart';

class OeuvreService {
  final CollectionReference _oeuvresRef =
      FirebaseFirestore.instance.collection('oeuvres');

  // ==================== STREAMS TEMPS RÉEL ====================

  /// Toutes les œuvres (stream live) — tri côté client
  Stream<List<OeuvreModel>> getOeuvresStream() {
    return _oeuvresRef.snapshots().map((snap) {
      final list = snap.docs.map(OeuvreModel.fromFirestore).toList();
      // Featured en premier, puis ordre alphabétique
      list.sort((a, b) {
        if (a.isFeatured && !b.isFeatured) return -1;
        if (!a.isFeatured && b.isFeatured) return 1;
        return a.titre.compareTo(b.titre);
      });
      return list;
    });
  }

  /// Œuvres featured pour la section hero
  Stream<List<OeuvreModel>> getFeaturedStream() {
    return _oeuvresRef
        .where('isFeatured', isEqualTo: true)
        .snapshots()
        .map((snap) => snap.docs.map(OeuvreModel.fromFirestore).toList());
  }

  /// Œuvres par catégorie
  Stream<List<OeuvreModel>> getByCategorie(String categorie) {
    return _oeuvresRef
        .where('categorie', isEqualTo: categorie)
        .snapshots()
        .map((snap) => snap.docs.map(OeuvreModel.fromFirestore).toList());
  }

  /// Œuvres volées / pillées
  Stream<List<OeuvreModel>> getOeuvresVolees() {
    return _oeuvresRef
        .where('statut', isEqualTo: 'volé')
        .snapshots()
        .map((snap) => snap.docs.map(OeuvreModel.fromFirestore).toList());
  }

  // ==================== FUTURES ====================

  /// Récupérer toutes les œuvres — sans orderBy Firestore
  /// pour éviter d'exclure les docs sans certains champs
  Future<List<OeuvreModel>> getAllOeuvres() async {
    final snap = await _oeuvresRef.get();
    final list = snap.docs.map(OeuvreModel.fromFirestore).toList();
    // Tri côté client : featured d'abord, puis alphabétique
    list.sort((a, b) {
      if (a.isFeatured && !b.isFeatured) return -1;
      if (!a.isFeatured && b.isFeatured) return 1;
      return a.titre.compareTo(b.titre);
    });
    return list;
  }

  /// Récupérer une œuvre par ID
  Future<OeuvreModel?> getOeuvreById(String id) async {
    final doc = await _oeuvresRef.doc(id).get();
    if (!doc.exists) return null;
    return OeuvreModel.fromFirestore(doc);
  }

  /// Recherche côté client
  Future<List<OeuvreModel>> search(String query) async {
    if (query.trim().isEmpty) return getAllOeuvres();
    final all = await getAllOeuvres();
    final q = query.toLowerCase().trim();
    return all.where((o) {
      return o.titre.toLowerCase().contains(q) ||
          o.artiste.toLowerCase().contains(q) ||
          o.categorie.toLowerCase().contains(q) ||
          o.pays.toLowerCase().contains(q);
    }).toList();
  }

  /// Liste des catégories distinctes
  Future<List<String>> getCategories() async {
    final all = await getAllOeuvres();
    final cats = all.map((o) => o.categorie).toSet().toList();
    cats.sort();
    return cats;
  }

  // ==================== ADMIN : CRUD ====================

  Future<void> addOeuvre(OeuvreModel oeuvre) async {
    await _oeuvresRef.add(oeuvre.toFirestore());
  }

  Future<void> updateOeuvre(String id, Map<String, dynamic> data) async {
    await _oeuvresRef.doc(id).update(data);
  }

  Future<void> deleteOeuvre(String id) async {
    await _oeuvresRef.doc(id).delete();
  }

  Future<void> toggleFeatured(String id, bool value) async {
    await _oeuvresRef.doc(id).update({'isFeatured': value});
  }
}