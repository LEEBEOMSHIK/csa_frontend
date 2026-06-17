import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// 서버(ElevenLabs 등)가 사전 생성해 내려준 나레이션 오디오(audioUrl) 재생 래퍼.
/// 기기 TTS(TtsService)와 동일한 싱글턴 + ValueNotifier 패턴을 따른다.
class AudioNarrationService {
  AudioNarrationService._();
  static final AudioNarrationService instance = AudioNarrationService._();

  final AudioPlayer _player = AudioPlayer();
  bool _initialized = false;

  final ValueNotifier<bool> isPlaying = ValueNotifier<bool>(false);

  /// 테스트에서 실제 오디오 플랫폼 대신 재생 동작을 주입하기 위한 훅.
  /// null 이면 just_audio 플레이어를 사용한다.
  @visibleForTesting
  Future<bool> Function(String url)? playOverride;

  @visibleForTesting
  Future<bool> Function(String filePath)? playFileOverride;

  @visibleForTesting
  Future<void> Function()? stopOverride;

  void _ensureInit() {
    if (_initialized) return;
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        isPlaying.value = false;
      } else {
        isPlaying.value = state.playing;
      }
    });
    _initialized = true;
  }

  /// [url] 재생을 시작한다. 성공 시 true, 실패 시 false 를 반환한다.
  Future<bool> play(String url) async {
    if (url.trim().isEmpty) return false;
    final override = playOverride;
    if (override != null) {
      final ok = await override(url);
      isPlaying.value = ok;
      return ok;
    }
    _ensureInit();
    try {
      await _player.stop();
      await _player.setUrl(url);
      isPlaying.value = true;
      unawaited(_player.play());
      return true;
    } catch (_) {
      isPlaying.value = false;
      return false;
    }
  }

  /// 로컬 파일 경로의 오디오를 재생한다. 성공 시 true, 실패 시 false.
  Future<bool> playFile(String filePath) async {
    if (filePath.trim().isEmpty) return false;
    final override = playFileOverride;
    if (override != null) {
      final ok = await override(filePath);
      isPlaying.value = ok;
      return ok;
    }
    _ensureInit();
    try {
      await _player.stop();
      await _player.setFilePath(filePath);
      isPlaying.value = true;
      unawaited(_player.play());
      return true;
    } catch (_) {
      isPlaying.value = false;
      return false;
    }
  }

  Future<void> stop() async {
    final override = stopOverride;
    if (override != null) {
      await override();
      isPlaying.value = false;
      return;
    }
    try {
      await _player.stop();
    } catch (_) {
      // 무시: 정지 실패는 사용자 흐름에 영향 없음
    }
    isPlaying.value = false;
  }
}
