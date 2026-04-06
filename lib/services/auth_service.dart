import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<User?> get authStateChanges => _auth.authStateChanges();
  User? get currentUser => _auth.currentUser;

  // ==================== EMAIL / MOT DE PASSE ====================

  Future<UserCredential?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<UserCredential?> registerWithEmail({
    required String email,
    required String password,
    required String nom,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await credential.user?.updateDisplayName(nom);
      await credential.user?.sendEmailVerification();

      // ✅ Créer le document Firestore automatiquement
      await _createUserDocument(
        uid: credential.user!.uid,
        nom: nom,
        email: email.trim(),
        photoUrl: null,
      );

      return credential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ==================== GOOGLE ====================

  Future<UserCredential?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // ✅ Créer le document seulement si c'est la première connexion
      final isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      if (isNewUser) {
        await _createUserDocument(
          uid: userCredential.user!.uid,
          nom: userCredential.user?.displayName ?? 'Utilisateur',
          email: userCredential.user?.email ?? '',
          photoUrl: userCredential.user?.photoURL,
        );
      }

      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    } catch (e) {
      throw 'Erreur Google Sign-In : $e';
    }
  }

  // ==================== CRÉER DOCUMENT USER ====================

  Future<void> _createUserDocument({
    required String uid,
    required String nom,
    required String email,
    String? photoUrl,
  }) async {
    await _firestore.collection('users').doc(uid).set({
      'uid': uid,
      'nom': nom,
      'email': email,
      'role': 'user', // par défaut → user
      'photoUrl': photoUrl ?? '',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ==================== DÉCONNEXION ====================

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  // ==================== MOT DE PASSE OUBLIÉ ====================

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // ==================== GESTION ERREURS ====================

  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Aucun compte trouvé avec cet email.';
      case 'wrong-password':
        return 'Mot de passe incorrect.';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé.';
      case 'invalid-email':
        return 'Email invalide.';
      case 'weak-password':
        return 'Mot de passe trop faible (6 caractères minimum).';
      case 'user-disabled':
        return 'Ce compte a été désactivé.';
      case 'too-many-requests':
        return 'Trop de tentatives. Réessayez plus tard.';
      case 'network-request-failed':
        return 'Erreur réseau. Vérifiez votre connexion.';
      default:
        return 'Une erreur est survenue. Réessayez.';
    }
  }
}
