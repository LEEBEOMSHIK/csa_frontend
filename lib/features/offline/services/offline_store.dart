import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:csa_frontend/features/offline/models/offline_meta_entry.dart';
import 'package:csa_frontend/features/offline/models/offline_slide_entry.dart';

const String offlineSlideBoxName = 'offline_slide_box';
const String offlineMetaBoxName = 'offline_meta_box';

/// Hive 초기화 + 어댑터 등록 + 오프라인 box open 을 담당하는 단일 진입점.
/// main() 에서 앱 부팅 전에 한 번 호출한다.
class OfflineStore {
  OfflineStore._();
  static final OfflineStore instance = OfflineStore._();

  bool _initialized = false;

  late Box<OfflineSlideEntry> _slideBox;
  late Box<OfflineMetaEntry> _metaBox;

  bool get isInitialized => _initialized;

  Box<OfflineSlideEntry> get slideBox => _slideBox;
  Box<OfflineMetaEntry> get metaBox => _metaBox;

  Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    _registerAdapters();
    _slideBox = await Hive.openBox<OfflineSlideEntry>(offlineSlideBoxName);
    _metaBox = await Hive.openBox<OfflineMetaEntry>(offlineMetaBoxName);
    _initialized = true;
  }

  /// 테스트에서 이미 열린 box 를 주입해 초기화한다.
  @visibleForTesting
  void initForTest({
    required Box<OfflineSlideEntry> slideBox,
    required Box<OfflineMetaEntry> metaBox,
  }) {
    _slideBox = slideBox;
    _metaBox = metaBox;
    _initialized = true;
  }

  @visibleForTesting
  void registerAdaptersForTest() => _registerAdapters();

  void _registerAdapters() {
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(OfflineSlideEntryAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(OfflineMetaEntryAdapter());
    }
  }
}
