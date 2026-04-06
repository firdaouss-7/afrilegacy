import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afrilegacy/models/user_model.dart';

class UserService {
  final CollectionReference _users = FirebaseFirestore.instance.collection(
    'users',
  );

  Future<UserModel?> getUser(String uid) async {
    final doc = await _users.doc(uid).get();
    if (doc.exists) return UserModel.fromFirestore(doc);
    return null;
  }

  Stream<UserModel?> getUserStream(String uid) {
    return _users.doc(uid).snapshots().map((doc) {
      if (doc.exists) return UserModel.fromFirestore(doc);
      return null;
    });
  }

  // ✅ NOUVEAU — pour la liste admin
  Stream<List<UserModel>> getUsersStream() {
    return _users.snapshots().map(
      (snap) => snap.docs.map((doc) => UserModel.fromFirestore(doc)).toList(),
    );
  }

  Future<void> updateUser(String uid, Map<String, dynamic> data) async {
    await _users.doc(uid).update(data);
  }

  Future<bool> isAdmin(String uid) async {
    final user = await getUser(uid);
    return user?.isAdmin ?? false;
  }
}
