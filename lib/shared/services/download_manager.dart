import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
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
            {void Function(int, int)? onReceiveProgress,
            CancelToken? cancelToken})?
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
          {void Function(int, int)? onReceiveProgress,
          CancelToken? cancelToken})
      _fileDownloader;
  final Future<Directory> Function() _documentsDirProvider;

  final Map<String, StreamController<double>> _progressControllers = {};

  /// 진행 중 다운로드의 취소 토큰(fairytaleId별). 취소 또는 종료 시 제거된다.
  final Map<String, CancelToken> _cancelTokens = {};

  /// 동시 다운로드 1개 큐 — 진행 중인 작업 완료까지 다음 작업이 대기한다.
  Future<void> _queue = Future<void>.value();

  static Future<void> _defaultFileDownloader(
    String url,
    String savePath, {
    void Function(int, int)? onReceiveProgress,
    CancelToken? cancelToken,
  }) {
    return ApiClient.instance.downloadFile(
      url,
      savePath,
      onReceiveProgress: onReceiveProgress,
      cancelToken: cancelToken,
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

  /// 해당 동화의 다운로드가 진행(또는 큐 대기) 중인지 여부.
  bool isDownloading(String fairytaleId) =>
      _cancelTokens.containsKey(fairytaleId);

  /// 진행 중(또는 큐 대기 중)인 다운로드를 취소한다.
  /// dio CancelToken 으로 전송을 중단하고, 부분 저장 파일과 미완료 메타를 정리한다.
  /// 이미 완료됐거나 진행 중이 아니면 아무 동작도 하지 않는다.
  Future<void> cancel(String fairytaleId) async {
    final token = _cancelTokens[fairytaleId];
    if (token == null) return;
    if (!token.isCancelled) {
      token.cancel('cancelled by user');
    }
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

  /// 완료·미만료 상태로 저장된 동화의 메타데이터 목록(최근 저장 순).
  /// 저장 관리 화면에서 용량/저장일 표시에 사용한다.
  List<OfflineMetaEntry> availableMeta() {
    if (!_store.isInitialized) return const [];
    final now = DateTime.now();
    final entries = <OfflineMetaEntry>[];
    for (final id in _store.metaBox.keys.cast<String>()) {
      final meta = _store.metaBox.get(id);
      if (meta == null || !meta.isCompleted || meta.isExpired(now)) continue;
      if (!_store.slideBox.containsKey(id)) continue;
      entries.add(meta);
    }
    entries.sort((a, b) => b.downloadedAt.compareTo(a.downloadedAt));
    return entries;
  }

  /// 완료·미만료 저장본의 총 사용 용량(바이트) 합산.
  int totalUsedBytes() {
    var total = 0;
    for (final meta in availableMeta()) {
      total += meta.totalSizeBytes;
    }
    return total;
  }

  /// 저장된(완료·미만료) 동화 개수.
  int savedCount() => availableMeta().length;

  /// 저장된 모든 슬라이드 동화를 삭제한다(파일 + Hive 메타/본문).
  Future<void> deleteAll() async {
    if (!_store.isInitialized) return;
    final ids = _store.metaBox.keys.cast<String>().toList();
    for (final id in ids) {
      await delete(id);
    }
  }

  /// 슬라이드 형식 동화를 오프라인 저장한다.
  /// 동시에 1개만 진행되도록 내부 큐에 직렬화한다.
  Future<void> downloadSlide({
    required int fairytaleId,
    required String voiceType,
    required String language,
  }) {
    final id = fairytaleId.toString();
    // 큐 대기 중에도 취소가 가능하도록 토큰을 시작 시점에 등록한다.
    final token = _cancelTokens.putIfAbsent(id, CancelToken.new);

    final result = _queue.then(
      (_) => _runDownloadSlide(
        fairytaleId: fairytaleId,
        voiceType: voiceType,
        language: language,
        cancelToken: token,
      ),
    );
    // 실패/취소가 큐 전체를 막지 않도록 swallow 한 future 로 다음 작업을 잇는다.
    _queue = result.catchError((_) {});
    return result;
  }

  Future<void> _runDownloadSlide({
    required int fairytaleId,
    required String voiceType,
    required String language,
    required CancelToken cancelToken,
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
      // 큐 대기 중 취소된 경우 네트워크 호출 전에 중단한다.
      if (cancelToken.isCancelled) {
        throw _CancelledException();
      }
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
        await _fileDownloader(
          task.url,
          task.savePath,
          cancelToken: cancelToken,
        );
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
      final cancelled = cancelToken.isCancelled || e is _CancelledException;
      // 부분 저장 파일 정리 (방치 금지 규칙 준수).
      await _deleteFiles(id);
      await _store.slideBox.delete(id);
      if (cancelled) {
        // 취소는 에러가 아닌 정상 흐름 — 미저장 상태로 되돌리고 항목을 제거한다.
        await _store.metaBox.delete(id);
        if (!controller.isClosed) controller.add(0.0);
        return;
      }
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
    } finally {
      _cancelTokens.remove(id);
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

/// 큐 대기 중 취소를 정상 취소로 구분하기 위한 내부 sentinel.
class _CancelledException implements Exception {}
