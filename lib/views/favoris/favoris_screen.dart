import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:afrilegacy/models/oeuvre_model.dart';
import 'package:afrilegacy/services/favori_service.dart';
import 'package:afrilegacy/services/auth_service.dart';
import 'package:afrilegacy/views/oeuvres/oeuvre_detail_screen.dart';

class FavorisScreen extends StatefulWidget {
  const FavorisScreen({super.key});

  @override
  State<FavorisScreen> createState() => _FavorisScreenState();
}

class _FavorisScreenState extends State<FavorisScreen>
    with TickerProviderStateMixin {
  final _favoriService = FavoriService();
  final _authService = AuthService();

  late AnimationController _headerController;
  late AnimationController _shimmerController;
  late AnimationController _patternController;
  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;
  late Animation<double> _shimmer;

  static const _sand    = Color(0xFFFBF8F3);
  static const _papyrus = Color(0xFFF2EBE0);
  static const _brun    = Color(0xFF3D2B1A);
  static const _or      = Color(0xFFC4A96A);
  static const _ocre    = Color(0xFF8C7A68);
  static const _roseLat = Color(0xFFD4A89A);
  static const _argile  = Color(0xFFC9B99F);
  static const _miel    = Color(0xFFE8C87A);
  static const _cielNil = Color(0xFF8FAFC0);
  static const _savane  = Color(0xFFA8C4A2);
  static const _violet  = Color(0xFFB8A8CC);

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 800));
    _shimmerController = AnimationController(
        vsync: this, duration: const Duration(seconds: 2))..repeat();
    _patternController = AnimationController(
        vsync: this, duration: const Duration(seconds: 20))..repeat();

    _headerOpacity = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _headerController, curve: Curves.easeIn));
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.2), end: Offset.zero)
        .animate(CurvedAnimation(
            parent: _headerController, curve: Curves.easeOut));
    _shimmer = Tween<double>(begin: -2, end: 2).animate(
        CurvedAnimation(parent: _shimmerController, curve: Curves.linear));

    _headerController.forward();
  }

  @override
  void dispose() {
    _headerController.dispose();
    _shimmerController.dispose();
    _patternController.dispose();
    super.dispose();
  }

  String? get _userId => _authService.currentUser?.uid;

  void _navigateToDetail(OeuvreModel oeuvre) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => OeuvreDetailScreen(
            oeuvre: oeuvre, heroTag: 'favori_${oeuvre.id}'),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  Future<void> _removeFavori(String oeuvreId) async {
    final uid = _userId;
    if (uid == null) return;
    await _favoriService.removeFavori(uid, oeuvreId);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Retiré des favoris',
              style: TextStyle(color: _papyrus)),
          backgroundColor: _brun,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _sand,
      body: Stack(
        children: [
          // Fond animé
          AnimatedBuilder(
            animation: _patternController,
            builder: (_, __) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _FavBgPainter(progress: _patternController.value),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildContent()),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _headerController,
      builder: (_, child) => Opacity(
        opacity: _headerOpacity.value,
        child: SlideTransition(position: _headerSlide, child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _papyrus,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _argile.withOpacity(0.4)),
                ),
                child: const Icon(Icons.arrow_back_ios_new,
                    color: _brun, size: 16),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Mes Favoris',
                      style: TextStyle(
                          color: _brun,
                          fontSize: 22,
                          fontWeight: FontWeight.w900)),
                  Text('Vos œuvres sauvegardées',
                      style: TextStyle(
                          color: _ocre.withOpacity(0.7), fontSize: 12)),
                ],
              ),
            ),
            // Icône cœur décoratif
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _roseLat.withOpacity(0.12),
                shape: BoxShape.circle,
                border:
                    Border.all(color: _roseLat.withOpacity(0.3), width: 1.5),
              ),
              child: const Icon(Icons.favorite_rounded,
                  color: _roseLat, size: 22),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final uid = _userId;
    if (uid == null) {
      return _buildNotLoggedIn();
    }

    return StreamBuilder<List<OeuvreModel>>(
      stream: _favoriService.getFavorisStream(uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildSkeleton();
        }
        if (snapshot.hasError) {
          return _buildError(snapshot.error.toString());
        }
        final favoris = snapshot.data ?? [];
        if (favoris.isEmpty) return _buildEmpty();
        return _buildGrid(favoris);
      },
    );
  }

  Widget _buildGrid(List<OeuvreModel> favoris) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          sliver: SliverToBoxAdapter(
            child: Text(
              '${favoris.length} œuvre${favoris.length > 1 ? 's' : ''} sauvegardée${favoris.length > 1 ? 's' : ''}',
              style: const TextStyle(
                  color: _ocre, fontSize: 12, fontWeight: FontWeight.w500),
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 14,
                crossAxisSpacing: 14,
                childAspectRatio: 0.72),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildCard(favoris[index], index),
              childCount: favoris.length,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard(OeuvreModel oeuvre, int index) {
    final catColor = _getCatColor(oeuvre.categorie);
    return GestureDetector(
      onTap: () => _navigateToDetail(oeuvre),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: _brun.withOpacity(0.08),
                blurRadius: 14,
                offset: const Offset(0, 5))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(fit: StackFit.expand, children: [
                  Hero(
                    tag: 'favori_${oeuvre.id}',
                    child: oeuvre.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: oeuvre.imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (_, __) => _placeholder(oeuvre),
                            errorWidget: (_, __, ___) => _placeholder(oeuvre),
                          )
                        : _placeholder(oeuvre),
                  ),
                  // Bouton retirer favori
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _removeFavori(oeuvre.id),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.92),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                                color: _roseLat.withOpacity(0.3),
                                blurRadius: 6)
                          ],
                        ),
                        child: const Icon(Icons.favorite_rounded,
                            color: _roseLat, size: 17),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            // Infos
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(oeuvre.categorie,
                          style: TextStyle(
                              color: catColor,
                              fontSize: 9,
                              fontWeight: FontWeight.w700)),
                    ),
                    Text(oeuvre.titre,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: _brun,
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            height: 1.3)),
                    Text(oeuvre.artiste,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: _ocre,
                            fontSize: 10,
                            fontWeight: FontWeight.w500)),
                    Row(children: [
                      const Icon(Icons.place_outlined,
                          size: 10, color: _cielNil),
                      const SizedBox(width: 2),
                      Expanded(
                        child: Text('${oeuvre.pays} · ${oeuvre.annee}',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                                color: _cielNil, fontSize: 9)),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── États ─────────────────────────────────────────

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _roseLat.withOpacity(0.1),
              border: Border.all(color: _roseLat.withOpacity(0.25), width: 2),
            ),
            child: const Icon(Icons.favorite_border_rounded,
                color: _roseLat, size: 42),
          ),
          const SizedBox(height: 20),
          const Text('Aucun favori pour l\'instant',
              style: TextStyle(
                  color: _brun,
                  fontSize: 18,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(
            'Appuyez sur ❤️ sur une œuvre\npour la sauvegarder ici',
            textAlign: TextAlign.center,
            style: TextStyle(color: _ocre.withOpacity(0.8), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildNotLoggedIn() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock_outline_rounded,
              size: 56, color: _ocre.withOpacity(0.5)),
          const SizedBox(height: 16),
          const Text('Connectez-vous pour voir vos favoris',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: _brun,
                  fontSize: 16,
                  fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: _roseLat.withOpacity(0.7)),
          const SizedBox(height: 12),
          Text('Erreur : $error',
              textAlign: TextAlign.center,
              style: const TextStyle(color: _ocre, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.72),
        itemCount: 4,
        itemBuilder: (_, __) => AnimatedBuilder(
          animation: _shimmerController,
          builder: (_, __) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment(_shimmer.value - 1, 0),
                end: Alignment(_shimmer.value + 1, 0),
                colors: [_papyrus, _argile.withOpacity(0.3), _papyrus],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────

  Widget _placeholder(OeuvreModel oeuvre) {
    final color = _getCatColor(oeuvre.categorie);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), _papyrus],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
          child: Icon(Icons.art_track, size: 40, color: color.withOpacity(0.6))),
    );
  }

  Color _getCatColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'sculpture':    return _roseLat;
      case 'peinture':     return _violet;
      case 'textile':      return _miel;
      case 'bijoux':       return _or;
      case 'poterie':      return _argile;
      case 'monument':     return _cielNil;
      case 'architecture': return _cielNil;
      case 'instrument':   return _savane;
      default:             return _or;
    }
  }
}

// ── Background painter ────────────────────────────────
class _FavBgPainter extends CustomPainter {
  final double progress;
  _FavBgPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    paint.color = const Color(0xFFD4A89A)
        .withOpacity(0.05 + sin(progress * 2 * pi) * 0.02);
    for (int i = 0; i < 5; i++) {
      canvas.drawCircle(
        Offset(size.width * 0.85, 80 + i * 60.0),
        20 + i * 8.0,
        paint,
      );
    }
    paint.color = const Color(0xFFC4A96A)
        .withOpacity(0.04 + cos(progress * 2 * pi) * 0.015);
    for (int i = 0; i < 4; i++) {
      final path = Path();
      final x = size.width * 0.1;
      final y = size.height * 0.5 + i * 50.0;
      path.moveTo(x, y - 14);
      path.lineTo(x + 14, y);
      path.lineTo(x, y + 14);
      path.lineTo(x - 14, y);
      path.close();
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}