import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:csa_frontend/shared/services/connectivity_service.dart';

class _FakeSource implements ConnectivitySource {
  _FakeSource(this.initial);

  List<ConnectivityResult> initial;
  final StreamController<List<ConnectivityResult>> controller =
      StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async => initial;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      controller.stream;
}

void main() {
  test('start resolves initial offline state', () async {
    final source = _FakeSource([ConnectivityResult.none]);
    final service = ConnectivityService(source: source);

    await service.start();

    expect(service.isOnline.value, isFalse);
    await service.dispose();
  });

  test('start resolves initial online state', () async {
    final source = _FakeSource([ConnectivityResult.wifi]);
    final service = ConnectivityService(source: source);

    await service.start();

    expect(service.isOnline.value, isTrue);
    await service.dispose();
  });

  test('stream changes flip isOnline notifier', () async {
    final source = _FakeSource([ConnectivityResult.wifi]);
    final service = ConnectivityService(source: source);
    await service.start();
    expect(service.isOnline.value, isTrue);

    source.controller.add([ConnectivityResult.none]);
    await Future<void>.delayed(Duration.zero);
    expect(service.isOnline.value, isFalse);

    source.controller.add([ConnectivityResult.mobile]);
    await Future<void>.delayed(Duration.zero);
    expect(service.isOnline.value, isTrue);

    await service.dispose();
  });
}
