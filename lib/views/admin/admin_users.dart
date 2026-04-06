import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:afrilegacy/views/admin/afri_theme.dart';

class AdminUsers extends StatefulWidget {
  const AdminUsers({super.key});
  @override
  State<AdminUsers> createState() => _AdminUsersState();
}

class _AdminUsersState extends State<AdminUsers> {
  String _search = '';
  String _filter = 'Tous';
  final _searchCtrl = TextEditingController();

  static const _avatarColors = [
    Afri.gold, Afri.nil, Afri.savane, Afri.laterite, Afri.kente, Afri.honey,
  ];
  Color _avatarColor(int i) => _avatarColors[i % _avatarColors.length];

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: Afri.bg,
    body: NestedScrollView(
      headerSliverBuilder: (_, __) => [
        AfriSliverHeader(
          title: 'Membres', subtitle: 'Gérez les comptes utilisateurs',
          badge: 'UTILISATEURS', expandedHeight: 130,
        ),
        SliverToBoxAdapter(child: _buildSearchFilters()),
      ],
      body: _buildList(),
    ),
  );

  Widget _buildSearchFilters() => Container(
    color: Afri.bg,
    child: Column(children: [
      Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
        child: Container(
          height: 46,
          decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Afri.sand.withOpacity(0.6)),
            boxShadow: [BoxShadow(
                color: Afri.dark.withOpacity(0.04),
                blurRadius: 10, offset: const Offset(0, 3))],
          ),
          child: TextField(
            controller: _searchCtrl,
            onChanged: (v) => setState(() => _search = v),
            style: const TextStyle(fontSize: 13, color: Afri.dark),
            decoration: InputDecoration(
              hintText: 'Rechercher un utilisateur...',
              hintStyle: const TextStyle(fontSize: 12, color: Afri.clay),
              prefixIcon: const Icon(Icons.search, color: Afri.ocre, size: 20),
              suffixIcon: _search.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 16, color: Afri.ocre),
                      onPressed: () {
                        _searchCtrl.clear();
                        setState(() => _search = '');
                      })
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 13),
            ),
          ),
        ),
      ),
      SizedBox(
        height: 48,
        child: ListView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          children: ['Tous', 'Actifs', 'Admins', 'Désactivés'].map((f) {
            final act = _filter == f;
            return GestureDetector(
              onTap: () => setState(() => _filter = f),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                padding: const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  gradient: act
                      ? const LinearGradient(colors: [Afri.gold, Afri.honey])
                      : null,
                  color: act ? null : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                      color: act ? Afri.gold : Afri.sand.withOpacity(0.6)),
                ),
                child: Center(child: Text(f,
                  style: TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w700,
                    color: act ? Afri.dark : Afri.ocre))),
              ),
            );
          }).toList(),
        ),
      ),
    ]),
  );

  Widget _buildList() => StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('users')
        .orderBy('createdAt', descending: true)
        .snapshots(),
    builder: (ctx, snap) {
      if (snap.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator(color: Afri.gold));
      }
      var docs = snap.data?.docs ?? [];

      if (_search.isNotEmpty) {
        final q = _search.toLowerCase();
        docs = docs.where((d) {
          final m = d.data() as Map<String, dynamic>;
          return (m['email'] ?? '').toString().toLowerCase().contains(q) ||
              (m['nom'] ?? '').toString().toLowerCase().contains(q) ||
              (m['prenom'] ?? '').toString().toLowerCase().contains(q);
        }).toList();
      }

      if (_filter == 'Admins') {
        docs = docs.where((d) =>
            (d.data() as Map)['role'] == 'admin').toList();
      } else if (_filter == 'Désactivés') {
        docs = docs.where((d) =>
            (d.data() as Map)['isActive'] == false).toList();
      } else if (_filter == 'Actifs') {
        docs = docs.where((d) =>
            (d.data() as Map)['isActive'] != false).toList();
      }

      if (docs.isEmpty) {
        return Center(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.group_off_outlined,
                size: 48, color: Afri.ocre.withOpacity(0.4)),
            const SizedBox(height: 12),
            const Text('Aucun utilisateur trouvé',
                style: TextStyle(fontSize: 14, color: Afri.ocre)),
          ]),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
        itemCount: docs.length,
        itemBuilder: (_, i) {
          final doc = docs[i];
          final data = doc.data() as Map<String, dynamic>;
          return _UserCard(
            data: data, index: i,
            color: _avatarColor(i),
            onToggleRole: () => _toggleRole(doc.id, data['role'] ?? 'user'),
            onToggleActive: () => _toggleActive(doc.id, data['isActive'] ?? true),
          );
        },
      );
    },
  );

  Future<void> _toggleRole(String id, String current) async {
    final newRole = current == 'admin' ? 'user' : 'admin';
    await FirebaseFirestore.instance
        .collection('users').doc(id).update({'role': newRole});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Rôle → $newRole'),
        backgroundColor: Afri.gold, behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))));
    }
  }

  Future<void> _toggleActive(String id, bool current) async {
    final action = current ? 'désactiver' : 'réactiver';
    final actionLabel = current ? 'Désactiver' : 'Réactiver';
    final actionColor = current ? Afri.laterite : Afri.savane;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Afri.bg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(children: [
          Icon(current ? Icons.block : Icons.check_circle_outline,
              color: actionColor, size: 22),
          const SizedBox(width: 8),
          Text(actionLabel, style: TextStyle(
              fontSize: 16, fontWeight: FontWeight.w800, color: Afri.dark)),
        ]),
        content: Text(
          'Voulez-vous vraiment $action ce compte ?\n\n'
          '${current ? 'L\'utilisateur ne pourra plus se connecter.' : 'L\'utilisateur pourra à nouveau se connecter.'}',
          style: const TextStyle(fontSize: 13, color: Afri.ocre, height: 1.5),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700, color: Afri.ocre)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(actionLabel, style: const TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await FirebaseFirestore.instance
          .collection('users').doc(id).update({'isActive': !current});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Compte ${!current ? 'réactivé ✓' : 'désactivé'}'),
          backgroundColor: !current ? Afri.savane : Afri.laterite,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12))));
      }
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
class _UserCard extends StatefulWidget {
  final Map<String, dynamic> data;
  final int index;
  final Color color;
  final VoidCallback onToggleRole;
  final VoidCallback onToggleActive;

