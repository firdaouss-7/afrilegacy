import 'dart:math';
import 'package:flutter/material.dart';

// ════════════════════════════════════════════════
//  PALETTE OFFICIELLE AFRILEGACY
// ════════════════════════════════════════════════
class Afri {
  // Fonds & surfaces
  static const bg = Color(0xFFFBF8F3); // Crème Antique
  static const bg2 = Color(0xFFF2EBE0); // Papyrus
  static const bg3 = Color(0xFFE4D9C8); // Lin Naturel
  static const clay = Color(0xFFC9B99F); // Argile Claire
  static const sand = Color(0xFFD9C9B2); // Sable Doux
  // Principales
  static const gold = Color(0xFFC4A96A); // Or Patiné ★
  static const honey = Color(0xFFE8C87A); // Miel du Désert
  static const nil = Color(0xFF8FAFC0); // Ciel du Nil ★
  static const nilPale = Color(0xFFA0B8C0); // Turquoise Pâle
  // Touches
  static const savane = Color(0xFFA8C4A2); // Savane Tendre
  static const laterite = Color(0xFFD4A89A); // Rose Latérite
  static const kente = Color(0xFFB8A8CC); // Violet Kente
  // Neutres
  static const dark = Color(0xFF3D2B1A); // Bois Foncé ★
  static const mid = Color(0xFF5C3D2E); // Bois Moyen
  static const ocre = Color(0xFF8C7A68); // Ocre Doux

  // Gradients
  static const headerGrad = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3D2B1A), Color(0xFF5C3D2E), Color(0xFF2A1D10)],
  );

  static Color categoryColor(String? cat) {
    switch (cat) {
      case 'Art':
        return gold;
      case 'Art rituel':
        return gold;
      case 'Histoire':
        return nil;
      case 'Culture':
        return savane;
      case 'Musique':
        return laterite;
      case 'Textile':
        return kente;
      case 'Architecture':
        return honey;
      default:
        return clay;
    }
  }

  static String categoryEmoji(String? cat) {
    switch (cat) {
      case 'Art':
        return '🎨';
      case 'Art rituel':
        return '🎭';
      case 'Histoire':
        return '🏛️';
      case 'Culture':
        return '🌍';
      case 'Musique':
        return '🎵';
      case 'Textile':
        return '🧵';
      case 'Architecture':
        return '🏰';
      default:
        return '✨';
    }
  }
}

// ════════════════════════════════════════════════
//  KENTE PATTERN PAINTER
// ════════════════════════════════════════════════
class KentePainter extends CustomPainter {
  final double progress;
  final double opacity;
  KentePainter({required this.progress, this.opacity = 1.0});

  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..style = PaintingStyle.fill;
    final offset = progress * 40;

    // Horizontal shimmer bands
    const bandH = 8.0;
    const cols = [
      Color(0xFFC4A96A),
      Color(0xFF8FAFC0),
      Color(0xFFA8C4A2),
      Color(0xFFD4A89A),
      Color(0xFFB8A8CC),
    ];
    for (double y = -bandH + (offset % bandH); y < size.height; y += bandH) {
      final ci = ((y + offset) ~/ bandH).abs() % cols.length;
      p.color = cols[ci].withOpacity(0.055 * opacity);
      canvas.drawRect(Rect.fromLTWH(0, y, size.width, bandH - 0.5), p);
    }

    // Diagonal lines
    final lp = Paint()
      ..color = Afri.gold.withOpacity(0.07 * opacity)
      ..strokeWidth = 0.8;
    for (
      double x = -size.height + (offset * 0.4 % 28);
      x < size.width + size.height;
      x += 28
    ) {
      canvas.drawLine(Offset(x, 0), Offset(x - size.height, size.height), lp);
    }

    // Animated diamond ornaments
    final dp = Paint()
      ..color = Afri.gold.withOpacity(0.12 * opacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.7;
    for (double x = 24.0; x < size.width; x += 36) {
      for (double y = 20.0; y < size.height; y += 36) {
        final ay = y + sin((x + progress * 6.28) * 0.12) * 2.5;
        final path = Path()
          ..moveTo(x, ay - 5)
          ..lineTo(x + 5, ay)
          ..lineTo(x, ay + 5)
          ..lineTo(x - 5, ay)
          ..close();
        canvas.drawPath(path, dp);
      }
    }
  }

  @override
  bool shouldRepaint(KentePainter o) => o.progress != progress;
}

