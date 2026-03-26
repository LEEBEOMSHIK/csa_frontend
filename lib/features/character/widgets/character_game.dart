import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'character_preview.dart';

// ─────────────────────────────────────────────────────────────────────────────
// CharacterGame — Flame 2D 게임형 캐릭터 미리보기
// ─────────────────────────────────────────────────────────────────────────────

class CharacterGame extends FlameGame {
  List<int> _variants;
  _CharacterComponent? _char;

  CharacterGame({required List<int> variants})
      : _variants = List.from(variants);

  @override
  Color backgroundColor() => const Color(0xFFFFF4CC);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(_BackgroundComponent());
    _char = _CharacterComponent(variants: _variants);
    add(_char!);
    _addSparkles();
  }

  void _addSparkles() {
    final rng = math.Random();
    for (int i = 0; i < 8; i++) {
      add(_FloatingSparkle(
        position: Vector2(
          rng.nextDouble() * size.x,
          20 + rng.nextDouble() * (size.y - 40),
        ),
        phase: rng.nextDouble() * math.pi * 2,
        speed: 0.7 + rng.nextDouble() * 0.9,
        sparkSize: 2.5 + rng.nextDouble() * 3.0,
      ));
    }
  }

  /// 아이템 교체 시 호출 — 캐릭터 업데이트 + 버스트 파티클
  void equipItem(List<int> variants) {
    if (!isLoaded) return;
    _variants = List.from(variants);
    _char?.updateVariants(variants);
    _spawnBurst();
  }

  void _spawnBurst() {
    final rng = math.Random();
    final center = Vector2(size.x / 2, size.y / 2 - 15);
    const burstColors = [
      Color(0xFFFF7043),
      Color(0xFFFFD700),
      Color(0xFF5CB85C),
      Color(0xFF4488CC),
      Color(0xFFFF8FAB),
      Color(0xFFCC44AA),
    ];
    for (int i = 0; i < 14; i++) {
      final angle = i * math.pi * 2 / 14;
      final speed = 70.0 + rng.nextDouble() * 90;
      add(_BurstParticle(
        position: center +
            Vector2(math.cos(angle) * 25, math.sin(angle) * 20),
        velocity: Vector2(
          math.cos(angle) * speed,
          math.sin(angle) * speed - 40,
        ),
        color: burstColors[i % burstColors.length],
      ));
    }
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 배경 컴포넌트
// ─────────────────────────────────────────────────────────────────────────────

class _BackgroundComponent extends Component with HasGameReference<CharacterGame> {
  @override
  void render(Canvas canvas) {
    final w = game.size.x;
    final h = game.size.y;

    final gradient = const LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFFFE082), Color(0xFFFFF8DC)],
    );
    canvas.drawRect(
      Rect.fromLTWH(0, 0, w, h),
      Paint()
        ..shader = gradient.createShader(Rect.fromLTWH(0, 0, w, h)),
    );

    canvas.drawLine(
      Offset(20, h - 18),
      Offset(w - 20, h - 18),
      Paint()
        ..color = const Color(0xFFFFCC80).withValues(alpha: 0.55)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    _drawCloud(canvas, Offset(w * 0.14, h * 0.18), 14);
    _drawCloud(canvas, Offset(w * 0.84, h * 0.13), 11);
  }

  void _drawCloud(Canvas canvas, Offset center, double r) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.45);
    canvas.drawCircle(center, r, paint);
    canvas.drawCircle(center + Offset(r * 0.85, r * 0.1), r * 0.75, paint);
    canvas.drawCircle(center - Offset(r * 0.8, -r * 0.05), r * 0.6, paint);
    canvas.drawCircle(center + Offset(r * 0.1, r * 0.45), r * 0.65, paint);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// PNG 파트 레이어 — 단일 이미지를 고정 크기로 렌더링
// Flame Component가 아닌 일반 Dart 클래스 — 부모 컴포넌트가 직접 render 호출
// ─────────────────────────────────────────────────────────────────────────────

class _PartLayer {
  ui.Image? _image;
  final double _w;
  final double _h;

