import 'dart:math' as math;
import 'dart:ui' show ImageFilter;
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

/// Shared visual building blocks for the forgot-password flow
/// (forgot password → forgot verify → reset password) so the three
/// screens don't each re-declare the same gradient, glass card, badge,
/// nav button, field decoration and glow button.

const _kAccent = Color(0xFF4A9CD9);

// ── Background gradient + decorative blobs ─────────────────────────────────

class AuthFlowBackground extends StatelessWidget {
  const AuthFlowBackground({super.key, required this.isDark, this.mirrored = false});

  final bool isDark;

  /// Flips the blob positions (used to give each screen in the flow a
  /// slightly different feel) without duplicating the whole widget.
  final bool mirrored;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: isDark
                  ? [const Color(0xFF0D1E3A), const Color(0xFF060912)]
                  : [const Color(0xFF1A3462), const Color(0xFF0A1628)],
            ),
          ),
        ),
        Positioned(
          top: -70,
          left: mirrored ? null : -60,
          right: mirrored ? -60 : null,
          child: Container(
            width: 260,
            height: 260,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1565C0).withAlpha(50),
            ),
          ),
        ),
        Positioned(
          bottom: -50,
          right: mirrored ? null : -50,
          left: mirrored ? -40 : null,
          child: Container(
            width: 200,
            height: 200,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _kAccent.withAlpha(25),
            ),
          ),
        ),
      ],
    );
  }
}

// ── One-shot entrance animation (fade + slide up) ──────────────────────────

/// Wraps [child] with the fade/slide-in transition every screen in the flow
/// plays on first appearance, without each screen owning an
/// [AnimationController] itself.
class AuthEntrance extends StatefulWidget {
  const AuthEntrance({super.key, required this.child});

  final Widget child;

  @override
  State<AuthEntrance> createState() => _AuthEntranceState();
}

class _AuthEntranceState extends State<AuthEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fade,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

// ── Top bar ─────────────────────────────────────────────────────────────────

class AuthTopBar extends StatelessWidget {
  const AuthTopBar({
    super.key,
    required this.title,
    required this.onBack,
    this.titleColor,
  });

  final String title;
  final VoidCallback onBack;
  final Color? titleColor;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Row(
        children: [
          CircleNavButton(icon: Icons.arrow_back_rounded, onTap: onBack),
          const Spacer(),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Almarai',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: titleColor,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

class CircleNavButton extends StatelessWidget {
  const CircleNavButton({super.key, required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: _kAccent.withAlpha(25),
          border: Border.all(color: _kAccent.withAlpha(80), width: 1.2),
        ),
        child: Icon(icon, color: _kAccent, size: 20),
      ),
    );
  }
}

// ── Glass card ──────────────────────────────────────────────────────────────

class GlassCard extends StatelessWidget {
  const GlassCard({super.key, required this.isDark, required this.child});

  final bool isDark;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF0B1830).withAlpha(155)
                : Colors.white.withAlpha(20),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: _kAccent.withAlpha(90), width: 1.2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(60),
                blurRadius: 30,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: _kAccent.withAlpha(18),
                blurRadius: 26,
                spreadRadius: -4,
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

// ── Badge chip ──────────────────────────────────────────────────────────────

class BadgeChip extends StatelessWidget {
  const BadgeChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: _kAccent.withAlpha(30),
        border: Border.all(color: _kAccent.withAlpha(80), width: 1),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Almarai',
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _kAccent,
        ),
      ),
    );
  }
}

// ── Field decoration ────────────────────────────────────────────────────────

InputDecoration authFieldDecoration({
  required BuildContext context,
  required String hint,
  Widget? prefixIcon,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(
      fontFamily: 'Almarai',
      color: Colors.white.withAlpha(70),
      fontSize: 14,
    ),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: const Color(0xFF060912).withAlpha(200),
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: _kAccent.withAlpha(60)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: _kAccent.withAlpha(60)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: const BorderSide(color: _kAccent, width: 1.5),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: context.appError),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: context.appError, width: 1.5),
    ),
    errorStyle: const TextStyle(fontFamily: 'Almarai', fontSize: 12),
  );
}

