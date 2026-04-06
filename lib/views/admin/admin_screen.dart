import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:afrilegacy/views/admin/afri_theme.dart';
import 'package:afrilegacy/views/admin/admin_dashboard.dart';
import 'package:afrilegacy/views/admin/admin_oeuvres.dart';
import 'package:afrilegacy/views/admin/admin_users.dart' show AdminUsers;
import 'package:afrilegacy/views/admin/admin_stats.dart';
import 'package:afrilegacy/services/auth_service.dart';
import 'package:afrilegacy/views/auth/login_screen.dart';

// AdminCollections supprimé — collection 'collections' absente de Firestore

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});
  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen>
    with TickerProviderStateMixin {
  int _index = 0;
  late AnimationController _navAnim;
  late Animation<Offset> _navSlide;
  final _auth = AuthService();

  // 4 pages — Collections retiré
  late final List<Widget> _pages = [
    const AdminDashboard(),
    const AdminOeuvres(),
    const AdminUsers(),
    const AdminStats(),
  ];

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ));
    _navAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _navSlide = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
        CurvedAnimation(parent: _navAnim, curve: Curves.easeOutBack));

    Future.delayed(const Duration(milliseconds: 350), () {
      if (mounted) _navAnim.forward();
    });
  }

  @override
  void dispose() {
    _navAnim.dispose();
    super.dispose();
  }

  void _go(int i) {
    HapticFeedback.lightImpact();
    setState(() => _index = i);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Afri.bg,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, a) => FadeTransition(
          opacity:
          CurvedAnimation(parent: a, curve: Curves.easeIn),
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.025),
              end: Offset.zero,
            ).animate(a),
            child: child,
          ),
        ),
        child: KeyedSubtree(
          key: ValueKey(_index),
          child: _pages[_index],
        ),
      ),
      bottomNavigationBar: SlideTransition(
        position: _navSlide,
        child: _Nav(index: _index, onTap: _go),
      ),
    );
  }
}

// ─── Nav items data class ──────────────────────────────
class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItemData({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
}

// ─── Bottom Nav ──────────────────────────────────────
class _Nav extends StatelessWidget {
  final int index;
  final ValueChanged<int> onTap;

  const _Nav({required this.index, required this.onTap});

  // 4 items — Collections retiré
  static const List<_NavItemData> _items = [
    _NavItemData(
      icon: Icons.museum_outlined,
      activeIcon: Icons.museum_rounded,
      label: 'Accueil',
    ),
    _NavItemData(
      icon: Icons.palette_outlined,
      activeIcon: Icons.palette_rounded,
      label: 'Œuvres',
    ),
    _NavItemData(
      icon: Icons.people_outline_rounded,
      activeIcon: Icons.people_rounded,
      label: 'Membres',
    ),
    _NavItemData(
      icon: Icons.bar_chart_outlined,
      activeIcon: Icons.bar_chart_rounded,
      label: 'Stats',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Color(0xFFEDE3D6), width: 0.8),
        ),
        boxShadow: [
          BoxShadow(
            color: Color(0x10000000),
            blurRadius: 16,
            offset: Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: _items.asMap().entries.map((e) {
              return Expanded(
                child: _Tab(
                  icon: e.value.icon,
                  activeIcon: e.value.activeIcon,
                  label: e.value.label,
                  active: index == e.key,
                  onTap: () => onTap(e.key),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// ─── Nav Tab ─────────────────────────────────────────
class _Tab extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool active;
  final VoidCallback onTap;

  const _Tab({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.active,
    required this.onTap,
  });

  @override
  State<_Tab> createState() => _TabState();
}

class _TabState extends State<_Tab> with SingleTickerProviderStateMixin {
  late AnimationController _c;

  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 220),
    );
    if (widget.active) _c.value = 1;
  }

  @override
  void didUpdateWidget(_Tab old) {
    super.didUpdateWidget(old);
    if (widget.active && !old.active) {
      _c.forward();
    } else if (!widget.active && old.active) {
      _c.reverse();
    }
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final col = widget.active ? Afri.gold : Afri.ocre;

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Transform.scale(
              scale: 1 + _c.value * 0.12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: widget.active
                      ? Afri.gold.withOpacity(0.12)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.active ? widget.activeIcon : widget.icon,
                  size: 20,
                  color: col,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              widget.label,
              style: TextStyle(
                fontSize: 8,
                fontWeight: FontWeight.w700,
                color: col,
              ),
            ),
            const SizedBox(height: 3),
            Container(
              width: _c.value * 16,
              height: 2.5,
              decoration: BoxDecoration(
                color: Afri.gold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        ),
      ),
    );
  }
}