  _PartLayer({required double w, required double h})
      : _w = w,
        _h = h;

  Future<void> loadPath(String? path) async {
    if (path == null) {
      _image = null;
      return;
    }
    try {
      print('load: $path');
      final data = await rootBundle.load(path);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _image = frame.image;
      print('load OK: $path (${_image!.width}×${_image!.height})');
    } catch (e) {
      print('load FAIL: $path -> $e');
      _image = null;
    }
  }

  void clear() => _image = null;

  // 모든 파트는 동일한 캔버스 기준(512×512)이므로 같은 dst rect에 그리면 정렬됨
  void render(Canvas canvas) {
    if (_image == null) return;
    canvas.drawImageRect(
      _image!,
      Rect.fromLTWH(0, 0, _image!.width.toDouble(), _image!.height.toDouble()),
      Rect.fromLTWH(0, 0, _w, _h),
      Paint(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 캐릭터 컴포넌트
// 구조: BodyComponent / HeadComponent / EyesComponent / NoseComponent /
//       MouthComponent / 의상 코드 오버레이 (clothesOnly)
// ─────────────────────────────────────────────────────────────────────────────

class _CharacterComponent extends Component
    with HasGameReference<CharacterGame> {
  double _time = 0;
  List<int> _variants;
  Vector2 _basePos = Vector2.zero();

  static const _w = 120.0;
  static const _h = 148.0;

  // 레이어 구조 (각 파트 독립 Sprite 레이어)
  late final _PartLayer bodyComponent;
  late final _PartLayer headComponent;
  late final _PartLayer eyesComponent;
  late final _PartLayer noseComponent;
  late final _PartLayer mouthComponent;

  // 의상·모자·악세서리 코드 오버레이 (얼굴 파트 제외)
  late CharacterPainter _clothesPainter;

  _CharacterComponent({required List<int> variants})
      : _variants = List.from(variants);

  CharacterPainter _buildClothesPainter(List<int> v) => CharacterPainter(
        hatVariant:       v[0],
        topVariant:       v[1],
        bottomVariant:    v[2],
        glassesVariant:   v[3],
        accessoryVariant: v[4],
        faceVariant:      v.length > 5 ? v[5] : 1,
        eyesVariant:      v.length > 6 ? v[6] : 1,
        noseVariant:      v.length > 7 ? v[7] : 1,
        mouthVariant:     v.length > 8 ? v[8] : 1,
        clothesOnly:      true,
      );

  @override
  Future<void> onLoad() async {
    _basePos = Vector2(game.size.x / 2, game.size.y / 2 - 8);
    _clothesPainter = _buildClothesPainter(_variants);

    bodyComponent  = _PartLayer(w: _w, h: _h);
    headComponent  = _PartLayer(w: _w, h: _h);
    eyesComponent  = _PartLayer(w: _w, h: _h);
    noseComponent  = _PartLayer(w: _w, h: _h);
    mouthComponent = _PartLayer(w: _w, h: _h);

    // _PartLayer는 Flame Component가 아니므로 addAll 없이 직접 render 호출
    await _loadAllParts(_variants);
  }

  Future<void> _loadAllParts(List<int> v) async {
    final fv = v.length > 5 ? v[5] : 1;
    final ev = v.length > 6 ? v[6] : 1;
    final nv = v.length > 7 ? v[7] : 1;
    final mv = v.length > 8 ? v[8] : 1;

    await Future.wait([
      bodyComponent.loadPath('assets/character_parts/base/body.png'),
      headComponent.loadPath(
        (fv >= 1 && fv <= 2) ? 'assets/character_parts/base/head_0$fv.png' : null,
      ),
      eyesComponent.loadPath(
        (ev >= 1 && ev <= 3) ? 'assets/character_parts/eyes/eyes_0$ev.png' : null,
      ),
      noseComponent.loadPath(
        (nv >= 1 && nv <= 2) ? 'assets/character_parts/nose/nose_0$nv.png' : null,
      ),
      mouthComponent.loadPath(
        (mv >= 1 && mv <= 3) ? 'assets/character_parts/mouth/mouth_0$mv.png' : null,
      ),
    ]);
  }

  /// 선택 변경 시 호출 — 즉시 기존 파트 클리어 후 새 에셋 로드
  void updateVariants(List<int> variants) {
    _variants = List.from(variants);
    _clothesPainter = _buildClothesPainter(variants);

    // 스테일 이미지가 보이지 않도록 즉시 클리어
    headComponent.clear();
    eyesComponent.clear();
    noseComponent.clear();
    mouthComponent.clear();

    // 비동기 로드 — 완료되면 다음 프레임부터 반영
    _loadAllParts(variants);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _basePos = Vector2(size.x / 2, size.y / 2 - 8);
  }

  @override
  void update(double dt) {
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final bounce = math.sin(_time * 2.5) * 3.0;
    final shadowScale = 1.0 - (bounce.abs() / 18.0);

    // 그림자 (바운스 없음 — 지면에 고정)
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(_basePos.x, _basePos.y + _h / 2 - 10),
        width: 48 * shadowScale,
        height: 7 * shadowScale,
      ),
      Paint()..color = const Color(0x28000000),
    );

    // 캐릭터 위치로 이동 (바운스 포함)
    canvas.save();
    canvas.translate(_basePos.x - _w / 2, _basePos.y - _h / 2 + bounce);

    // ── PNG 레이어 렌더링 (모든 파트 동일 dst rect → 정렬 보장) ──
    // 레이어 순: body → head → eyes → nose → mouth → clothes
    for (final layer in [bodyComponent, headComponent, eyesComponent, noseComponent, mouthComponent]) {
      layer.render(canvas);
    }

    // ── 의상 코드 오버레이 (clothesOnly=true: 얼굴/머리/눈/코/입 미포함) ──
    _clothesPainter.paint(canvas, const Size(_w, _h));

    canvas.restore();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 떠다니는 반짝이 별
// ─────────────────────────────────────────────────────────────────────────────

class _FloatingSparkle extends Component {
  final Vector2 _pos;
  final double _phase;
  final double _speed;
  final double _sparkSize;
  double _time = 0;

  _FloatingSparkle({
    required Vector2 position,
    required double phase,
    required double speed,
    required double sparkSize,
  })  : _pos = position.clone(),
        _phase = phase,
        _speed = speed,
        _sparkSize = sparkSize;

  @override
  void update(double dt) {
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final alpha =
        (math.sin(_time * _speed + _phase) * 0.5 + 0.5) * 0.65;
    if (alpha < 0.04) return;

    final yDrift = math.sin(_time * _speed * 0.5 + _phase) * 6.0;
    final cx = _pos.x;
    final cy = _pos.y + yDrift;
    final r = _sparkSize;

    final paint = Paint()
      ..color = const Color(0xFFFFD700).withValues(alpha: alpha);

    final path = Path();
    for (int i = 0; i < 8; i++) {
      final radius = i.isEven ? r : r * 0.35;
      final angle = i * math.pi / 4 - math.pi / 4;
      final x = cx + radius * math.cos(angle);
      final y = cy + radius * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    canvas.drawPath(path, paint);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 버스트 파티클
// ─────────────────────────────────────────────────────────────────────────────

class _BurstParticle extends Component {
  final Vector2 _pos;
  final Vector2 _vel;
  double _time = 0;
  static const _lifetime = 0.7;
  final Color _color;

  _BurstParticle({
    required Vector2 position,
    required Vector2 velocity,
    required Color color,
  })  : _pos = position.clone(),
        _vel = velocity.clone(),
        _color = color;

  @override
  void update(double dt) {
    _time += dt;
    _pos.x += _vel.x * dt;
    _pos.y += _vel.y * dt;
    _vel.y += 220 * dt;
    if (_time >= _lifetime) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final progress = _time / _lifetime;
    final alpha = (1.0 - progress * 1.3).clamp(0.0, 1.0);
    final radius = ((1.0 - progress * 0.5) * 5.0).clamp(1.0, 6.0);
    canvas.drawCircle(
      Offset(_pos.x, _pos.y),
      radius,
      Paint()..color = _color.withValues(alpha: alpha),
    );
  }
}