// ════════════════════════════════════════════════
//  ANIMATED KENTE BACKGROUND WIDGET
// ════════════════════════════════════════════════
class KenteBg extends StatefulWidget {
  final Widget child;
  final double opacity;
  const KenteBg({super.key, required this.child, this.opacity = 1.0});
  @override
  State<KenteBg> createState() => _KenteBgState();
}

class _KenteBgState extends State<KenteBg> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _ctrl,
    builder: (_, child) => CustomPaint(
      painter: KentePainter(progress: _ctrl.value, opacity: widget.opacity),
      child: child,
    ),
    child: widget.child,
  );
}

// ════════════════════════════════════════════════
//  ANIMATED COUNTER
// ════════════════════════════════════════════════
class AfriCounter extends StatefulWidget {
  final int value;
  final TextStyle? style;
  const AfriCounter({super.key, required this.value, this.style});
  @override
  State<AfriCounter> createState() => _AfriCounterState();
}

class _AfriCounterState extends State<AfriCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _anim = Tween<double>(
      begin: 0,
      end: widget.value.toDouble(),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutExpo));
    _ctrl.forward();
  }

  @override
  void didUpdateWidget(AfriCounter old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value) {
      _anim = Tween<double>(
        begin: _anim.value,
        end: widget.value.toDouble(),
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
      _ctrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _anim,
    builder: (_, __) => Text(
      _anim.value.toInt().toString(),
      style:
          widget.style ??
          const TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w900,
            color: Afri.dark,
          ),
    ),
  );
}

// ════════════════════════════════════════════════
//  AFRI HEADER SLIVER
// ════════════════════════════════════════════════
class AfriSliverHeader extends StatefulWidget {
  final String title;
  final String subtitle;
  final String? badge;
  final List<Widget>? actions;
  final double expandedHeight;
  const AfriSliverHeader({
    super.key,
    required this.title,
    required this.subtitle,
    this.badge,
    this.actions,
    this.expandedHeight = 140,
  });
  @override
  State<AfriSliverHeader> createState() => _AfriSliverHeaderState();
}

class _AfriSliverHeaderState extends State<AfriSliverHeader>
    with SingleTickerProviderStateMixin {
  late AnimationController _patternCtrl;
  @override
  void initState() {
    super.initState();
    _patternCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
  }

  @override
  void dispose() {
    _patternCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: widget.expandedHeight,
      pinned: true,
      floating: false,
      backgroundColor: Afri.dark,
      elevation: 0,
      automaticallyImplyLeading: false,
      // Après
      leading: null,
      actions: widget.actions,
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        background: AnimatedBuilder(
          animation: _patternCtrl,
          builder: (_, __) => Container(
            decoration: const BoxDecoration(gradient: Afri.headerGrad),
            child: Stack(
              children: [
                Positioned.fill(
                  child: CustomPaint(
                    painter: KentePainter(progress: _patternCtrl.value),
                  ),
                ),
                // Orbs
                Positioned(
                  top: -30,
                  right: -20,
                  child: Container(
                    width: 130,
                    height: 130,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Afri.gold.withOpacity(0.18),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: -15,
                  left: -15,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          Afri.nil.withOpacity(0.14),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Text content
                Positioned(
                  left: 20,
                  right: 20,
                  bottom: 18,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.badge != null)
                        Container(
                          margin: const EdgeInsets.only(bottom: 6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Afri.gold.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Afri.gold.withOpacity(0.3),
                            ),
                          ),
                          child: Text(
                            widget.badge!,
                            style: const TextStyle(
                              fontSize: 9,
                              letterSpacing: 1.8,
                              color: Afri.gold,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      Text(
                        widget.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFFECE2D0),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(fontSize: 11, color: Afri.ocre),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════
//  ACCENT BAR CARD
// ════════════════════════════════════════════════
class AfriCard extends StatelessWidget {
  final Color accentColor;
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  const AfriCard({
    super.key,
    required this.accentColor,
    required this.child,
    this.padding,
    this.onTap,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Afri.sand.withOpacity(0.55)),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.07),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Container(
              width: 4,
              decoration: BoxDecoration(
                color: accentColor,
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: padding ?? const EdgeInsets.all(14),
                child: child,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

// ════════════════════════════════════════════════
//  PULSING STAT CARD
// ════════════════════════════════════════════════
class AfriStatCard extends StatefulWidget {
  final String emoji;
  final int value;
  final String label;
  final String delta;
  final Color color;
  const AfriStatCard({
    super.key,
    required this.emoji,
    required this.value,
    required this.label,
    required this.delta,
    required this.color,
  });
  @override
  State<AfriStatCard> createState() => _AfriStatCardState();
}

class _AfriStatCardState extends State<AfriStatCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulse;
  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _pulse,
    builder: (_, __) => Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Afri.sand.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: widget.color.withOpacity(0.06 + _pulse.value * 0.06),
            blurRadius: 20 + _pulse.value * 8,
            spreadRadius: 1,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                height: 3,
                width: 28 + _pulse.value * 10,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [widget.color, widget.color.withOpacity(0.25)],
                  ),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withOpacity(0.10 + _pulse.value * 0.06),
                ),
                child: Center(
                  child: Text(
                    widget.emoji,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
          const Spacer(),
          AfriCounter(
            value: widget.value,
            style: const TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.w900,
              color: Afri.dark,
              height: 1,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            widget.label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Afri.dark,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            widget.delta,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: widget.color,
            ),
          ),
        ],
      ),
    ),
  );
}

// ════════════════════════════════════════════════
//  SMALL BADGE
// ════════════════════════════════════════════════
class AfriBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const AfriBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(
      color: color.withOpacity(0.13),
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: color.withOpacity(0.25)),
    ),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 9, color: color),
          const SizedBox(width: 3),
        ],
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
      ],
    ),
  );
}

