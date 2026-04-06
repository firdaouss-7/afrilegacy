import 'dart:math';
import 'package:flutter/material.dart';

class _P {
  static const bg      = Color(0xFFFBF8F3);
  static const bg2     = Color(0xFFF2EBE0);
  static const dark    = Color(0xFF3D2B1A);
  static const mid     = Color(0xFF5C3D2E);
  static const gold    = Color(0xFFC4A96A);
  static const honey   = Color(0xFFE8C87A);
  static const nil     = Color(0xFF8FAFC0);
  static const savane  = Color(0xFFA8C4A2);
  static const laterite= Color(0xFFD4A89A);
  static const kente   = Color(0xFFB8A8CC);
  static const ocre    = Color(0xFF8C7A68);
  static const sand    = Color(0xFFD9C9B2);
  static const clay    = Color(0xFFC9B99F);
}

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});
  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen>
    with TickerProviderStateMixin {

  late AnimationController _patternCtrl;
  late AnimationController _contentCtrl;

  @override
  void initState() {
    super.initState();
    _patternCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
    _contentCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..forward();
  }

  @override
  void dispose() { _patternCtrl.dispose(); _contentCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _P.bg,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── Header ────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF1A1008),
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _P.gold.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _P.gold.withOpacity(0.3))),
                child: const Icon(Icons.arrow_back_ios_new, color: _P.gold, size: 16)),
            ),
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: AnimatedBuilder(
                animation: _patternCtrl,
                builder: (_, __) {
                  final size = MediaQuery.of(context).size;
                  return Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft, end: Alignment.bottomRight,
                        colors: [Color(0xFF1A1008), Color(0xFF3D2B1A),
                                 Color(0xFF2A1F0E), Color(0xFF1A1008)],
                        stops: [0.0, 0.3, 0.7, 1.0])),
                    child: Stack(children: [
                      CustomPaint(size: Size(size.width, 220),
                          painter: _AboutPatternPainter(progress: _patternCtrl.value)),

                      // Glow doré
                      Positioned(top: -30, right: -40,
                        child: Container(width: 200, height: 200,
                          decoration: BoxDecoration(shape: BoxShape.circle,
                            gradient: RadialGradient(colors: [
                              _P.gold.withOpacity(0.18),
                              Colors.transparent])))),

                      // Logo centré
                      const SafeArea(
                        child: Center(
                          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                            SizedBox(height: 20),
                            // Logo AfriLegacy
                            _LogoWidget(),
                            SizedBox(height: 14),
                            Text('AfriLegacy',
                              style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900,
                                  color: Color(0xFFECE2D0), letterSpacing: 1)),
                            SizedBox(height: 4),
                            Text('Patrimoine africain numérique',
                              style: TextStyle(fontSize: 12, color: _P.ocre, letterSpacing: 0.5)),
                          ]),
                        ),
                      ),
                    ]),
                  );
                },
              ),
            ),
          ),

          // ── Content ───────────────────────────────
          SliverToBoxAdapter(
            child: FadeTransition(
              opacity: _contentCtrl,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
                    .animate(CurvedAnimation(parent: _contentCtrl, curve: Curves.easeOut)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                  child: Column(children: [

                    // Courbe
                    Container(height: 24,
                      decoration: const BoxDecoration(color: Color(0xFF1A1008)),
                      child: Container(decoration: const BoxDecoration(
                        color: _P.bg,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28))))),

                    const SizedBox(height: 8),

                    // ── Version ───────────────────────
                    _buildVersionCard(),
                    const SizedBox(height: 20),

                    // ── Mission ───────────────────────
                    _buildSection(
                      icon: '🌍',
                      title: 'Notre Mission',
                      color: _P.gold,
                      content:
                          'AfriLegacy est un musée virtuel dédié à la préservation et à la valorisation du '
                          'patrimoine culturel africain. Notre mission est de rendre accessible à tous '
                          'la richesse artistique et historique du continent africain, qu\'il s\'agisse '
                          'd\'œuvres d\'art, de sculptures, de textiles ou d\'objets culturels.',
                    ),
                    const SizedBox(height: 16),

                    // ── Stolen Art ────────────────────
                    _buildSection(
                      icon: '⚖️',
                      title: 'Engagement pour la Restitution',
                      color: _P.laterite,
                      content:
                          'AfriLegacy s\'engage à documenter et signaler les œuvres d\'art africaines '
                          'pillées ou illégalement déplacées dans des musées à travers le monde. '
                          'Nous croyons que chaque peuple a le droit de voir son patrimoine '
                          'restitué et préservé pour les générations futures.',
                    ),
                    const SizedBox(height: 16),

                    // ── Fonctionnalités ────────────────
                    _buildFeaturesCard(),
                    const SizedBox(height: 16),

                    // ── Citation ──────────────────────
                    _buildQuote(),
                    const SizedBox(height: 16),

                    // ── Équipe / Contact ──────────────
                    _buildSection(
                      icon: '✉️',
                      title: 'Contact',
                      color: _P.nil,
                      content:
                          'Pour toute question, suggestion ou signalement d\'une œuvre pillée, '
                          'contactez-nous à : contact@afrilegacy.com\n\n'
                          'Nous sommes également ouverts aux partenariats avec des musées, '
                          'universités et institutions culturelles africaines.',
                    ),
                    const SizedBox(height: 16),

                    // ── Infos légales ─────────────────
                    _buildLegalCard(),
                    const SizedBox(height: 24),

                    // Signature
                    Center(child: Column(children: [
                      const Text('Fait avec ❤️ pour l\'Afrique',
                        style: TextStyle(fontSize: 13, color: _P.ocre,
                            fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('© ${DateTime.now().year} AfriLegacy — Tous droits réservés',
                        style: const TextStyle(fontSize: 10, color: _P.clay)),
                    ])),
                  ]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVersionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF3D2B1A), Color(0xFF5C3D2E)]),
        borderRadius: BorderRadius.circular(24)),
      child: Row(children: [
        Container(width: 52, height: 52,
          decoration: BoxDecoration(
            color: _P.gold.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _P.gold.withOpacity(0.3))),
          child: const Center(child: Text('🌍', style: TextStyle(fontSize: 26)))),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('AfriLegacy', style: TextStyle(fontSize: 18,
              fontWeight: FontWeight.w900, color: Color(0xFFECE2D0))),
          const Text('Version 1.0.0', style: TextStyle(fontSize: 12, color: _P.gold)),
          Text('Build ${DateTime.now().year}',
            style: const TextStyle(fontSize: 10, color: _P.ocre)),
        ])),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: _P.savane.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _P.savane.withOpacity(0.3))),
          child: const Text('Stable', style: TextStyle(fontSize: 10,
              fontWeight: FontWeight.w700, color: _P.savane))),
      ]),
    );
  }

  Widget _buildSection({
    required String icon, required String title,
    required Color color, required String content,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _P.sand.withOpacity(0.5)),
        boxShadow: [BoxShadow(color: color.withOpacity(0.05),
            blurRadius: 16, offset: const Offset(0, 4))]),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13)),
            child: Center(child: Text(icon, style: const TextStyle(fontSize: 20)))),
          const SizedBox(width: 12),
          Expanded(child: Text(title, style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w900, color: _P.dark))),
        ]),
        const SizedBox(height: 14),
        Container(height: 1.5,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: [color.withOpacity(0.4), Colors.transparent]))),
        const SizedBox(height: 14),
        Text(content, style: const TextStyle(
            fontSize: 13, color: _P.ocre, height: 1.7)),
      ]),
    );
  }

  Widget _buildFeaturesCard() {
    final features = [
      _Feat('🖼️', 'Collection d\'œuvres', 'Sculptures, peintures, textiles, bijoux et poteries', _P.gold),
      _Feat('🔴', 'Stolen Art', 'Signalement des œuvres pillées et déplacées', _P.laterite),
      _Feat('⭐', 'Favoris', 'Sauvegardez vos œuvres préférées', _P.honey),
      _Feat('🎧', 'Audio Guide', 'Narrations audio pour chaque œuvre', _P.nil),
      _Feat('🗂️', 'Collections', 'Œuvres organisées par thèmes culturels', _P.savane),
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _P.sand.withOpacity(0.5))),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40,
            decoration: BoxDecoration(
              color: _P.kente.withOpacity(0.12),
              borderRadius: BorderRadius.circular(13)),
            child: const Center(child: Text('✨', style: TextStyle(fontSize: 20)))),
          const SizedBox(width: 12),
          const Text('Fonctionnalités', style: TextStyle(
              fontSize: 15, fontWeight: FontWeight.w900, color: _P.dark)),
        ]),
        const SizedBox(height: 16),
        ...features.map((f) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Row(children: [
            Container(width: 36, height: 36,
              decoration: BoxDecoration(
                color: f.color.withOpacity(0.10),
                borderRadius: BorderRadius.circular(10)),
              child: Center(child: Text(f.emoji, style: const TextStyle(fontSize: 16)))),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f.title, style: const TextStyle(fontSize: 12,
                  fontWeight: FontWeight.w700, color: _P.dark)),
              Text(f.sub, style: const TextStyle(fontSize: 10, color: _P.ocre)),
            ])),
          ]),
        )),
      ]),
    );
  }

  Widget _buildQuote() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [_P.gold.withOpacity(0.08), _P.honey.withOpacity(0.05)]),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: _P.gold.withOpacity(0.25))),
      child: Column(children: [
        const Icon(Icons.format_quote_rounded, color: _P.gold, size: 28),
        const SizedBox(height: 10),
        const Text(
          '"En Afrique, quand un vieillard meurt,\nc\'est une bibliothèque qui brûle."',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: _P.dark,
              fontStyle: FontStyle.italic, height: 1.6)),
        const SizedBox(height: 10),
        const Text('— Ahmadou Hampâté Bâ',
          style: TextStyle(fontSize: 11, color: _P.gold, fontWeight: FontWeight.w700)),
      ]),
    );
  }

  Widget _buildLegalCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _P.bg2,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _P.sand.withOpacity(0.5))),
      child: Column(children: [
        _LegalRow('Conditions d\'utilisation', Icons.description_outlined),
        const SizedBox(height: 10),
        _LegalRow('Politique de confidentialité', Icons.privacy_tip_outlined),
        const SizedBox(height: 10),
        _LegalRow('Licences open source', Icons.code_outlined),
      ]),
    );
  }
}

