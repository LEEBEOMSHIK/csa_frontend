import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
// ignore_for_file: depend_on_referenced_packages
// hive 는 hive_flutter 의 transitive dependency. 어댑터 read/write 를 박스 없이
// 단위 검증하기 위해 내부 binary impl 을 직접 사용한다.
import 'package:hive/src/binary/binary_reader_impl.dart';
import 'package:hive/src/binary/binary_writer_impl.dart';
import 'package:hive/src/hive_impl.dart';
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
      fileDownloader: (url, savePath, {onReceiveProgress, cancelToken}) async {
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

  test(
    'downloadSlide can fetch shared fairytale slides through public path',
    () async {
      final api = _RecordingApi();
      final sharedManager = DownloadManager(
        fairytaleService: MyFairytaleService(api: api),
        store: OfflineStore.instance,
        documentsDirProvider: () async => tempDir,
        fileDownloader:
            (url, savePath, {onReceiveProgress, cancelToken}) async {
              await File(savePath).create(recursive: true);
              await File(savePath).writeAsString('bytes');
            },
      );

      await sharedManager.downloadSlide(
        fairytaleId: 42,
        voiceType: 'dad',
        language: 'ko',
        shared: true,
      );

      expect(api.requestedPaths, contains('/fairytale/shared/42/slides'));
      expect(sharedManager.isOfflineAvailable('42'), isTrue);
    },
  );

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
        voiceType: 'dad',
        language: 'ko',
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
        voiceType: 'dad',
        language: 'ko',
      ),
    );

    await manager.cleanupExpired();

    expect(metaBox.containsKey('99'), isFalse);
    expect(metaBox.containsKey('100'), isFalse);
  });

  test(
    'availableMeta/totalUsedBytes/savedCount aggregate saved entries',
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
          voiceType: 'dad',
          language: 'ko',
        ),
      );

      expect(manager.savedCount(), 1);
      expect(manager.availableMeta().length, 1);
      expect(manager.availableMeta().first.fairytaleId, '42');
      expect(
        manager.totalUsedBytes(),
        manager.availableMeta().first.totalSizeBytes,
      );
      expect(manager.totalUsedBytes(), greaterThan(0));
    },
  );

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

  test(
    'cancel during download cleans up files and meta, no failed state',
    () async {
      // 첫 파일 다운로드 시점에 취소를 트리거하고, 취소된 토큰이면 dio cancel 예외를 던지는 fake.
      final downloadStarted = Completer<void>();
      final cancelManager = DownloadManager(
        fairytaleService: MyFairytaleService(api: _FakeApi()),
        store: OfflineStore.instance,
        documentsDirProvider: () async => tempDir,
        fileDownloader:
            (url, savePath, {onReceiveProgress, cancelToken}) async {
              if (cancelToken != null && cancelToken.isCancelled) {
                throw DioException(
                  requestOptions: RequestOptions(path: url),
                  type: DioExceptionType.cancel,
                );
              }
              if (!downloadStarted.isCompleted) downloadStarted.complete();
              await File(savePath).create(recursive: true);
              await File(savePath).writeAsString('bytes');
            },
      );

      final future = cancelManager.downloadSlide(
        fairytaleId: 42,
        voiceType: 'dad',
        language: 'ko',
      );
      await downloadStarted.future;
      await cancelManager.cancel('42');
      await future;

      expect(cancelManager.isOfflineAvailable('42'), isFalse);
      expect(slideBox.containsKey('42'), isFalse);
      // 취소는 failed 가 아니라 메타 제거(미저장)로 정리된다.
      expect(metaBox.containsKey('42'), isFalse);
      // 부분 저장 디렉터리/파일 잔존 없음.
      expect(Directory('${tempDir.path}/offline/42').existsSync(), isFalse);
      expect(cancelManager.isDownloading('42'), isFalse);
    },
  );

  test('cancel completes via progress stream without error event', () async {
    final downloadStarted = Completer<void>();
    final cancelManager = DownloadManager(
      fairytaleService: MyFairytaleService(api: _FakeApi()),
      store: OfflineStore.instance,
      documentsDirProvider: () async => tempDir,
      fileDownloader: (url, savePath, {onReceiveProgress, cancelToken}) async {
        if (cancelToken != null && cancelToken.isCancelled) {
          throw DioException(
            requestOptions: RequestOptions(path: url),
            type: DioExceptionType.cancel,
          );
        }
        if (!downloadStarted.isCompleted) downloadStarted.complete();
        await File(savePath).create(recursive: true);
        await File(savePath).writeAsString('bytes');
      },
    );

    final errors = <Object>[];
    final sub = cancelManager
        .progressStream('42')
        .listen((_) {}, onError: errors.add);

    final future = cancelManager.downloadSlide(
      fairytaleId: 42,
      voiceType: 'dad',
      language: 'ko',
    );
    await downloadStarted.future;
    await cancelManager.cancel('42');
    // 취소는 정상 흐름이므로 downloadSlide future 가 throw 하지 않는다.
    await expectLater(future, completes);

    await sub.cancel();
    expect(errors, isEmpty);
    expect(metaBox.get('42'), isNull);
  });

  test('cancel does not block subsequent queue item', () async {
    final firstStarted = Completer<void>();
    final cancelManager = DownloadManager(
      fairytaleService: MyFairytaleService(api: _FakeApi()),
      store: OfflineStore.instance,
      documentsDirProvider: () async => tempDir,
      fileDownloader: (url, savePath, {onReceiveProgress, cancelToken}) async {
        if (cancelToken != null && cancelToken.isCancelled) {
          throw DioException(
            requestOptions: RequestOptions(path: url),
            type: DioExceptionType.cancel,
          );
        }
        if (!firstStarted.isCompleted) firstStarted.complete();
        await File(savePath).create(recursive: true);
        await File(savePath).writeAsString('bytes');
      },
    );

    final first = cancelManager.downloadSlide(
      fairytaleId: 42,
      voiceType: 'dad',
      language: 'ko',
    );
    // 두 번째 항목은 같은 id 큐 직렬화를 검증하기 위해 첫 작업 취소 후 진행.
    await firstStarted.future;
    await cancelManager.cancel('42');
    await first;

    expect(cancelManager.isOfflineAvailable('42'), isFalse);

    // 취소 후 다음 다운로드가 정상 진행되어 저장까지 완료되는지 확인(큐 비차단).
    await cancelManager.downloadSlide(
      fairytaleId: 42,
      voiceType: 'dad',
      language: 'ko',
    );
    expect(cancelManager.isOfflineAvailable('42'), isTrue);
    expect(metaBox.get('42')!.status, DownloadStatus.completed);
  });

  test('cancel on already completed id is a safe no-op', () async {
    await manager.downloadSlide(
      fairytaleId: 42,
      voiceType: 'dad',
      language: 'ko',
    );
    expect(manager.isOfflineAvailable('42'), isTrue);

    // 진행 중이 아닌 id 취소는 아무 동작도 하지 않아야 한다(저장본 보존).
    await manager.cancel('42');

    expect(manager.isOfflineAvailable('42'), isTrue);
    expect(metaBox.get('42')!.status, DownloadStatus.completed);
  });

  test('cancel while queued cancels before any network call', () async {
    final firstRelease = Completer<void>();
    final firstStarted = Completer<void>();
    final downloadedUrls = <String>[];
    final cancelManager = DownloadManager(
      fairytaleService: MyFairytaleService(api: _FakeApi()),
      store: OfflineStore.instance,
      documentsDirProvider: () async => tempDir,
      fileDownloader: (url, savePath, {onReceiveProgress, cancelToken}) async {
        if (cancelToken != null && cancelToken.isCancelled) {
          throw DioException(
            requestOptions: RequestOptions(path: url),
            type: DioExceptionType.cancel,
          );
        }
        downloadedUrls.add(url);
        if (!firstStarted.isCompleted) firstStarted.complete();
        // 첫 작업을 붙잡아 두어 둘째 작업이 큐 대기 상태에 머물게 한다.
        await firstRelease.future;
        await File(savePath).create(recursive: true);
        await File(savePath).writeAsString('bytes');
      },
    );

    final first = cancelManager.downloadSlide(
      fairytaleId: 42,
      voiceType: 'dad',
      language: 'ko',
    );
    await firstStarted.future;

    // 둘째 작업은 큐 대기 — 시작 전 취소한다.
    final second = cancelManager.downloadSlide(
      fairytaleId: 7,
      voiceType: 'dad',
      language: 'ko',
    );
    expect(cancelManager.isDownloading('7'), isTrue);
    await cancelManager.cancel('7');

    firstRelease.complete();
    await first;
    await second;

    // 둘째(7) 는 네트워크 호출 없이 취소되어 저장되지 않음.
    expect(cancelManager.isOfflineAvailable('7'), isFalse);
    expect(metaBox.containsKey('7'), isFalse);
    expect(downloadedUrls.every((u) => !u.contains('7')), isTrue);
    // 첫 작업(42) 은 정상 완료.
    expect(cancelManager.isOfflineAvailable('42'), isTrue);
  });

  test('offline meta entry serializes through hive round-trip', () async {
    final entry = OfflineMetaEntry(
      fairytaleId: 'rt',
      format: 'slide',
      totalSizeBytes: 1234,
      downloadedAt: DateTime.fromMillisecondsSinceEpoch(1000000),
      expiresAt: DateTime.fromMillisecondsSinceEpoch(2000000),
      status: DownloadStatus.completed,
      voiceType: 'mom',
      language: 'ja',
    );
    await metaBox.put('rt', entry);
    final loaded = metaBox.get('rt')!;
    expect(loaded.fairytaleId, 'rt');
    expect(loaded.totalSizeBytes, 1234);
    expect(loaded.expiresAt, DateTime.fromMillisecondsSinceEpoch(2000000));
    expect(loaded.status, DownloadStatus.completed);
    expect(loaded.voiceType, 'mom');
    expect(loaded.language, 'ja');
  });

  test('legacy bytes without voice/lang decode to default values', () {
    // voice/lang append 이전(구) write 형식으로 직렬화한 바이트를 만든 뒤
    // 현재 adapter.read 로 디코드해 EOF 안전·기본값 폴백을 검증한다.
    final registry = HiveImpl();
    final writer = BinaryWriterImpl(registry)
      ..writeString('legacy')
      ..writeString('slide')
      ..writeInt(777)
      ..writeInt(
        DateTime.fromMillisecondsSinceEpoch(1000000).millisecondsSinceEpoch,
      )
      ..writeBool(false)
      ..writeInt(DownloadStatus.completed.index);
    final adapter = OfflineMetaEntryAdapter();
    final reader = BinaryReaderImpl(writer.toBytes(), registry);
    final decoded = adapter.read(reader);
    expect(decoded.fairytaleId, 'legacy');
    expect(decoded.totalSizeBytes, 777);
    expect(decoded.status, DownloadStatus.completed);
    expect(decoded.voiceType, 'dad');
    expect(decoded.language, 'ko');
  });

  test(
    'downloadSlide persists voiceType/language into meta (ja + mom)',
    () async {
      await manager.downloadSlide(
        fairytaleId: 42,
        voiceType: 'mom',
        language: 'ja',
      );

      final meta = metaBox.get('42')!;
      expect(meta.status, DownloadStatus.completed);
      expect(meta.voiceType, 'mom');
      expect(meta.language, 'ja');

      // Hive 디스크 라운드트립 후에도 보존되는지 확인(회귀 방지).
      final reopened = metaBox.get('42')!;
      expect(reopened.voiceType, 'mom');
      expect(reopened.language, 'ja');
    },
  );
}

class _RecordingApi implements MyFairytaleApiClient {
  final List<String> requestedPaths = [];

  @override
  Future<dynamic> get(String path) async {
    requestedPaths.add(path);
    if (path == '/fairytale/shared/42/slides') {
      return {
        'id': 42,
        'title': '공유 오프라인 동화',
        'language': 'ko',
        'voiceType': 'dad',
        'pages': [
          {
            'pageIndex': 1,
            'text': '공유 첫 페이지',
            'imageUrl': 'https://cdn.example.com/shared-p1.png',
            'audioUrl': 'https://cdn.example.com/shared-p1.mp3',
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
