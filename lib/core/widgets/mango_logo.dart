import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// The Arrow con Mango logo (mango + leaf), reproduced from the design SVG.
///
/// [leaf] tints the leaf (green on light surfaces, yellow on dark headers).
class MangoLogo extends StatelessWidget {
  const MangoLogo({super.key, required this.size, this.leaf = const Color(0xFF4CAF50)});

  final double size;
  final Color leaf;

  static String svg(Color leaf) {
    final leafHex = '#${(leaf.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';
    return '''
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">
<ellipse cx="12" cy="13.5" rx="8.5" ry="7" transform="rotate(-18 12 13.5)" fill="#F4843D"/>
<ellipse cx="9" cy="11" rx="3.4" ry="2.4" transform="rotate(-18 9 11)" fill="#F9C74F" opacity="0.9"/>
<path d="M15 5.5 Q13.8 3.2 12.8 2.4" stroke="#6D4C2A" stroke-width="1.6" fill="none" stroke-linecap="round"/>
<path d="M15.5 6.5 Q19.5 3.5 21 6.5 Q18.5 9 15.5 7.5 Z" fill="$leafHex"/>
</svg>''';
  }

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(svg(leaf), width: size, height: size);
  }
}

/// Floating, sparkling mango — reproduces the `floatMango` + `sparkle`
/// animations from the design.
class FloatingMango extends StatefulWidget {
  const FloatingMango({
    super.key,
    required this.size,
    this.leaf = const Color(0xFF4CAF50),
    this.sparkles = true,
  });

  final double size;
  final Color leaf;
  final bool sparkles;

  @override
  State<FloatingMango> createState() => _FloatingMangoState();
}

class _FloatingMangoState extends State<FloatingMango>
    with SingleTickerProviderStateMixin {
  late final AnimationController _float = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 3200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _float.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;
    return SizedBox(
      width: s * 1.9,
      height: s * 1.7,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          if (widget.sparkles) ...[
            _Sparkle(left: s * 0.02, top: s * 0.02, size: 18, delayMs: 0),
            _Sparkle(right: s * 0.05, top: -s * 0.09, size: 13, delayMs: 300),
            _Sparkle(right: -s * 0.05, top: s * 0.52, size: 20, delayMs: 700),
            _Sparkle(left: s * 0.0, top: s * 0.59, size: 11, delayMs: 1000),
          ],
          AnimatedBuilder(
            animation: _float,
            builder: (context, child) {
              final t = Curves.easeInOut.transform(_float.value);
              return Transform.translate(
                offset: Offset(0, -14 * t),
                child: Transform.rotate(angle: (-4 + 8 * t) * 3.14159 / 180, child: child),
              );
            },
            child: DecoratedBox(
              decoration: const BoxDecoration(
                boxShadow: [
                  BoxShadow(color: Color(0x38000000), blurRadius: 20, offset: Offset(0, 10)),
                ],
              ),
              child: MangoLogo(size: s, leaf: widget.leaf),
            ),
          ),
        ],
      ),
    );
  }
}

class _Sparkle extends StatefulWidget {
  const _Sparkle({this.left, this.right, this.top, required this.size, required this.delayMs});

  final double? left;
  final double? right;
  final double? top;
  final double size;
  final int delayMs;

  @override
  State<_Sparkle> createState() => _SparkleState();
}

class _SparkleState extends State<_Sparkle> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1900),
  );
  Timer? _delay;

  static const _svg =
      '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="#F9C74F">'
      '<path d="M12 2 L14.3 9.7 L22 12 L14.3 14.3 L12 22 L9.7 14.3 L2 12 L9.7 9.7 Z"/></svg>';

  @override
  void initState() {
    super.initState();
    _delay = Timer(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.repeat(reverse: true);
    });
  }

  @override
  void dispose() {
    _delay?.cancel();
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.left,
      right: widget.right,
      top: widget.top,
      child: AnimatedBuilder(
        animation: _c,
        builder: (context, child) {
          final t = Curves.easeInOut.transform(_c.value);
          return Opacity(
            opacity: 0.5 + 0.5 * t,
            child: Transform.scale(scale: 0.8 + 0.55 * t, child: child),
          );
        },
        child: SvgPicture.string(_svg, width: widget.size, height: widget.size),
      ),
    );
  }
}
