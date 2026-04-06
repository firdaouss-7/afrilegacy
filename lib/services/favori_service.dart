import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afrilegacy/models/oeuvre_model.dart';

/// Structure Firestore :
/// favoris/{userId}/oeuvres/{oeuvreId}  →  { oeuvreId, addedAt }
class FavoriService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference _ref(String userId) => _db
      .collection('favoris')
      .doc(userId)
      .collection('oeuvres');

  // ── Ajouter ──────────────────────────────────────
  Future<void> addFavori(String userId, String oeuvreId) async {
    await _ref(userId).doc(oeuvreId).set({
      'oeuvreId': oeuvreId,
      'addedAt': FieldValue.serverTimestamp(),
    });
  }

  // ── Retirer ──────────────────────────────────────
  Future<void> removeFavori(String userId, String oeuvreId) async {
    await _ref(userId).doc(oeuvreId).delete();
  }

  // ── Toggle ───────────────────────────────────────
  Future<bool> toggleFavori(String userId, String oeuvreId) async {
    final doc = await _ref(userId).doc(oeuvreId).get();
    if (doc.exists) {
      await removeFavori(userId, oeuvreId);
      return false; // n'est plus favori
    } else {
      await addFavori(userId, oeuvreId);
      return true; // est devenu favori
    }
  }

  // ── Est-ce un favori ? (one-shot) ────────────────
  Future<bool> isFavori(String userId, String oeuvreId) async {
    final doc = await _ref(userId).doc(oeuvreId).get();
    return doc.exists;
  }

  // ── Stream : est-ce un favori ? (temps réel) ─────
  Stream<bool> isFavoriStream(String userId, String oeuvreId) {
    return _ref(userId)
        .doc(oeuvreId)
        .snapshots()
        .map((doc) => doc.exists);
  }

  // ── Stream : IDs favoris de l'utilisateur ────────
  Stream<List<String>> getFavoriIdsStream(String userId) {
    return _ref(userId)
        .orderBy('addedAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => d.id).toList());
  }

  // ── Récupérer les œuvres favorites complètes ─────
  Future<List<OeuvreModel>> getFavorisOeuvres(String userId) async {
    final snap = await _ref(userId)
        .orderBy('addedAt', descending: true)
        .get();

    if (snap.docs.isEmpty) return [];

    final ids = snap.docs.map((d) => d.id).toList();

    // Firestore whereIn max 30 éléments — on chunk si besoin
    final List<OeuvreModel> result = [];
    for (int i = 0; i < ids.length; i += 30) {
      final chunk = ids.sublist(i, (i + 30).clamp(0, ids.length));
      final oeuvresSnap = await _db
          .collection('oeuvres')
          .where(FieldPath.documentId, whereIn: chunk)
          .get();
      result.addAll(
          oeuvresSnap.docs.map(OeuvreModel.fromFirestore));
    }

    // Réordonner selon l'ordre d'ajout (le whereIn ne garantit pas l'ordre)
    final orderMap = {for (int i = 0; i < ids.length; i++) ids[i]: i};
    result.sort((a, b) =>
        (orderMap[a.id] ?? 999).compareTo(orderMap[b.id] ?? 999));

    return result;
  }

  // ── Stream : œuvres favorites complètes ──────────
  Stream<List<OeuvreModel>> getFavorisStream(String userId) {
    return getFavoriIdsStream(userId).asyncMap(
      (ids) async {
        if (ids.isEmpty) return <OeuvreModel>[];
        final List<OeuvreModel> result = [];
        for (int i = 0; i < ids.length; i += 30) {
          final chunk = ids.sublist(i, (i + 30).clamp(0, ids.length));
          final snap = await _db
              .collection('oeuvres')
              .where(FieldPath.documentId, whereIn: chunk)
              .get();
          result.addAll(snap.docs.map(OeuvreModel.fromFirestore));
        }
        final orderMap = {for (int i = 0; i < ids.length; i++) ids[i]: i};
        result.sort((a, b) =>
            (orderMap[a.id] ?? 999).compareTo(orderMap[b.id] ?? 999));
        return result;
      },
    );
  }
}