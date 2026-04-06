import 'dart:math';
import 'package:flutter/material.dart';
import 'package:afrilegacy/models/oeuvre_model.dart';
import 'package:afrilegacy/views/oeuvres/oeuvre_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:afrilegacy/services/oeuvre_service.dart';
import 'package:afrilegacy/services/auth_service.dart';
import 'package:afrilegacy/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afrilegacy/views/profile/profile_screen.dart';
import 'package:afrilegacy/services/favori_service.dart';
import 'package:afrilegacy/views/favoris/favoris_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final _oeuvreService = OeuvreService();
  final _authService = AuthService();
  final _favoriService = FavoriService();

  Set<String> _favoriIds = {};

  List<OeuvreModel> _allOeuvres = [];
  List<OeuvreModel> _filtered = [];
  List<OeuvreModel> _featured = [];
  String _selectedCategorie = 'Tout';
  List<String> _categories = ['Tout'];
  bool _isLoading = true;
  String _searchQuery = '';
  UserModel? _currentUser;

  final _searchController = TextEditingController();
  late AnimationController _headerController;
  late AnimationController _listController;
  late AnimationController _patternController;
  late AnimationController _shimmerController;
  late AnimationController _featuredController;

  late Animation<double> _headerOpacity;
  late Animation<Offset> _headerSlide;
  late Animation<double> _shimmer;
  late Animation<double> _featuredScale;

  int _selectedTab = 0;

  static const _sand    = Color(0xFFFBF8F3);
  static const _papyrus = Color(0xFFF2EBE0);
  static const _brun    = Color(0xFF3D2B1A);
  static const _or      = Color(0xFFC4A96A);
  static const _cielNil = Color(0xFF8FAFC0);
  static const _savane  = Color(0xFFA8C4A2);
  static const _roseLat = Color(0xFFD4A89A);
  static const _violet  = Color(0xFFB8A8CC);
  static const _miel    = Color(0xFFE8C87A);
  static const _ocre    = Color(0xFF8C7A68);
  static const _argile  = Color(0xFFC9B99F);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadData();
    _loadUser();
    _listenFavoris();
  }

  void _initAnimations() {
    _headerController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 900));
    _listController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 600));
    _patternController = AnimationController(
      vsync: this, duration: const Duration(seconds: 20))..repeat();
    _shimmerController = AnimationController(
      vsync: this, duration: const Duration(seconds: 2))..repeat();
    _featuredController = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 800));

    _headerOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _headerController, curve: Curves.easeIn));
    _headerSlide = Tween<Offset>(
            begin: const Offset(0, -0.2), end: Offset.zero)
        .animate(CurvedAnimation(parent: _headerController, curve: Curves.easeOut));
    _shimmer = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear));
    _featuredScale = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _featuredController, curve: Curves.elasticOut));
  }

