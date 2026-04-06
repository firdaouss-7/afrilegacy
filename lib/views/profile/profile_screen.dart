import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afrilegacy/services/auth_service.dart';
import 'package:afrilegacy/models/user_model.dart';
import 'package:afrilegacy/services/oeuvre_service.dart';
import 'package:afrilegacy/models/oeuvre_model.dart';
import 'package:afrilegacy/views/auth/login_screen.dart';
import 'package:afrilegacy/views/profile/edit_profile_screen.dart';
import 'package:afrilegacy/views/profile/about_screen.dart';
import 'package:afrilegacy/services/favori_service.dart';

class _P {
  static const bg       = Color(0xFFFBF8F3);
  static const bg2      = Color(0xFFF2EBE0);
  static const dark     = Color(0xFF3D2B1A);
  static const mid      = Color(0xFF5C3D2E);
  static const gold     = Color(0xFFC4A96A);
  static const honey    = Color(0xFFE8C87A);
  static const nil      = Color(0xFF8FAFC0);
  static const savane   = Color(0xFFA8C4A2);
  static const laterite = Color(0xFFD4A89A);
  static const kente    = Color(0xFFB8A8CC);
  static const ocre     = Color(0xFF8C7A68);
  static const sand     = Color(0xFFD9C9B2);
  static const clay     = Color(0xFFC9B99F);
}

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {

  final _auth = AuthService();
  final _oeuvreService = OeuvreService();
  final _favoriService = FavoriService();

  UserModel? _user;
  List<OeuvreModel> _favoris = [];
  int _favCount = 0;
  bool _loading = true;

  late AnimationController _headerCtrl;
  late AnimationController _patternCtrl;
  late AnimationController _glowCtrl;
  late AnimationController _cardsCtrl;
  late AnimationController _avatarCtrl;

  late Animation<double> _headerOpacity;
  late Animation<Offset>  _headerSlide;
  late Animation<double>  _avatarScale;
  late Animation<double>  _glowSize;

  @override
  void initState() {
    super.initState();
    _headerCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _patternCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 18))..repeat();
    _glowCtrl    = AnimationController(vsync: this, duration: const Duration(milliseconds: 2200))..repeat(reverse: true);
    _cardsCtrl   = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _avatarCtrl  = AnimationController(vsync: this, duration: const Duration(milliseconds: 1000));

    _headerOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _headerCtrl, curve: const Interval(0, 0.6, curve: Curves.easeIn)));
    _headerSlide = Tween<Offset>(begin: const Offset(0, -0.15), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerCtrl, curve: Curves.easeOut));
    _avatarScale = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _avatarCtrl, curve: Curves.elasticOut));
    _glowSize = Tween<double>(begin: 180, end: 260)
        .animate(CurvedAnimation(parent: _glowCtrl, curve: Curves.easeInOut));

    _loadData();
  }

  Future<void> _loadData() async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) { setState(() => _loading = false); return; }
    try {
      // Charger le profil user
      final doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      if (!mounted) return;
      if (doc.exists) _user = UserModel.fromFirestore(doc);

      // ✅ Charger les favoris depuis la sous-collection favoris/{uid}/oeuvres
      final favOeuvres = await _favoriService.getFavorisOeuvres(uid);
      if (!mounted) return;
      setState(() {
        _favoris  = favOeuvres.take(6).toList(); // max 6 pour le carousel
        _favCount = favOeuvres.length;            // compteur réel
        _loading  = false;
      });

      _avatarCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 100));
      _headerCtrl.forward();
      await Future.delayed(const Duration(milliseconds: 200));
      _cardsCtrl.forward();
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refreshData() async {
    setState(() => _loading = true);
    await _loadData();
  }

  @override
  void dispose() {
    _headerCtrl.dispose(); _patternCtrl.dispose();
    _glowCtrl.dispose(); _cardsCtrl.dispose(); _avatarCtrl.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    HapticFeedback.mediumImpact();
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: _P.dark.withOpacity(0.55),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(26),
          decoration: BoxDecoration(color: _P.bg,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: _P.sand)),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 58, height: 58,
              decoration: BoxDecoration(color: _P.laterite.withOpacity(0.12), shape: BoxShape.circle),
              child: const Icon(Icons.logout_rounded, color: _P.laterite, size: 26)),
            const SizedBox(height: 14),
            const Text('Déconnexion',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: _P.dark)),
            const SizedBox(height: 6),
            const Text('Voulez-vous vraiment quitter ?',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: _P.ocre)),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: OutlinedButton(
                onPressed: () => Navigator.pop(context, false),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: _P.sand), foregroundColor: _P.ocre,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12)),
                child: const Text('Annuler'))),
              const SizedBox(width: 10),
              Expanded(child: ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _P.dark, foregroundColor: _P.sand,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  padding: const EdgeInsets.symmetric(vertical: 12), elevation: 0),
                child: const Text('Sortir', style: TextStyle(fontWeight: FontWeight.w800)))),
            ]),
          ]),
        ),
      ),
    );
    if (ok == true && mounted) {
      await _auth.signOut();
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (_) => const LoginScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _P.bg,
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _P.gold))
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                _buildHeader(),
                SliverToBoxAdapter(child: _buildBody()),
              ],
            ),
    );
  }

  Widget _buildHeader() {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      floating: false,
      backgroundColor: const Color(0xFF1A1008),
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.12)),
          ),
          child: const Icon(Icons.arrow_back_ios_new,
              color: Color(0xFFECE2D0), size: 16),
        ),
      ),
      title: FadeTransition(
        opacity: _headerOpacity,
        child: const Text('Mon Profil',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800,
              color: Color(0xFFECE2D0), letterSpacing: 0.5))),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 14),
          child: GestureDetector(
            onTap: _logout,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _P.laterite.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _P.laterite.withOpacity(0.35))),
              child: const Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(Icons.logout_rounded, size: 13, color: _P.laterite),
                SizedBox(width: 5),
                Text('Sortir', style: TextStyle(fontSize: 11,
                    fontWeight: FontWeight.w800, color: _P.laterite)),
              ]),
            ),
          ),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: _ProfileHeader(
          user: _user,
          patternCtrl: _patternCtrl,
          glowCtrl: _glowCtrl,
          avatarCtrl: _avatarCtrl,
          headerCtrl: _headerCtrl,
          headerOpacity: _headerOpacity,
          headerSlide: _headerSlide,
          avatarScale: _avatarScale,
          glowSize: _glowSize,
        ),
      ),
    );
  }

  Widget _buildBody() {
    return Column(children: [
      Container(height: 24,
        decoration: const BoxDecoration(color: Color(0xFF1A1008)),
        child: Container(decoration: const BoxDecoration(
          color: _P.bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28))))),

      Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 100),
        child: Column(children: [

          // ── Infos ──────────────────────────────────
          _buildInfoCard(),
          const SizedBox(height: 20),

          // ── Stat favoris uniquement ────────────────
          _buildFavStat(),
          const SizedBox(height: 24),

          // ── Favoris carousel ──────────────────────
          if (_favoris.isNotEmpty) ...[
            _buildSectionTitle('Mes Favoris', Icons.favorite_rounded, _P.laterite),
            const SizedBox(height: 14),
            _buildFavorisList(),
            const SizedBox(height: 24),
          ],

          // ── Menu ──────────────────────────────────
          _buildSectionTitle('Paramètres', Icons.settings_outlined, _P.nil),
          const SizedBox(height: 14),
          _buildMenuItems(),
        ]),
      ),
    ]);
  }

  Widget _buildSectionTitle(String title, IconData icon, Color color) {
    return Row(children: [
      Container(width: 3, height: 18,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: 10),
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 6),
      Text(title, style: const TextStyle(
          fontSize: 15, fontWeight: FontWeight.w900, color: _P.dark)),
    ]);
  }

  Widget _buildInfoCard() {
    final nom    = _user?.nom   ?? 'Utilisateur';
    final email  = _user?.email ?? '';
    final joined = _memberSince();

    return _AnimCard(delay: 0.05,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: _P.sand.withOpacity(0.5)),
          boxShadow: [BoxShadow(color: _P.gold.withOpacity(0.06),
              blurRadius: 20, offset: const Offset(0, 4))]),
        child: Column(children: [
          _InfoRow(icon: Icons.person_outline_rounded, color: _P.gold,
              label: 'Nom', value: nom),
          const _Divider(),
          _InfoRow(icon: Icons.email_outlined, color: _P.nil,
              label: 'Email', value: email),
          const _Divider(),
          _InfoRow(icon: Icons.calendar_today_outlined, color: _P.savane,
              label: 'Membre depuis', value: joined),
        ]),
      ),
    );
  }

  Widget _buildFavStat() {
    return _AnimCard(delay: 0.12,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFF3D2B1A), Color(0xFF5C3D2E)]),
          borderRadius: BorderRadius.circular(24)),
        child: Row(children: [
          const Text('❤️', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 16),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('$_favCount',
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w900, color: _P.gold)),
            const Text('œuvres en favoris',
              style: TextStyle(fontSize: 12, color: _P.ocre)),
          ]),
          const Spacer(),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _P.gold.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _P.gold.withOpacity(0.2))),
            child: const Icon(Icons.collections_outlined, color: _P.gold, size: 22)),
        ]),
      ),
    );
  }

  Widget _buildFavorisList() {
    return SizedBox(
      height: 130,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _favoris.length,
        itemBuilder: (_, i) {
          final o = _favoris[i];
          return _AnimCard(delay: 0.1 + i * 0.07,
            child: Container(
              width: 100,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                boxShadow: [BoxShadow(color: _P.dark.withOpacity(0.08),
                    blurRadius: 10, offset: const Offset(0, 3))]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: Stack(fit: StackFit.expand, children: [
                  o.imageUrl.isNotEmpty
                      ? Image.network(o.imageUrl, fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _placeholder())
                      : _placeholder(),
                  Container(decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      colors: [Colors.transparent, _P.dark.withOpacity(0.75)],
                      stops: const [0.4, 1.0]))),
                  Positioned(bottom: 8, left: 8, right: 8,
                    child: Text(o.titre, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white,
                          fontSize: 9, fontWeight: FontWeight.w700))),
                ]),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMenuItems() {
    final items = [
      _MenuItem(
        icon: Icons.edit_outlined, color: _P.gold,
        label: 'Modifier le profil', sub: 'Nom, photo',
        onTap: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => EditProfileScreen(user: _user)));
          _refreshData();
        },
      ),
      _MenuItem(
        icon: Icons.info_outline_rounded, color: _P.nil,
        label: 'À propos', sub: 'AfriLegacy v1.0',
        onTap: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const AboutScreen())),
      ),
    ];

    return Column(
      children: items.asMap().entries.map((e) {
        final idx = e.key; final item = e.value;
        return _AnimCard(delay: 0.05 + idx * 0.08,
          child: GestureDetector(
            onTap: item.onTap,
            child: Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _P.sand.withOpacity(0.4)),
                boxShadow: [BoxShadow(color: item.color.withOpacity(0.05),
                    blurRadius: 10, offset: const Offset(0, 3))]),
              child: Row(children: [
                Container(width: 42, height: 42,
                  decoration: BoxDecoration(
                    color: item.color.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(13)),
                  child: Icon(item.icon, color: item.color, size: 20)),
                const SizedBox(width: 14),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(item.label, style: const TextStyle(
                      fontSize: 13, fontWeight: FontWeight.w700, color: _P.dark)),
                  Text(item.sub, style: const TextStyle(fontSize: 10, color: _P.ocre)),
                ])),
                Icon(Icons.arrow_forward_ios_rounded, size: 13, color: _P.clay),
              ]),
            ),
          ),
        );
      }).toList(),
    );
  }

  String _memberSince() {
    if (_user?.createdAt == null) return 'Récemment';
    final d = _user!.createdAt!;
    const mois = ['jan','fév','mar','avr','mai','juin','juil','aoû','sep','oct','nov','déc'];
    return '${d.day} ${mois[d.month - 1]} ${d.year}';
  }

  Widget _placeholder() => Container(
    decoration: BoxDecoration(
      gradient: LinearGradient(
        colors: [_P.gold.withOpacity(0.3), const Color(0xFFF2EBE0)],
        begin: Alignment.topLeft, end: Alignment.bottomRight)),
    child: const Center(child: Icon(Icons.art_track, color: _P.gold, size: 28)));
}

