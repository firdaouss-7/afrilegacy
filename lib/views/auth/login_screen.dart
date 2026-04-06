import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afrilegacy/services/auth_service.dart';
import 'package:afrilegacy/views/home/home_screen.dart';
import 'package:afrilegacy/views/admin/admin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _errorMessage;

  AnimationController? _formController;
  Animation<double>? _formOpacity;
  Animation<Offset>? _formSlide;

  @override
  void initState() {
    super.initState();
    _formController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _formOpacity = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(parent: _formController!, curve: Curves.easeIn));
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _formController!, curve: Curves.easeOut));
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _formController!.forward();
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _formController?.dispose();
    super.dispose();
  }

  Future<void> _redirectAfterLogin() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
    final role = doc.data()?['role'] ?? 'user';
    if (!mounted) return;
    if (role == 'admin') {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const AdminScreen()));
    } else {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const HomeScreen()));
    }
  }

  Future<void> _signIn() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      setState(() => _errorMessage = 'Veuillez remplir tous les champs.');
      return;
    }
    setState(() { _isLoading = true; _errorMessage = null; });

    try {
      final result = await _authService.signInWithEmail(
        email: _emailController.text,
        password: _passwordController.text,
      );

      final uid = result?.user?.uid;
      if (uid == null) return;

      Map<String, dynamic>? userData;
      String role = 'user';

      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get()
            .timeout(const Duration(seconds: 5));

        userData = doc.data();
        role = userData?['role'] ?? 'user';
      } catch (e) {
        await _authService.signOut();
        setState(() => _errorMessage = 'Erreur réseau. Vérifiez votre connexion.');
        return;
      }

      // ✅ Vérification isActive
      final isActive = userData?['isActive'] ?? true;
      if (isActive == false) {
        await _authService.signOut();
        setState(() => _errorMessage =
            'Votre compte a été désactivé. Contactez l\'administrateur.');
        return;
      }

      if (role == 'admin') {
        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const AdminScreen()));
        }
        return;
      }

      // User normal → vérification email
      if (result?.user?.emailVerified == false) {
        setState(() => _errorMessage =
            'Veuillez vérifier votre email avant de vous connecter.');
        await _authService.signOut();
        return;
      }

      if (mounted) {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (_) => const HomeScreen()));
      }
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() { _isGoogleLoading = true; _errorMessage = null; });
    try {
      final result = await _authService.signInWithGoogle();
      if (result == null) return;

      final uid = result.user?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      final isActive = doc.data()?['isActive'] ?? true;

      if (isActive == false) {
        await _authService.signOut();
        if (mounted) {
          setState(() => _errorMessage =
              'Votre compte a été désactivé. Contactez l\'administrateur.');
        }
        return;
      }

      if (mounted) await _redirectAfterLogin();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      if (mounted) setState(() => _isGoogleLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFBF8F3),
      body: Stack(
        children: [
          Positioned(
            top: -60, right: -60,
            child: Container(
              width: 200, height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFFC4A96A).withOpacity(0.12),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          Positioned(
            bottom: -40, left: -40,
            child: Container(
              width: 160, height: 160,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  const Color(0xFF8FAFC0).withOpacity(0.1),
                  Colors.transparent,
                ]),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    children: [
                      IconButton(
                        icon: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF2EBE0),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.arrow_back_ios_new,
                              color: Color(0xFF3D2B1A), size: 18),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: AnimatedBuilder(
                      animation: _formController!,
                      builder: (context, child) => Opacity(
                        opacity: _formOpacity!.value,
                        child: SlideTransition(position: _formSlide!, child: child),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          ShaderMask(
                            shaderCallback: (bounds) => const LinearGradient(
                              colors: [Color(0xFF3D2B1A), Color(0xFFC4A96A)],
                            ).createShader(bounds),
                            child: const Text('Connexion',
                              style: TextStyle(fontSize: 34,
                                  fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                          const SizedBox(height: 8),
                          const Text('Bienvenue ! Explorez le patrimoine africain.',
                            style: TextStyle(color: Color(0xFF8C7A68), fontSize: 14)),
                          const SizedBox(height: 32),

                          // ── Message d'erreur ──
                          if (_errorMessage != null)
                            Container(
                              padding: const EdgeInsets.all(12),
                              margin: const EdgeInsets.only(bottom: 16),
                              decoration: BoxDecoration(
                                color: const Color(0xFFD4A89A).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFD4A89A)),
                              ),
                              child: Row(children: [
                                const Icon(Icons.error_outline,
                                    color: Color(0xFFD4A89A), size: 18),
                                const SizedBox(width: 8),
                                Expanded(child: Text(_errorMessage!,
                                  style: const TextStyle(
                                      color: Color(0xFF8C3A2A), fontSize: 13))),
                              ]),
                            ),

                          // ── Email ──
                          const Text('Adresse email',
                            style: TextStyle(color: Color(0xFF3D2B1A),
                                fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(color: Color(0xFF3D2B1A)),
                            decoration: InputDecoration(
                              hintText: 'exemple@email.com',
                              hintStyle: TextStyle(
                                  color: const Color(0xFF8C7A68).withOpacity(0.6)),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFC4A96A).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.email_outlined,
                                    color: Color(0xFFC4A96A), size: 18),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF2EBE0),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                    color: Color(0xFFC4A96A), width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 16),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Mot de passe ──
                          const Text('Mot de passe',
                            style: TextStyle(color: Color(0xFF3D2B1A),
                                fontSize: 13, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 8),
                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(color: Color(0xFF3D2B1A)),
                            decoration: InputDecoration(
                              hintText: '••••••••',
                              hintStyle: TextStyle(
                                  color: const Color(0xFF8C7A68).withOpacity(0.6)),
                              prefixIcon: Container(
                                margin: const EdgeInsets.all(12),
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF8FAFC0).withOpacity(0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.lock_outline,
                                    color: Color(0xFF8FAFC0), size: 18),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF8C7A68), size: 20,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                              filled: true,
                              fillColor: const Color(0xFFF2EBE0),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16),
                                  borderSide: BorderSide.none),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: const BorderSide(
                                    color: Color(0xFF8FAFC0), width: 2),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 18, horizontal: 16),
                            ),
                          ),

                          // ── Mot de passe oublié ──
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () async {
                                if (_emailController.text.isNotEmpty) {
                                  try {
                                    await _authService.resetPassword(
                                        _emailController.text);
                                    if (mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Email de réinitialisation envoyé !'),
                                          backgroundColor: Color(0xFFC4A96A),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setState(() => _errorMessage = e.toString());
                                  }
                                } else {
                                  setState(() => _errorMessage =
                                      'Entrez votre email d\'abord.');
                                }
                              },
                              child: const Text('Mot de passe oublié ?',
                                style: TextStyle(color: Color(0xFF8FAFC0),
                                    fontSize: 13, fontWeight: FontWeight.w500)),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // ── Bouton connexion ──
                          Container(
                            width: double.infinity, height: 58,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              gradient: const LinearGradient(
                                  colors: [Color(0xFF3D2B1A), Color(0xFF5C3D2E)]),
                              boxShadow: [BoxShadow(
                                color: const Color(0xFF3D2B1A).withOpacity(0.3),
                                blurRadius: 20, offset: const Offset(0, 8))],
                            ),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                              ),
                              child: _isLoading
                                  ? const SizedBox(width: 24, height: 24,
                                      child: CircularProgressIndicator(
                                          color: Color(0xFFD9C9B2), strokeWidth: 2))
                                  : const Text('Se connecter',
                                      style: TextStyle(fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFFD9C9B2),
                                          letterSpacing: 1)),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // ── Séparateur ──
                          Row(children: [
                            Expanded(child: Container(height: 1,
                                color: const Color(0xFFD9C9B2).withOpacity(0.5))),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Text('ou continuer avec',
                                  style: TextStyle(
                                      color: Color(0xFF8C7A68), fontSize: 12)),
                            ),
                            Expanded(child: Container(height: 1,
                                color: const Color(0xFFD9C9B2).withOpacity(0.5))),
                          ]),

                          const SizedBox(height: 20),

                          // ── Bouton Google ──
                          Container(
                            width: double.infinity, height: 58,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                  color: const Color(0xFFD9C9B2), width: 1.5),
                              color: Colors.white,
                            ),
                            child: ElevatedButton(
                              onPressed: _isGoogleLoading ? null : _signInWithGoogle,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18)),
                              ),
                              child: _isGoogleLoading
                                  ? const SizedBox(width: 24, height: 24,
                                      child: CircularProgressIndicator(strokeWidth: 2))
                                  : Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Image.network(
                                            'https://www.google.com/favicon.ico',
                                            width: 22, height: 22),
                                        const SizedBox(width: 12),
                                        const Text('Continuer avec Google',
                                          style: TextStyle(fontSize: 15,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF3D2B1A))),
                                      ],
                                    ),
                            ),
                          ),

                          const SizedBox(height: 24),

                          Center(
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: RichText(
                                text: const TextSpan(
                                  text: 'Pas encore de compte ? ',
                                  style: TextStyle(
                                      color: Color(0xFF8C7A68), fontSize: 14),
                                  children: [
                                    TextSpan(text: 'S\'inscrire',
                                      style: TextStyle(color: Color(0xFFC4A96A),
                                          fontWeight: FontWeight.w700)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}