import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // inclut Timestamp
import 'package:afrilegacy/views/admin/afri_theme.dart';
import 'package:afrilegacy/views/admin/admin_oeuvre_form.dart';

class AdminOeuvres extends StatefulWidget {
  const AdminOeuvres({super.key});
  @override
  State<AdminOeuvres> createState() => _AdminOeuvresState();
}

class _AdminOeuvresState extends State<AdminOeuvres>
    with TickerProviderStateMixin {
  String _search = '';
  String _filter = 'Toutes'; // ← valeur par défaut = 'Toutes'
  final _searchCtrl = TextEditingController();

  // 'Toutes' en premier + les 5 catégories Firestore
  static const _filters = [
    'Toutes',
    'Sculpture',
    'Peinture',
    'Textile',
    'Bijoux',
    'Poterie',
  ];

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Afri.bg,
        body: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            AfriSliverHeader(
              title: 'Gestion des œuvres',
              subtitle: 'Ajoutez, modifiez, supprimez',
              badge: 'ŒUVRES',
              expandedHeight: 130,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 14),
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('oeuvres')
                        .snapshots(),
                    builder: (_, s) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Afri.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: Afri.gold.withOpacity(0.3)),
                      ),
                      child: Text('${s.data?.size ?? 0} œuvres',
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Afri.gold)),
                    ),
                  ),
                ),
              ],
            ),
            SliverToBoxAdapter(child: _buildSearchAndFilters()),
          ],
          body: _buildList(),
        ),
        floatingActionButton: _FAB(
            onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const AdminOeuvreForm()))),
      );

  Widget _buildSearchAndFilters() => Container(
        color: Afri.bg,
        child: Column(children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
            child: Container(
              height: 46,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: Afri.sand.withOpacity(0.6)),
                boxShadow: [
                  BoxShadow(
                      color: Afri.dark.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 3))
                ],
              ),
              child: TextField(
                controller: _searchCtrl,
                onChanged: (v) => setState(() => _search = v),
                style:
                    const TextStyle(fontSize: 13, color: Afri.dark),
                decoration: InputDecoration(
                  hintText: 'Rechercher par titre, artiste...',
                  hintStyle: const TextStyle(
                      fontSize: 12, color: Afri.clay),
                  prefixIcon: const Icon(Icons.search,
                      color: Afri.ocre, size: 20),
                  suffixIcon: _search.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.close,
                              size: 16, color: Afri.ocre),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _search = '');
                          })
                      : null,
                  border: InputBorder.none,
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 13),
                ),
              ),
            ),
          ),
          // Filter chips
          SizedBox(
            height: 50,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: 16, vertical: 10),
              itemCount: _filters.length,
              itemBuilder: (_, i) {
                final f = _filters[i];
                final active = _filter == f;
                return GestureDetector(
                  onTap: () => setState(() => _filter = f),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14),
                    decoration: BoxDecoration(
                      gradient: active
                          ? const LinearGradient(
                              colors: [Afri.gold, Afri.honey])
                          : null,
                      color: active ? null : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                          color: active
                              ? Afri.gold
                              : Afri.sand.withOpacity(0.6)),
                      boxShadow: active
                          ? [
                              BoxShadow(
                                  color:
                                      Afri.gold.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2))
                            ]
                          : [],
                    ),
                    child: Center(
                        child: Text(f,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color:
                                  active ? Afri.dark : Afri.ocre,
                            ))),
                  ),
                );
              },
            ),
          ),
        ]),
      );

  Widget _buildList() => StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('oeuvres')
            .snapshots(),
        builder: (ctx, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(
                child:
                    CircularProgressIndicator(color: Afri.gold));
          }
          var docs = snap.data?.docs ?? [];

          // Tri manuel — gère les docs sans createdAt
          docs = [...docs]..sort((a, b) {
              final aT = ((a.data() as Map)['createdAt'] as Timestamp?)
                      ?.toDate() ??
                  DateTime(2000);
              final bT = ((b.data() as Map)['createdAt'] as Timestamp?)
                      ?.toDate() ??
                  DateTime(2000);
              return bT.compareTo(aT);
            });

          // Filtre recherche
          if (_search.isNotEmpty) {
            final q = _search.toLowerCase();
            docs = docs.where((d) {
              final m = d.data() as Map<String, dynamic>;
              return (m['titre'] ?? '')
                      .toString()
                      .toLowerCase()
                      .contains(q) ||
                  (m['artiste'] ?? '')
                      .toString()
                      .toLowerCase()
                      .contains(q);
            }).toList();
          }

          // Filtre catégorie — 'Toutes' = pas de filtre
          if (_filter != 'Toutes') {
            docs = docs
                .where((d) =>
                    (d.data() as Map)['categorie'] == _filter)
                .toList();
          }

          if (docs.isEmpty) return _empty(ctx);

          return ListView.builder(
            padding:
                const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final doc = docs[i];
              final data = doc.data() as Map<String, dynamic>;
              return _OeuvreRow(
                doc: doc,
                data: data,
                index: i,
                onEdit: () => Navigator.push(
                    ctx,
                    MaterialPageRoute(
                        builder: (_) => AdminOeuvreForm(
                            docId: doc.id,
                            existingData: data))),
                onDelete: () =>
                    _delete(doc.id, data['titre'] ?? ''),
              );
            },
          );
        },
      );

  Widget _empty(BuildContext ctx) => Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                      color: Afri.gold.withOpacity(0.10),
                      shape: BoxShape.circle),
                  child: const Icon(Icons.palette_outlined,
                      size: 36, color: Afri.gold),
                ),
                const SizedBox(height: 16),
                const Text('Aucune œuvre',
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: Afri.dark)),
                const SizedBox(height: 6),
                const Text('Ajoutez votre première œuvre',
                    style: TextStyle(
                        fontSize: 13, color: Afri.ocre)),
                const SizedBox(height: 24),
                AfriButton(
                    label: 'Ajouter une œuvre',
                    icon: Icons.add,
                    onTap: () => Navigator.push(
                        ctx,
                        MaterialPageRoute(
                            builder: (_) =>
                                const AdminOeuvreForm()))),
              ]),
        ),
      );

  Future<void> _delete(String id, String titre) async {
    final ok = await showDialog<bool>(
      context: context,
      barrierColor: Afri.dark.withOpacity(0.5),
      builder: (_) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
              color: Afri.bg,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Afri.sand)),
          child:
              Column(mainAxisSize: MainAxisSize.min, children: [
            Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                    color: Afri.laterite.withOpacity(0.12),
                    shape: BoxShape.circle),
                child: const Icon(Icons.delete_outline,
                    color: Afri.laterite, size: 26)),
            const SizedBox(height: 14),
            const Text('Supprimer ?',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Afri.dark)),
            const SizedBox(height: 6),
            Text('"$titre" sera définitivement supprimée.',
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 12, color: Afri.ocre)),
            const SizedBox(height: 20),
            Row(children: [
              Expanded(
                  child: OutlinedButton(
                      onPressed: () =>
                          Navigator.pop(context, false),
                      style: OutlinedButton.styleFrom(
                          foregroundColor: Afri.ocre,
                          side: const BorderSide(color: Afri.sand),
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12)),
                      child: const Text('Annuler'))),
              const SizedBox(width: 10),
              Expanded(
                  child: ElevatedButton(
                      onPressed: () =>
                          Navigator.pop(context, true),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Afri.laterite,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(
                              vertical: 12),
                          elevation: 0),
                      child: const Text('Supprimer',
                          style: TextStyle(
                              fontWeight: FontWeight.w800)))),
            ]),
          ]),
        ),
      ),
    );
    if (ok == true) {
      await FirebaseFirestore.instance
          .collection('oeuvres')
          .doc(id)
          .delete();
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('"$titre" supprimée'),
          backgroundColor: Afri.gold,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ));
    }
  }
}