// ══════════════════════════════════════════════════════
//  ANIMATED HEADER
// ══════════════════════════════════════════════════════
class _ProfileHeader extends StatelessWidget {
  final UserModel? user;
  final AnimationController patternCtrl, glowCtrl, avatarCtrl, headerCtrl;
  final Animation<double> headerOpacity, avatarScale, glowSize;
  final Animation<Offset> headerSlide;

  const _ProfileHeader({
    required this.user, required this.patternCtrl, required this.glowCtrl,
    required this.avatarCtrl, required this.headerCtrl,
    required this.headerOpacity, required this.headerSlide,
    required this.avatarScale, required this.glowSize,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([patternCtrl, glowCtrl, avatarCtrl, headerCtrl]),
      builder: (_, __) {
        final size    = MediaQuery.of(context).size;
        final nom     = user?.nom   ?? 'Utilisateur';
        final email   = user?.email ?? '';
        final initial = nom.isNotEmpty ? nom[0].toUpperCase() : 'U';

        return Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [Color(0xFF1A1008), Color(0xFF3D2B1A),
                       Color(0xFF2A1F0E), Color(0xFF1A1008)],
              stops: [0.0, 0.3, 0.7, 1.0])),
          child: Stack(children: [
            CustomPaint(size: Size(size.width, 280),
                painter: _PatternPainter(progress: patternCtrl.value)),
            Positioned(
              top: 280/2 - glowSize.value/2 - 10,
              right: -glowSize.value * 0.5,
              child: Container(
                width: glowSize.value, height: glowSize.value,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  gradient: RadialGradient(colors: [
                    const Color(0xFFC4A96A).withOpacity(0.20),
                    const Color(0xFFE8C87A).withOpacity(0.08),
                    Colors.transparent])))),
            Positioned(top: 20, left: -30,
              child: Container(width: 90, height: 90,
                decoration: BoxDecoration(shape: BoxShape.circle,
                  color: const Color(0xFFA8C4A2).withOpacity(0.07),
                  border: Border.all(color: const Color(0xFFA8C4A2).withOpacity(0.12))))),

            // Contenu centré
            Positioned.fill(
              child: FadeTransition(opacity: headerOpacity,
                child: SlideTransition(position: headerSlide,
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const SizedBox(height: 40),
                    // Avatar avec ring animé
                    ScaleTransition(scale: avatarScale,
                      child: AnimatedBuilder(
                        animation: glowCtrl,
                        builder: (_, child) => Container(
                          width: 96, height: 96,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                const Color(0xFFC4A96A).withOpacity(0.8),
                                const Color(0xFFE8C87A).withOpacity(0.4),
                                const Color(0xFFC4A96A).withOpacity(0.8)],
                              transform: GradientRotation(glowCtrl.value * 2 * pi))),
                          child: child),
                        // ── Avatar : photo Cloudinary ou initiale ──
                        child: Center(
                          child: Container(
                            width: 88, height: 88,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [Color(0xFF5C3D2E), Color(0xFF3D2B1A)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight)),
                            child: ClipOval(
                              child: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                                // ✅ Photo Cloudinary disponible
                                ? Image.network(
                                    user!.photoUrl!,
                                    fit: BoxFit.cover,
                                    width: 88,
                                    height: 88,
                                    loadingBuilder: (_, child, progress) =>
                                        progress == null
                                            ? child
                                            : const Center(
                                                child: CircularProgressIndicator(
                                                    color: Color(0xFFC4A96A),
                                                    strokeWidth: 2)),
                                    errorBuilder: (_, __, ___) => Center(
                                        child: Text(initial,
                                            style: const TextStyle(
                                                fontSize: 36,
                                                fontWeight: FontWeight.w900,
                                                color: Color(0xFFC4A96A)))))
                                // Initiale par défaut
                                : Center(
                                    child: Text(initial,
                                        style: const TextStyle(
                                            fontSize: 36,
                                            fontWeight: FontWeight.w900,
                                            color: Color(0xFFC4A96A)))),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(nom, style: const TextStyle(fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFECE2D0), letterSpacing: 0.3)),
                    const SizedBox(height: 4),
                    Text(email, style: TextStyle(fontSize: 12,
                        color: const Color(0xFF8C7A68).withOpacity(0.9))),
                  ]),
                ),
              ),
            ),
          ]),
        );
      },
    );
  }
}

