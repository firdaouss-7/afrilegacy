import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afrilegacy/views/admin/afri_theme.dart';
import 'package:afrilegacy/services/auth_service.dart';
import 'package:afrilegacy/views/auth/login_screen.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});
  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with TickerProviderStateMixin {
  // ── Animation controllers ──────────────────────────
  late AnimationController _patternCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _particlesCtrl;
  late AnimationController _heroCtrl;
  late AnimationController _cardsCtrl;
  late AnimationController _bodyCtrl;

  // ── Hero animations ────────────────────────────────
  late Animation<double> _heroOpacity;
  late Animation<Offset> _heroSlide;
  late Animation<double> _glowSize;

  // ── Data ───────────────────────────────────────────
  // Collections Firestore existantes : 'oeuvres', 'users'
  // 'collections' est supprimée car absente de Firestore
  int _oeuvres = 0, _users = 0, _model3d = 0, _stolen = 0;
  bool _loading = true;
  final List<Map<String, dynamic>> _recent = [];
  final _auth = AuthService();

  @override
  void initState() {
    super.initState();

    _patternCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _particlesCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    )..repeat();

    _heroCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _cardsCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _bodyCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _heroOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _heroCtrl,
        curve: const Interval(0, 0.6, curve: Curves.easeIn),
      ),
    );
    _heroSlide = Tween<Offset>(
      begin: const Offset(0, -0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _heroCtrl, curve: Curves.easeOut));

    _glowSize = Tween<double>(
      begin: 220,
      end: 320,
    ).animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _load();
  }

  Future<void> _load() async {
    try {
      final o = await FirebaseFirestore.instance.collection('oeuvres').get();
      final u = await FirebaseFirestore.instance.collection('users').get();

      // Compte les œuvres avec un model3dUrl non vide
      final model3dCount = o.docs
          .where((d) => (d.data()['model3dUrl'] ?? '').toString().isNotEmpty)
          .length;

      // Compte les œuvres volées (statut == 'volé')
      final stolenCount = o.docs
          .where((d) => d.data()['statut'] == 'volé')
          .length;

      final sorted = [...o.docs]
        ..sort((a, b) {
          final aT =
              (a.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
          final bT =
              (b.data()['createdAt'] as Timestamp?)?.toDate() ?? DateTime(2000);
          return bT.compareTo(aT);
        });

      if (!mounted) return;
      setState(() {
        _oeuvres = o.size;
        _users = u.size;
        _model3d = model3dCount;
        _stolen = stolenCount;
        _loading = false;

        for (final d in sorted.take(3)) {
          final m = d.data();
          _recent.add({
            'titre': m['titre'] ?? 'Sans titre',
            'artiste': m['artiste'] ?? '',
            'categorie': m['categorie'] ?? '',
            'annee': m['annee'] ?? '',
            'has3D': (m['model3dUrl'] ?? '').toString().isNotEmpty,
            'imageUrl': m['imageUrl'] ?? '',
            'statut': m['statut'] ?? 'normal',
          });
        }
      });

      _heroCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      _cardsCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 150));
      _bodyCtrl.forward();
    } catch (_) {
      if (mounted) {
        setState(() => _loading = false);
        _heroCtrl.forward();
        _cardsCtrl.forward();
        _bodyCtrl.forward();
      }
    }
  }

  @override
  void dispose() {
    _patternCtrl.dispose();
    _glowCtrl.dispose();
    _particlesCtrl.dispose();
    _heroCtrl.dispose();
    _cardsCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Afri.dark.withOpacity(0.6),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Afri.bg,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: Afri.sand),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Afri.laterite.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Afri.laterite,
                  size: 26,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'Déconnexion',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Afri.dark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Quitter l\'espace administrateur ?',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Afri.ocre),
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Afri.sand),
                        foregroundColor: Afri.ocre,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Afri.dark,
                        foregroundColor: Afri.sand,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Sortir',
                        style: TextStyle(fontWeight: FontWeight.w800),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (ok == true && mounted) {
      await _auth.signOut();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Afri.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          _buildAnimatedHeader(),
          SliverToBoxAdapter(child: _buildBody()),
        ],
      ),
    );
  }

  Widget _buildAnimatedHeader() {
    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      floating: false,
      backgroundColor: const Color(0xFF1A1008),
      elevation: 0,
      automaticallyImplyLeading: false,
      title: const SizedBox.shrink(),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: _logout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Afri.laterite.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Afri.laterite.withOpacity(0.35)),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.logout_rounded, size: 14, color: Afri.laterite),
                  SizedBox(width: 5),
                  Text(
                    'Sortir',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Afri.laterite,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _AnimatedHeader(
          patternCtrl: _patternCtrl,
          glowCtrl: _glowCtrl,
          particlesCtrl: _particlesCtrl,
          heroCtrl: _heroCtrl,
          heroOpacity: _heroOpacity,
          heroSlide: _heroSlide,
          glowSize: _glowSize,
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator(color: Afri.gold)),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 28,
          decoration: const BoxDecoration(color: Color(0xFF1A1008)),
          child: Container(
            decoration: const BoxDecoration(
              color: Afri.bg,
              borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeTransition(
                opacity: _cardsCtrl,
                child: SlideTransition(
                  position:
                      Tween<Offset>(
                        begin: const Offset(0, 0.1),
                        end: Offset.zero,
                      ).animate(
                        CurvedAnimation(
                          parent: _cardsCtrl,
                          curve: Curves.easeOut,
                        ),
                      ),
                  child: _buildStatsGrid(),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(opacity: _bodyCtrl, child: _buildRecent()),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    final stats = [
      // Champs réels Firestore
      _S('🖼️', _oeuvres, 'Œuvres', '↑ +14 ce mois', Afri.gold),
      _S('👥', _users, 'Utilisateurs', '↑ +203', Afri.nil),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Vue d\'ensemble'),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.2,
          children: stats.asMap().entries.map((e) {
            final delay = e.key * 0.12;
            return _FadeIn(
              delay: delay,
              child: AfriStatCard(
                emoji: e.value.emoji,
                value: e.value.val,
                label: e.value.lbl,
                delta: e.value.delta,
                color: e.value.color,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildRecent() {
    // Fallback avec catégories valides : Sculpture, Peinture, Textile, Bijoux, Poterie
    final fallback = [
      {
        'titre': 'Bronzes du Bénin',
        'artiste': 'Artisans Bénin',
        'categorie': 'Sculpture',
        'annee': '1500',
        'has3D': false,
        'imageUrl': '',
        'statut': 'volé',
      },
      {
        'titre': 'Masque Dogon',
        'artiste': 'Mali',
        'categorie': 'Sculpture',
        'annee': 'XVIe s.',
        'has3D': true,
        'imageUrl': '',
        'statut': 'normal',
      },
      {
        'titre': 'Tissu Kente',
        'artiste': 'Ghana',
        'categorie': 'Textile',
        'annee': 'XVIIIe s.',
        'has3D': false,
        'imageUrl': '',
        'statut': 'normal',
      },
    ];
    final items = _recent.isNotEmpty ? _recent : fallback;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Label('Œuvres récentes'),
        const SizedBox(height: 10),
        ...items.asMap().entries.map(
          (e) => _FadeIn(
            delay: 0.1 + e.key * 0.1,
            child: _RecentCard(data: e.value),
          ),
        ),
      ],
    );
  }
}

// ══════════════════════════════════════════════════════
//  ANIMATED HEADER WIDGET
// ══════════════════════════════════════════════════════
class _AnimatedHeader extends StatelessWidget {
  final AnimationController patternCtrl, glowCtrl, particlesCtrl, heroCtrl;
  final Animation<double> heroOpacity, glowSize;
  final Animation<Offset> heroSlide;

  const _AnimatedHeader({
    required this.patternCtrl,
    required this.glowCtrl,
    required this.particlesCtrl,
    required this.heroCtrl,
    required this.heroOpacity,
    required this.heroSlide,
    required this.glowSize,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        patternCtrl,
        glowCtrl,
        particlesCtrl,
        heroCtrl,
      ]),
      builder: (_, __) {
        final size = MediaQuery.of(context).size;
        return Container(
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
              CustomPaint(
                size: Size(size.width, 260),
                painter: _HeaderPatternPainter(progress: patternCtrl.value),
              ),
              CustomPaint(
                size: Size(size.width, 260),
                painter: _HeaderParticlesPainter(progress: particlesCtrl.value),
              ),
              Positioned(
                top: 10,
                left: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Afri.savane.withOpacity(0.07),
                    border: Border.all(color: Afri.savane.withOpacity(0.12)),
                  ),
                ),
              ),
              Positioned(
                top: 5,
                right: -20,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Afri.kente.withOpacity(0.07),
                    border: Border.all(color: Afri.kente.withOpacity(0.12)),
                  ),
                ),
              ),
              Positioned(
                bottom: 30,
                right: 20,
                child: Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Afri.nil.withOpacity(0.07),
                    border: Border.all(color: Afri.nil.withOpacity(0.12)),
                  ),
                ),
              ),
              Positioned(
                top: 260 / 2 - glowSize.value / 2 - 20,
                right: -glowSize.value * 0.4,
                child: Container(
                  width: glowSize.value,
                  height: glowSize.value,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        Afri.gold.withOpacity(0.18),
                        Afri.honey.withOpacity(0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 80,
                bottom: 36,
                child: FadeTransition(
                  opacity: heroOpacity,
                  child: SlideTransition(
                    position: heroSlide,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Colors.transparent, Afri.gold],
                                  ),
                                ),
                              ),
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              child: Icon(
                                Icons.auto_awesome,
                                color: Afri.gold,
                                size: 14,
                              ),
                            ),
                            Expanded(
                              child: Container(
                                height: 1,
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [Afri.gold, Colors.transparent],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Afri.gold.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Afri.gold.withOpacity(0.3),
                            ),
                          ),
                          child: const Text(
                            'TABLEAU DE BORD',
                            style: TextStyle(
                              fontSize: 9,
                              letterSpacing: 2.5,
                              color: Afri.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Bonjour, Admin 👋',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFFECE2D0),
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: const BoxDecoration(
                                color: Afri.savane,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              _todayLabel(),
                              style: const TextStyle(
                                fontSize: 11,
                                color: Afri.ocre,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _todayLabel() {
    const j = ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'];
    const m = [
      'jan',
      'fév',
      'mar',
      'avr',
      'mai',
      'juin',
      'juil',
      'aoû',
      'sep',
      'oct',
      'nov',
      'déc',
    ];
    final n = DateTime.now();
    return '${j[n.weekday - 1]} ${n.day} ${m[n.month - 1]} ${n.year}';
  }
}

// ══════════════════════════════════════════════════════
//  PAINTERS
// ══════════════════════════════════════════════════════
class _HeaderPatternPainter extends CustomPainter {
  final double progress;
  _HeaderPatternPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    paint.color = Afri.gold.withOpacity(0.06 + sin(progress * 2 * pi) * 0.03);
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final x = size.width * 0.88;
      final y = 30.0 + i * 28.0;
      path.moveTo(x, y);
      path.lineTo(x + 18, y + 18);
      path.lineTo(x - 18, y + 18);
      path.close();
      canvas.drawPath(path, paint);
    }

    paint.color = Afri.nil.withOpacity(0.06 + cos(progress * 2 * pi) * 0.03);
    for (int i = 0; i < 4; i++) {
      final path = Path();
      final x = size.width * 0.08;
      final y = size.height * 0.55 + i * 30.0;
      path.moveTo(x, y - 10);
      path.lineTo(x + 10, y);
      path.lineTo(x, y + 10);
      path.lineTo(x - 10, y);
      path.close();
      canvas.drawPath(path, paint);
    }

    const colors = [
      Afri.gold,
      Afri.nil,
      Afri.savane,
      Afri.laterite,
      Afri.kente,
    ];
    const bandH = 8.0;
    final offset = progress * 40;
    final bandPaint = Paint()..style = PaintingStyle.fill;
    for (double y = -bandH + (offset % bandH); y < size.height; y += bandH) {
      final ci = ((y + offset) ~/ bandH).abs() % colors.length;
      bandPaint.color = colors[ci].withOpacity(0.045);
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, bandH - 0.5), bandPaint);
    }

    final lp = Paint()
      ..color = Afri.gold.withOpacity(0.055)
      ..strokeWidth = 0.7;
    for (
      double x = -size.height + (offset * 0.4 % 28);
      x < size.width + size.height;
      x += 28
    ) {
      canvas.drawLine(Offset(x, 0), Offset(x - size.height, size.height), lp);
    }
  }

  @override
  bool shouldRepaint(_HeaderPatternPainter o) => o.progress != progress;
}

class _HeaderParticlesPainter extends CustomPainter {
  final double progress;
  _HeaderParticlesPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final rng = Random(42);
    const colors = [
      Afri.gold,
      Afri.nil,
      Afri.savane,
      Afri.laterite,
      Afri.kente,
      Afri.honey,
    ];
    for (int i = 0; i < 28; i++) {
      final startX = rng.nextDouble() * size.width;
      final startY = rng.nextDouble() * size.height;
      final speed = 0.3 + rng.nextDouble() * 0.7;
      final offset = (progress * speed) % 1.0;
      final x = startX;
      final y =
          (startY - offset * size.height * 1.2 + size.height) % size.height;
      final paint = Paint()
        ..color = colors[i % colors.length].withOpacity(
          0.08 + rng.nextDouble() * 0.18,
        )
        ..style = PaintingStyle.fill;
      final radius = 1.2 + rng.nextDouble() * 2.8;
      canvas.drawCircle(Offset(x, y), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_HeaderParticlesPainter o) => o.progress != progress;
}

// ══════════════════════════════════════════════════════
//  LOCAL HELPERS
// ══════════════════════════════════════════════════════
class _S {
  final String emoji, lbl, delta;
  final int val;
  final Color color;
  const _S(this.emoji, this.val, this.lbl, this.delta, this.color);
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);

  @override
  Widget build(BuildContext context) => Text(
    text,
    style: const TextStyle(
      fontSize: 17,
      fontWeight: FontWeight.w900,
      color: Afri.dark,
      letterSpacing: 0.1,
    ),
  );
}

class _FadeIn extends StatefulWidget {
  final Widget child;
  final double delay;
  const _FadeIn({required this.child, required this.delay});

  @override
  State<_FadeIn> createState() => _FadeInState();
}

class _FadeInState extends State<_FadeIn> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _op;
  late Animation<Offset> _sl;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _op = CurvedAnimation(parent: _c, curve: Curves.easeIn);
    _sl = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _op,
    child: SlideTransition(position: _sl, child: widget.child),
  );
}