// ════════════════════════════════════════════════
//  PRESSABLE BUTTON
// ════════════════════════════════════════════════
class AfriButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final bool isLoading;
  final Color? backgroundColor;
  final Color? textColor;
  final IconData? icon;
  const AfriButton({
    super.key,
    required this.label,
    required this.onTap,
    this.isLoading = false,
    this.backgroundColor,
    this.textColor,
    this.icon,
  });
  @override
  State<AfriButton> createState() => _AfriButtonState();
}

class _AfriButtonState extends State<AfriButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTapDown: (_) => _ctrl.forward(),
    onTapUp: (_) {
      _ctrl.reverse();
      widget.onTap();
    },
    onTapCancel: () => _ctrl.reverse(),
    child: AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) => Transform.scale(
        scale: 1 - _ctrl.value * 0.04,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            color: widget.backgroundColor ?? Afri.dark,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: (widget.backgroundColor ?? Afri.dark).withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: widget.isLoading
              ? const Center(
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Color(0xFFD9C9B2),
                      strokeWidth: 2,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      Icon(
                        widget.icon,
                        size: 18,
                        color: widget.textColor ?? Afri.gold,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      widget.label,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: widget.textColor ?? const Color(0xFFD9C9B2),
                        letterSpacing: 0.6,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    ),
  );
}

// ════════════════════════════════════════════════
//  AFRI TEXT FIELD
// ════════════════════════════════════════════════
class AfriField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String hint;
  final int maxLines;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final Function(String)? onChanged;
  const AfriField({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    this.maxLines = 1,
    this.keyboardType,
    this.validator,
    this.onChanged,
  });
  @override
  State<AfriField> createState() => _AfriFieldState();
}

class _AfriFieldState extends State<AfriField> {
  bool _focused = false;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        widget.label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: _focused ? Afri.gold : Afri.dark,
          letterSpacing: 0.3,
        ),
      ),
      const SizedBox(height: 6),
      Focus(
        onFocusChange: (f) => setState(() => _focused = f),
        child: TextFormField(
          controller: widget.controller,
          maxLines: widget.maxLines,
          keyboardType: widget.keyboardType,
          validator: widget.validator,
          onChanged: widget.onChanged,
          style: const TextStyle(fontSize: 13, color: Afri.dark),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle: const TextStyle(color: Color(0xFFBFAF9A), fontSize: 12),
            filled: true,
            fillColor: _focused ? Colors.white : Afri.bg2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Afri.gold, width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Afri.laterite),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 13,
            ),
          ),
        ),
      ),
    ],
  );
}

// ════════════════════════════════════════════════
//  SECTION CONTAINER
// ════════════════════════════════════════════════
class AfriSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const AfriSection({super.key, required this.title, required this.children});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
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
            Text(
              title,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: Afri.dark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        ...children,
      ],
    ),
  );
}

// ════════════════════════════════════════════════
//  TOGGLE ROW
// ════════════════════════════════════════════════
class AfriToggle extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;
  const AfriToggle({
    super.key,
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: () => onChanged(!value),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: value ? iconColor.withOpacity(0.06) : Afri.bg2,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: value
              ? iconColor.withOpacity(0.25)
              : Afri.sand.withOpacity(0.5),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Afri.dark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 10, color: Afri.ocre),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: iconColor,
            activeTrackColor: iconColor.withOpacity(0.28),
            inactiveThumbColor: Afri.sand,
            inactiveTrackColor: Afri.sand.withOpacity(0.4),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ],
      ),
    ),
  );
}
