import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// 가족 목소리 근사용 프리셋 (기기 TTS pitch/rate)
class TtsVoicePreset {
  final double pitch;
  final double rate;
  const TtsVoicePreset(this.pitch, this.rate);
}

/// 기기 TTS(flutter_tts) 래퍼 — 동화 본문 읽어주기.
/// ElevenLabs 사전생성 오디오 재생은 AI 동화 뷰어 도입 시 별도 경로로 추가 예정.
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  final ValueNotifier<bool> isSpeaking = ValueNotifier<bool>(false);

  // 아빠/엄마/할머니/할아버지 → 피치·속도 근사
  static const Map<String, TtsVoicePreset> _presets = {
    'dad': TtsVoicePreset(0.8, 0.45),
    'mom': TtsVoicePreset(1.2, 0.5),
    'grandma': TtsVoicePreset(1.05, 0.4),
    'grandpa': TtsVoicePreset(0.7, 0.4),
  };

  void _ensureInit() {
    if (_initialized) return;
    _tts.setCompletionHandler(() => isSpeaking.value = false);
    _tts.setCancelHandler(() => isSpeaking.value = false);
    _tts.setErrorHandler((_) => isSpeaking.value = false);
    _initialized = true;
  }

  Future<void> speak(
    String text, {
    required String lang,
    required String voice,
  }) async {
    if (text.trim().isEmpty) return;
    _ensureInit();
    await _tts.stop();
    await _tts.setLanguage(lang == 'ja' ? 'ja-JP' : 'ko-KR');
    final preset = _presets[voice] ?? const TtsVoicePreset(1.0, 0.5);
    await _tts.setPitch(preset.pitch);
    await _tts.setSpeechRate(preset.rate);
    isSpeaking.value = true;
    await _tts.speak(text);
  }

  Future<void> stop() async {
    await _tts.stop();
    isSpeaking.value = false;
  }
}
