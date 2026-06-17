import 'dart:async';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'package:csa_frontend/features/my/services/my_fairytale_service.dart';
import 'package:csa_frontend/features/offline/models/offline_meta_entry.dart';
import 'package:csa_frontend/features/offline/models/offline_slide_entry.dart';
import 'package:csa_frontend/features/offline/services/offline_store.dart';
import 'package:csa_frontend/shared/services/api_client.dart';

/// 슬라이드 형식 동화의 오프라인 다운로드/저장/삭제/조회를 담당하는 서비스.
/// 영상(video) 형식은 후속 단계 — 현재 범위에 포함되지 않는다.
class DownloadManager {
  DownloadManager({
    MyFairytaleService? fairytaleService,
    OfflineStore? store,
    Future<void> Function(String url, String savePath,
            {void Function(int, int)? onReceiveProgress})?
        fileDownloader,
    Future<Directory> Function()? documentsDirProvider,
  })  : _fairytaleService = fairytaleService ?? MyFairytaleService.instance,
        _store = store ?? OfflineStore.instance,
        _fileDownloader = fileDownloader ?? _defaultFileDownloader,
        _documentsDirProvider =
            documentsDirProvider ?? getApplicationDocumentsDirectory;

  static final DownloadManager instance = DownloadManager();

  /// TTL: 30일 미사용 시 만료 (무기한 캐싱 금지 규칙 준수).
  static const Duration ttl = Duration(days: 30);

  final MyFairytaleService _fairytaleService;
  final OfflineStore _store;
  final Future<void> Function(String url, String savePath,
      {void Function(int, int)? onReceiveProgress}) _fileDownloader;
  final Future<Directory> Function() _documentsDirProvider;

  final Map<String, StreamController<double>> _progressControllers = {};

  /// 동시 다운로드 1개 큐 — 진행 중인 작업 완료까지 다음 작업이 대기한다.
  Future<void> _queue = Future<void>.value();

