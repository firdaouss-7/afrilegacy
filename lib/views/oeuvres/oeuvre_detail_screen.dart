import 'dart:math';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:afrilegacy/models/oeuvre_model.dart';
import 'package:afrilegacy/services/favori_service.dart';
import 'package:afrilegacy/services/auth_service.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

class OeuvreDetailScreen extends StatefulWidget {
  final OeuvreModel oeuvre;
  final String heroTag;

  const OeuvreDetailScreen({
    super.key,
    required this.oeuvre,
    required this.heroTag,
  });

  @override
  State<OeuvreDetailScreen> createState() => _OeuvreDetailScreenState();
}

class _OeuvreDetailScreenState extends State<OeuvreDetailScreen>
    with TickerProviderStateMixin {
  final _audioPlayer = AudioPlayer();
  PlayerState _playerState = PlayerState.stopped;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  final _favoriService = FavoriService();
  final _authService = AuthService();
  bool _isFavorite = false;
  bool _isFavLoading = true; // état pendant le chargement initial
  bool _isDescExpanded = false;

  late AnimationController _contentController;
  late AnimationController _pulseController;
  late AnimationController _patternController;
  late AnimationController _fabController;

  late Animation<double> _contentOpacity;
  late Animation<Offset> _contentSlide;
  late Animation<double> _pulse;
  late Animation<double> _fabScale;

  static const _sand = Color(0xFFFBF8F3);
  static const _papyrus = Color(0xFFF2EBE0);
  static const _brun = Color(0xFF3D2B1A);
  static const _or = Color(0xFFC4A96A);
  static const _cielNil = Color(0xFF8FAFC0);
  static const _savane = Color(0xFFA8C4A2);
  static const _roseLat = Color(0xFFD4A89A);
  static const _violet = Color(0xFFB8A8CC);
  static const _miel = Color(0xFFE8C87A);
  static const _ocre = Color(0xFF8C7A68);
  static const _argile = Color(0xFFC9B99F);

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _initAudio();
    _loadFavoriStatus();
  }

  void _initAnimations() {
    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _patternController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _contentOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _contentController, curve: Curves.easeIn),
    );
    _contentSlide =
        Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero).animate(
          CurvedAnimation(parent: _contentController, curve: Curves.easeOut),
        );
    _pulse = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    _fabScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.elasticOut),
    );

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) {
        _contentController.forward();
        _fabController.forward();
      }
    });
  }

  void _initAudio() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => _playerState = state);
    });
    _audioPlayer.onDurationChanged.listen((duration) {
      if (mounted) setState(() => _duration = duration);
    });
    _audioPlayer.onPositionChanged.listen((position) {
      if (mounted) setState(() => _position = position);
    });
  }

  Future<void> _toggleAudio() async {
    final url = widget.oeuvre.audioUrl;
    if (url.isEmpty) {
      _showSnack('Aucun audioguide disponible pour cette œuvre.');
      return;
    }
    if (_playerState == PlayerState.playing) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(UrlSource(url));
    }
  }

  Future<void> _loadFavoriStatus() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      if (mounted) setState(() => _isFavLoading = false);
      return;
    }
    final status =
        await _favoriService.isFavori(uid, widget.oeuvre.id);
    if (mounted) setState(() { _isFavorite = status; _isFavLoading = false; });
  }

  Future<void> _toggleFavorite() async {
    final uid = _authService.currentUser?.uid;
    if (uid == null) {
      _showSnack('Connectez-vous pour ajouter aux favoris');
      return;
    }
    final isNow = await _favoriService.toggleFavori(uid, widget.oeuvre.id);
    if (mounted) {
      setState(() => _isFavorite = isNow);
      _showSnack(isNow ? '❤️ Ajouté aux favoris' : 'Retiré des favoris');
    }
  }

  void _launch3D() {
    if (!widget.oeuvre.has3D) {
      _showSnack('Modèle 3D non disponible pour cette œuvre.');
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _Model3DScreen(
          oeuvre: widget.oeuvre,
        ),
      ),
    );
  }

  void _launchAR() {
    if (!widget.oeuvre.has3D) {
      _showSnack('Modèle 3D non disponible pour cette œuvre.');
      return;
    }
    _showSnack('Ouverture de la réalité augmentée...');
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: _papyrus)),
        backgroundColor: _brun,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _contentController.dispose();
    _pulseController.dispose();
    _patternController.dispose();
    _fabController.dispose();
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
              painter: _DetailBgPainter(progress: _patternController.value),
            ),
          ),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(context),
              SliverToBoxAdapter(child: _buildBody()),
            ],
          ),
          _buildFavoriteFab(),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context) {
    final oeuvre = widget.oeuvre;

    return SliverAppBar(
      expandedHeight: 360,
      pinned: true,
      backgroundColor: _brun,
      leading: GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black26,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.arrow_back_ios_new,
            color: Colors.white,
            size: 18,
          ),
        ),
      ),
      actions: const [],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            Hero(
              tag: widget.heroTag,
              child: oeuvre.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: oeuvre.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => _buildImagePlaceholder(),
                      errorWidget: (context, url, error) =>
                          _buildImagePlaceholder(),
                    )
                  : _buildImagePlaceholder(),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, _brun.withValues(alpha: 0.95)],
                  stops: const [0.45, 1.0],
                ),
              ),
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    oeuvre.titre,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${oeuvre.artiste} · ${oeuvre.pays}',
                    style: TextStyle(
                      color: _papyrus.withValues(alpha: 0.8),
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 24,
              right: 20,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: _or.withValues(alpha: 0.9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  oeuvre.annee,
                  style: const TextStyle(
                    color: _brun,
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    return AnimatedBuilder(
      animation: _contentController,
      builder: (context, child) => Opacity(
        opacity: _contentOpacity.value,
        child: SlideTransition(position: _contentSlide, child: child),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),
          _buildInfoRow(),
          const SizedBox(height: 20),
          _buildActionButtons(),
          const SizedBox(height: 24),
          if (widget.oeuvre.audioUrl.isNotEmpty) ...[
            _buildAudioPlayer(),
            const SizedBox(height: 24),
          ],
          _buildDescriptionSection(),
          const SizedBox(height: 24),
          _buildMuseeSection(),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildInfoRow() {
    final oeuvre = widget.oeuvre;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          _buildInfoChip(
            icon: Icons.category_outlined,
            label: oeuvre.categorie,
            color: _getCatColor(oeuvre.categorie),
          ),
          const SizedBox(width: 8),
          _buildInfoChip(
            icon: Icons.public_outlined,
            label: oeuvre.pays,
            color: _cielNil,
          ),
          const SizedBox(width: 8),
          _buildInfoChip(
            icon: Icons.calendar_today_outlined,
            label: oeuvre.annee,
            color: _or,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    final isPlaying = _playerState == PlayerState.playing;
    final buttonColor = _cielNil; // Même couleur pour tous

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Bouton Audioguide
          Expanded(
            child: _buildActionBtn(
              icon: isPlaying ? Icons.pause_rounded : Icons.headphones_rounded,
              label: isPlaying ? 'Pause' : 'Audioguide',
              color: buttonColor,
              onTap: _toggleAudio,
            ),
          ),
          const SizedBox(width: 12),
          // Bouton Modèle 3D
          Expanded(
            child: _buildActionBtn(
              icon: Icons.view_in_ar_rounded,
              label: 'Modèle 3D',
              color: buttonColor,
              onTap: _launch3D,
            ),
          ),
          const SizedBox(width: 12),
          // Bouton Réalité AR
          Expanded(
            child: _buildActionBtn(
              icon: Icons.camera_alt_rounded,
              label: 'Réalité AR',
              color: buttonColor,
              onTap: _launchAR,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionBtn({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52,
        decoration: BoxDecoration(
          color: color, // Même couleur pour tous
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAudioPlayer() {
    final progress = _duration.inSeconds > 0
        ? _position.inSeconds / _duration.inSeconds
        : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: _brun,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: _brun.withValues(alpha: 0.25),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                AnimatedBuilder(
                  animation: _pulseController,
                  builder: (context, child) => Transform.scale(
                    scale: _playerState == PlayerState.playing
                        ? _pulse.value
                        : 1.0,
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _or.withValues(alpha: 0.15),
                        border: Border.all(color: _or.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(
                        Icons.music_note_rounded,
                        color: _or,
                        size: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Audioguide',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        widget.oeuvre.titre,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: _papyrus.withValues(alpha: 0.6),
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: _toggleAudio,
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (context, child) => Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [_or, _miel],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _or.withValues(
                              alpha: _playerState == PlayerState.playing
                                  ? 0.5 * _pulse.value
                                  : 0.3,
                            ),
                            blurRadius: 12,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: Icon(
                        _playerState == PlayerState.playing
                            ? Icons.pause_rounded
                            : Icons.play_arrow_rounded,
                        color: _brun,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Column(
              children: [
                SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 3,
                    thumbShape: const RoundSliderThumbShape(
                      enabledThumbRadius: 6,
                    ),
                    overlayShape: const RoundSliderOverlayShape(
                      overlayRadius: 14,
                    ),
                    activeTrackColor: _or,
                    inactiveTrackColor: Colors.white12,
                    thumbColor: _miel,
                    overlayColor: _or.withValues(alpha: 0.2),
                  ),
                  child: Slider(
                    value: progress.clamp(0.0, 1.0),
                    onChanged: (value) async {
                      final position = Duration(
                        seconds: (value * _duration.inSeconds).round(),
                      );
                      await _audioPlayer.seek(position);
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDuration(_position),
                        style: TextStyle(
                          color: _papyrus.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                      Text(
                        _formatDuration(_duration),
                        style: TextStyle(
                          color: _papyrus.withValues(alpha: 0.5),
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDescriptionSection() {
    final description = widget.oeuvre.description;
    final isLong = description.length > 200;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('À propos', Icons.article_outlined),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _papyrus,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _argile.withValues(alpha: 0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isLong && !_isDescExpanded
                      ? '${description.substring(0, 200)}…'
                      : description,
                  style: const TextStyle(
                    color: _brun,
                    fontSize: 14,
                    height: 1.7,
                  ),
                ),
                if (isLong) ...[
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: () =>
                        setState(() => _isDescExpanded = !_isDescExpanded),
                    child: Text(
                      _isDescExpanded ? 'Voir moins' : 'Lire la suite',
                      style: const TextStyle(
                        color: _or,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMuseeSection() {
    final oeuvre = widget.oeuvre;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Musée', Icons.museum_outlined),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: _papyrus,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: _argile.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: _cielNil.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _cielNil.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(
                    Icons.account_balance_outlined,
                    color: _cielNil,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        oeuvre.museeActuel.isNotEmpty
                            ? oeuvre.museeActuel
                            : 'Non renseigné',
                        style: const TextStyle(
                          color: _brun,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(
                            Icons.place_outlined,
                            size: 13,
                            color: _cielNil,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            oeuvre.paysActuel.isNotEmpty
                                ? oeuvre.paysActuel
                                : 'Pays inconnu',
                            style: const TextStyle(color: _ocre, fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteFab() {
    return Positioned(
      bottom: 30,
      right: 24,
      child: ScaleTransition(
        scale: _fabScale,
        child: GestureDetector(
          onTap: _isFavLoading ? null : _toggleFavorite,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) => Container(
              width: 58,
              height: 58,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isFavorite ? _roseLat : Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: (_isFavorite ? _roseLat : _argile).withValues(
                      alpha: _isFavorite ? 0.4 * _pulse.value : 0.3,
                    ),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: _isFavLoading
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: _roseLat,
                      ),
                    )
                  : Icon(
                      _isFavorite
                          ? Icons.favorite_rounded
                          : Icons.favorite_border_rounded,
                      color: _isFavorite ? Colors.white : _roseLat,
                      size: 26,
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 20,
          decoration: BoxDecoration(
            color: _or,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Icon(icon, size: 16, color: _or),
        const SizedBox(width: 6),
        Text(
          title,
          style: const TextStyle(
            color: _brun,
            fontSize: 16,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  Widget _buildImagePlaceholder() {
    final color = _getCatColor(widget.oeuvre.categorie);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withValues(alpha: 0.4), _papyrus],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 72,
          color: color.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  Color _getCatColor(String category) {
    switch (category.toLowerCase()) {
      case 'sculpture':
        return _roseLat;
      case 'peinture':
        return _violet;
      case 'textile':
        return _miel;
      case 'architecture':
        return _cielNil;
      case 'musique':
        return _savane;
      default:
        return _or;
    }
  }
}

class _DetailBgPainter extends CustomPainter {
  final double progress;
  _DetailBgPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    paint.color = const Color(
      0xFFC4A96A,
    ).withValues(alpha: 0.04 + sin(progress * 2 * pi) * 0.02);
    for (int i = 0; i < 4; i++) {
      final path = Path();
      final x = size.width * 0.92;
      final y = size.height * 0.45 + i * 36.0;
      path.moveTo(x, y);
      path.lineTo(x + 18, y + 18);
      path.lineTo(x - 18, y + 18);
      path.close();
      canvas.drawPath(path, paint);
    }
    paint.color = const Color(
      0xFF8FAFC0,
    ).withValues(alpha: 0.04 + cos(progress * 2 * pi) * 0.02);
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final x = size.width * 0.06;
      final y = size.height * 0.55 + i * 40.0;
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

// ══════════════════════════════════════════════════════
//  PAGE VIEWER 3D
// ══════════════════════════════════════════════════════
class _Model3DScreen extends StatelessWidget {
  final OeuvreModel oeuvre;
  const _Model3DScreen({required this.oeuvre});

  static const _brun    = Color(0xFF3D2B1A);
  static const _or      = Color(0xFFC4A96A);
  static const _papyrus = Color(0xFFF2EBE0);
  static const _sand    = Color(0xFFFBF8F3);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _sand,
      appBar: AppBar(
        backgroundColor: _brun,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_ios_new,
                color: Colors.white, size: 16),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(oeuvre.titre,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w800)),
            const Text('Modèle 3D interactif',
                style: TextStyle(color: _or, fontSize: 11)),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 14),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: _or.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _or.withOpacity(0.3)),
            ),
            child: const Row(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.threed_rotation, color: _or, size: 14),
              SizedBox(width: 4),
              Text('3D', style: TextStyle(
                  color: _or, fontSize: 11, fontWeight: FontWeight.w800)),
            ]),
          ),
        ],
      ),
      body: Column(
        children: [
          // Viewer 3D
          Expanded(
            child: ModelViewer(
              src: oeuvre.model3dUrl,
              alt: oeuvre.titre,
              ar: true,                    // Active la RA si disponible
              autoRotate: true,
              autoRotateDelay: 500,
              rotationPerSecond: '20deg',
              cameraControls: true,
              shadowIntensity: 1,
              backgroundColor: const Color(0xFFFBF8F3),
            ),
          ),
          // Barre d'infos en bas
          Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [BoxShadow(
                  color: _brun.withOpacity(0.07),
                  blurRadius: 16,
                  offset: const Offset(0, -4))],
            ),
            child: Row(children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _or.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.view_in_ar_rounded,
                    color: _or, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(oeuvre.titre,
                        style: const TextStyle(
                            color: _brun,
                            fontSize: 13,
                            fontWeight: FontWeight.w800)),
                    Text('${oeuvre.artiste} · ${oeuvre.pays}',
                        style: const TextStyle(
                            color: Color(0xFF8C7A68), fontSize: 11)),
                  ],
                ),
              ),
              // Hint pinch/rotate
              Column(
                children: [
                  Icon(Icons.swipe, color: _or.withOpacity(0.6), size: 18),
                  Text('Tourner',
                      style: TextStyle(
                          color: _or.withOpacity(0.6),
                          fontSize: 9,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ]),
          ),
        ],
      ),
    );
  }
}