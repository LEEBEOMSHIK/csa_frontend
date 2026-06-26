import 'dart:math' as math;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';

import 'child_avatar_painter.dart';

class CharacterGame extends FlameGame {
  List<int> _variants;
  _CharacterComponent? _character;

  CharacterGame({required List<int> variants})
    : _variants = List.from(variants);

  @override
  Color backgroundColor() => const Color(0xFFFFF4CC);

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    add(_BackgroundComponent());
    _character = _CharacterComponent(variants: _variants);
    add(_character!);
    _addSparkles();
  }

  void equipItem(List<int> variants) {
    if (!isLoaded) return;
    _variants = List.from(variants);
    _character?.updateVariants(_variants);
    _spawnBurst();
  }

  void _addSparkles() {
    final rng = math.Random();
    for (var i = 0; i < 10; i++) {
      add(
        _FloatingSparkle(
          position: Vector2(
            rng.nextDouble() * size.x,
            18 + rng.nextDouble() * (size.y - 36),
          ),
          phase: rng.nextDouble() * math.pi * 2,
          speed: 0.6 + rng.nextDouble() * 0.9,
          sparkSize: 2.4 + rng.nextDouble() * 3.4,
        ),
      );
    }
  }

  void _spawnBurst() {
    final rng = math.Random();
    final center = Vector2(size.x / 2, size.y / 2 - 8);
    const burstColors = [
      Color(0xFFFF7043),
      Color(0xFFFFD54F),
      Color(0xFF5CB85C),
      Color(0xFF4E9AD8),
      Color(0xFFFF8FAB),
      Color(0xFFB866D8),
    ];

    for (var i = 0; i < 16; i++) {
      final angle = i * math.pi * 2 / 16;
      final speed = 80.0 + rng.nextDouble() * 85;
      add(
        _BurstParticle(
          position:
              center + Vector2(math.cos(angle) * 36, math.sin(angle) * 26),
          velocity: Vector2(
            math.cos(angle) * speed,
            math.sin(angle) * speed - 48,
          ),
          color: burstColors[i % burstColors.length],
        ),
      );
    }
  }
}

class _BackgroundComponent extends Component
    with HasGameReference<CharacterGame> {
  @override
  void render(Canvas canvas) {
    final w = game.size.x;
    final h = game.size.y;
    final rect = Rect.fromLTWH(0, 0, w, h);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE082), Color(0xFFFFF8DC)],
        ).createShader(rect),
    );

    final groundY = h - 20;
    canvas.drawLine(
      Offset(20, groundY),
      Offset(w - 20, groundY),
      Paint()
        ..color = const Color(0xFFFFCC80).withValues(alpha: 0.55)
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(w / 2, groundY - 2),
        width: 124,
        height: 18,
      ),
      Paint()..color = const Color(0xFFFFC46C).withValues(alpha: 0.13),
    );

    _drawCloud(canvas, Offset(w * 0.14, h * 0.18), 14);
    _drawCloud(canvas, Offset(w * 0.84, h * 0.13), 11);
  }

  void _drawCloud(Canvas canvas, Offset center, double radius) {
    final paint = Paint()..color = Colors.white.withValues(alpha: 0.48);
    canvas.drawCircle(center, radius, paint);
    canvas.drawCircle(
      center + Offset(radius * 0.85, radius * 0.1),
      radius * 0.75,
      paint,
    );
    canvas.drawCircle(
      center - Offset(radius * 0.8, -radius * 0.05),
      radius * 0.6,
      paint,
    );
    canvas.drawCircle(
      center + Offset(radius * 0.1, radius * 0.45),
      radius * 0.65,
      paint,
    );
  }
}

class _CharacterComponent extends Component
    with HasGameReference<CharacterGame> {
  static const _width = 174.0;
  static const _height = 206.0;

  List<int> _variants;
  Vector2 _basePosition = Vector2.zero();
  double _time = 0;
  late ChildAvatarPainter _avatarPainter;

  _CharacterComponent({required List<int> variants})
    : _variants = List.from(variants);

  @override
  void onLoad() {
    _avatarPainter = ChildAvatarPainter(variants: _variants);
    _basePosition = Vector2(game.size.x / 2, game.size.y / 2 + 7);
  }

  void updateVariants(List<int> variants) {
    _variants = List.from(variants);
    _avatarPainter = ChildAvatarPainter(variants: _variants);
  }

  @override
  void onGameResize(Vector2 size) {
    super.onGameResize(size);
    _basePosition = Vector2(size.x / 2, size.y / 2 + 7);
  }

  @override
  void update(double dt) {
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final bounce = math.sin(_time * 2.35) * 3.4;
    final shadowScale = 1.0 - (bounce.abs() / 20.0);

    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(_basePosition.x, _basePosition.y + _height / 2 - 8),
        width: 86 * shadowScale,
        height: 12 * shadowScale,
      ),
      Paint()..color = const Color(0x29000000),
    );

    canvas.save();
    canvas.translate(
      _basePosition.x - _width / 2,
      _basePosition.y - _height / 2 + bounce,
    );
    _avatarPainter.paint(canvas, const Size(_width, _height));
    canvas.restore();
  }
}

class _FloatingSparkle extends Component {
  final Vector2 _position;
  final double _phase;
  final double _speed;
  final double _sparkSize;
  double _time = 0;

  _FloatingSparkle({
    required Vector2 position,
    required double phase,
    required double speed,
    required double sparkSize,
  }) : _position = position.clone(),
       _phase = phase,
       _speed = speed,
       _sparkSize = sparkSize;

  @override
  void update(double dt) {
    _time += dt;
  }

  @override
  void render(Canvas canvas) {
    final alpha = (math.sin(_time * _speed + _phase) * 0.5 + 0.5) * 0.65;
    if (alpha < 0.04) return;

    final drift = math.sin(_time * _speed * 0.55 + _phase) * 6.0;
    final center = Offset(_position.x, _position.y + drift);
    final path = Path();

    for (var i = 0; i < 8; i++) {
      final radius = i.isEven ? _sparkSize : _sparkSize * 0.35;
      final angle = i * math.pi / 4 - math.pi / 4;
      final point = Offset(
        center.dx + radius * math.cos(angle),
        center.dy + radius * math.sin(angle),
      );
      i == 0
          ? path.moveTo(point.dx, point.dy)
          : path.lineTo(point.dx, point.dy);
    }

    canvas.drawPath(
      path..close(),
      Paint()..color = const Color(0xFFFFD700).withValues(alpha: alpha),
    );
  }
}

class _BurstParticle extends Component {
  final Vector2 _position;
  final Vector2 _velocity;
  final Color _color;
  double _time = 0;

  static const _lifetime = 0.7;

  _BurstParticle({
    required Vector2 position,
    required Vector2 velocity,
    required Color color,
  }) : _position = position.clone(),
       _velocity = velocity.clone(),
       _color = color;

  @override
  void update(double dt) {
    _time += dt;
    _position.x += _velocity.x * dt;
    _position.y += _velocity.y * dt;
    _velocity.y += 220 * dt;
    if (_time >= _lifetime) removeFromParent();
  }

  @override
  void render(Canvas canvas) {
    final progress = _time / _lifetime;
    final alpha = (1.0 - progress * 1.25).clamp(0.0, 1.0);
    final radius = ((1.0 - progress * 0.5) * 5.4).clamp(1.0, 6.0);
    canvas.drawCircle(
      Offset(_position.x, _position.y),
      radius,
      Paint()..color = _color.withValues(alpha: alpha),
    );
  }
}
