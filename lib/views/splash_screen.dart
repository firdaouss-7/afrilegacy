import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afrilegacy/views/auth/welcome_screen.dart';
import 'package:afrilegacy/views/home/home_screen.dart';
import 'package:afrilegacy/views/admin/admin_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Controllers
  late AnimationController _logoController;
  late AnimationController _glowController;
  late AnimationController _particlesController;
  late AnimationController _quoteController;
  late AnimationController _progressController;
  late AnimationController _patternController;

  // Logo animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoRotate;

  // Glow
  late Animation<double> _glowSize;

  // Quote
  late Animation<double> _quoteOpacity;
  late Animation<Offset> _quoteSlide;

  // Progress
  late Animation<double> _progress;

  int _currentQuote = 0;
  bool _showQuote = false;

  final List<Map<String, String>> _quotes = [
    {
      'text':
          '"L\'Afrique est le berceau de l\'humanité\net de toutes les civilisations"',
      'author': '— Cheikh Anta Diop',
    },
    {
      'text': '"Un peuple sans mémoire\nest un peuple sans avenir"',
      'author': '— Aimé Césaire',
    },
    {
      'text':
          '"En Afrique, quand un vieillard meurt, c\'est une bibliothèque qui brûle."',
      'author': '— Ahmadou Hampâté Bâ',
    },
    {
      'text':
          '"Un musée virtuel pour préserver la mémoire,\nconnecter les cultures et transmettre l’héritage africain au monde."',
      'author': '— AfriLegacy',
    },
  ];

  @override
  void initState() {
    super.initState();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _quoteController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _patternController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    // Logo
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );
    _logoRotate = Tween<double>(begin: -0.1, end: 0.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    // Glow
    _glowSize = Tween<double>(begin: 200, end: 280).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    // Quote
    _quoteOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _quoteController, curve: Curves.easeIn));
    _quoteSlide = Tween<Offset>(
      begin: const Offset(0, 0.4),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _quoteController, curve: Curves.easeOut));

    // Progress
    _progress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _progressController, curve: Curves.linear),
    );

    _startSequence();
  }

  void _startSequence() async {
    // Logo entre
    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;
    _logoController.forward();
    _progressController.forward();

    // Première citation
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() {
      _showQuote = true;
      _currentQuote = 0;
    });
    _quoteController.forward();

    // Changer les citations toutes les 5 secondes
    for (int i = 1; i < _quotes.length; i++) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      await _quoteController.reverse();
      setState(() => _currentQuote = i);
      _quoteController.forward();
    }

    // Attendre la fin
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    // ✅ VÉRIFICATION DU RÔLE ADMIN
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      // Non connecté → WelcomeScreen
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const WelcomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 1200),
        ),
      );
      return;
    }

    // Connecté → vérifier le rôle dans Firestore (avec retry)
    String role = 'user';
    for (int attempt = 0; attempt < 3; attempt++) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        role = userDoc.data()?['role'] ?? 'user';
        print('👤 Rôle trouvé: $role');
        print('📧 Email: ${user.email}');
        print('🆔 UID: ${user.uid}');
        break;
      } catch (e) {
        print('⚠️ Firestore attempt ${attempt + 1} failed: $e');
        if (attempt < 2) {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    }

    if (role == 'admin') {
      print('✅ REDIRECTION VERS ADMIN DASHBOARD');
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const AdminScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 1200),
        ),
      );
    } else {
      print('❌ REDIRECTION VERS HOME SCREEN (role = $role)');
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (_, __, ___) => const HomeScreen(),
          transitionsBuilder: (_, animation, __, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 1200),
        ),
      );
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _glowController.dispose();
    _particlesController.dispose();
    _quoteController.dispose();
    _progressController.dispose();
    _patternController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF1A1008),
              Color(0xFF3D2B1A),
              Color(0xFF2A1F0E),
              Color(0xFF1A1008),
            ],
            stops: [0.0, 0.3, 0.7, 1.0],
          ),
        ),
        child: Stack(
          children: [
            // Motifs africains en arrière-plan
            AnimatedBuilder(
              animation: _patternController,
              builder: (context, child) {
                return CustomPaint(
                  size: size,
                  painter: _AfricanPatternPainter(
                    progress: _patternController.value,
                  ),
                );
              },
            ),

            // Particules flottantes
            AnimatedBuilder(
              animation: _particlesController,
              builder: (context, child) {
                return CustomPaint(
                  size: size,
                  painter: _ParticlesPainter(
                    progress: _particlesController.value,
                  ),
                );
              },
            ),

            // Cercles colorés décoratifs
            Positioned(
              top: size.height * 0.1,
              left: -40,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFA8C4A2).withOpacity(0.08),
                  border: Border.all(
                    color: const Color(0xFFA8C4A2).withOpacity(0.15),
                    width: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              top: size.height * 0.05,
              right: -30,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFB8A8CC).withOpacity(0.08),
                  border: Border.all(
                    color: const Color(0xFFB8A8CC).withOpacity(0.15),
                    width: 1,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: size.height * 0.15,
              right: -20,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8FAFC0).withOpacity(0.08),
                  border: Border.all(
                    color: const Color(0xFF8FAFC0).withOpacity(0.15),
                    width: 1,
                  ),
                ),
              ),
            ),

            // Contenu principal
            SafeArea(
              child: Column(
                children: [
                  const Spacer(flex: 2),

                  // Logo avec glow animé
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _logoController,
                      _glowController,
                    ]),
                    builder: (context, child) {
                      return Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Transform.rotate(
                            angle: _logoRotate.value,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                // Glow externe Or
                                Container(
                                  width: _glowSize.value + 40,
                                  height: _glowSize.value + 40,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(
                                          0xFFC4A96A,
                                        ).withOpacity(0.15),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                // Glow interne
                                Container(
                                  width: _glowSize.value,
                                  height: _glowSize.value,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: RadialGradient(
                                      colors: [
                                        const Color(
                                          0xFFC4A96A,
                                        ).withOpacity(0.25),
                                        const Color(
                                          0xFFE8C87A,
                                        ).withOpacity(0.1),
                                        Colors.transparent,
                                      ],
                                    ),
                                  ),
                                ),
                                // Logo
                                Image.asset(
                                  'assets/images/logoremovebg.png',
                                  width: 200,
                                  height: 200,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const Spacer(),

                  // Citation animée
                  if (_showQuote)
                    AnimatedBuilder(
                      animation: _quoteController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _quoteOpacity.value,
                          child: SlideTransition(
                            position: _quoteSlide,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 36,
                              ),
                              child: Column(
                                children: [
                                  // Ligne décorative haut
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Colors.transparent,
                                                Color(0xFFC4A96A),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const Padding(
                                        padding: EdgeInsets.symmetric(
                                          horizontal: 12,
                                        ),
                                        child: Icon(
                                          Icons.auto_awesome,
                                          color: Color(0xFFC4A96A),
                                          size: 18,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 1,
                                          decoration: const BoxDecoration(
                                            gradient: LinearGradient(
                                              colors: [
                                                Color(0xFFC4A96A),
                                                Colors.transparent,
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    _quotes[_currentQuote]['text']!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFD9C9B2),
                                      fontSize: 16,
                                      fontStyle: FontStyle.italic,
                                      height: 1.7,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  Text(
                                    _quotes[_currentQuote]['author']!,
                                    style: const TextStyle(
                                      color: Color(0xFFC4A96A),
                                      fontSize: 13,
                                      letterSpacing: 1,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Indicateurs de citation
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: List.generate(
                                      _quotes.length,
                                      (i) => AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 3,
                                        ),
                                        width: i == _currentQuote ? 20 : 6,
                                        height: 6,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                            3,
                                          ),
                                          color: i == _currentQuote
                                              ? const Color(0xFFC4A96A)
                                              : const Color(
                                                  0xFFD9C9B2,
                                                ).withOpacity(0.3),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                  const Spacer(flex: 2),

                  // Barre de progression
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 48),
                    child: Column(
                      children: [
                        AnimatedBuilder(
                          animation: _progress,
                          builder: (context, child) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: _progress.value,
                                backgroundColor: const Color(
                                  0xFFD9C9B2,
                                ).withOpacity(0.15),
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                  Color(0xFFC4A96A),
                                ),
                                minHeight: 3,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Chargement du patrimoine africain...',
                          style: TextStyle(
                            color: Color(0xFF8C7A68),
                            fontSize: 11,
                            letterSpacing: 1,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Painter pour les motifs africains
class _AfricanPatternPainter extends CustomPainter {
  final double progress;
  _AfricanPatternPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    _drawTrianglePattern(canvas, size, paint);
    _drawDiamondPattern(canvas, size, paint);
  }

  void _drawTrianglePattern(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(
      0xFFC4A96A,
    ).withOpacity(0.06 + sin(progress * 2 * pi) * 0.03);

    for (int i = 0; i < 5; i++) {
      final path = Path();
      final x = size.width * 0.85;
      final y = size.height * 0.1 + i * 30.0;
      path.moveTo(x, y);
      path.lineTo(x + 20, y + 20);
      path.lineTo(x - 20, y + 20);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  void _drawDiamondPattern(Canvas canvas, Size size, Paint paint) {
    paint.color = const Color(
      0xFF8FAFC0,
    ).withOpacity(0.06 + cos(progress * 2 * pi) * 0.03);

    for (int i = 0; i < 4; i++) {
      final path = Path();
      final x = size.width * 0.1;
      final y = size.height * 0.7 + i * 35.0;
      path.moveTo(x, y - 12);
      path.lineTo(x + 12, y);
      path.lineTo(x, y + 12);
      path.lineTo(x - 12, y);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Painter pour les particules
class _ParticlesPainter extends CustomPainter {
  final double progress;
  _ParticlesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    // Guard against zero size (causes NaN)
    if (size.width <= 0 || size.height <= 0) return;
    final random = Random(42);
    final colors = [
      const Color(0xFFC4A96A),
      const Color(0xFF8FAFC0),
      const Color(0xFFA8C4A2),
      const Color(0xFFD4A89A),
      const Color(0xFFB8A8CC),
      const Color(0xFFE8C87A),
    ];

    for (int i = 0; i < 30; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = random.nextDouble() * size.height;
      final speed = 0.3 + random.nextDouble() * 0.7;
      final offset = (progress * speed) % 1.0;

      final x = startX;
      final y =
          (startY - offset * size.height * 1.2 + size.height) % size.height;

      final paint = Paint()
        ..color = colors[i % colors.length].withOpacity(
          0.1 + random.nextDouble() * 0.25,
        )
        ..style = PaintingStyle.fill;

      final radius = 1.5 + random.nextDouble() * 3;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}