class _RecentCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _RecentCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final color = Afri.categoryColor(data['categorie']);
    final emoji = Afri.categoryEmoji(data['categorie']);
    // Utilise has3D (basé sur model3dUrl) au lieu de estAR
    final has3D = data['has3D'] == true;
    final isStolen = data['statut'] == 'volé';

    return AfriCard(
      accentColor: color,
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child:
                data['imageUrl'] != null &&
                    (data['imageUrl'] as String).isNotEmpty
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(15),
                    child: Image.network(
                      data['imageUrl'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Center(
                        child: Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                      ),
                    ),
                  )
                : Center(
                    child: Text(emoji, style: const TextStyle(fontSize: 24)),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['titre'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: Afri.dark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${data['artiste']} · ${data['categorie']} · ${data['annee']}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Afri.ocre),
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    if (has3D)
                      const AfriBadge(
                        label: '3D',
                        color: Afri.kente,
                        icon: Icons.view_in_ar_rounded,
                      ),
                    if (has3D && isStolen) const SizedBox(width: 4),
                    if (isStolen)
                      const AfriBadge(
                        label: 'Volé',
                        color: Afri.laterite,
                        icon: Icons.gavel_rounded,
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: [
              _Btn(icon: Icons.edit_outlined, color: Afri.nil),
              const SizedBox(height: 6),
              _Btn(icon: Icons.delete_outline, color: Afri.laterite),
            ],
          ),
        ],
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final Color color;
  const _Btn({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    width: 32,
    height: 32,
    decoration: BoxDecoration(
      color: color.withOpacity(0.10),
      borderRadius: BorderRadius.circular(10),
    ),
    child: Icon(icon, size: 15, color: color),
  );
}
