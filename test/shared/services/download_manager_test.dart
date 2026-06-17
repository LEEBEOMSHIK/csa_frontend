import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:csa_frontend/features/fairytale_create/models/fairytale_generate_response.dart';
import 'package:csa_frontend/features/my/services/my_fairytale_service.dart';
import 'package:csa_frontend/features/offline/models/offline_meta_entry.dart';
import 'package:csa_frontend/features/offline/models/offline_slide_entry.dart';
import 'package:csa_frontend/features/offline/services/offline_store.dart';
import 'package:csa_frontend/shared/services/download_manager.dart';

class _FakeApi implements MyFairytaleApiClient {
  @override
  Future<dynamic> get(String path) async {
    if (path == '/fairytale/42/slides') {
      return {
        'id': 42,
        'title': '오프라인 동화',
        'language': 'ko',
        'voiceType': 'dad',
        'pages': [
          {
            'pageIndex': 1,
            'text': '첫 페이지',
            'imageUrl': 'https://cdn.example.com/p1.png',
            'audioUrl': 'https://cdn.example.com/p1.mp3',
          },
          {
            'pageIndex': 2,
            'text': '둘째 페이지',
            'imageUrl': 'https://cdn.example.com/p2.png',
            'audioUrl': 'https://cdn.example.com/p2.mp3',
          },
        ],
      };
    }
    throw StateError('unexpected $path');
  }

  @override
  Future<dynamic> post(String path) => throw UnimplementedError();

  @override
  Future<dynamic> delete(String path) => throw UnimplementedError();
}

void main() {
  late Directory tempDir;
  late Box<OfflineSlideEntry> slideBox;
  late Box<OfflineMetaEntry> metaBox;
  late List<String> savedPaths;
  late DownloadManager manager;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('offline_test');
    Hive.init('${tempDir.path}/hive');
    OfflineStore.instance.registerAdaptersForTest();
    slideBox = await Hive.openBox<OfflineSlideEntry>('offline_slide_box');
    metaBox = await Hive.openBox<OfflineMetaEntry>('offline_meta_box');
    OfflineStore.instance.initForTest(slideBox: slideBox, metaBox: metaBox);

    savedPaths = [];
    manager = DownloadManager(
      fairytaleService: MyFairytaleService(api: _FakeApi()),
      store: OfflineStore.instance,
      documentsDirProvider: () async => tempDir,
      fileDownloader: (url, savePath, {onReceiveProgress}) async {
        savedPaths.add(savePath);
        await File(savePath).create(recursive: true);
        await File(savePath).writeAsString('bytes');
      },
    );
  });

  tearDown(() async {
    await slideBox.deleteFromDisk();
    await metaBox.deleteFromDisk();
    await Hive.close();
    if (await tempDir.exists()) {
      await tempDir.delete(recursive: true);
    }
  });

  test('downloadSlide saves files with path rules and records hive', () async {
    await manager.downloadSlide(
      fairytaleId: 42,
      voiceType: 'dad',
      language: 'ko',
    );

    expect(savedPaths.any((p) => p.endsWith('offline/42/page_1.png')), isTrue);
    expect(
      savedPaths.any((p) => p.endsWith('offline/42/page_1_dad_ko.mp3')),
      isTrue,
    );
    expect(savedPaths.any((p) => p.endsWith('offline/42/page_2.png')), isTrue);

    expect(manager.isOfflineAvailable('42'), isTrue);

    final entry = manager.getSlide('42');
    expect(entry, isNotNull);
    expect(entry!.pages.length, 2);
    expect(entry.pages.first.localAudioPaths['dad_ko'], isNotNull);

    final meta = metaBox.get('42');
    expect(meta!.status, DownloadStatus.completed);
    expect(meta.totalSizeBytes, greaterThan(0));
    expect(meta.expiresAt, isNotNull);
  });

  test('fromOfflineSlide maps local paths into response', () async {
    await manager.downloadSlide(
      fairytaleId: 42,
      voiceType: 'dad',
      language: 'ko',
    );
    final entry = manager.getSlide('42')!;
    final response = FairytaleGenerateResponse.fromOfflineSlide(
      entry,
      language: 'ko',
      voiceType: 'dad',
    );
    expect(response.pages.first.localImagePath, contains('page_1.png'));
    expect(response.pages.first.localAudioPath, contains('page_1_dad_ko.mp3'));
  });

  test('delete removes hive entries and files', () async {
    await manager.downloadSlide(
      fairytaleId: 42,
      voiceType: 'dad',
      language: 'ko',
    );
    expect(manager.isOfflineAvailable('42'), isTrue);

    await manager.delete('42');

    expect(manager.isOfflineAvailable('42'), isFalse);
    expect(slideBox.containsKey('42'), isFalse);
    expect(metaBox.containsKey('42'), isFalse);
    expect(Directory('${tempDir.path}/offline/42').existsSync(), isFalse);
  });

  test('cleanupExpired removes expired and incomplete entries', () async {
    metaBox.put(
      '99',
      OfflineMetaEntry(
        fairytaleId: '99',
        format: 'slide',
        totalSizeBytes: 10,
        downloadedAt: DateTime.now(),
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        status: DownloadStatus.completed,
      ),
    );
    metaBox.put(
      '100',
      OfflineMetaEntry(
        fairytaleId: '100',
        format: 'slide',
        totalSizeBytes: 0,
        downloadedAt: DateTime.now(),
        status: DownloadStatus.downloading,
      ),
    );

    await manager.cleanupExpired();

    expect(metaBox.containsKey('99'), isFalse);
    expect(metaBox.containsKey('100'), isFalse);
  });

  test('availableMeta/totalUsedBytes/savedCount aggregate saved entries',
      () async {
    await manager.downloadSlide(
      fairytaleId: 42,
      voiceType: 'dad',
      language: 'ko',
    );

    // 만료 항목은 집계에서 제외되어야 한다.
    metaBox.put(
      '99',
      OfflineMetaEntry(
        fairytaleId: '99',
        format: 'slide',
        totalSizeBytes: 5000,
        downloadedAt: DateTime.now(),
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
        status: DownloadStatus.completed,
      ),
    );

    expect(manager.savedCount(), 1);
    expect(manager.availableMeta().length, 1);
    expect(manager.availableMeta().first.fairytaleId, '42');
    expect(manager.totalUsedBytes(), manager.availableMeta().first.totalSizeBytes);
    expect(manager.totalUsedBytes(), greaterThan(0));
  });

  test('deleteAll removes every saved entry and files', () async {
    await manager.downloadSlide(
      fairytaleId: 42,
      voiceType: 'dad',
      language: 'ko',
    );
    expect(manager.savedCount(), 1);

    await manager.deleteAll();

    expect(manager.savedCount(), 0);
    expect(slideBox.isEmpty, isTrue);
    expect(metaBox.isEmpty, isTrue);
    expect(Directory('${tempDir.path}/offline/42').existsSync(), isFalse);
  });

  test('offline meta entry serializes through hive round-trip', () async {
    final entry = OfflineMetaEntry(
      fairytaleId: 'rt',
      format: 'slide',
      totalSizeBytes: 1234,
      downloadedAt: DateTime.fromMillisecondsSinceEpoch(1000000),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(2000000),
      status: DownloadStatus.completed,
    );
    await metaBox.put('rt', entry);
    final loaded = metaBox.get('rt')!;
    expect(loaded.fairytaleId, 'rt');
    expect(loaded.totalSizeBytes, 1234);
    expect(loaded.expiresAt, DateTime.fromMillisecondsSinceEpoch(2000000));
    expect(loaded.status, DownloadStatus.completed);
  });
}