Future<void> _loadData() async {
  try {
    final oeuvres = await _oeuvreService.getAllOeuvres();
    print('[DEBUG] Œuvres: ${oeuvres.length}'); // ← ajoute
    final cats = await _oeuvreService.getCategories();
    if (!mounted) return;
    setState(() {
      _allOeuvres = oeuvres;
      _filtered   = oeuvres;
      _featured   = oeuvres.where((o) => o.isFeatured).toList();
      _categories = ['Tout', ...cats];
      _isLoading  = false;
    });
    _headerController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    _listController.forward();
    _featuredController.forward();
  } catch (e, stack) {
    print('[DEBUG] Erreur: $e'); // ← ajoute
    print('[DEBUG] Stack: $stack'); // ← ajoute
    if (!mounted) return;
    setState(() => _isLoading = false);
  }
}

  Future<void> _loadUser() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    final doc = await FirebaseFirestore.instance
        .collection('users').doc(uid).get();
    if (!mounted) return;
    if (doc.exists) setState(() => _currentUser = UserModel.fromFirestore(doc));
  }

  void _listenFavoris() {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    _favoriService.getFavoriIdsStream(uid).listen((ids) {
      if (mounted) setState(() => _favoriIds = ids.toSet());
    });
  }

  Future<void> _toggleFavori(OeuvreModel oeuvre) async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) return;
    final isNowFavori = await _favoriService.toggleFavori(uid, oeuvre.id);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
          isNowFavori ? '❤️ Ajouté aux favoris' : 'Retiré des favoris',
          style: const TextStyle(color: Color(0xFFF2EBE0)),
        ),
        backgroundColor: const Color(0xFF3D2B1A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        duration: const Duration(seconds: 2),
      ));
    }
  }

  void _applyFilters() {
    setState(() {
      _filtered = _allOeuvres.where((o) {
        final matchCat = _selectedCategorie == 'Tout' ||
            o.categorie == _selectedCategorie;
        final matchSearch = _searchQuery.isEmpty ||
            o.titre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            o.artiste.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            o.pays.toLowerCase().contains(_searchQuery.toLowerCase());
        return matchCat && matchSearch;
      }).toList();
    });
  }

  void _navigateToDetail(OeuvreModel oeuvre) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            OeuvreDetailScreen(oeuvre: oeuvre, heroTag: 'oeuvre_${oeuvre.id}'),
        transitionsBuilder: (context, animation, secondaryAnimation, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _headerController.dispose();
    _listController.dispose();
    _patternController.dispose();
    _shimmerController.dispose();
    _featuredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _sand,
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _patternController,
            builder: (context, child) => CustomPaint(
              size: MediaQuery.of(context).size,
              painter: _HomeBgPainter(progress: _patternController.value),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSearchBar(),
                _buildCategoryChips(),
                Expanded(child: _buildBody()),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  // ─── Header ───────────────────────────────────────
  Widget _buildHeader() {
    final greeting = _getGreeting();
    final nom = _currentUser?.nom ?? '';

    return AnimatedBuilder(
      animation: _headerController,
      builder: (context, child) => Opacity(
        opacity: _headerOpacity.value,
        child: SlideTransition(position: _headerSlide, child: child),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(greeting,
                    style: const TextStyle(color: _ocre, fontSize: 13,
                        fontWeight: FontWeight.w500, letterSpacing: 0.5)),
                  const SizedBox(height: 2),
                  AnimatedBuilder(
                    animation: _shimmerController,
                    builder: (_, __) => ShaderMask(
                      shaderCallback: (bounds) => LinearGradient(
                        begin: Alignment(_shimmer.value - 1, 0),
                        end: Alignment(_shimmer.value + 1, 0),
                        colors: const [_brun, _or, _miel, _or, _brun],
                        stops: const [0.0, 0.35, 0.5, 0.65, 1.0],
                      ).createShader(bounds),
                      child: Text(
                        nom.isNotEmpty ? 'Bienvenue, $nom' : 'AfriLegacy',
                        style: const TextStyle(fontSize: 22,
                            fontWeight: FontWeight.w900, color: Colors.white,
                            letterSpacing: 0.3)),
                    ),
                  ),
                  const SizedBox(height: 2),
                  const Text('Explorez le patrimoine africain',
                    style: TextStyle(color: _ocre, fontSize: 12)),
                ],
              ),
            ),
            _buildAvatarButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarButton() {
    final initials = _currentUser?.nom.isNotEmpty == true
        ? _currentUser!.nom[0].toUpperCase()
        : 'A';
    return GestureDetector(
      onTap: () => Navigator.push(context,
          MaterialPageRoute(builder: (_) => const ProfileScreen())),
      child: Container(
        width: 46, height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
              colors: [_or, _miel],
              begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(
              color: _or.withOpacity(0.35), blurRadius: 12,
              offset: const Offset(0, 4))]),
        child: Center(child: Text(initials,
          style: const TextStyle(color: _brun, fontWeight: FontWeight.w800,
              fontSize: 18))),
      ),
    );
  }

  // ─── Search ───────────────────────────────────────
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: AnimatedBuilder(
        animation: _headerController,
        builder: (context, child) =>
            Opacity(opacity: _headerOpacity.value, child: child),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: _papyrus,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: _argile.withOpacity(0.4), width: 1),
            boxShadow: [BoxShadow(
                color: _brun.withOpacity(0.06), blurRadius: 12,
                offset: const Offset(0, 4))]),
          child: TextField(
            controller: _searchController,
            onChanged: (value) { _searchQuery = value; _applyFilters(); },
            style: const TextStyle(color: _brun, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Chercher une œuvre, un artiste, un pays',
              hintStyle: TextStyle(color: _ocre.withOpacity(0.5), fontSize: 13),
              prefixIcon: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _or.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.search_rounded, color: _or, size: 18)),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close_rounded, color: _ocre, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _searchQuery = '';
                        _applyFilters();
                      })
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            ),
          ),
        ),
      ),
    );
  }

  // ─── Category chips ───────────────────────────────
  Widget _buildCategoryChips() {
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: SizedBox(
        height: 36,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _categories.length,
          itemBuilder: (context, index) {
            final cat = _categories[index];
            final selected = cat == _selectedCategorie;
            return GestureDetector(
              onTap: () { setState(() => _selectedCategorie = cat); _applyFilters(); },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: selected ? _brun : _papyrus,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: selected ? _brun : _argile.withOpacity(0.5), width: 1),
                  boxShadow: selected
                      ? [BoxShadow(color: _brun.withOpacity(0.25),
                          blurRadius: 8, offset: const Offset(0, 3))]
                      : []),
                child: Text(cat,
                  style: TextStyle(
                    color: selected ? _papyrus : _ocre, fontSize: 12,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    letterSpacing: 0.3)),
              ),
            );
          },
        ),
      ),
    );
  }

  // ─── Body ─────────────────────────────────────────
  Widget _buildBody() {
    if (_isLoading) return _buildSkeleton();
    if (_filtered.isEmpty) return _buildEmpty();

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        if (_featured.isNotEmpty &&
            _selectedCategorie == 'Tout' &&
            _searchQuery.isEmpty)
          SliverToBoxAdapter(child: _buildFeaturedSection()),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Toutes les œuvres',
                  style: TextStyle(color: _brun, fontSize: 16,
                      fontWeight: FontWeight.w800)),
                Text('${_filtered.length} œuvre${_filtered.length > 1 ? 's' : ''}',
                  style: const TextStyle(color: _ocre, fontSize: 12)),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, mainAxisSpacing: 14,
              crossAxisSpacing: 14, childAspectRatio: 0.72),
            delegate: SliverChildBuilderDelegate(
              (context, index) => _buildOeuvreCard(_filtered[index], index),
              childCount: _filtered.length),
          ),
        ),
      ],
    );
  }

  // ─── Featured ─────────────────────────────────────
  Widget _buildFeaturedSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          child: Row(children: [
            Container(width: 4, height: 18,
              decoration: BoxDecoration(
                color: _or, borderRadius: BorderRadius.circular(2))),
            const SizedBox(width: 8),
            const Text('À la une',
              style: TextStyle(color: _brun, fontSize: 16,
                  fontWeight: FontWeight.w800)),
          ]),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: _featured.length,
            itemBuilder: (context, index) {
              final oeuvre = _featured[index];
              return GestureDetector(
                onTap: () => _navigateToDetail(oeuvre),
                child: ScaleTransition(
                  scale: _featuredScale,
                  child: _buildFeaturedCard(oeuvre)),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFeaturedCard(OeuvreModel oeuvre) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(
            color: _brun.withOpacity(0.12), blurRadius: 16,
            offset: const Offset(0, 6))]),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(fit: StackFit.expand, children: [
          oeuvre.imageUrl.isNotEmpty
              ? Image.network(oeuvre.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _buildPlaceholder(oeuvre))
              : _buildPlaceholder(oeuvre),
          Container(decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Colors.transparent, _brun.withOpacity(0.85)],
              stops: const [0.4, 1.0]))),
          Positioned(bottom: 14, left: 14, right: 14,
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(oeuvre.titre, maxLines: 2, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Colors.white, fontSize: 15,
                    fontWeight: FontWeight.w800)),
              const SizedBox(height: 4),
              Text('${oeuvre.artiste} · ${oeuvre.pays}',
                style: TextStyle(color: _papyrus.withOpacity(0.75), fontSize: 11)),
            ])),
        ]),
      ),
    );
  }

  // ─── Oeuvre card ──────────────────────────────────
  Widget _buildOeuvreCard(OeuvreModel oeuvre, int index) {
    final catColor = _getCatColor(oeuvre.categorie);
    return AnimatedBuilder(
      animation: _listController,
      builder: (context, child) {
        final delay = (index * 0.06).clamp(0.0, 0.9);
        final progress =
            ((_listController.value - delay) / (1 - delay)).clamp(0.0, 1.0);
        return Opacity(
          opacity: progress,
          child: Transform.translate(
              offset: Offset(0, 30 * (1 - progress)), child: child));
      },
      child: GestureDetector(
        onTap: () => _navigateToDetail(oeuvre),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(
                color: _brun.withOpacity(0.08), blurRadius: 14,
                offset: const Offset(0, 5))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              flex: 6,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                child: Stack(fit: StackFit.expand, children: [
                  Hero(
                    tag: 'oeuvre_${oeuvre.id}',
                    child: oeuvre.imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: oeuvre.imageUrl, fit: BoxFit.cover,
                            placeholder: (_, __) => _buildPlaceholder(oeuvre),
                            errorWidget: (_, __, ___) => _buildPlaceholder(oeuvre))
                        : _buildPlaceholder(oeuvre),
                  ),
                  Positioned(top: 8, right: 8,
                    child: GestureDetector(
                      onTap: () => _toggleFavori(oeuvre),
                      child: Container(width: 30, height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle),
                        child: Icon(
                          _favoriIds.contains(oeuvre.id)
                              ? Icons.favorite_rounded
                              : Icons.favorite_border_rounded,
                          color: _roseLat, size: 16)))),
                ]),
              ),
            ),
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: catColor.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(8)),
                      child: Text(oeuvre.categorie,
                        style: TextStyle(color: catColor, fontSize: 9,
                            fontWeight: FontWeight.w700, letterSpacing: 0.3))),
                    const SizedBox(height: 4),
                    Text(oeuvre.titre, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _brun, fontSize: 12,
                          fontWeight: FontWeight.w800, height: 1.3)),
                    Text(oeuvre.artiste, maxLines: 1, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: _ocre, fontSize: 10,
                          fontWeight: FontWeight.w500)),
                    Row(children: [
                      const Icon(Icons.place_outlined, size: 10, color: _cielNil),
                      const SizedBox(width: 2),
                      Expanded(child: Text('${oeuvre.pays} · ${oeuvre.annee}',
                        maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: _cielNil, fontSize: 9))),
                    ]),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  // ─── Placeholder ──────────────────────────────────
  Widget _buildPlaceholder(OeuvreModel oeuvre) {
    final color = _getCatColor(oeuvre.categorie);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.3), _papyrus],
          begin: Alignment.topLeft, end: Alignment.bottomRight)),
      child: Center(child: Icon(Icons.art_track, size: 40,
          color: color.withOpacity(0.6))));
  }

  // ─── Skeleton ─────────────────────────────────────
  Widget _buildSkeleton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, mainAxisSpacing: 14,
          crossAxisSpacing: 14, childAspectRatio: 0.72),
        itemCount: 6,
        itemBuilder: (context, index) => AnimatedBuilder(
          animation: _shimmerController,
          builder: (context, child) => Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: LinearGradient(
                begin: Alignment(_shimmer.value - 1, 0),
                end: Alignment(_shimmer.value + 1, 0),
                colors: [_papyrus, _argile.withOpacity(0.3), _papyrus]))),
        ),
      ),
    );
  }

  // ─── Empty ────────────────────────────────────────
  Widget _buildEmpty() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.search_off, size: 56, color: _ocre),
        const SizedBox(height: 16),
        const Text('Aucune œuvre trouvée',
          style: TextStyle(color: _brun, fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        const Text('Essayez un autre terme ou une autre catégorie',
          textAlign: TextAlign.center,
          style: TextStyle(color: _ocre, fontSize: 14)),
      ]),
    );
  }

  // ─── Bottom Nav ───────────────────────────────────
  Widget _buildBottomNav() {
    final items = [
      _NavItem(icon: Icons.home_rounded,     label: 'Accueil'),
      _NavItem(icon: Icons.search_rounded,   label: 'Explorer'),
      _NavItem(icon: Icons.favorite_rounded, label: 'Favoris'),
      _NavItem(icon: Icons.person_rounded,   label: 'Profil'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [BoxShadow(
            color: _brun.withOpacity(0.08), blurRadius: 20,
            offset: const Offset(0, -4))]),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(items.length, (index) {
              final selected = _selectedTab == index;
              return GestureDetector(
                // ✅ Onglet Profil (index 3) et Favoris (index 2) → navigation
                onTap: () {
                  if (index == 3) {
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const ProfileScreen()));
                  } else if (index == 2) {
                    Navigator.push(context,
                        MaterialPageRoute(
                            builder: (_) => const FavorisScreen()));
                  } else {
                    setState(() => _selectedTab = index);
                  }
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? _brun : Colors.transparent,
                    borderRadius: BorderRadius.circular(16)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(items[index].icon,
                        color: selected ? _papyrus : _argile, size: 22),
                    if (selected) ...[
                      const SizedBox(width: 6),
                      Text(items[index].label,
                        style: const TextStyle(color: _papyrus,
                            fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ]),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }

  // ─── Helpers ──────────────────────────────────────
  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Bonjour';
    if (hour < 18) return 'Bon après-midi';
    return 'Bonsoir';
  }

  Color _getCatColor(String cat) {
    switch (cat.toLowerCase()) {
      case 'sculpture':   return _roseLat;
      case 'peinture':    return _violet;
      case 'textile':     return _miel;
      case 'bijoux':      return _or;
      case 'poterie':     return _argile;
      case 'monument':    return _cielNil;
      case 'architecture':return _cielNil;
      case 'musique':     return _savane;
      default:            return _or;
    }
  }
}

// ════════════════════════════════════════════════════
//  HELPERS
// ════════════════════════════════════════════════════
class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}

class _HomeBgPainter extends CustomPainter {
  final double progress;
  _HomeBgPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.stroke..strokeWidth = 1;

    paint.color =
        const Color(0xFFC4A96A).withOpacity(0.04 + sin(progress * 2 * pi) * 0.015);
    for (int i = 0; i < 5; i++) {
      final path = Path();
      final x = size.width * 0.9;
      final y = 60.0 + i * 34;
      path.moveTo(x, y);
      path.lineTo(x + 20, y + 20);
      path.lineTo(x - 20, y + 20);
      path.close();
      canvas.drawPath(path, paint);
    }

    paint.color =
        const Color(0xFF8FAFC0).withOpacity(0.04 + cos(progress * 2 * pi) * 0.015);
    for (int i = 0; i < 4; i++) {
      final path = Path();
      final x = size.width * 0.08;
      final y = size.height * 0.6 + i * 38.0;
      path.moveTo(x, y - 16);
      path.lineTo(x + 16, y);
      path.lineTo(x, y + 16);
      path.lineTo(x - 16, y);
      path.close();
      canvas.drawPath(path, paint);
    }

    paint.color = const Color(0xFFA8C4A2).withOpacity(0.05);
    canvas.drawCircle(Offset(size.width * 0.85, size.height * 0.7),
        60 + 10 * sin(progress * 2 * pi), paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.3),
        40 + 8 * cos(progress * 2 * pi), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter old) => true;
}