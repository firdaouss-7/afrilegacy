import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afrilegacy/views/admin/afri_theme.dart';

class AdminStats extends StatefulWidget {
  const AdminStats({super.key});
  @override
  State<AdminStats> createState() => _AdminStatsState();
}

class _AdminStatsState extends State<AdminStats> with TickerProviderStateMixin {
  late AnimationController _anim;

  int _totalOeuvres = 0, _totalUsers = 0, _totalFavs = 0;
  int _arCount = 0, _audioCount = 0;
  Map<String, int> _catCounts = {};
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _load();
  }

  Future<void> _load() async {
    final o = await FirebaseFirestore.instance.collection('oeuvres').get();
    final u = await FirebaseFirestore.instance.collection('users').get();

    // Compter les favoris depuis favoris/{userId}/oeuvres
    int favs = 0;
    for (final userDoc in u.docs) {
      final favSnap = await FirebaseFirestore.instance
          .collection('favoris')
          .doc(userDoc.id)
          .collection('oeuvres')
          .get();
      favs += favSnap.size;
    }

    int ar = 0, audio = 0;
    final cats = <String, int>{};
    for (final d in o.docs) {
      final m = d.data();
      if (m['estAR'] == true) ar++;
      if ((m['audioUrl'] ?? '').toString().isNotEmpty) audio++;
      final cat = m['categorie'] ?? 'Autre';
      cats[cat] = (cats[cat] ?? 0) + 1;
    }
    if (!mounted) return;
    setState(() {
      _totalOeuvres = o.size;
      _totalUsers = u.size;
      _totalFavs = favs;
      _arCount = ar;
      _audioCount = audio;
      _catCounts = cats;
      _loading = false;
    });
    _anim.forward();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Afri.bg,
    body: CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        AfriSliverHeader(
          title: 'Statistiques',
          subtitle: 'Vue globale AfriLegacy',
          badge: 'ANALYTICS',
          expandedHeight: 130,
        ),
        SliverToBoxAdapter(
          child: _loading
              ? const SizedBox(
                  height: 300,
                  child: Center(
                    child: CircularProgressIndicator(color: Afri.gold),
                  ),
                )
              : FadeTransition(
                  opacity: _anim,
                  child: SlideTransition(
                    position:
                        Tween<Offset>(
                          begin: const Offset(0, 0.06),
                          end: Offset.zero,
                        ).animate(
                          CurvedAnimation(parent: _anim, curve: Curves.easeOut),
                        ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 100),
                      child: Column(
                        children: [
                          _buildTopGrid(),
                          const SizedBox(height: 20),
                          _buildCategoryChart(),
                          const SizedBox(height: 20),
                          _buildFeatures(),
                          const SizedBox(height: 20),
                          _buildFunFacts(),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    ),
  );

  Widget _buildTopGrid() {
    final items = [
      (emoji: '🖼️', val: _totalOeuvres, lbl: 'Œuvres', color: Afri.gold),
      (emoji: '👥', val: _totalUsers, lbl: 'Membres', color: Afri.nil),
    ];
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: items.asMap().entries.map((e) {
        final it = e.value;
        return AfriStatCard(
          emoji: it.emoji,
          value: it.val,
          label: it.lbl,
          delta: '',
          color: it.color,
        );
      }).toList(),
    );
  }

  Widget _buildCategoryChart() {
    if (_catCounts.isEmpty) return const SizedBox();
    final total = _catCounts.values.fold(0, (a, b) => a + b);
    final sorted = _catCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    const colors = [
      Afri.gold,
      Afri.nil,
      Afri.savane,
      Afri.laterite,
      Afri.kente,
      Afri.honey,
    ];

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Afri.sand.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Par catégorie',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Afri.dark,
            ),
          ),
          const SizedBox(height: 16),
          ...sorted.asMap().entries.map((e) {
            final cat = e.value.key;
            final count = e.value.value;
            final pct = total > 0 ? count / total : 0.0;
            final color = colors[e.key % colors.length];
            return Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: color,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          cat,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Afri.dark,
                          ),
                        ),
                      ),
                      Text(
                        '$count  ·  ${(pct * 100).toStringAsFixed(0)}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  TweenAnimationBuilder<double>(
                    duration: Duration(milliseconds: 900 + e.key * 100),
                    curve: Curves.easeOutCubic,
                    tween: Tween(begin: 0, end: pct),
                    builder: (_, v, __) => ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: v,
                        minHeight: 8,
                        backgroundColor: Afri.bg2,
                        valueColor: AlwaysStoppedAnimation<Color>(color),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    final arPct = _totalOeuvres > 0 ? _arCount / _totalOeuvres : 0.0;
    final audioPct = _totalOeuvres > 0 ? _audioCount / _totalOeuvres : 0.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Afri.sand.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fonctionnalités avancées',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Afri.dark,
            ),
          ),
          const SizedBox(height: 16),
          _FeatureRow(
            icon: Icons.view_in_ar_rounded,
            color: Afri.kente,
            label: 'Réalité Augmentée',
            count: _arCount,
            total: _totalOeuvres,
            pct: arPct,
          ),
          const SizedBox(height: 14),
          _FeatureRow(
            icon: Icons.headphones_outlined,
            color: Afri.nil,
            label: 'Audio Guide',
            count: _audioCount,
            total: _totalOeuvres,
            pct: audioPct,
          ),
        ],
      ),
    );
  }

  Widget _buildFunFacts() => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: Afri.bg2,
      borderRadius: BorderRadius.circular(22),
      border: Border.all(color: Afri.sand.withOpacity(0.5)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 3,
              height: 16,
              decoration: BoxDecoration(
                color: Afri.gold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'Le saviez-vous ?',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Afri.dark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        _Fact(
          icon: '🌍',
          text: '54 pays africains représentés dans le patrimoine mondial',
        ),
        const SizedBox(height: 8),
        _Fact(
          icon: '🏺',
          text: 'Plus de 5 000 ans d\'histoire culturelle africaine documentée',
        ),
        const SizedBox(height: 8),
        _Fact(
          icon: '✨',
          text:
              'L\'art africain a inspiré le cubisme et l\'art moderne occidental',
        ),
      ],
    ),
  );
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final int count, total;
  final double pct;
  const _FeatureRow({
    required this.icon,
    required this.color,
    required this.label,
    required this.count,
    required this.total,
    required this.pct,
  });
  @override
  Widget build(BuildContext context) => Row(
    children: [
      Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 18),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Afri.dark,
                  ),
                ),
                Text(
                  '$count / $total',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 1000),
              curve: Curves.easeOutCubic,
              tween: Tween(begin: 0, end: pct),
              builder: (_, v, __) => ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: LinearProgressIndicator(
                  value: v,
                  minHeight: 7,
                  backgroundColor: Afri.bg2,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
          ],
        ),
      ),
    ],
  );
}

class _Fact extends StatelessWidget {
  final String icon, text;
  const _Fact({required this.icon, required this.text});
  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(icon, style: const TextStyle(fontSize: 16)),
      const SizedBox(width: 10),
      Expanded(
        child: Text(
          text,
          style: const TextStyle(fontSize: 12, color: Afri.ocre, height: 1.4),
        ),
      ),
    ],
  );
}
