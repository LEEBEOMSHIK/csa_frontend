import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// 네트워크 상태(온라인/오프라인) 전역 상태와 변화 감지를 담당한다.
///
/// `connectivity_plus` 를 직접 구독하지 않고 [ConnectivitySource] 추상화를 통해
/// 주입받으므로, 테스트에서는 플러그인 없이 가짜 소스로 동작을 검증할 수 있다.
abstract class ConnectivitySource {
  Future<List<ConnectivityResult>> checkConnectivity();
  Stream<List<ConnectivityResult>> get onConnectivityChanged;
}

class _PluginConnectivitySource implements ConnectivitySource {
  final Connectivity _connectivity = Connectivity();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() =>
      _connectivity.checkConnectivity();

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged;
}

class ConnectivityService {
  ConnectivityService({ConnectivitySource? source})
    : _source = source ?? _PluginConnectivitySource();

  static final ConnectivityService instance = ConnectivityService();

  final ConnectivitySource _source;

  /// 현재 온라인 여부. 앱 전역에서 구독한다(예: 오프라인 배너, 목록 전환).
  /// 초기화 전 기본값은 온라인으로 가정한다(연결 확인 실패가 곧 오프라인은 아님).
  final ValueNotifier<bool> isOnline = ValueNotifier<bool>(true);

  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _started = false;

  /// 현재 연결 상태를 1회 조회하고 변화 스트림을 구독한다.
  /// main() 에서 호출하되 실패해도 앱 기동을 막지 않도록 호출부에서 try/catch 한다.
  Future<void> start() async {
    if (_started) return;
    _started = true;
    final current = await _source.checkConnectivity();
    isOnline.value = _resolveOnline(current);
    _subscription = _source.onConnectivityChanged.listen((results) {
      isOnline.value = _resolveOnline(results);
    });
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    _subscription = null;
    _started = false;
  }

  static bool _resolveOnline(List<ConnectivityResult> results) {
    if (results.isEmpty) return false;
    return results.any((r) => r != ConnectivityResult.none);
  }
}
