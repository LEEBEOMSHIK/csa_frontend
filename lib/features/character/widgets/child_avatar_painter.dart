import 'dart:math' as math;

import 'package:flutter/material.dart';

class ChildAvatarPainter extends CustomPainter {
  final List<int> variants;

  const ChildAvatarPainter({required this.variants});

  static const _artboard = Size(220, 260);
  static const _anchors = _AvatarAnchors();

  int _variant(int index, int fallback) =>
      variants.length > index ? variants[index] : fallback;

  int get _hat => _variant(0, 0);
  int get _top => _variant(1, 0);
  int get _bottom => _variant(2, 0);
  int get _glasses => _variant(3, 0);
  int get _accessory => _variant(4, 0);
  int get _face => _variant(5, 1);
  int get _eyes => _variant(6, 1);
  int get _nose => _variant(7, 1);
  int get _mouth => _variant(8, 1);

  @override
  void paint(Canvas canvas, Size size) {
    final scale = math.min(
      size.width / _artboard.width,
      size.height / _artboard.height,
    );

    canvas.save();
    canvas.translate(
      (size.width - _artboard.width * scale) / 2,
      (size.height - _artboard.height * scale) / 2,
    );
    canvas.scale(scale);

    _drawBackAccessory(canvas);
    _drawBackHair(canvas);
    _drawLegs(canvas);
    _drawBottomWear(canvas);
    _drawShoes(canvas);
    _drawTorso(canvas);
    _drawArms(canvas);
    _drawNeck(canvas);
    _drawHead(canvas);
    _drawHair(canvas);
    _drawFace(canvas);
    _drawGlasses(canvas);
    _drawHat(canvas);
    _drawFrontAccessory(canvas);

    canvas.restore();
  }

  Color get _skin {
    switch (_face) {
      case 2:
        return const Color(0xFFFFC48F);
      case 3:
        return const Color(0xFFF0AA78);
      default:
        return const Color(0xFFFFD3AA);
    }
  }

  Color get _hairColor {
    switch (_face) {
      case 2:
        return const Color(0xFF242229);
      case 3:
        return const Color(0xFFA95733);
      default:
        return const Color(0xFF5F3A27);
    }
  }

  Color get _topColor {
    switch (_top) {
      case 1:
        return const Color(0xFFFFF2E5);
      case 2:
        return const Color(0xFFF36F8A);
      case 3:
        return const Color(0xFF4A95D5);
      case 4:
        return const Color(0xFF60825C);
      default:
        return const Color(0xFF66A9E1);
    }
  }

  Color get _bottomColor {
    switch (_bottom) {
      case 1:
        return const Color(0xFFE4A61E);
      case 2:
        return const Color(0xFFE45B97);
      case 3:
        return const Color(0xFF6587BF);
      default:
        return const Color(0xFF5C78B6);
    }
  }

  Color get _skinShadow => _shiftLightness(_skin, -0.09);
  Color get _skinHighlight => _shiftLightness(_skin, 0.08);

  Paint _paint(Color color) => Paint()
    ..isAntiAlias = true
    ..color = color;

  Paint _stroke(Color color, double width) => Paint()
    ..isAntiAlias = true
    ..color = color
    ..strokeWidth = width
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..style = PaintingStyle.stroke;