  const _UserCard({
    required this.data, required this.index, required this.color,
    required this.onToggleRole, required this.onToggleActive,
  });

  @override
  State<_UserCard> createState() => _UserCardState();
}

class _UserCardState extends State<_UserCard> with SingleTickerProviderStateMixin {
  late AnimationController _c;
  late Animation<double> _op;
  late Animation<Offset> _sl;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 400));
    _op = CurvedAnimation(parent: _c, curve: Curves.easeIn);
    _sl = Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: _c, curve: Curves.easeOut));
    Future.delayed(Duration(milliseconds: 40 + widget.index * 55), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() { _c.dispose(); super.dispose(); }

  String _initials() {
    final nom = widget.data['nom'] ?? '';
    final prenom = widget.data['prenom'] ?? '';
    final email = widget.data['email'] ?? '';
    if (nom.isNotEmpty && prenom.isNotEmpty)
      return '${prenom[0]}${nom[0]}'.toUpperCase();
    if (email.isNotEmpty) return email[0].toUpperCase();
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final d = widget.data;
    final isAdmin = d['role'] == 'admin';
    final isActive = d['isActive'] ?? true;
    final email = d['email'] ?? '';
    final nom = '${d['prenom'] ?? ''} ${d['nom'] ?? ''}'.trim();
    final display = nom.isNotEmpty ? nom : email;

    return FadeTransition(
      opacity: _op,
      child: SlideTransition(
        position: _sl,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Afri.bg2,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isActive
                  ? Afri.sand.withOpacity(0.5)
                  : Afri.laterite.withOpacity(0.25)),
            boxShadow: [BoxShadow(
                color: widget.color.withOpacity(0.06),
                blurRadius: 14, offset: const Offset(0, 3))],
          ),
          child: Row(children: [

            // ── Avatar ──
            Stack(children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(isActive ? 0.15 : 0.08),
                ),
                child: Center(child: Text(_initials(),
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900,
                      color: widget.color.withOpacity(isActive ? 1.0 : 0.5)))),
              ),
              if (isAdmin) Positioned(bottom: 0, right: 0,
                child: Container(width: 15, height: 15,
                  decoration: const BoxDecoration(
                      color: Afri.gold, shape: BoxShape.circle),
                  child: const Icon(Icons.star_rounded,
                      size: 10, color: Afri.dark))),
              if (!isActive) Positioned(bottom: 0, right: 0,
                child: Container(width: 15, height: 15,
                  decoration: const BoxDecoration(
                      color: Afri.laterite, shape: BoxShape.circle),
                  child: const Icon(Icons.block,
                      size: 10, color: Colors.white))),
            ]),

            const SizedBox(width: 12),

            // ── Infos ──
            Expanded(child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(child: Text(display,
                    maxLines: 1, overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800,
                        color: isActive ? Afri.dark : Afri.ocre))),
                  if (isAdmin)
                    const AfriBadge(
                        label: 'ADMIN', color: Afri.gold,
                        icon: Icons.star_rounded),
                ]),
                const SizedBox(height: 2),
                Text(email, maxLines: 1, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 10, color: Afri.ocre)),
                const SizedBox(height: 5),
                Row(children: [
                  Container(width: 7, height: 7,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive ? Afri.savane : Afri.laterite)),
                  const SizedBox(width: 5),
                  Text(isActive ? 'Actif' : 'Désactivé',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                        color: isActive ? Afri.savane : Afri.laterite)),
                ]),
              ],
            )),

            // ── Boutons actions ──
            Column(children: [
              // Bouton rôle
              GestureDetector(
                onTap: widget.onToggleRole,
                child: Container(width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: isAdmin
                        ? Afri.gold.withOpacity(0.12)
                        : Afri.sand.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(10)),
                  child: Icon(
                    isAdmin ? Icons.star_rounded : Icons.star_border_rounded,
                    size: 16,
                    color: isAdmin ? Afri.gold : Afri.ocre))),
              const SizedBox(height: 6),
              // Bouton désactiver/réactiver
              GestureDetector(
                onTap: widget.onToggleActive,
                child: Container(width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: isActive
                        ? Afri.laterite.withOpacity(0.10)
                        : Afri.savane.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10)),
                  child: Icon(
                    isActive ? Icons.lock_open_outlined : Icons.lock_outlined,
                    size: 15,
                    color: isActive ? Afri.laterite : Afri.savane))),
            ]),
          ]),
        ),
      ),
    );
  }
}