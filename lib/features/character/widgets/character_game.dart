import 'dart:math' as math;
import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
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
// 배경 컴포넌트 — 따뜻한 그라디언트 + 구름 장식
// ─────────────────────────────────────────────────────────────────────────────

class _BackgroundComponent extends Component with HasGameReference<CharacterGame> {
  @override
  void render(Canvas canvas) {
    final w = game.size.x;
    final h = game.size.y;

    // 그라디언트 배경
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

    // 지면 장식선
    canvas.drawLine(
      Offset(20, h - 18),
      Offset(w - 20, h - 18),
      Paint()
        ..color = const Color(0xFFFFCC80).withValues(alpha: 0.55)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // 구름 (왼쪽)
    _drawCloud(canvas, Offset(w * 0.14, h * 0.18), 14);
    // 구름 (오른쪽)
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
// 캐릭터 컴포넌트 — CharacterPainter 래핑 + idle bounce 애니메이션
// ─────────────────────────────────────────────────────────────────────────────

class _CharacterComponent extends Component
    with HasGameReference<CharacterGame> {
  double _time = 0;
  late CharacterPainter _painter;
  Vector2 _pos = Vector2.zero();

  static const _w = 120.0;
  static const _h = 148.0;

  _CharacterComponent({required List<int> variants}) {
    _painter = _buildPainter(variants);
  }

  @override
  void onLoad() {
    _pos = Vector2(game.size.x / 2, game.size.y / 2 - 8);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _pos = Vector2(size.x / 2, size.y / 2 - 8);
  }

  void updateVariants(List<int> variants) {
    _painter = _buildPainter(variants);
  }

  CharacterPainter _buildPainter(List<int> v) => CharacterPainter(
        hatVariant:       v[0],
        topVariant:       v[1],
        bottomVariant:    v[2],
        glassesVariant:   v[3],
        accessoryVariant: v[4],
        faceVariant:      v.length > 5 ? v[5] : 1,
        eyesVariant:      v.length > 6 ? v[6] : 1,
        noseVariant:      v.length > 7 ? v[7] : 1,
        mouthVariant:     v.length > 8 ? v[8] : 1,
      );

  @override
  void update(double dt) {
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final bounce = math.sin(_time * 2.5) * 3.0;
    final shadowScale = 1.0 - (bounce.abs() / 18.0);

    // 그림자
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(_pos.x, _pos.y + _h / 2 - 10),
        width: 48 * shadowScale,
        height: 7 * shadowScale,
      ),
      Paint()..color = const Color(0x28000000),
    );

    // 캐릭터 본체
    canvas.save();
    canvas.translate(_pos.x - _w / 2, _pos.y - _h / 2 + bounce);
    _painter.paint(canvas, const Size(_w, _h));
    canvas.restore();
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// 떠다니는 반짝이 별 — 배경에 상시 떠있음
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
// 버스트 파티클 — equipItem() 호출 시 생성, 자동 소멸
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
    _vel.y += 220 * dt; // 중력
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