  Paint _gradient(Rect rect, List<Color> colors) => Paint()
    ..isAntiAlias = true
    ..shader = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    ).createShader(rect);

  Color _shiftLightness(Color color, double delta) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withLightness((hsl.lightness + delta).clamp(0.0, 1.0).toDouble())
        .toColor();
  }

  void _drawBackAccessory(Canvas canvas) {
    if (_accessory != 3) return;

    final wand = _stroke(const Color(0xFF8D6429), 5.2);
    canvas.drawLine(
      _anchors.rightHandCenter + const Offset(15, -4),
      const Offset(194, 79),
      wand,
    );
  }

  void _drawBackHair(Canvas canvas) {
    final hair = _paint(_hairColor);
    final shadow = _paint(_shiftLightness(_hairColor, -0.08));

    if (_face == 2) {
      final back = RRect.fromRectAndRadius(
        const Rect.fromLTWH(48, 18, 124, 112),
        const Radius.circular(54),
      );
      canvas.drawRRect(back, shadow);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(53, 15, 114, 119),
          const Radius.circular(50),
        ),
        hair,
      );
      return;
    }

    if (_face == 3) {
      canvas.drawOval(const Rect.fromLTWH(49, 16, 122, 112), shadow);
      canvas.drawOval(const Rect.fromLTWH(52, 13, 116, 111), hair);
      return;
    }

    canvas.drawOval(const Rect.fromLTWH(50, 15, 120, 110), shadow);
    canvas.drawOval(const Rect.fromLTWH(54, 12, 112, 106), hair);
  }

  void _drawLegs(Canvas canvas) {
    final leg = _gradient(const Rect.fromLTWH(72, 181, 78, 66), [
      _skinHighlight,
      _skin,
    ]);
    final inner = _stroke(_skinShadow.withValues(alpha: 0.34), 2);

    for (final rect in _anchors.legs) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(13)),
        leg,
      );
    }
    canvas.drawLine(const Offset(110, 195), const Offset(110, 236), inner);
  }

  void _drawBottomWear(Canvas canvas) {
    if (_bottom == 2) {
      final skirt = Path()
        ..moveTo(68, 174)
        ..quadraticBezierTo(62, 199, 67, 222)
        ..quadraticBezierTo(109, 234, 153, 222)
        ..quadraticBezierTo(159, 199, 152, 174)
        ..quadraticBezierTo(110, 184, 68, 174)
        ..close();
      canvas.drawShadow(skirt, Colors.black.withValues(alpha: 0.2), 2, false);
      canvas.drawPath(
        skirt,
        _gradient(const Rect.fromLTWH(62, 174, 98, 60), [
          _shiftLightness(_bottomColor, 0.07),
          _bottomColor,
        ]),
      );
      canvas.drawPath(skirt, _stroke(_shiftLightness(_bottomColor, -0.17), 1));
      final pleat = _stroke(Colors.white.withValues(alpha: 0.32), 1.4);
      canvas.drawLine(const Offset(91, 184), const Offset(84, 222), pleat);
      canvas.drawLine(const Offset(110, 186), const Offset(110, 226), pleat);
      canvas.drawLine(const Offset(129, 184), const Offset(136, 222), pleat);
      return;
    }

    if (_bottom == 3) {
      final waist = RRect.fromRectAndRadius(
        const Rect.fromLTWH(65, 174, 90, 22),
        const Radius.circular(10),
      );
      canvas.drawRRect(waist, _paint(_shiftLightness(_bottomColor, -0.05)));
      for (final rect in const [
        Rect.fromLTWH(73, 189, 34, 51),
        Rect.fromLTWH(113, 189, 34, 51),
      ]) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(12)),
          _gradient(rect, [_shiftLightness(_bottomColor, 0.04), _bottomColor]),
        );
      }
      canvas.drawLine(
        const Offset(110, 191),
        const Offset(110, 238),
        _stroke(const Color(0xFF425C8B).withValues(alpha: 0.5), 1.5),
      );
      canvas.drawLine(
        const Offset(82, 205),
        const Offset(99, 205),
        _stroke(Colors.white.withValues(alpha: 0.24), 1.2),
      );
      return;
    }

    final shortsPath = Path()
      ..moveTo(65, 173)
      ..quadraticBezierTo(110, 181, 155, 173)
      ..lineTo(151, 207)
      ..quadraticBezierTo(132, 214, 113, 205)
      ..quadraticBezierTo(110, 202, 107, 205)
      ..quadraticBezierTo(88, 214, 69, 207)
      ..close();
    canvas.drawShadow(
      shortsPath,
      Colors.black.withValues(alpha: 0.16),
      1.5,
      false,
    );
    canvas.drawPath(
      shortsPath,
      _gradient(const Rect.fromLTWH(65, 173, 90, 42), [
        _shiftLightness(_bottomColor, 0.07),
        _bottomColor,
      ]),
    );
    canvas.drawPath(
      shortsPath,
      _stroke(_shiftLightness(_bottomColor, -0.16), 1),
    );
    canvas.drawLine(
      const Offset(110, 182),
      const Offset(110, 209),
      _stroke(
        _shiftLightness(_bottomColor, -0.18).withValues(alpha: 0.65),
        1.2,
      ),
    );
  }

  void _drawShoes(Canvas canvas) {
    final sole = _paint(const Color(0xFF382F2A));
    final shoeTop = _paint(const Color(0xFF5C4D43));
    final highlight = _paint(Colors.white.withValues(alpha: 0.22));

    for (final rect in _anchors.shoes) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(rect.left, rect.top + 8, rect.width, 8),
          const Radius.circular(6),
        ),
        sole,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect, const Radius.circular(12)),
        shoeTop,
      );
      canvas.drawOval(
        Rect.fromLTWH(rect.left + 12, rect.top + 4, 16, 4),
        highlight,
      );
    }
  }

  void _drawTorso(Canvas canvas) {
    final shirt = _shirtPath();
    canvas.drawShadow(shirt, Colors.black.withValues(alpha: 0.14), 2.2, false);
    canvas.drawPath(
      shirt,
      _gradient(_anchors.torso, [_shiftLightness(_topColor, 0.08), _topColor]),
    );
    canvas.drawPath(shirt, _stroke(_shiftLightness(_topColor, -0.18), 1.2));

    final collar = Path()
      ..moveTo(88, 116)
      ..quadraticBezierTo(110, 138, 132, 116)
      ..lineTo(132, 111)
      ..quadraticBezierTo(110, 125, 88, 111)
      ..close();
    canvas.drawPath(collar, _paint(_skin));
    canvas.drawPath(collar, _stroke(_skinShadow.withValues(alpha: 0.28), 1));

    if (_top == 0) {
      _drawPocket(canvas);
    } else if (_top == 3) {
      final stripe = _stroke(Colors.white.withValues(alpha: 0.42), 4.2);
      for (final y in [139.0, 157.0, 175.0]) {
        canvas.drawLine(Offset(68, y), Offset(152, y), stripe);
      }
    } else if (_top == 4) {
      _drawOveralls(canvas);
    } else if (_top == 2) {
      _drawRibbon(canvas);
    }
  }

  Path _shirtPath() => Path()
    ..moveTo(58, 121)
    ..quadraticBezierTo(75, 110, 95, 111)
    ..quadraticBezierTo(110, 119, 125, 111)
    ..quadraticBezierTo(145, 110, 162, 121)
    ..lineTo(162, 181)
    ..quadraticBezierTo(145, 195, 110, 197)
    ..quadraticBezierTo(75, 195, 58, 181)
    ..close();

  void _drawPocket(Canvas canvas) {
    final pocket = RRect.fromRectAndRadius(
      const Rect.fromLTWH(123, 141, 19, 22),
      const Radius.circular(6),
    );
    canvas.drawRRect(pocket, _paint(Colors.white.withValues(alpha: 0.34)));
    canvas.drawLine(
      const Offset(126, 151),
      const Offset(139, 151),
      _stroke(const Color(0xFF2E6FA9).withValues(alpha: 0.32), 1.2),
    );
  }

  void _drawOveralls(Canvas canvas) {
    final denim = _paint(const Color(0xFF3F6F87));
    final bib = RRect.fromRectAndRadius(
      const Rect.fromLTWH(86, 131, 48, 50),
      const Radius.circular(10),
    );
    canvas.drawRRect(bib, denim);
    final strap = _stroke(const Color(0xFF3F6F87), 7);
    canvas.drawLine(const Offset(83, 116), const Offset(98, 139), strap);
    canvas.drawLine(const Offset(137, 116), const Offset(122, 139), strap);
    canvas.drawCircle(
      const Offset(97, 140),
      2.2,
      _paint(const Color(0xFFEEC45A)),
    );
    canvas.drawCircle(
      const Offset(123, 140),
      2.2,
      _paint(const Color(0xFFEEC45A)),
    );
  }

  void _drawRibbon(Canvas canvas) {
    final ribbon = _paint(const Color(0xFFFFD1DA));
    final center = const Offset(110, 127);
    final left = Path()
      ..moveTo(center.dx, center.dy)
      ..quadraticBezierTo(93, 117, 86, 128)
      ..quadraticBezierTo(94, 139, center.dx, center.dy)
      ..close();
    final right = Path()
      ..moveTo(center.dx, center.dy)
      ..quadraticBezierTo(127, 117, 134, 128)
      ..quadraticBezierTo(126, 139, center.dx, center.dy)
      ..close();
    canvas.drawPath(left, ribbon);
    canvas.drawPath(right, ribbon);
    canvas.drawCircle(center, 4.5, _paint(const Color(0xFFF06D8B)));
  }

  void _drawArms(Canvas canvas) {
    _drawArm(
      canvas,
      shoulder: const Offset(57, 123),
      elbow: const Offset(42, 157),
      hand: _anchors.leftHandCenter,
      flip: false,
    );
    _drawArm(
      canvas,
      shoulder: const Offset(163, 123),
      elbow: const Offset(178, 157),
      hand: _anchors.rightHandCenter,
      flip: true,
    );
  }

  void _drawArm(
    Canvas canvas, {
    required Offset shoulder,
    required Offset elbow,
    required Offset hand,
    required bool flip,
  }) {
    final sleeve = Path()
      ..moveTo(shoulder.dx, shoulder.dy)
      ..quadraticBezierTo(
        flip ? shoulder.dx + 21 : shoulder.dx - 21,
        shoulder.dy + 5,
        elbow.dx,
        elbow.dy - 2,
      )
      ..quadraticBezierTo(
        flip ? elbow.dx - 7 : elbow.dx + 7,
        elbow.dy + 15,
        flip ? elbow.dx - 1 : elbow.dx + 1,
        elbow.dy + 28,
      )
      ..quadraticBezierTo(
        flip ? shoulder.dx + 8 : shoulder.dx - 8,
        shoulder.dy + 42,
        shoulder.dx,
        shoulder.dy,
      )
      ..close();
    canvas.drawPath(
      sleeve,
      _gradient(Rect.fromCircle(center: elbow, radius: 34), [
        _shiftLightness(_topColor, 0.08),
        _topColor,
      ]),
    );

    final forearm = Path()
      ..moveTo(flip ? elbow.dx - 5 : elbow.dx + 5, elbow.dy + 20)
      ..quadraticBezierTo(
        flip ? hand.dx + 2 : hand.dx - 2,
        hand.dy - 28,
        hand.dx,
        hand.dy - 8,
      )
      ..quadraticBezierTo(
        flip ? hand.dx + 8 : hand.dx - 8,
        hand.dy + 4,
        hand.dx,
        hand.dy + 13,
      )
      ..quadraticBezierTo(
        flip ? elbow.dx - 16 : elbow.dx + 16,
        elbow.dy + 49,
        flip ? elbow.dx - 11 : elbow.dx + 11,
        elbow.dy + 18,
      )
      ..close();
    canvas.drawPath(
      forearm,
      _gradient(Rect.fromCircle(center: hand, radius: 38), [
        _skinHighlight,
        _skin,
      ]),
    );
    canvas.drawOval(
      Rect.fromCenter(center: hand, width: 25, height: 20),
      _paint(_skin),
    );
    final finger = _stroke(_skinShadow.withValues(alpha: 0.36), 1.1);
    canvas.drawLine(
      hand + Offset(flip ? -3 : 3, 3),
      hand + Offset(flip ? -10 : 10, 8),
      finger,
    );
  }

  void _drawNeck(Canvas canvas) {
    final neck = RRect.fromRectAndRadius(
      _anchors.neck,
      const Radius.circular(12),
    );
    canvas.drawRRect(neck, _gradient(_anchors.neck, [_skinHighlight, _skin]));
    canvas.drawOval(
      const Rect.fromLTWH(91, 111, 38, 11),
      _paint(_skinShadow.withValues(alpha: 0.24)),
    );
  }

  void _drawHead(Canvas canvas) {
    final ears = [_anchors.leftEar, _anchors.rightEar];
    for (final ear in ears) {
      canvas.drawOval(ear, _gradient(ear, [_skinHighlight, _skin]));
      canvas.drawArc(
        ear.deflate(4),
        -math.pi / 2,
        math.pi,
        false,
        _stroke(_skinShadow.withValues(alpha: 0.3), 1.2),
      );
    }

    final faceRect = switch (_face) {
      2 => const Rect.fromLTWH(59, 29, 102, 99),
      3 => const Rect.fromLTWH(56, 31, 108, 96),
      _ => _anchors.face,
    };
    canvas.drawOval(faceRect, _gradient(faceRect, [_skinHighlight, _skin]));
    canvas.drawArc(
      const Rect.fromLTWH(77, 92, 66, 38),
      0.15,
      math.pi - 0.3,
      false,
      _stroke(_skinShadow.withValues(alpha: 0.18), 1.5),
    );
    canvas.drawOval(
      const Rect.fromLTWH(74, 77, 20, 10),
      _paint(const Color(0xFFFF9FA4).withValues(alpha: 0.28)),
    );
    canvas.drawOval(
      const Rect.fromLTWH(126, 77, 20, 10),
      _paint(const Color(0xFFFF9FA4).withValues(alpha: 0.28)),
    );
  }

  void _drawHair(Canvas canvas) {
    final hair = _paint(_hairColor);
    final dark = _stroke(
      _shiftLightness(_hairColor, -0.13).withValues(alpha: 0.55),
      1.2,
    );
    final shine = _stroke(
      _shiftLightness(_hairColor, 0.11).withValues(alpha: 0.5),
      2,
    );

    if (_face == 2) {
      canvas.drawArc(
        const Rect.fromLTWH(56, 18, 108, 73),
        math.pi,
        math.pi,
        true,
        hair,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(50, 58, 22, 63),
          const Radius.circular(12),
        ),
        hair,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(148, 58, 22, 63),
          const Radius.circular(12),
        ),
        hair,
      );
      canvas.drawLine(const Offset(83, 32), const Offset(78, 83), shine);
      canvas.drawLine(const Offset(139, 34), const Offset(145, 82), shine);
      return;
    }

    final crown = Path()
      ..moveTo(55, 60)
      ..quadraticBezierTo(63, 21, 99, 17)
      ..quadraticBezierTo(129, 10, 159, 38)
      ..quadraticBezierTo(166, 49, 164, 65)
      ..quadraticBezierTo(144, 42, 125, 52)
      ..quadraticBezierTo(106, 28, 84, 54)
      ..quadraticBezierTo(71, 48, 55, 60)
      ..close();
    canvas.drawPath(crown, hair);

    final frontHair = Path()
      ..moveTo(56, 61)
      ..quadraticBezierTo(71, 39, 91, 47)
      ..quadraticBezierTo(105, 22, 122, 48)
      ..quadraticBezierTo(143, 38, 164, 65)
      ..lineTo(158, 72)
      ..quadraticBezierTo(143, 58, 127, 61)
      ..quadraticBezierTo(112, 50, 96, 61)
      ..quadraticBezierTo(75, 56, 59, 70)
      ..close();
    canvas.drawPath(frontHair, hair);
    canvas.drawPath(frontHair, dark);

    final strand = _stroke(
      _shiftLightness(_hairColor, -0.18).withValues(alpha: 0.35),
      1.1,
    );
    canvas.drawLine(const Offset(83, 46), const Offset(74, 67), strand);
    canvas.drawLine(const Offset(110, 39), const Offset(108, 64), strand);
    canvas.drawLine(const Offset(139, 47), const Offset(151, 67), strand);

    canvas.drawLine(const Offset(90, 29), const Offset(80, 55), shine);
    canvas.drawLine(const Offset(132, 30), const Offset(147, 55), shine);
  }

  void _drawFace(Canvas canvas) {
    _drawEyebrows(canvas);
    _drawEyes(canvas);
    _drawNose(canvas);
    _drawMouth(canvas);
  }

  void _drawEyebrows(Canvas canvas) {
    final brow = _stroke(_shiftLightness(_hairColor, -0.12), 2.4);
    canvas.drawLine(const Offset(82, 66), const Offset(98, 63), brow);
    canvas.drawLine(const Offset(122, 63), const Offset(138, 66), brow);
  }

  void _drawEyes(Canvas canvas) {
    final centers = [const Offset(91, 75), const Offset(129, 75)];
    final outline = _paint(const Color(0xFF25232A));
    final white = _paint(Colors.white.withValues(alpha: 0.95));
    final iris = _paint(
      _eyes == 2 ? const Color(0xFF5B7E9E) : const Color(0xFF3E2B22),
    );
    final highlight = _paint(Colors.white);

    if (_eyes == 3) {
      final closed = _stroke(const Color(0xFF2B2A30), 3.5);
      canvas.drawArc(
        const Rect.fromLTWH(82, 68, 18, 12),
        0.1,
        math.pi - 0.2,
        false,
        closed,
      );
      canvas.drawArc(
        const Rect.fromLTWH(120, 68, 18, 12),
        0.1,
        math.pi - 0.2,
        false,
        closed,
      );
      return;
    }

    for (final center in centers) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: 18, height: 14),
        white,
      );
      canvas.drawOval(
        Rect.fromCenter(center: center, width: 10, height: 12),
        iris,
      );
      canvas.drawCircle(center, _eyes == 2 ? 4.2 : 4.8, outline);
      canvas.drawCircle(center - const Offset(2.3, 2.8), 1.8, highlight);
    }
  }

  void _drawNose(Canvas canvas) {
    final nose = _stroke(
      _skinShadow.withValues(alpha: 0.48),
      _nose == 2 ? 2.4 : 1.8,
    );
    if (_nose == 2) {
      canvas.drawArc(
        const Rect.fromLTWH(105, 77, 13, 16),
        -0.1,
        math.pi * 0.78,
        false,
        nose,
      );
    } else {
      canvas.drawLine(const Offset(111, 78), const Offset(109, 90), nose);
      canvas.drawLine(
        const Offset(109, 90),
        const Offset(114, 90),
        _stroke(_skinShadow.withValues(alpha: 0.35), 1.2),
      );
    }
  }

  void _drawMouth(Canvas canvas) {
    final mouth = _stroke(const Color(0xFF4A3030), 3);
    if (_mouth == 3) {
      canvas.drawArc(
        const Rect.fromLTWH(99, 93, 24, 12),
        math.pi + 0.2,
        math.pi - 0.4,
        false,
        mouth,
      );
      return;
    }
    canvas.drawArc(
      _mouth == 2
          ? const Rect.fromLTWH(98, 88, 26, 18)
          : const Rect.fromLTWH(99, 88, 24, 16),
      0.12,
      math.pi - 0.24,
      false,
      mouth,
    );
    if (_mouth == 2) {
      canvas.drawOval(
        const Rect.fromLTWH(105, 96, 11, 5),
        _paint(const Color(0xFFFF8A90).withValues(alpha: 0.55)),
      );
    }
  }

  void _drawGlasses(Canvas canvas) {
    if (_glasses == 0) return;

    final color = switch (_glasses) {
      2 => const Color(0xFFC28A25),
      3 => const Color(0xFFC754A5),
      _ => const Color(0xFF20483D),
    };
    final frame = _stroke(color, 3);

    if (_glasses == 3) {
      _drawStar(canvas, const Offset(91, 75), 11, color);
      _drawStar(canvas, const Offset(129, 75), 11, color);
    } else if (_glasses == 2) {
      canvas.drawCircle(const Offset(91, 75), 12, frame);
      canvas.drawCircle(const Offset(129, 75), 12, frame);
    } else {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(77, 67, 28, 18),
          const Radius.circular(6),
        ),
        _paint(color.withValues(alpha: 0.9)),
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(115, 67, 28, 18),
          const Radius.circular(6),
        ),
        _paint(color.withValues(alpha: 0.9)),
      );
    }
    canvas.drawLine(const Offset(103, 75), const Offset(117, 75), frame);
  }

  void _drawHat(Canvas canvas) {
    if (_hat == 0) return;

    if (_hat == 1) {
      final cap = _paint(const Color(0xFFFF7043));
      final bill = _paint(const Color(0xFFE65E38));
      canvas.drawArc(
        const Rect.fromLTWH(61, 23, 98, 52),
        math.pi,
        math.pi,
        true,
        cap,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(75, 25, 70, 37),
          const Radius.circular(18),
        ),
        cap,
      );
      canvas.drawOval(const Rect.fromLTWH(128, 55, 45, 11), bill);
      canvas.drawLine(
        const Offset(110, 27),
        const Offset(110, 61),
        _stroke(Colors.white.withValues(alpha: 0.23), 1.2),
      );
      return;
    }

    if (_hat == 2) {
      final crown = Path()
        ..moveTo(70, 47)
        ..lineTo(83, 17)
        ..lineTo(101, 43)
        ..lineTo(111, 13)
        ..lineTo(129, 43)
        ..lineTo(146, 18)
        ..lineTo(151, 58)
        ..lineTo(70, 58)
        ..close();
      canvas.drawPath(crown, _paint(const Color(0xFFFFC928)));
      canvas.drawPath(crown, _stroke(const Color(0xFFE39B13), 1.2));
      for (final p in const [
        Offset(83, 17),
        Offset(111, 13),
        Offset(146, 18),
      ]) {
        canvas.drawCircle(p, 3.4, _paint(const Color(0xFFFFF3A3)));
      }
      return;
    }

    if (_hat == 3) {
      final hat = _paint(const Color(0xFF6B4B32));
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          const Rect.fromLTWH(80, 16, 60, 43),
          const Radius.circular(14),
        ),
        hat,
      );
      canvas.drawOval(const Rect.fromLTWH(52, 52, 116, 20), hat);
      canvas.drawRect(
        const Rect.fromLTWH(82, 49, 56, 7),
        _paint(const Color(0xFF473325)),
      );
      return;
    }

    final cone = Path()
      ..moveTo(111, 1)
      ..lineTo(76, 63)
      ..lineTo(148, 63)
      ..close();
    canvas.drawPath(cone, _paint(const Color(0xFF6C4CCF)));
    canvas.drawPath(cone, _stroke(const Color(0xFF4F37A5), 1.2));
    canvas.drawOval(
      const Rect.fromLTWH(68, 57, 86, 14),
      _paint(const Color(0xFF6C4CCF)),
    );
    _drawStar(canvas, const Offset(111, 31), 7, const Color(0xFFFFD54F));
  }

  void _drawFrontAccessory(Canvas canvas) {
    if (_accessory == 1) {
      final bagRect = RRect.fromRectAndRadius(
        const Rect.fromLTWH(158, 172, 31, 36),
        const Radius.circular(8),
      );
      canvas.drawRRect(bagRect, _paint(const Color(0xFFE55C73)));
      canvas.drawRRect(
        bagRect.deflate(4),
        _paint(const Color(0xFFFF7E95).withValues(alpha: 0.35)),
      );
      canvas.drawArc(
        const Rect.fromLTWH(161, 159, 26, 31),
        math.pi + 0.12,
        math.pi * 1.55,
        false,
        _stroke(const Color(0xFFC74760), 4),
      );
      _drawHeart(canvas, const Offset(173, 189), const Color(0xFFFFC3CB));
      _drawGripFingers(canvas, const Offset(177, 188));
      return;
    }

    if (_accessory == 2) {
      final book = RRect.fromRectAndRadius(
        const Rect.fromLTWH(152, 165, 38, 47),
        const Radius.circular(5),
      );
      canvas.drawRRect(book, _paint(const Color(0xFF2D6B87)));
      canvas.drawLine(
        const Offset(160, 170),
        const Offset(160, 206),
        _stroke(const Color(0xFF17495E), 3),
      );
      for (final y in [178.0, 188.0, 198.0]) {
        canvas.drawLine(
          Offset(166, y),
          Offset(183, y),
          _stroke(Colors.white.withValues(alpha: 0.42), 1.3),
        );
      }
      _drawGripFingers(canvas, const Offset(174, 188));
      return;
    }

    if (_accessory == 3) {
      _drawStar(canvas, const Offset(194, 79), 18, const Color(0xFFFFD84D));
      _drawStar(canvas, const Offset(194, 79), 9, const Color(0xFFFFF3A3));
      canvas.drawCircle(
        const Offset(180, 187),
        4.6,
        _paint(const Color(0xFF8D6429)),
      );
      _drawGripFingers(canvas, const Offset(180, 188));
    }
  }

  void _drawGripFingers(Canvas canvas, Offset center) {
    final palm = _paint(_skin);
    final finger = _stroke(_skinShadow.withValues(alpha: 0.48), 1.1);
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 17, height: 12),
      palm,
    );
    canvas.drawLine(
      center + const Offset(-5, -1),
      center + const Offset(5, -1),
      finger,
    );
    canvas.drawLine(
      center + const Offset(-4, 3),
      center + const Offset(5, 3),
      finger,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final path = Path();
    for (var i = 0; i < 10; i++) {
      final r = i.isEven ? radius : radius * 0.42;
      final angle = -math.pi / 2 + i * math.pi / 5;
      final point = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path..close(), _paint(color));
  }

  void _drawHeart(Canvas canvas, Offset center, Color color) {
    const r = 5.0;
    final path = Path()
      ..moveTo(center.dx, center.dy + r)
      ..cubicTo(
        center.dx - 11,
        center.dy - 1,
        center.dx - 8,
        center.dy - 9,
        center.dx - 2,
        center.dy - 5,
      )
      ..cubicTo(
        center.dx,
        center.dy - 8,
        center.dx + 2,
        center.dy - 8,
        center.dx + 4,
        center.dy - 5,
      )
      ..cubicTo(
        center.dx + 10,
        center.dy - 9,
        center.dx + 12,
        center.dy - 1,
        center.dx,
        center.dy + r,
      )
      ..close();
    canvas.drawPath(path, _paint(color));
  }

  @override
  bool shouldRepaint(covariant ChildAvatarPainter oldDelegate) {
    if (variants.length != oldDelegate.variants.length) return true;
    for (var i = 0; i < variants.length; i++) {
      if (variants[i] != oldDelegate.variants[i]) return true;
    }
    return false;
  }
}

class _AvatarAnchors {
  const _AvatarAnchors();

  Rect get face => const Rect.fromLTWH(56, 28, 108, 101);
  Rect get neck => const Rect.fromLTWH(96, 101, 28, 30);
  Rect get torso => const Rect.fromLTWH(56, 111, 108, 87);
  Rect get leftEar => const Rect.fromLTWH(48, 67, 17, 23);
  Rect get rightEar => const Rect.fromLTWH(155, 67, 17, 23);
  Offset get leftHandCenter => const Offset(42, 194);
  Offset get rightHandCenter => const Offset(178, 194);

  List<Rect> get legs => const [
    Rect.fromLTWH(75, 188, 31, 57),
    Rect.fromLTWH(114, 188, 31, 57),
  ];

  List<Rect> get shoes => const [
    Rect.fromLTWH(63, 232, 48, 16),
    Rect.fromLTWH(109, 232, 48, 16),
  ];
}