class _LegalRow extends StatelessWidget {
  final String label; final IconData icon;
  const _LegalRow(this.label, this.icon);
  @override
  Widget build(BuildContext context) => Row(children: [
    Icon(icon, size: 16, color: _P.ocre),
    const SizedBox(width: 10),
    Expanded(child: Text(label, style: const TextStyle(fontSize: 12, color: _P.ocre))),
    const Icon(Icons.arrow_forward_ios_rounded, size: 11, color: _P.clay),
  ]);
}

class _Feat {
  final String emoji, title, sub; final Color color;
  const _Feat(this.emoji, this.title, this.sub, this.color);
}

class _LogoWidget extends StatelessWidget {
  const _LogoWidget();
  @override
  Widget build(BuildContext context) => Container(
    width: 70, height: 70,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      gradient: const LinearGradient(
        colors: [Color(0xFFC4A96A), Color(0xFFE8C87A)],
        begin: Alignment.topLeft, end: Alignment.bottomRight),
      boxShadow: [BoxShadow(
        color: const Color(0xFFC4A96A).withOpacity(0.35),
        blurRadius: 20, offset: const Offset(0, 6))]),
    child: const Center(child: Text('🌍', style: TextStyle(fontSize: 34))));
}

class _AboutPatternPainter extends CustomPainter {
  final double progress;
  _AboutPatternPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    const bandH = 8.0;
    const cols = [Color(0xFFC4A96A), Color(0xFF8FAFC0), Color(0xFFA8C4A2),
                  Color(0xFFD4A89A), Color(0xFFB8A8CC)];
    final offset = progress * 40;
    final bp = Paint()..style = PaintingStyle.fill;
    for (double y = -bandH + (offset % bandH); y < size.height; y += bandH) {
      final ci = ((y + offset) ~/ bandH).abs() % cols.length;
      bp.color = cols[ci].withOpacity(0.04);
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, bandH - 0.5), bp);
    }
    final dp = Paint()..color = const Color(0xFFC4A96A).withOpacity(0.09)
        ..style = PaintingStyle.stroke..strokeWidth = 0.6;
    for (double x = 24.0; x < size.width; x += 36) {
      for (double y = 20.0; y < size.height; y += 36) {
        final ay = y + sin((x + progress * 6.28) * 0.12) * 2.5;
        final path = Path()
          ..moveTo(x, ay - 5)..lineTo(x + 5, ay)
          ..lineTo(x, ay + 5)..lineTo(x - 5, ay)..close();
        canvas.drawPath(path, dp);
      }
    }
  }
  @override
  bool shouldRepaint(_AboutPatternPainter o) => o.progress != progress;
}