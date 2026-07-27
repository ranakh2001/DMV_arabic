import 'package:flutter/material.dart';

/// Wraps [child] with the fade/slide-in transition every screen in the auth
/// flow plays on first appearance, without each screen owning an
/// [AnimationController] itself.
class AuthEntrance extends StatefulWidget {
  const AuthEntrance({super.key, required this.child});

  final Widget child;

  @override
  State<AuthEntrance> createState() => _AuthEntranceState();
}

class _AuthEntranceState extends State<AuthEntrance> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 650));
    _fade = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.05), end: Offset.zero)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
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