  static Future<void> _defaultFileDownloader(
    String url,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
  }) {
    return ApiClient.instance.downloadFile(
      url,
      savePath,
      onReceiveProgress: onReceiveProgress,
    );
  }

  /// 진행률(0.0~1.0) 스트림. 다운로드 시작 시점에 구독하면 진행 상황을 받는다.
  Stream<double> progressStream(String fairytaleId) {
    return _controllerFor(fairytaleId).stream;
  }

  StreamController<double> _controllerFor(String fairytaleId) {
    return _progressControllers.putIfAbsent(
      fairytaleId,
      () => StreamController<double>.broadcast(),
    );
  }

  bool isOfflineAvailable(String fairytaleId) {
    if (!_store.isInitialized) return false;
    final meta = _store.metaBox.get(fairytaleId);
    if (meta == null || !meta.isCompleted) return false;
    if (meta.isExpired(DateTime.now())) return false;
    return _store.slideBox.containsKey(fairytaleId);
  }

  OfflineSlideEntry? getSlide(String fairytaleId) {
    if (!isOfflineAvailable(fairytaleId)) return null;
    return _store.slideBox.get(fairytaleId);
  }

  /// 완료·미만료 상태로 저장된(오프라인 이용 가능) 슬라이드 동화 목록.
  /// 오프라인 상태에서 서버 목록 대신 표시할 후보로 사용한다.
  List<OfflineSlideEntry> availableSlides() {
    if (!_store.isInitialized) return const [];
    final now = DateTime.now();
    final entries = <OfflineSlideEntry>[];
    for (final id in _store.metaBox.keys.cast<String>()) {
      final meta = _store.metaBox.get(id);
      if (meta == null || !meta.isCompleted || meta.isExpired(now)) continue;
      final slide = _store.slideBox.get(id);
      if (slide != null) entries.add(slide);
    }
    entries.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    return entries;
  }

  /// 슬라이드 형식 동화를 오프라인 저장한다.
  /// 동시에 1개만 진행되도록 내부 큐에 직렬화한다.
  Future<void> downloadSlide({
    required int fairytaleId,
    required String voiceType,
    required String language,
  }) {
    final result = _queue.then(
      (_) => _runDownloadSlide(
        fairytaleId: fairytaleId,
        voiceType: voiceType,
        language: language,
      ),
    );
    // 실패가 큐 전체를 막지 않도록 swallow 한 future 로 다음 작업을 잇는다.
    _queue = result.catchError((_) {});
    return result;
  }

  Future<void> _runDownloadSlide({
    required int fairytaleId,
    required String voiceType,
    required String language,
  }) async {
    final id = fairytaleId.toString();
    final controller = _controllerFor(id);
    controller.add(0.0);

    final dir = await _offlineDir(id);
    final voiceKey = '${voiceType}_$language';

    _store.metaBox.put(
      id,
      OfflineMetaEntry(
        fairytaleId: id,
        format: 'slide',
        totalSizeBytes: 0,
        downloadedAt: DateTime.now(),
        expiresAt: DateTime.now().add(ttl),
        status: DownloadStatus.downloading,
      ),
    );

    try {
      final response = await _fairytaleService.fetchSlides(fairytaleId);
      final pages = response.pages;

      // 다운로드 대상: 페이지별 이미지 + 선택 목소리 오디오.
      final tasks = <_DownloadTask>[];
      for (final page in pages) {
        final imageUrl = page.imageUrl?.trim();
        if (imageUrl != null && imageUrl.isNotEmpty) {
          tasks.add(
            _DownloadTask(
              url: imageUrl,
              savePath: '${dir.path}/page_${page.pageIndex}.png',
            ),
          );
        }
        final audioUrl = page.audioUrl?.trim();
        if (audioUrl != null && audioUrl.isNotEmpty) {
          tasks.add(
            _DownloadTask(
              url: audioUrl,
              savePath:
                  '${dir.path}/page_${page.pageIndex}_${voiceType}_$language.mp3',
            ),
          );
        }
      }

      final total = tasks.isEmpty ? 1 : tasks.length;
      var done = 0;
      for (final task in tasks) {
        await _fileDownloader(task.url, task.savePath);
        done++;
        controller.add(done / total);
      }

      final localPages = <OfflineSlidePage>[];
      for (final page in pages) {
        final imagePath = '${dir.path}/page_${page.pageIndex}.png';
        final audioUrl = page.audioUrl?.trim();
        final audioPaths = <String, String>{};
        if (audioUrl != null && audioUrl.isNotEmpty) {
          audioPaths[voiceKey] =
              '${dir.path}/page_${page.pageIndex}_${voiceType}_$language.mp3';
        }
        localPages.add(
          OfflineSlidePage(
            pageIndex: page.pageIndex,
            text: page.text,
            localImagePath:
                (page.imageUrl?.trim().isNotEmpty ?? false) ? imagePath : '',
            localAudioPaths: audioPaths,
          ),
        );
      }

      final totalBytes = await _dirSizeBytes(dir);

      await _store.slideBox.put(
        id,
        OfflineSlideEntry(
          fairytaleId: id,
          title: response.title,
          thumbnailLocalPath:
              localPages.isNotEmpty ? localPages.first.localImagePath : '',
          pages: localPages,
          downloadedAt: DateTime.now(),
        ),
      );

      await _store.metaBox.put(
        id,
        OfflineMetaEntry(
          fairytaleId: id,
          format: 'slide',
          totalSizeBytes: totalBytes,
          downloadedAt: DateTime.now(),
          expiresAt: DateTime.now().add(ttl),
          status: DownloadStatus.completed,
        ),
      );
      controller.add(1.0);
    } catch (e) {
      // 부분 저장 파일 정리 후 실패 상태 기록 (방치 금지 규칙 준수).
      await _deleteFiles(id);
      await _store.slideBox.delete(id);
      await _store.metaBox.put(
        id,
        OfflineMetaEntry(
          fairytaleId: id,
          format: 'slide',
          totalSizeBytes: 0,
          downloadedAt: DateTime.now(),
          status: DownloadStatus.failed,
        ),
      );
      controller.addError(e);
      rethrow;
    }
  }

  Future<void> delete(String fairytaleId) async {
    await _deleteFiles(fairytaleId);
    await _store.slideBox.delete(fairytaleId);
    await _store.metaBox.delete(fairytaleId);
  }

  /// TTL 만료 또는 미완료(failed/downloading 잔존) 항목을 정리한다.
  /// 앱 시작 시 호출하여 부분 저장/만료 데이터를 제거한다.
  Future<void> cleanupExpired() async {
    final now = DateTime.now();
    final ids = _store.metaBox.keys.cast<String>().toList();
    for (final id in ids) {
      final meta = _store.metaBox.get(id);
      if (meta == null) continue;
      final stale = meta.status != DownloadStatus.completed;
      if (stale || meta.isExpired(now)) {
        await delete(id);
      }
    }
  }

  Future<Directory> _offlineDir(String fairytaleId) async {
    final docs = await _documentsDirProvider();
    final dir = Directory('${docs.path}/offline/$fairytaleId');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  Future<void> _deleteFiles(String fairytaleId) async {
    try {
      final docs = await _documentsDirProvider();
      final dir = Directory('${docs.path}/offline/$fairytaleId');
      if (await dir.exists()) {
        await dir.delete(recursive: true);
      }
    } catch (_) {
      // 파일 정리 실패는 사용자 흐름에 영향 없음
    }
  }

  Future<int> _dirSizeBytes(Directory dir) async {
    var total = 0;
    if (!await dir.exists()) return 0;
    await for (final entity in dir.list(recursive: true, followLinks: false)) {
      if (entity is File) {
        total += await entity.length();
      }
    }
    return total;
  }
}

class _DownloadTask {
  final String url;
  final String savePath;
  const _DownloadTask({required this.url, required this.savePath});
}
