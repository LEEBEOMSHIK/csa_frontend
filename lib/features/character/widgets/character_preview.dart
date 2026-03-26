import 'dart:math' as math;
import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CharacterPreview widget  (HitZone 탭 포함)
// ─────────────────────────────────────────────────────────────────────────────

/// 인간형 2D 캐릭터 미리보기.
/// [selectedVariants]: [0]=hat, [1]=top, [2]=bottom, [3]=glasses,
///                     [4]=accessory, [5]=face, [6]=eyes, [7]=nose, [8]=mouth
class CharacterPreview extends StatelessWidget {
  final List<int> selectedVariants;
  final int selectedTabIndex;
  final ValueChanged<int> onPartTapped;

  const CharacterPreview({
    super.key,
    required this.selectedVariants,
    required this.selectedTabIndex,
    required this.onPartTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 120,
      height: 148,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          CustomPaint(
            size: const Size(120, 148),
            painter: CharacterPainter(
              hatVariant:       selectedVariants[0],
              topVariant:       selectedVariants[1],
              bottomVariant:    selectedVariants[2],
              glassesVariant:   selectedVariants[3],
              accessoryVariant: selectedVariants[4],
              faceVariant:      selectedVariants.length > 5 ? selectedVariants[5] : 1,
              eyesVariant:      selectedVariants.length > 6 ? selectedVariants[6] : 1,
              noseVariant:      selectedVariants.length > 7 ? selectedVariants[7] : 1,
              mouthVariant:     selectedVariants.length > 8 ? selectedVariants[8] : 1,
            ),
          ),
          // HitZone: 모자 영역 (머리 위)
          _HitZone(top: 0,   height: 28, left: 16, right: 16, tabIndex: 1,
              isActive: selectedTabIndex == 1, onTap: onPartTapped),
          // HitZone: 얼굴형
          _HitZone(top: 6,   height: 22, left: 20, right: 20, tabIndex: 6,
              isActive: selectedTabIndex == 6, onTap: onPartTapped),
          // HitZone: 안경 (눈 영역)
          _HitZone(top: 18,  height: 12, left: 22, right: 22, tabIndex: 4,
              isActive: selectedTabIndex == 4, onTap: onPartTapped),
          // HitZone: 눈
          _HitZone(top: 17,  height: 10, left: 26, right: 26, tabIndex: 7,
              isActive: selectedTabIndex == 7, onTap: onPartTapped),
          // HitZone: 코
          _HitZone(top: 27,  height: 8,  left: 36, right: 36, tabIndex: 8,
              isActive: selectedTabIndex == 8, onTap: onPartTapped),
          // HitZone: 입
          _HitZone(top: 35,  height: 10, left: 30, right: 30, tabIndex: 9,
              isActive: selectedTabIndex == 9, onTap: onPartTapped),
          // HitZone: 상의
          _HitZone(top: 58,  height: 44, left: 6,  right: 6,  tabIndex: 2,
              isActive: selectedTabIndex == 2, onTap: onPartTapped),
          // HitZone: 하의
          _HitZone(top: 102, height: 38, left: 10, right: 10, tabIndex: 3,
              isActive: selectedTabIndex == 3, onTap: onPartTapped),
          // HitZone: 악세서리 (오른쪽 옆)
          _HitZone(top: 60,  height: 44, left: 90, right: 0,  tabIndex: 5,
              isActive: selectedTabIndex == 5, onTap: onPartTapped),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// HitZone
// ─────────────────────────────────────────────────────────────────────────────

class _HitZone extends StatelessWidget {
  final double top, height, left, right;
  final int tabIndex;
  final bool isActive;
  final ValueChanged<int> onTap;

  const _HitZone({
    required this.top, required this.height,
    required this.left, required this.right,
    required this.tabIndex, required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: top, left: left, right: right, height: height,
      child: GestureDetector(
        onTap: () => onTap(tabIndex),
        child: Container(
          decoration: BoxDecoration(
            color: isActive
                ? const Color(0xFFFF7043).withValues(alpha: 0.10)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: isActive
                ? Border.all(
                    color: const Color(0xFFFF7043).withValues(alpha: 0.45),
                    width: 1.2)
                : null,
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// CharacterPainter — 인간형 2D 캐릭터
//
// Canvas: 120 × 148 px, cx = 60
//
// 레이아웃 (y 좌표):
//   y  6 – 50  ← 머리 (원 반지름 22, 중심 y=28)
//   y 49 – 59  ← 목
//   y 58 –106  ← 상체 / 셔츠
//   y 62 – 98  ← 팔
//  y104 –138  ← 하체 / 바지
//  y138 –148  ← 발 / 신발
// ─────────────────────────────────────────────────────────────────────────────

class CharacterPainter extends CustomPainter {
  final int hatVariant;
  final int topVariant;
  final int bottomVariant;
  final int glassesVariant;
  final int accessoryVariant;
  final int faceVariant;   // 1-4: 얼굴형 + 헤어
  final int eyesVariant;   // 1-4: 눈 스타일
  final int noseVariant;   // 1-4: 코 스타일
  final int mouthVariant;  // 1-4: 입 스타일
  final bool clothesOnly;  // true: 의상/모자/악세서리만 그림 (몸통/머리/눈/코/입 생략)

  const CharacterPainter({
    required this.hatVariant,
    required this.topVariant,
    required this.bottomVariant,
    required this.glassesVariant,
    required this.accessoryVariant,
    this.faceVariant   = 1,
    this.eyesVariant   = 1,
    this.noseVariant   = 1,
    this.mouthVariant  = 1,
    this.clothesOnly   = false,
  });

  // ── 스킨 색상 ──
  static const _skin     = Color(0xFFFFCBAA);
  static const _skinDeep = Color(0xFFE8A87C);

  // 얼굴형별 헤어 색상
  static const _hairColors = [
    Color(0xFF000000), // 미사용 index 0
    Color(0xFF5C3317), // 1: 브라운
    Color(0xFF1A1A1A), // 2: 블랙
    Color(0xFFD4A017), // 3: 블론드
    Color(0xFF8B1A1A), // 4: 레드
  ];

  Color get _hairColor =>
      (faceVariant >= 1 && faceVariant <= 4) ? _hairColors[faceVariant] : _hairColors[1];

  // ── 드로잉 순서 ──────────────────────────────────────────────────────────────
  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2; // 60

    _drawAccessory(canvas, cx, size, front: false);
    _drawBottom(canvas, cx, size);
    if (!clothesOnly) _drawBodySkin(canvas, cx);
    _drawTop(canvas, cx, size);
    _drawLowerArms(canvas, cx);
    _drawFeet(canvas, cx);
    if (!clothesOnly) _drawHead(canvas, cx);
    if (!clothesOnly) _drawHair(canvas, cx);
    if (!clothesOnly) _drawEyes(canvas, cx);
    if (!clothesOnly) _drawNose(canvas, cx);
    if (!clothesOnly) _drawMouth(canvas, cx);
    _drawGlasses(canvas, cx);
    _drawHat(canvas, cx);
    _drawAccessory(canvas, cx, size, front: true);
  }

  // ── 피부 기반 바디 (옷으로 덮임) ──────────────────────────────────────────────

  void _drawBodySkin(Canvas canvas, double cx) {
    final p = Paint()..color = _skin;

    // 목 (y49-y59)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, 54), width: 15, height: 12),
        const Radius.circular(6),
      ),
      p,
    );

    // 몸통
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, 83), width: 54, height: 50),
        const Radius.circular(14),
      ),
      p,
    );

    // 팔 (상박 — 소매로 덮임)
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 34, 78), width: 17, height: 44), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 34, 78), width: 17, height: 44), p);

    // 다리 (바지로 덮임)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 13, 122), width: 18, height: 38),
        const Radius.circular(8),
      ),
      p,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 13, 122), width: 18, height: 38),
        const Radius.circular(8),
      ),
      p,
    );
  }

  // ── 하박/손 (소매 아래로 보이는 부분) ────────────────────────────────────────

  void _drawLowerArms(Canvas canvas, double cx) {
    if (topVariant == 0) return; // 옷 없음 = 전체 팔이 이미 _drawBodySkin 에서 보임
    final p = Paint()..color = _skin;
    // 소매 아래 하박 y82-y98
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 34, 91), width: 14, height: 18), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 34, 91), width: 14, height: 18), p);
  }

  // ── 발 / 신발 ──────────────────────────────────────────────────────────────

  void _drawFeet(Canvas canvas, double cx) {
    final shoePaint = Paint()..color = const Color(0xFF3A3A3A);
    // 신발
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx - 13, 141), width: 22, height: 10),
      shoePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(cx + 13, 141), width: 22, height: 10),
      shoePaint,
    );
    // 신발 하이라이트
    final hl = Paint()..color = Colors.white.withValues(alpha: 0.2);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 15, 139), width: 10, height: 4), hl);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 11, 139), width: 10, height: 4), hl);
  }

  // ── 머리 (얼굴형에 따라 달라짐) ──────────────────────────────────────────────

  void _drawHead(Canvas canvas, double cx) {
    final headPaint = Paint()..color = _skin;
    final shadowPaint = Paint()..color = _skinDeep.withValues(alpha: 0.25);

    switch (faceVariant) {
      case 2: // 타원형 (약간 긴 얼굴)
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, 29), width: 40, height: 47),
          headPaint,
        );
        // 볼 그늘
        canvas.drawOval(Rect.fromCenter(center: Offset(cx - 14, 34), width: 12, height: 8), shadowPaint);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx + 14, 34), width: 12, height: 8), shadowPaint);

      case 3: // 각진 얼굴
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(cx, 28), width: 44, height: 44),
            const Radius.circular(13),
          ),
          headPaint,
        );
        canvas.drawOval(Rect.fromCenter(center: Offset(cx - 15, 33), width: 10, height: 7), shadowPaint);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx + 15, 33), width: 10, height: 7), shadowPaint);

      case 4: // 넓고 귀여운 얼굴
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, 27), width: 48, height: 42),
          headPaint,
        );
        canvas.drawOval(Rect.fromCenter(center: Offset(cx - 17, 32), width: 13, height: 9), shadowPaint);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx + 17, 32), width: 13, height: 9), shadowPaint);

      default: // case 1: 둥근 얼굴
        canvas.drawCircle(Offset(cx, 28), 22, headPaint);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx - 14, 33), width: 11, height: 7), shadowPaint);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx + 14, 33), width: 11, height: 7), shadowPaint);
    }
  }

  // ── 헤어 (얼굴형에 연동) ──────────────────────────────────────────────────────

  void _drawHair(Canvas canvas, double cx) {
    final hp = Paint()..color = _hairColor;

    switch (faceVariant) {
      case 2: // 직모 블랙
        // 상단 캡
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, 16), width: 44, height: 30), hp);
        // 양 옆 내려오는 머리카락
        canvas.drawOval(Rect.fromCenter(center: Offset(cx - 21, 35), width: 8, height: 26), hp);
        canvas.drawOval(Rect.fromCenter(center: Offset(cx + 21, 35), width: 8, height: 26), hp);

      case 3: // 삐쭉 블론드 (스파이키)
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, 15), width: 42, height: 26), hp);
        // 뾰족한 삐죽머리
        final spikeL = Path()..moveTo(cx - 14, 8)..lineTo(cx - 22, -6)..lineTo(cx - 6, 6)..close();
        final spikeM = Path()..moveTo(cx - 5, 6)..lineTo(cx, -10)..lineTo(cx + 5, 6)..close();
        final spikeR = Path()..moveTo(cx + 6, 8)..lineTo(cx + 22, -4)..lineTo(cx + 14, 9)..close();
        canvas.drawPath(spikeL, hp);
        canvas.drawPath(spikeM, hp);
        canvas.drawPath(spikeR, hp);

      case 4: // 웨이브 레드 (풍성한 곱슬)
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, 14), width: 50, height: 30), hp);
        canvas.drawCircle(Offset(cx - 22, 24), 10, hp);
        canvas.drawCircle(Offset(cx + 22, 24), 10, hp);
        canvas.drawCircle(Offset(cx - 20, 36), 8, hp);
        canvas.drawCircle(Offset(cx + 20, 36), 8, hp);

      default: // case 1: 캐주얼 브라운
        // 상단 머리
        canvas.drawOval(Rect.fromCenter(center: Offset(cx, 14), width: 46, height: 28), hp);
        // 앞머리 (이마에 조금 내려옴)
        final bang = Path()
          ..moveTo(cx - 20, 18)
          ..quadraticBezierTo(cx - 12, 26, cx - 4, 18)
          ..quadraticBezierTo(cx + 4, 12, cx + 10, 20)
          ..quadraticBezierTo(cx + 18, 28, cx + 22, 20)
          ..lineTo(cx + 22, 10)
          ..lineTo(cx - 20, 10)
          ..close();
        canvas.drawPath(bang, hp);
    }
  }

  // ── 눈 (eyesVariant에 따라 달라짐) ────────────────────────────────────────────

  void _drawEyes(Canvas canvas, double cx) {
    // 눈 위치: 얼굴형 중심 기준으로 계산
    final ey = _eyeY;
    final lx = cx - 8.0;
    final rx = cx + 8.0;

    switch (eyesVariant) {
      case 2: // 반짝이는 큰 눈
        final eyePaint = Paint()..color = const Color(0xFF1A1A1A);
        canvas.drawCircle(Offset(lx, ey), 5, eyePaint);
        canvas.drawCircle(Offset(rx, ey), 5, eyePaint);
        // 홍채 (짙은 갈색)
        canvas.drawCircle(Offset(lx, ey), 3.5, Paint()..color = const Color(0xFF3B2800));
        canvas.drawCircle(Offset(rx, ey), 3.5, Paint()..color = const Color(0xFF3B2800));
        // 별 모양 하이라이트 (여러 점)
        final hl = Paint()..color = Colors.white;
        canvas.drawCircle(Offset(lx - 2, ey - 2), 1.6, hl);
        canvas.drawCircle(Offset(lx + 1.5, ey - 1.5), 0.9, hl);
        canvas.drawCircle(Offset(rx - 2, ey - 2), 1.6, hl);
        canvas.drawCircle(Offset(rx + 1.5, ey - 1.5), 0.9, hl);

      case 3: // 졸린 눈 (반쯤 감긴)
        final eyePaint = Paint()..color = const Color(0xFF1A1A1A);
        // 아래 반원만 그림
        final leftEye = Path()
          ..addArc(Rect.fromCenter(center: Offset(lx, ey), width: 10, height: 8), 0, math.pi);
        final rightEye = Path()
          ..addArc(Rect.fromCenter(center: Offset(rx, ey), width: 10, height: 8), 0, math.pi);
        canvas.drawPath(leftEye, eyePaint);
        canvas.drawPath(rightEye, eyePaint);
        // 윗 속눈썹선
        canvas.drawLine(
          Offset(lx - 5, ey), Offset(lx + 5, ey),
          Paint()..color = const Color(0xFF1A1A1A)..strokeWidth = 2..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          Offset(rx - 5, ey), Offset(rx + 5, ey),
          Paint()..color = const Color(0xFF1A1A1A)..strokeWidth = 2..strokeCap = StrokeCap.round,
        );

      case 4: // 별 눈
        _drawSmallStar(canvas, Offset(lx, ey), 5.5,
            Paint()..color = const Color(0xFF1A1A1A));
        _drawSmallStar(canvas, Offset(rx, ey), 5.5,
            Paint()..color = const Color(0xFF1A1A1A));
        canvas.drawCircle(Offset(lx - 1, ey - 1.5), 1.2, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(rx - 1, ey - 1.5), 1.2, Paint()..color = Colors.white);

      default: // case 1: 기본 귀여운 눈
        final eyePaint = Paint()..color = const Color(0xFF1A1A1A);
        canvas.drawCircle(Offset(lx, ey), 4, eyePaint);
        canvas.drawCircle(Offset(rx, ey), 4, eyePaint);
        // 하이라이트
        canvas.drawCircle(Offset(lx - 1.5, ey - 1.5), 1.2, Paint()..color = Colors.white);
        canvas.drawCircle(Offset(rx - 1.5, ey - 1.5), 1.2, Paint()..color = Colors.white);
        // 속눈썹 윗선
        canvas.drawLine(
          Offset(lx - 4, ey - 3.5), Offset(lx + 4, ey - 3.5),
          Paint()..color = const Color(0xFF1A1A1A)..strokeWidth = 1.5..strokeCap = StrokeCap.round,
        );
        canvas.drawLine(
          Offset(rx - 4, ey - 3.5), Offset(rx + 4, ey - 3.5),
          Paint()..color = const Color(0xFF1A1A1A)..strokeWidth = 1.5..strokeCap = StrokeCap.round,
        );
    }
  }

  // ── 코 ──────────────────────────────────────────────────────────────────────

  void _drawNose(Canvas canvas, double cx) {
    final ny = _eyeY + 10.0;

    switch (noseVariant) {
      case 2: // 동글 버튼 코
        canvas.drawCircle(Offset(cx, ny), 3.5,
            Paint()..color = _skinDeep.withValues(alpha: 0.6));
        canvas.drawCircle(Offset(cx, ny), 2,
            Paint()..color = _skinDeep.withValues(alpha: 0.3));

      case 3: // 주근깨 + 작은 코
        canvas.drawCircle(Offset(cx, ny), 2.5,
            Paint()..color = _skinDeep.withValues(alpha: 0.5));
        // 주근깨
        final freckle = Paint()..color = _skinDeep.withValues(alpha: 0.45);
        for (final off in [
          Offset(-7.0, 5.0), Offset(-5.0, 7.0), Offset(-9.0, 7.0),
          Offset(7.0, 5.0),  Offset(5.0, 7.0),  Offset(9.0, 7.0),
        ]) {
          canvas.drawCircle(Offset(cx + off.dx, ny + off.dy - 2), 1.3, freckle);
        }

      case 4: // 들창코 (작은 삼각형)
        final nosePath = Path()
          ..moveTo(cx - 4, ny + 2)
          ..lineTo(cx + 4, ny + 2)
          ..lineTo(cx, ny - 3)
          ..close();
        canvas.drawPath(nosePath,
            Paint()..color = _skinDeep.withValues(alpha: 0.4));

      default: // case 1: 작은 점 코
        canvas.drawCircle(Offset(cx - 2.5, ny), 1.6,
            Paint()..color = _skinDeep.withValues(alpha: 0.55));
        canvas.drawCircle(Offset(cx + 2.5, ny), 1.6,
            Paint()..color = _skinDeep.withValues(alpha: 0.55));
    }
  }

  // ── 입 ──────────────────────────────────────────────────────────────────────

  void _drawMouth(Canvas canvas, double cx) {
    final my = _eyeY + 20.0;
    final mouthStroke = Paint()
      ..color = const Color(0xFFCC7755)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    switch (mouthVariant) {
      case 2: // 활짝 웃음 (치아 보임)
        // 입술 배경 (열린 입)
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, my), width: 18, height: 10),
          Paint()..color = const Color(0xFFCC4444),
        );
        // 치아
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, my - 1), width: 14, height: 6),
          Paint()..color = Colors.white,
        );
        // 볼 홍조
        _drawBlush(canvas, cx, my);

      case 3: // 무표정 (직선)
        canvas.drawLine(
          Offset(cx - 7, my), Offset(cx + 7, my),
          mouthStroke,
        );

      case 4: // 애교 삐죽 (작은 O)
        canvas.drawCircle(
          Offset(cx, my),
          4,
          Paint()
            ..color = const Color(0xFFCC5544)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        // 볼 홍조
        _drawBlush(canvas, cx, my);

      default: // case 1: 귀여운 미소
        final smilePath = Path()
          ..moveTo(cx - 8, my - 2)
          ..quadraticBezierTo(cx, my + 6, cx + 8, my - 2);
        canvas.drawPath(smilePath, mouthStroke);
        // 작은 볼 홍조
        _drawBlush(canvas, cx, my);
    }
  }

  void _drawBlush(Canvas canvas, double cx, double my) {
    final blush = Paint()..color = const Color(0xFFFF8FAB).withValues(alpha: 0.35);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 16, my - 1), width: 14, height: 7), blush);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 16, my - 1), width: 14, height: 7), blush);
  }

  // ── 상의 ──────────────────────────────────────────────────────────────────────
  // 셔츠/상의는 y=60(칼라 시작) ~ y=106(밑단), 소매는 y=62~y=82

  void _drawTop(Canvas canvas, double cx, Size size) {
    switch (topVariant) {
      case 1: _drawShirt(canvas, cx, const Color(0xFFF0F0F0), accentColor: const Color(0xFFCCCCCC));
      case 2: _drawShirt(canvas, cx, const Color(0xFFFF8FAB), accentColor: const Color(0xFFFF6090), hasFlower: true);
      case 3: _drawStripedShirt(canvas, cx);
      case 4: _drawSuit(canvas, cx);
    }
  }

  void _drawShirt(Canvas canvas, double cx, Color color,
      {Color? accentColor, bool hasFlower = false}) {
    final p = Paint()..color = color;

    // 소매 (어깨 ~ 팔꿈치, y=62~y=82)
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 34, 71), width: 18, height: 24), p);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 34, 71), width: 18, height: 24), p);

    // 셔츠 몸통 (y=62~y=106)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 26, 62, 52, 44),
        const Radius.circular(8),
      ),
      p,
    );

    // 칼라 스쿱넥 (피부가 보이도록 U자 컷)
    final collarPath = Path()
      ..moveTo(cx - 14, 62)
      ..quadraticBezierTo(cx, 76, cx + 14, 62)
      ..lineTo(cx + 14, 62)
      ..lineTo(cx - 14, 62)
      ..close();
    canvas.drawPath(collarPath, Paint()..color = _skin);

    // 칼라 윤곽선
    if (accentColor != null) {
      final collarLine = Path()
        ..moveTo(cx - 14, 62)
        ..quadraticBezierTo(cx, 76, cx + 14, 62);
      canvas.drawPath(
        collarLine,
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round,
      );
    }

    if (hasFlower) {
      // 꽃 도트 패턴
      final flowerPaint = Paint()..color = Colors.white.withValues(alpha: 0.65);
      for (final off in [
        const Offset(-10.0, -4.0), const Offset(8.0, -2.0),
        const Offset(-2.0, 8.0),   const Offset(12.0, 10.0),
      ]) {
        canvas.drawCircle(Offset(cx + off.dx, 80 + off.dy), 3.5, flowerPaint);
      }
    }
  }

  void _drawStripedShirt(Canvas canvas, double cx) {
    final baseColor = const Color(0xFF4488CC);

    // 소매
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 34, 71), width: 18, height: 24),
        Paint()..color = baseColor);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 34, 71), width: 18, height: 24),
        Paint()..color = baseColor);

    // 셔츠 몸통
    final shirtRR = RRect.fromRectAndRadius(
      Rect.fromLTWH(cx - 26, 62, 52, 44),
      const Radius.circular(8),
    );
    canvas.drawRRect(shirtRR, Paint()..color = baseColor);

    // 가로 줄무늬 (clip 후 그리기)
    canvas.save();
    canvas.clipRRect(shirtRR);
    final stripe = Paint()..color = Colors.white.withValues(alpha: 0.45);
    for (int i = 0; i < 5; i++) {
      canvas.drawRect(Rect.fromLTWH(cx - 26, 64.0 + i * 9, 52, 4.5), stripe);
    }
    canvas.restore();

    // 칼라
    final collarPath = Path()
      ..moveTo(cx - 14, 62)
      ..quadraticBezierTo(cx, 76, cx + 14, 62)
      ..close();
    canvas.drawPath(collarPath, Paint()..color = _skin);
    final collarLine = Path()
      ..moveTo(cx - 14, 62)
      ..quadraticBezierTo(cx, 76, cx + 14, 62);
    canvas.drawPath(
      collarLine,
      Paint()
        ..color = const Color(0xFF2255AA)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawSuit(Canvas canvas, double cx) {
    const suitColor = Color(0xFF2C3E50);
    const lapelColor = Color(0xFF3D5166);

    // 소매
    canvas.drawOval(Rect.fromCenter(center: Offset(cx - 34, 71), width: 18, height: 24),
        Paint()..color = suitColor);
    canvas.drawOval(Rect.fromCenter(center: Offset(cx + 34, 71), width: 18, height: 24),
        Paint()..color = suitColor);

    // 재킷 몸통
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 26, 62, 52, 44),
        const Radius.circular(8),
      ),
      Paint()..color = suitColor,
    );

    // 와이셔츠 (중앙 흰 부분)
    final shirtPath = Path()
      ..moveTo(cx - 6, 62)
      ..lineTo(cx - 6, 106)
      ..lineTo(cx + 6, 106)
      ..lineTo(cx + 6, 62)
      ..close();
    canvas.drawPath(shirtPath, Paint()..color = const Color(0xFFF0F0F0));

    // 라펠 (V자 옷깃)
    final leftLapel = Path()
      ..moveTo(cx - 6, 64)
      ..lineTo(cx - 18, 80)
      ..lineTo(cx - 6, 80)
      ..close();
    final rightLapel = Path()
      ..moveTo(cx + 6, 64)
      ..lineTo(cx + 18, 80)
      ..lineTo(cx + 6, 80)
      ..close();
    canvas.drawPath(leftLapel, Paint()..color = lapelColor);
    canvas.drawPath(rightLapel, Paint()..color = lapelColor);

    // 타이 (세로 선)
    canvas.drawRect(
      Rect.fromLTWH(cx - 2.5, 76, 5, 30),
      Paint()..color = const Color(0xFFCC2244),
    );

    // 버튼 2개
    final btnPaint = Paint()..color = const Color(0xFFD0D0D0);
    canvas.drawCircle(Offset(cx, 90), 2, btnPaint);
    canvas.drawCircle(Offset(cx, 100), 2, btnPaint);
  }

  // ── 하의 ──────────────────────────────────────────────────────────────────────
  // 바지: y=104(허리) ~ y=138(바짓단)

  void _drawBottom(Canvas canvas, double cx, Size size) {
    switch (bottomVariant) {
      case 1: _drawPants(canvas, cx, const Color(0xFF3A5FA0), seam: true);
      case 2: _drawShorts(canvas, cx, const Color(0xFFB8965A));
      case 3: _drawSkirt(canvas, cx);
    }
  }

  void _drawPants(Canvas canvas, double cx, Color color, {bool seam = false}) {
    final p = Paint()..color = color;

    // 허리띠
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 24, 104, 48, 8),
        const Radius.circular(4),
      ),
      Paint()..color = HSLColor.fromColor(color).withLightness(
          (HSLColor.fromColor(color).lightness - 0.1).clamp(0.0, 1.0)).toColor(),
    );

    // 왼쪽 바지다리
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx - 13, 122), width: 20, height: 36),
        const Radius.circular(8),
      ),
      p,
    );
    // 오른쪽 바지다리
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx + 13, 122), width: 20, height: 36),
        const Radius.circular(8),
      ),
      p,
    );

    if (seam) {
      // 중앙 솔기선
      canvas.drawLine(
        Offset(cx, 112), Offset(cx, 136),
        Paint()
          ..color = HSLColor.fromColor(color)
              .withLightness((HSLColor.fromColor(color).lightness - 0.12).clamp(0.0, 1.0))
              .toColor()
          ..strokeWidth = 1.5,
      );
    }
  }

  void _drawShorts(Canvas canvas, double cx, Color color) {
    final p = Paint()..color = color;

    // 반바지 (짧은 바지, y=104~118)
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, 112), width: 48, height: 20),
        const Radius.circular(8),
      ),
      p,
    );

    // 허리띠
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 24, 104, 48, 7),
        const Radius.circular(4),
      ),
      Paint()..color = HSLColor.fromColor(color)
          .withLightness((HSLColor.fromColor(color).lightness - 0.1).clamp(0.0, 1.0))
          .toColor(),
    );

    // 솔기선
    canvas.drawLine(
      Offset(cx, 110), Offset(cx, 120),
      Paint()..color = _skinDeep.withValues(alpha: 0.3)..strokeWidth = 1.2,
    );
  }

  void _drawSkirt(Canvas canvas, double cx) {
    const color = Color(0xFFE05580);

    // 스커트 (A-라인)
    final skirtPath = Path()
      ..moveTo(cx - 20, 104)
      ..quadraticBezierTo(cx - 30, 116, cx - 26, 136)
      ..lineTo(cx + 26, 136)
      ..quadraticBezierTo(cx + 30, 116, cx + 20, 104)
      ..close();
    canvas.drawPath(skirtPath, Paint()..color = color);

    // 허리띠
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(cx - 20, 104, 40, 7),
        const Radius.circular(4),
      ),
      Paint()..color = const Color(0xFFC03060),
    );

    // 주름선
    final linePaint = Paint()
      ..color = const Color(0xFFC03060).withValues(alpha: 0.55)
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(cx - 8, 112), Offset(cx - 16, 136), linePaint);
    canvas.drawLine(Offset(cx + 8, 112), Offset(cx + 16, 136), linePaint);
  }

  // ── 안경 ──────────────────────────────────────────────────────────────────────

  void _drawGlasses(Canvas canvas, double cx) {
    final ey = _eyeY;
    final lx = cx - 8.0;
    final rx = cx + 8.0;

    switch (glassesVariant) {
      case 1: // 선글라스
        final sgPaint = Paint()..color = const Color(0xFF1A5520).withValues(alpha: 0.9);
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(lx, ey), width: 13, height: 8),
            const Radius.circular(2),
          ),
          sgPaint,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(rx, ey), width: 13, height: 8),
            const Radius.circular(2),
          ),
          sgPaint,
        );
        canvas.drawLine(Offset(lx + 6.5, ey), Offset(rx - 6.5, ey),
            Paint()..color = const Color(0xFF114411)..strokeWidth = 1.5);
        // 안경다리
        canvas.drawLine(Offset(lx - 6.5, ey), Offset(lx - 12, ey - 2),
            Paint()..color = const Color(0xFF1A5520)..strokeWidth = 1.5);
        canvas.drawLine(Offset(rx + 6.5, ey), Offset(rx + 12, ey - 2),
            Paint()..color = const Color(0xFF1A5520)..strokeWidth = 1.5);

      case 2: // 둥근 안경 (금테)
        final framePaint = Paint()
          ..color = const Color(0xFFD4A017)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2;
        canvas.drawCircle(Offset(lx, ey), 6.5, framePaint);
        canvas.drawCircle(Offset(rx, ey), 6.5, framePaint);
        canvas.drawLine(Offset(lx + 6.5, ey), Offset(rx - 6.5, ey), framePaint);
        // 안경다리
        canvas.drawLine(Offset(lx - 6.5, ey), Offset(lx - 12, ey - 2),
            Paint()..color = const Color(0xFFD4A017)..strokeWidth = 1.5);
        canvas.drawLine(Offset(rx + 6.5, ey), Offset(rx + 12, ey - 2),
            Paint()..color = const Color(0xFFD4A017)..strokeWidth = 1.5);

      case 3: // 별 안경
        final starPaint = Paint()..color = const Color(0xFFCC44AA);
        _drawSmallStar(canvas, Offset(lx, ey), 7, starPaint);
        _drawSmallStar(canvas, Offset(rx, ey), 7, starPaint);
        canvas.drawLine(Offset(lx + 5, ey), Offset(rx - 5, ey),
            Paint()..color = const Color(0xFFCC44AA)..strokeWidth = 1.5);
    }
  }

  // ── 모자 ──────────────────────────────────────────────────────────────────────
  // 인간 머리 기준: 중심 (cx, 28), 반지름 22
  //   → 모자 챙은 y≈24에 위치, 크라운은 y=24 위로

  void _drawHat(Canvas canvas, double cx) {
    switch (hatVariant) {
      case 1: // 악마 뿔 투구 ─────────────────────────────────────────────
        final helmetPaint = Paint()..color = const Color(0xFFB22222);
        // 뿔 (가장 먼저, 뒤쪽)
        _drawHorn(canvas, cx - 14, 8, -0.3);
        _drawHorn(canvas, cx + 14, 8, 0.3);
        // 투구 돔 (머리 전체 덮음, 눈 위까지)
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, 18), width: 50, height: 36),
          helmetPaint,
        );
        // 투구 챙 (y=24, 귀 옆에 걸치는 선)
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, 24), width: 54, height: 10),
          helmetPaint,
        );
        // 눈 구멍 (뚫린 느낌)
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx - 10, 22), width: 11, height: 8),
          Paint()..color = const Color(0xFF1A1A1A),
        );
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx + 10, 22), width: 11, height: 8),
          Paint()..color = const Color(0xFF1A1A1A),
        );

      case 2: // 파라오 머리장식 ───────────────────────────────────────────
        final goldPaint  = Paint()..color = const Color(0xFFFFCC00);
        final bluePaint  = Paint()..color = const Color(0xFF1A5276);

        // 양쪽 내려오는 패널 (먼저 그려서 뒤쪽)
        final leftPanel = Path()
          ..moveTo(cx - 22, 20)..lineTo(cx - 28, 60)..lineTo(cx - 16, 60)..lineTo(cx - 18, 20)..close();
        final rightPanel = Path()
          ..moveTo(cx + 18, 20)..lineTo(cx + 16, 60)..lineTo(cx + 28, 60)..lineTo(cx + 22, 20)..close();
        canvas.drawPath(leftPanel, goldPaint);
        canvas.drawPath(rightPanel, goldPaint);
        // 패널 줄무늬
        for (int i = 0; i < 5; i++) {
          final y = 24.0 + i * 6;
          canvas.drawLine(Offset(cx - 26, y), Offset(cx - 17, y),
              Paint()..color = bluePaint.color..strokeWidth = 2);
          canvas.drawLine(Offset(cx + 17, y), Offset(cx + 26, y),
              Paint()..color = bluePaint.color..strokeWidth = 2);
        }

        // 상단 크라운
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 22, 2, 44, 20),
            const Radius.circular(4),
          ),
          goldPaint,
        );
        // 크라운 파란 줄무늬
        for (int i = 0; i < 4; i++) {
          canvas.drawRect(Rect.fromLTWH(cx - 20, 4 + i * 4.5, 5, 2.5), bluePaint);
          canvas.drawRect(Rect.fromLTWH(cx + 15, 4 + i * 4.5, 5, 2.5), bluePaint);
        }
        // 코브라 장식
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, 6), width: 9, height: 7),
          goldPaint,
        );

      case 3: // 카우보이 모자 ────────────────────────────────────────────
        final brownPaint = Paint()..color = const Color(0xFF7B4F2E);
        final darkBrown  = Paint()..color = const Color(0xFF5C3317);

        // 크라운 (y=4-24)
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(cx - 17, 4, 34, 22),
            const Radius.circular(8),
          ),
          brownPaint,
        );
        // 챙 (넓은 타원, y=24에 위치)
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, 24), width: 60, height: 10),
          brownPaint,
        );
        // 밴드
        canvas.drawRect(
          Rect.fromLTWH(cx - 17, 22, 34, 4),
          darkBrown,
        );

      case 4: // 마법사 고깔 ───────────────────────────────────────────────
        final purplePaint = Paint()..color = const Color(0xFF6B2FA0);

        // 고깔 본체 (끝이 위로 뾰족)
        final conePath = Path()
          ..moveTo(cx, -10)
          ..lineTo(cx - 19, 26)
          ..lineTo(cx + 19, 26)
          ..close();
        canvas.drawPath(conePath, purplePaint);

        // 챙 (타원, y=26에)
        canvas.drawOval(
          Rect.fromCenter(center: Offset(cx, 26), width: 52, height: 11),
          purplePaint,
        );

        // 별 장식
        _drawSmallStar(canvas, Offset(cx - 4, 8),  7, Paint()..color = const Color(0xFFFFD700));
        _drawSmallStar(canvas, Offset(cx + 8, 20), 5, Paint()..color = const Color(0xFFFFD700));
    }
  }

  // ── 악세서리 ────────────────────────────────────────────────────────────────

  void _drawAccessory(Canvas canvas, double cx, Size size, {required bool front}) {
    if (accessoryVariant == 0) return;
    final ax = cx + 46;
    const ay = 88.0;

    switch (accessoryVariant) {
      case 1: // 하트 머그컵
        if (front) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(ax, ay), width: 20, height: 22),
              const Radius.circular(4),
            ),
            Paint()..color = const Color(0xFFCC2244),
          );
          canvas.drawArc(
            Rect.fromCenter(center: Offset(ax + 14, ay), width: 14, height: 14),
            -math.pi / 2, math.pi,
            false,
            Paint()
              ..color = const Color(0xFFAA1133)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 3,
          );
          _drawSmallHeart(canvas, Offset(ax, ay), const Color(0xFFFFAAAA));
        }

      case 2: // 책
        if (front) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(center: Offset(ax, ay), width: 18, height: 24),
              const Radius.circular(2),
            ),
            Paint()..color = const Color(0xFF226688),
          );
          canvas.drawLine(
            Offset(ax - 9, ay - 12), Offset(ax - 9, ay + 12),
            Paint()..color = const Color(0xFF1A4F66)..strokeWidth = 2,
          );
          for (int i = 0; i < 3; i++) {
            canvas.drawLine(
              Offset(ax - 5, ay - 6 + i * 5.0), Offset(ax + 7, ay - 6 + i * 5.0),
              Paint()..color = Colors.white.withValues(alpha: 0.4)..strokeWidth = 1,
            );
          }
        }

      case 3: // 별 지팡이
        if (!front) {
          canvas.drawLine(
            Offset(ax, ay + 18), Offset(ax, ay - 20),
            Paint()..color = const Color(0xFFB8860B)..strokeWidth = 4..strokeCap = StrokeCap.round,
          );
        }
        if (front) {
          _drawSmallStar(canvas, Offset(ax, ay - 20), 11, Paint()..color = const Color(0xFFFFD700));
          _drawSmallStar(canvas, Offset(ax, ay - 20), 7,  Paint()..color = const Color(0xFFFFF0A0));
        }
    }
  }

  // ── 유틸리티 ────────────────────────────────────────────────────────────────

  // 눈 y좌표 (얼굴형 중심에 따라 조정)
  double get _eyeY {
    switch (faceVariant) {
      case 2: return 24.0;  // 긴 타원
      case 4: return 21.0;  // 넓은 얼굴 (눈이 약간 위)
      default: return 22.0;
    }
  }

  void _drawHorn(Canvas canvas, double x, double y, double lean) {
    final path = Path()
      ..moveTo(x - 3, y + 12)
      ..cubicTo(x - 5 + lean * 8, y + 4, x + lean * 10, y - 8, x + lean * 6, y - 14)
      ..cubicTo(x + lean * 2, y - 8, x + 5, y + 4, x + 3, y + 12)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFF8B0000));
  }

  void _drawSmallStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    for (int i = 0; i < 10; i++) {
      final radius = i.isEven ? r : r * 0.4;
      final angle  = -math.pi / 2 + i * math.pi / 5;
      final pt = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      i == 0 ? path.moveTo(pt.dx, pt.dy) : path.lineTo(pt.dx, pt.dy);
    }
    canvas.drawPath(path..close(), paint);
  }

  void _drawSmallHeart(Canvas canvas, Offset center, Color color) {
    const r = 4.0;
    final path = Path()
      ..moveTo(center.dx, center.dy + r * 0.9)
      ..cubicTo(center.dx - r * 1.2, center.dy + r * 0.2, center.dx - r * 1.2, center.dy - r * 0.6,
          center.dx - r * 0.5, center.dy - r * 0.4)
      ..cubicTo(center.dx - r * 0.15, center.dy - r * 0.65, center.dx, center.dy - r * 0.3,
          center.dx, center.dy - r * 0.1)
      ..cubicTo(center.dx, center.dy - r * 0.3, center.dx + r * 0.15, center.dy - r * 0.65,
          center.dx + r * 0.5, center.dy - r * 0.4)
      ..cubicTo(center.dx + r * 1.2, center.dy - r * 0.6, center.dx + r * 1.2, center.dy + r * 0.2,
          center.dx, center.dy + r * 0.9)
      ..close();
    canvas.drawPath(path, Paint()..color = color);
  }

  @override
  bool shouldRepaint(CharacterPainter old) =>
      hatVariant       != old.hatVariant       ||
      topVariant       != old.topVariant       ||
      bottomVariant    != old.bottomVariant    ||
      glassesVariant   != old.glassesVariant   ||
      accessoryVariant != old.accessoryVariant ||
      faceVariant      != old.faceVariant      ||
      eyesVariant      != old.eyesVariant      ||
      noseVariant      != old.noseVariant      ||
      mouthVariant     != old.mouthVariant     ||
      clothesOnly      != old.clothesOnly;
}