class _PatternPainter extends CustomPainter {
  final double progress;
  _PatternPainter({required this.progress});
  @override
  void paint(Canvas canvas, Size size) {
    const bandH = 8.0;
    const cols = [Color(0xFFC4A96A), Color(0xFF8FAFC0), Color(0xFFA8C4A2),
                  Color(0xFFD4A89A), Color(0xFFB8A8CC)];
    final offset = progress * 40;
    final bp = Paint()..style = PaintingStyle.fill;
    for (double y = -bandH + (offset % bandH); y < size.height; y += bandH) {
      final ci = ((y + offset) ~/ bandH).abs() % cols.length;
      bp.color = cols[ci].withOpacity(0.045);
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, bandH - 0.5), bp);
    }
    final dp = Paint()..color = const Color(0xFFC4A96A).withOpacity(0.10)
        ..style = PaintingStyle.stroke..strokeWidth = 0.7;
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
  bool shouldRepaint(_PatternPainter o) => o.progress != progress;
}

// ══════════════════════════════════════════════════════
//  WIDGETS HELPERS
// ══════════════════════════════════════════════════════
class _InfoRow extends StatelessWidget {
  final IconData icon; final Color color; final String label, value;
  const _InfoRow({required this.icon, required this.color,
      required this.label, required this.value});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: Row(children: [
      Container(width: 36, height: 36,
        decoration: BoxDecoration(color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(11)),
        child: Icon(icon, color: color, size: 18)),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: const TextStyle(fontSize: 10, color: _P.ocre,
            fontWeight: FontWeight.w600)),
        Text(value, style: const TextStyle(fontSize: 13, color: _P.dark,
            fontWeight: FontWeight.w700)),
      ])),
    ]),
  );
}

class _Divider extends StatelessWidget {
  const _Divider();
  @override
  Widget build(BuildContext context) => Container(
    height: 0.5, color: const Color(0xFFD9C9B2).withOpacity(0.5),
    margin: const EdgeInsets.only(left: 48));
}

class _MenuItem {
  final IconData icon; final Color color;
  final String label, sub; final VoidCallback onTap;
  const _MenuItem({required this.icon, required this.color,
      required this.label, required this.sub, required this.onTap});
}

class _AnimCard extends StatefulWidget {
  final Widget child; final double delay;
  const _AnimCard({required this.child, required this.delay});
  @override
  State<_AnimCard> createState() => _AnimCardState();
}
class _AnimCardState extends State<_AnimCard> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _op;
  late Animation<Offset> _sl;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _op = CurvedAnimation(parent: _c, curve: Curves.easeIn);
    _sl = Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()),
        () { if (mounted) _c.forward(); });
  }
  @override
  void dispose() { _c.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: _op, child: SlideTransition(position: _sl, child: widget.child));
}