// ── Glow submit button ──────────────────────────────────────────────────────

class GlowElevatedButton extends StatelessWidget {
  const GlowElevatedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _kAccent.withAlpha(95),
            blurRadius: 24,
            spreadRadius: -2,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: SizedBox(
        height: 54,
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: _kAccent,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18, color: Colors.white),
                const SizedBox(width: 10),
              ],
              Text(
                label,
                style: const TextStyle(
                  fontFamily: 'Almarai',
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Animated hero icon ───────────────────────────────────────────────────────

/// A small badge orbiting the hero icon rings (e.g. the lock on the
/// "forgot password" mail icon, or the mail/check marks on the OTP icon).
class HeroBadge {
  const HeroBadge({
    this.top,
    this.left,
    this.right,
    this.bottom,
    required this.icon,
    this.size = 30,
    this.iconSize = 14,
  });

  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final IconData icon;
  final double size;
  final double iconSize;
}

/// The circular hero icon used at the top of every forgot-password screen:
/// two concentric rings with an orbiting accent dot, a gently breathing
/// center circle, and the whole thing floats up and down.
class AnimatedHeroIcon extends StatefulWidget {
  const AnimatedHeroIcon({
    super.key,
    required this.icon,
    this.iconColor = _kAccent,
    this.iconSize = 38,
    this.badges = const [],
  });

  final IconData icon;
  final Color iconColor;
  final double iconSize;
  final List<HeroBadge> badges;

  @override
  State<AnimatedHeroIcon> createState() => _AnimatedHeroIconState();
}

class _AnimatedHeroIconState extends State<AnimatedHeroIcon>
    with TickerProviderStateMixin {
  late final AnimationController _floatCtrl;
  late final AnimationController _spinCtrl;
  late final AnimationController _pulseCtrl;

  late final Animation<double> _float;
  late final Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _spinCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _float = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _pulse = Tween<double>(
      begin: 0.97,
      end: 1.04,
    ).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _floatCtrl.dispose();
    _spinCtrl.dispose();
    _pulseCtrl.dispose();
    super.dispose();
  }

  Widget _ring({required double size, required int borderAlpha, required double dotSize}) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: widget.iconColor.withAlpha(borderAlpha),
                width: 1,
              ),
            ),
          ),
          Positioned(
            top: -dotSize / 2,
            child: Container(
              width: dotSize,
              height: dotSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.iconColor,
                boxShadow: [
                  BoxShadow(
                    color: widget.iconColor.withAlpha(140),
                    blurRadius: 6,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_float, _spinCtrl, _pulse]),
      builder: (context, _) {
        final spinAngle = _spinCtrl.value * 2 * math.pi;
        return Transform.translate(
          offset: Offset(0, _float.value),
          child: SizedBox(
            width: 176,
            height: 176,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: spinAngle,
                  child: _ring(size: 176, borderAlpha: 22, dotSize: 8),
                ),
                Transform.rotate(
                  angle: -spinAngle * 1.6,
                  child: _ring(size: 130, borderAlpha: 45, dotSize: 6),
                ),
                Transform.scale(
                  scale: _pulse.value,
                  child: Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF0D1B3E),
                      border: Border.all(
                        color: _kAccent.withAlpha(90),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: _kAccent.withAlpha(60),
                          blurRadius: 20,
                          spreadRadius: -4,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Icon(
                        widget.icon,
                        color: widget.iconColor,
                        size: widget.iconSize,
                      ),
                    ),
                  ),
                ),
                for (final badge in widget.badges)
                  Positioned(
                    top: badge.top,
                    left: badge.left,
                    right: badge.right,
                    bottom: badge.bottom,
                    child: Container(
                      width: badge.size,
                      height: badge.size,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF0D1B3E),
                        border: Border.all(
                          color: _kAccent.withAlpha(80),
                          width: 1,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          badge.icon,
                          color: _kAccent,
                          size: badge.iconSize,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
