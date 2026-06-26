import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:csa_frontend/features/character/widgets/child_avatar_painter.dart';

void main() {
  test('paints a unified child avatar without loading image assets', () {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const variants = [1, 2, 1, 3, 2, 2, 3, 2, 1];
    const painter = ChildAvatarPainter(variants: variants);

    painter.paint(canvas, const Size(220, 260));

    final picture = recorder.endRecording();
    picture.dispose();

    expect(
      painter.shouldRepaint(const ChildAvatarPainter(variants: variants)),
      isFalse,
    );
    expect(
      painter.shouldRepaint(
        const ChildAvatarPainter(variants: [2, 2, 1, 3, 2, 2, 3, 2, 1]),
      ),
      isTrue,
    );
  });

  test(
    'default child avatar fills the artboard with a usable silhouette',
    () async {
      const painter = ChildAvatarPainter(variants: [0, 0, 0, 0, 0, 1, 1, 1, 1]);

      final bytes = await _paintBytes(painter);

      final bounds = _opaqueBounds(bytes!, 220, 260);

      expect(bounds.width, greaterThanOrEqualTo(145));
      expect(bounds.height, greaterThanOrEqualTo(225));
    },
  );

  test(
    'representative accessories stay visually connected to the right hand',
    () async {
      const baseVariants = [2, 4, 3, 2, 0, 2, 2, 2, 1];
      final withoutAccessory = await _paintBytes(
        const ChildAvatarPainter(variants: baseVariants),
      );
      const gripZone = Rect.fromLTWH(162, 182, 36, 32);

      for (final accessory in [1, 2, 3]) {
        final withAccessory = await _paintBytes(
          ChildAvatarPainter(
            variants: _withVariant(baseVariants, 4, accessory),
          ),
        );

        expect(
          _changedPixelCount(
            before: withoutAccessory!,
            after: withAccessory!,
            width: 220,
            height: 260,
            zone: gripZone,
          ),
          greaterThan(20),
          reason: 'accessory $accessory should overlap the hand grip anchor',
        );
      }
    },
  );
}

Future<ByteData?> _paintBytes(ChildAvatarPainter painter) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  painter.paint(canvas, const Size(220, 260));

  final picture = recorder.endRecording();
  final image = await picture.toImage(220, 260);
  final bytes = await image.toByteData(format: ui.ImageByteFormat.rawRgba);
  picture.dispose();
  image.dispose();

  return bytes;
}

List<int> _withVariant(List<int> variants, int index, int value) {
  final updated = List<int>.of(variants);
  updated[index] = value;
  return updated;
}

int _changedPixelCount({
  required ByteData before,
  required ByteData after,
  required int width,
  required int height,
  required Rect zone,
}) {
  var count = 0;
  final left = zone.left.floor().clamp(0, width);
  final top = zone.top.floor().clamp(0, height);
  final right = zone.right.ceil().clamp(0, width);
  final bottom = zone.bottom.ceil().clamp(0, height);

  for (var y = top; y < bottom; y++) {
    for (var x = left; x < right; x++) {
      final offset = (y * width + x) * 4;
      if (_pixelDelta(before, after, offset) > 24) {
        count++;
      }
    }
  }

  return count;
}

int _pixelDelta(ByteData before, ByteData after, int offset) {
  var total = 0;
  for (var channel = 0; channel < 4; channel++) {
    total +=
        (before.getUint8(offset + channel) - after.getUint8(offset + channel))
            .abs();
  }
  return total;
}

Rect _opaqueBounds(ByteData bytes, int width, int height) {
  var minX = width;
  var minY = height;
  var maxX = 0;
  var maxY = 0;

  for (var y = 0; y < height; y++) {
    for (var x = 0; x < width; x++) {
      final alpha = bytes.getUint8((y * width + x) * 4 + 3);
      if (alpha == 0) continue;
      if (x < minX) minX = x;
      if (y < minY) minY = y;
      if (x > maxX) maxX = x;
      if (y > maxY) maxY = y;
    }
  }

  return Rect.fromLTRB(
    minX.toDouble(),
    minY.toDouble(),
    (maxX + 1).toDouble(),
    (maxY + 1).toDouble(),
  );
}