// ─── Row card ──────────────────────────────────────────
class _OeuvreRow extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  final Map<String, dynamic> data;
  final int index;
  final VoidCallback onEdit, onDelete;
  const _OeuvreRow(
      {required this.doc,
      required this.data,
      required this.index,
      required this.onEdit,
      required this.onDelete});
  @override
  State<_OeuvreRow> createState() => _OeuvreRowState();
}

class _OeuvreRowState extends State<_OeuvreRow>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _op;
  late Animation<Offset> _sl;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 420));
    _op = CurvedAnimation(parent: _c, curve: Curves.easeIn);
    _sl = Tween<Offset>(
            begin: const Offset(0.04, 0), end: Offset.zero)
        .animate(
            CurvedAnimation(parent: _c, curve: Curves.easeOut));
    Future.delayed(
        Duration(milliseconds: 50 + widget.index * 55), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final color = Afri.categoryColor(d['categorie']);
    final emoji = Afri.categoryEmoji(d['categorie']);
    // Utilise model3dUrl et audioUrl (champs Firestore réels)
    final has3D =
        (d['model3dUrl'] ?? '').toString().isNotEmpty;
    final hasAudio =
        (d['audioUrl'] ?? '').toString().isNotEmpty;

    return FadeTransition(
      opacity: _op,
      child: SlideTransition(
        position: _sl,
        child: AfriCard(
          accentColor: color,
          onTap: widget.onEdit,
          child: Row(children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14)),
              child: d['imageUrl'] != null &&
                      (d['imageUrl'] as String).isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Image.network(d['imageUrl'],
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Center(
                              child: Text(emoji,
                                  style: const TextStyle(
                                      fontSize: 20)))))
                  : Center(
                      child: Text(emoji,
                          style:
                              const TextStyle(fontSize: 20))),
            ),
            const SizedBox(width: 12),
            Expanded(
                child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                  Text(d['titre'] ?? 'Sans titre',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: Afri.dark)),
                  const SizedBox(height: 2),
                  Text(
                      '${d['artiste'] ?? ''} · ${d['annee'] ?? ''}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontSize: 10, color: Afri.ocre)),
                  const SizedBox(height: 6),
                  Row(children: [
                    AfriBadge(
                        label: d['categorie'] ?? '',
                        color: color),
                    if (has3D) ...[
                      const SizedBox(width: 5),
                      const AfriBadge(
                          label: '3D',
                          color: Afri.kente,
                          icon: Icons.view_in_ar_rounded),
                    ],
                    if (hasAudio) ...[
                      const SizedBox(width: 5),
                      const AfriBadge(
                          label: 'Audio',
                          color: Afri.nil,
                          icon: Icons.headphones_outlined),
                    ],
                  ]),
                ])),
            const SizedBox(width: 8),
            Column(children: [
              _ActionBtn(
                  icon: Icons.edit_outlined,
                  color: Afri.nil,
                  onTap: widget.onEdit),
              const SizedBox(height: 6),
              _ActionBtn(
                  icon: Icons.delete_outline,
                  color: Afri.laterite,
                  onTap: widget.onDelete),
            ]),
          ]),
        ),
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _ActionBtn(
      {required this.icon,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, size: 15, color: color),
        ),
      );
}

class _FAB extends StatefulWidget {
  final VoidCallback onTap;
  const _FAB({required this.onTap});
  @override
  State<_FAB> createState() => _FABState();
}

class _FABState extends State<_FAB>
    with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 100));
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTapDown: (_) => _c.forward(),
        onTapUp: (_) {
          _c.reverse();
          widget.onTap();
        },
        onTapCancel: () => _c.reverse(),
        child: AnimatedBuilder(
          animation: _c,
          builder: (_, __) => Transform.scale(
            scale: 1 - _c.value * 0.08,
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                    colors: [Afri.dark, Afri.mid]),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                      color: Afri.dark.withOpacity(0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6))
                ],
                border: Border.all(
                    color: Afri.gold.withOpacity(0.3)),
              ),
              child: const Icon(Icons.add,
                  color: Afri.gold, size: 28),
            ),
          ),
        ),
      );
}