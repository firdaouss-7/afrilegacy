import 'dart:math';
import 'package:flutter/material.dart';
import 'package:afrilegacy/views/auth/login_screen.dart';
import 'package:afrilegacy/views/auth/register_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  AnimationController? _bgController;
  AnimationController? _logoController;
  AnimationController? _nameController;
  AnimationController? _subtitleController;
  AnimationController? _tagsController;
  AnimationController? _buttonsController;
  AnimationController? _ring1Controller;
  AnimationController? _ring2Controller;
  AnimationController? _ring3Controller;
  AnimationController? _pulseController;
  AnimationController? _shimmerController;
  AnimationController? _particlesController;
  AnimationController? _patternController;

  Animation<double>? _logoScale;
  Animation<double>? _logoOpacity;
  Animation<double>? _nameOpacity;
  Animation<double>? _nameLetterSpacing;
  Animation<double>? _subtitleOpacity;
  Animation<Offset>? _subtitleSlide;
  Animation<double>? _tagsOpacity;
  Animation<Offset>? _tagsSlide;
  Animation<double>? _btn1Opacity;
  Animation<Offset>? _btn1Slide;
  Animation<double>? _btn2Opacity;
  Animation<Offset>? _btn2Slide;
  Animation<double>? _pulse;
  Animation<double>? _shimmer;

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _ring1Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _ring2Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat(reverse: false);

    _ring3Controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    _particlesController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _patternController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..repeat();

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _nameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _subtitleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _tagsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _buttonsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _logoController!, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController!,
        curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _nameOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _nameController!, curve: Curves.easeIn));
    _nameLetterSpacing = Tween<double>(
      begin: 15.0,
      end: 4.0,
    ).animate(CurvedAnimation(parent: _nameController!, curve: Curves.easeOut));

    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _subtitleController!, curve: Curves.easeIn),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero).animate(
          CurvedAnimation(parent: _subtitleController!, curve: Curves.easeOut),
        );

    _tagsOpacity = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _tagsController!, curve: Curves.easeIn));
    _tagsSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _tagsController!, curve: Curves.easeOut));

    _btn1Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonsController!,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    _btn1Slide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _buttonsController!,
            curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
          ),
        );

    _btn2Opacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonsController!,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
    _btn2Slide = Tween<Offset>(begin: const Offset(0, 0.6), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _buttonsController!,
            curve: const Interval(0.3, 1.0, curve: Curves.easeOut),
          ),
        );

    _pulse = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController!, curve: Curves.easeInOut),
    );

    _shimmer = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(parent: _shimmerController!, curve: Curves.linear),
    );

    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    if (mounted) _logoController!.forward();
    await Future.delayed(const Duration(milliseconds: 600));
    if (mounted) _nameController!.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) _subtitleController!.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _tagsController!.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _buttonsController!.forward();
  }

  @override
  void dispose() {
    _bgController?.dispose();
    _ring1Controller?.dispose();
    _ring2Controller?.dispose();
    _ring3Controller?.dispose();
    _pulseController?.dispose();
    _shimmerController?.dispose();
    _particlesController?.dispose();
    _patternController?.dispose();
    _logoController?.dispose();
    _nameController?.dispose();
    _subtitleController?.dispose();
    _tagsController?.dispose();
    _buttonsController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: _bgController!,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.lerp(
                    const Color(0xFFF2EBE0),
                    const Color(0xFFFBF8F3),
                    _bgController!.value,
                  )!,
                  Color.lerp(
                    const Color(0xFFFBF8F3),
                    const Color(0xFFE4D9C8),
                    _bgController!.value,
                  )!,
                ],
              ),
            ),
            child: child,
          );
        },
        child: Stack(
          children: [
            // Motifs africains en arrière-plan
            AnimatedBuilder(
              animation: _patternController!,
              builder: (context, child) {
                return CustomPaint(
                  size: size,
                  painter: _WelcomePatternPainter(
                    progress: _patternController!.value,
                  ),
                );
              },
            ),

            // Particules autour du logo
            AnimatedBuilder(
              animation: _particlesController!,
              builder: (context, child) {
                return CustomPaint(
                  size: size,
                  painter: _LogoParticlesPainter(
                    progress: _particlesController!.value,
                    centerY: size.height * 0.28,
                  ),
                );
              },
            ),

            // Orbe bas gauche
            Positioned(
              bottom: -60,
              left: -60,
              child: AnimatedBuilder(
                animation: _pulseController!,
                builder: (context, child) {
                  return Opacity(
                    opacity: _pulse!.value * 0.6,
                    child: Container(
                      width: 220,
                      height: 220,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            const Color(0xFF8FAFC0).withOpacity(0.15),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            // Orbe bas droit
            Positioned(
              bottom: size.height * 0.1,
              right: -40,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      const Color(0xFFA8C4A2).withOpacity(0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const Spacer(flex: 1),

                    // === LOGO SECTION ===
                    AnimatedBuilder(
                      animation: _logoController!,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacity!.value,
                          child: Transform.scale(
                            scale: _logoScale!.value,
                            child: SizedBox(
                              width: 220,
                              height: 220,
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Ring 3 — grande rotation lente
                                  AnimatedBuilder(
                                    animation: _ring3Controller!,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle:
                                            _ring3Controller!.value *
                                            2 *
                                            pi *
                                            0.3,
                                        child: CustomPaint(
                                          size: const Size(210, 210),
                                          painter: _DashedRingPainter(
                                            color: const Color(
                                              0xFFB8A8CC,
                                            ).withOpacity(0.3),
                                            strokeWidth: 1,
                                            dashCount: 20,
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  // Ring 2 — rotation moyenne
                                  AnimatedBuilder(
                                    animation: _ring2Controller!,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle:
                                            -_ring2Controller!.value * 2 * pi,
                                        child: CustomPaint(
                                          size: const Size(180, 180),
                                          painter: _DashedRingPainter(
                                            color: const Color(
                                              0xFF8FAFC0,
                                            ).withOpacity(0.4),
                                            strokeWidth: 1.5,
                                            dashCount: 12,
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  // Ring 1 — rotation rapide Or
                                  AnimatedBuilder(
                                    animation: _ring1Controller!,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle: _ring1Controller!.value * 2 * pi,
                                        child: CustomPaint(
                                          size: const Size(155, 155),
                                          painter: _DashedRingPainter(
                                            color: const Color(
                                              0xFFC4A96A,
                                            ).withOpacity(0.6),
                                            strokeWidth: 2,
                                            dashCount: 8,
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  // Glow pulsant
                                  AnimatedBuilder(
                                    animation: _pulseController!,
                                    builder: (context, child) {
                                      return Transform.scale(
                                        scale: _pulse!.value,
                                        child: Container(
                                          width: 130,
                                          height: 130,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            gradient: RadialGradient(
                                              colors: [
                                                const Color(
                                                  0xFFC4A96A,
                                                ).withOpacity(0.2),
                                                const Color(
                                                  0xFFE8C87A,
                                                ).withOpacity(0.1),
                                                Colors.transparent,
                                              ],
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                color: const Color(0xFFC4A96A)
                                                    .withOpacity(
                                                      0.15 * _pulse!.value,
                                                    ),
                                                blurRadius: 30,
                                                spreadRadius: 5,
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),

                                  // Points décoratifs sur les rings
                                  AnimatedBuilder(
                                    animation: _ring1Controller!,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        size: const Size(155, 155),
                                        painter: _OrbitDotsPainter(
                                          progress: _ring1Controller!.value,
                                          color: const Color(0xFFC4A96A),
                                          radius: 77.5,
                                        ),
                                      );
                                    },
                                  ),

                                  AnimatedBuilder(
                                    animation: _ring2Controller!,
                                    builder: (context, child) {
                                      return CustomPaint(
                                        size: const Size(180, 180),
                                        painter: _OrbitDotsPainter(
                                          progress: -_ring2Controller!.value,
                                          color: const Color(0xFF8FAFC0),
                                          radius: 90,
                                        ),
                                      );
                                    },
                                  ),

                                  // Logo image
                                  ClipOval(
                                    child: Container(
                                      width: 118,
                                      height: 118,
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.transparent,
                                      ),
                                      child: Image.asset(
                                        'assets/images/logoremovebg.png',
                                        width: 118,
                                        height: 118,
                                        fit: BoxFit.contain,
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

                    const SizedBox(height: 20),

                    // === NOM APP avec shimmer ===
                    AnimatedBuilder(
                      animation: _nameController!,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _nameOpacity!.value,
                          child: AnimatedBuilder(
                            animation: _shimmerController!,
                            builder: (context, child) {
                              return ShaderMask(
                                shaderCallback: (bounds) {
                                  return LinearGradient(
                                    begin: Alignment(_shimmer!.value - 1, 0),
                                    end: Alignment(_shimmer!.value + 1, 0),
                                    colors: const [
                                      Color(0xFF3D2B1A),
                                      Color(0xFFC4A96A),
                                      Color(0xFFE8C87A),
                                      Color(0xFFC4A96A),
                                      Color(0xFF3D2B1A),
                                    ],
                                    stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                                  ).createShader(bounds);
                                },
                                child: Text(
                                  'AFRILEGACY',
                                  style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: Colors.white,
                                    letterSpacing: _nameLetterSpacing!.value,
                                  ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 6),

                    // Dots colorés
                    AnimatedBuilder(
                      animation: _nameController!,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _nameOpacity!.value,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildColorDot(const Color(0xFFC4A96A)),
                              _buildColorDot(const Color(0xFF8FAFC0)),
                              _buildColorDot(const Color(0xFFA8C4A2)),
                              _buildColorDot(const Color(0xFFD4A89A)),
                              _buildColorDot(const Color(0xFFB8A8CC)),
                              _buildColorDot(const Color(0xFFE8C87A)),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 18),

                    // === SOUS-TITRE ===
                    AnimatedBuilder(
                      animation: _subtitleController!,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _subtitleOpacity!.value,
                          child: SlideTransition(
                            position: _subtitleSlide!,
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(30),
                                    border: Border.all(
                                      color: const Color(
                                        0xFFC4A96A,
                                      ).withOpacity(0.3),
                                      width: 1,
                                    ),
                                    color: const Color(
                                      0xFFC4A96A,
                                    ).withOpacity(0.06),
                                  ),
                                  child: const Text(
                                    '🌍  Musée Virtuel Africain',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Color(0xFF8C7A68),
                                      letterSpacing: 1.5,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                const Text(
                                  'Explorez des siècles d\'histoire,\nd\'art et de culture africaine',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Color(0xFF8C7A68),
                                    height: 1.6,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // === TAGS ===
                    AnimatedBuilder(
                      animation: _tagsController!,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _tagsOpacity!.value,
                          child: SlideTransition(
                            position: _tagsSlide!,
                            child: Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              alignment: WrapAlignment.center,
                              children: [
                                _buildTag('🎨 Art', const Color(0xFFD4A89A)),
                                _buildTag(
                                  '🏛️ Histoire',
                                  const Color(0xFF8FAFC0),
                                ),
                                _buildTag(
                                  '🌿 Culture',
                                  const Color(0xFFA8C4A2),
                                ),
                                _buildTag('✨ AR & 3D', const Color(0xFFB8A8CC)),
                                _buildTag('🎵 Audio', const Color(0xFFE8C87A)),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const Spacer(flex: 2),

                    // === BOUTON SE CONNECTER ===
                    AnimatedBuilder(
                      animation: _buttonsController!,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _btn1Opacity!.value,
                          child: SlideTransition(
                            position: _btn1Slide!,
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF3D2B1A),
                                    Color(0xFF5C3D2E),
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF3D2B1A,
                                    ).withOpacity(0.4),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          const LoginScreen(),
                                      transitionsBuilder:
                                          (_, animation, __, child) {
                                            return SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(1, 0),
                                                end: Offset.zero,
                                              ).animate(animation),
                                              child: child,
                                            );
                                          },
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Se connecter',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFFD9C9B2),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFC4A96A,
                                        ).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.arrow_forward_ios,
                                        color: Color(0xFFC4A96A),
                                        size: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // === BOUTON S'INSCRIRE ===
                    AnimatedBuilder(
                      animation: _buttonsController!,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _btn2Opacity!.value,
                          child: SlideTransition(
                            position: _btn2Slide!,
                            child: Container(
                              width: double.infinity,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: const Color(
                                    0xFFC4A96A,
                                  ).withOpacity(0.4),
                                  width: 1.5,
                                ),
                                gradient: LinearGradient(
                                  colors: [
                                    const Color(0xFFC4A96A).withOpacity(0.06),
                                    const Color(0xFF8FAFC0).withOpacity(0.04),
                                  ],
                                ),
                              ),
                              child: OutlinedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    PageRouteBuilder(
                                      pageBuilder: (_, __, ___) =>
                                          const RegisterScreen(),
                                      transitionsBuilder:
                                          (_, animation, __, child) {
                                            return SlideTransition(
                                              position: Tween<Offset>(
                                                begin: const Offset(1, 0),
                                                end: Offset.zero,
                                              ).animate(animation),
                                              child: child,
                                            );
                                          },
                                    ),
                                  );
                                },
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF3D2B1A),
                                  side: BorderSide.none,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'Créer un compte',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF3D2B1A),
                                        letterSpacing: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFA8C4A2,
                                        ).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Icon(
                                        Icons.person_add_outlined,
                                        color: Color(0xFFA8C4A2),
                                        size: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Stats
                    AnimatedBuilder(
                      animation: _buttonsController!,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _btn2Opacity!.value,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 14,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: const Color(0xFFC4A96A).withOpacity(0.06),
                              border: Border.all(
                                color: const Color(0xFFD9C9B2).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _buildStat('54', 'Pays'),
                                _buildDivider(),
                                _buildStat('500+', 'Œuvres'),
                                _buildDivider(),
                                _buildStat('AR', '3D Live'),
                                _buildDivider(),
                                _buildStat('🎵', 'Audio'),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorDot(Color color) {
    return AnimatedBuilder(
      animation: _pulseController!,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: 6,
          height: 6,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.6 + _pulse!.value * 0.4),
          ),
        );
      },
    );
  }

  Widget _buildTag(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: color.withOpacity(0.9),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStat(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w800,
            color: Color(0xFF3D2B1A),
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            color: Color(0xFF8C7A68),
            letterSpacing: 0.5,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 30,
      color: const Color(0xFFD9C9B2).withOpacity(0.4),
    );
  }
}

// ==================== PAINTERS ====================

class _DashedRingPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final int dashCount;

  _DashedRingPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final dashAngle = (2 * pi) / (dashCount * 2);

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle * 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        dashAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OrbitDotsPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double radius;

  _OrbitDotsPainter({
    required this.progress,
    required this.color,
    required this.radius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final center = Offset(size.width / 2, size.height / 2);

    // 3 points en orbite
    for (int i = 0; i < 3; i++) {
      final angle = progress * 2 * pi + (i * 2 * pi / 3);
      final x = center.dx + radius * cos(angle);
      final y = center.dy + radius * sin(angle);
      canvas.drawCircle(Offset(x, y), 4, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _LogoParticlesPainter extends CustomPainter {
  final double progress;
  final double centerY;

  _LogoParticlesPainter({required this.progress, required this.centerY});

  @override
  void paint(Canvas canvas, Size size) {
    final random = Random(99);
    final colors = [
      const Color(0xFFC4A96A),
      const Color(0xFF8FAFC0),
      const Color(0xFFA8C4A2),
      const Color(0xFFD4A89A),
      const Color(0xFFB8A8CC),
    ];

    for (int i = 0; i < 15; i++) {
      final angle = random.nextDouble() * 2 * pi;
      final baseRadius = 90 + random.nextDouble() * 50;
      final orbitSpeed = 0.3 + random.nextDouble() * 0.7;
      final currentAngle = angle + progress * 2 * pi * orbitSpeed;

      final x = size.width / 2 + baseRadius * cos(currentAngle);
      final y = centerY + baseRadius * sin(currentAngle) * 0.4;

      final paint = Paint()
        ..color = colors[i % colors.length].withOpacity(
          0.15 + random.nextDouble() * 0.3,
        )
        ..style = PaintingStyle.fill;

      canvas.drawCircle(Offset(x, y), 2 + random.nextDouble() * 2, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class _WelcomePatternPainter extends CustomPainter {
  final double progress;

  _WelcomePatternPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    paint.color = const Color(
      0xFFC4A96A,
    ).withOpacity(0.05 + sin(progress * 2 * pi) * 0.02);
    for (int i = 0; i < 6; i++) {
      final path = Path();
      final x = size.width * 0.88;
      final y = size.height * 0.08 + i * 28.0;
      path.moveTo(x, y);
      path.lineTo(x + 18, y + 18);
      path.lineTo(x - 18, y + 18);
      path.close();
      canvas.drawPath(path, paint);
    }

    paint.color = const Color(
      0xFF8FAFC0,
    ).withOpacity(0.05 + cos(progress * 2 * pi) * 0.02);
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final x = size.width * 0.08;
      final y = size.height * 0.65 + i * 32.0;
      path.moveTo(x, y - 14);
      path.lineTo(x + 14, y);
      path.lineTo(x, y + 14);
      path.lineTo(x - 14, y);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
