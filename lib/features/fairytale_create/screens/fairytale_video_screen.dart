import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'package:csa_frontend/features/report/widgets/report_button.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/utils/app_colors.dart';

class FairytaleVideoScreen extends StatefulWidget {
  final String title;
  final String videoUrl;

  /// 신고 대상 동화 id. 남의 공유 동화를 열 때만 전달하며, null이면(내 동화·
  /// 오프라인 열람) 상단 바에 신고 버튼을 노출하지 않는다.
  final int? reportFairytaleId;

  /// 신고 대상 동화의 작성자 id. null이면 작성자 신고 항목을 감춘다.
  final int? reportOwnerId;

  const FairytaleVideoScreen({
    super.key,
    required this.title,
    required this.videoUrl,
    this.reportFairytaleId,
    this.reportOwnerId,
  });

  @override
  State<FairytaleVideoScreen> createState() => _FairytaleVideoScreenState();
}

class _FairytaleVideoScreenState extends State<FairytaleVideoScreen> {
  static const Duration _initializeTimeout = Duration(seconds: 20);

  VideoPlayerController? _controller;
  bool _loading = true;
  bool _failed = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  static Uri? _parseVideoUri(String rawUrl) {
    final url = rawUrl.trim();
    if (url.isEmpty) return null;
    final uri = Uri.tryParse(url);
    if (uri == null) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;
    return uri;
  }

  Future<void> _initialize() async {
    final uri = _parseVideoUri(widget.videoUrl);
    if (uri == null) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _failed = true;
      });
      return;
    }

    final controller = VideoPlayerController.networkUrl(uri);
    try {
      await controller.initialize().timeout(_initializeTimeout);
      if (!mounted) {
        _disposeInBackground(controller);
        return;
      }
      setState(() {
        _controller = controller;
        _loading = false;
        _failed = false;
      });
    } catch (_) {
      // 에러 UI를 먼저 띄우고 정리는 뒤로 미룬다. timeout으로 빠진 경우
      // dispose()가 아직 끝나지 않은 initialize를 기다리며 블록되는데,
      // 그걸 await하면 타임아웃을 둔 의미가 사라진다(스피너가 계속 돈다).
      if (mounted) {
        setState(() {
          _controller = null;
          _loading = false;
          _failed = true;
        });
      }
      _disposeInBackground(controller);
    }
  }

  Future<void> _retry() async {
    final previous = _controller;
    setState(() {
      _controller = null;
      _loading = true;
      _failed = false;
    });
    if (previous != null) {
      _disposeInBackground(previous);
    }
    await _initialize();
  }

  /// dispose()는 아직 완료되지 않은 initialize를 기다릴 수 있어 무기한 블록될 수
  /// 있다. 정리는 백그라운드로 넘기고 UI 흐름은 막지 않는다.
  static void _disposeInBackground(VideoPlayerController controller) {
    unawaited(controller.dispose().catchError((_) {}));
  }

  void _togglePlay() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    if (controller.value.isPlaying) {
      controller.pause();
    } else {
      controller.play();
    }
  }

  /// 신고 대상 정보가 전달된 경우(= 남의 공유 동화)에만 신고 버튼을 만든다.
  Widget? _buildReportButton(AppLocalizations l10n) {
    final fairytaleId = widget.reportFairytaleId;
    if (fairytaleId == null) return null;
    return ReportButton(
      l10n: l10n,
      fairytaleId: fairytaleId,
      ownerId: widget.reportOwnerId,
      variant: ReportButtonVariant.topBar,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final materialL10n = MaterialLocalizations.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      body: SafeArea(
        child: Column(
          children: [
            _VideoTopBar(
              title: widget.title,
              closeLabel: materialL10n.closeButtonTooltip,
              reportButton: _buildReportButton(l10n),
            ),
            Expanded(child: _buildBody(l10n)),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(AppLocalizations l10n) {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.create),
      );
    }

    final controller = _controller;
    if (_failed || controller == null) {
      return _VideoErrorView(
        message: l10n.videoPlayerError,
        retryLabel: l10n.videoPlayerRetry,
        onRetry: _retry,
      );
    }

    return ValueListenableBuilder<VideoPlayerValue>(
      valueListenable: controller,
      builder: (context, value, _) {
        if (value.hasError) {
          return _VideoErrorView(
            message: l10n.videoPlayerError,
            retryLabel: l10n.videoPlayerRetry,
            onRetry: _retry,
          );
        }
        return Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(22),
                    child: AspectRatio(
                      aspectRatio: value.aspectRatio,
                      child: VideoPlayer(controller),
                    ),
                  ),
                ),
              ),
            ),
            _VideoControls(
              controller: controller,
              value: value,
              playLabel: l10n.videoPlayerPlay,
              pauseLabel: l10n.videoPlayerPause,
              onPlayToggle: _togglePlay,
            ),
          ],
        );
      },
    );
  }
}

class _VideoTopBar extends StatelessWidget {
  final String title;
  final String closeLabel;
  final Widget? reportButton;

  const _VideoTopBar({
    required this.title,
    required this.closeLabel,
    this.reportButton,
  });

  @override
  Widget build(BuildContext context) {
    final report = reportButton;
    return Padding(
      padding: EdgeInsets.fromLTRB(12, 8, report == null ? 16 : 4, 8),
      child: Row(
        children: [
          IconButton(
            tooltip: closeLabel,
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close_rounded),
          ),
          Expanded(
            child: Text(
              title,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          ?report,
        ],
      ),
    );
  }
}

class _VideoControls extends StatelessWidget {
  final VideoPlayerController controller;
  final VideoPlayerValue value;
  final String playLabel;
  final String pauseLabel;
  final VoidCallback onPlayToggle;

  const _VideoControls({
    required this.controller,
    required this.value,
    required this.playLabel,
    required this.pauseLabel,
    required this.onPlayToggle,
  });

  static String _formatDuration(Duration duration) {
    final totalSeconds = duration.inSeconds;
    final minutes = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (totalSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final isPlaying = value.isPlaying;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Column(
        children: [
          VideoProgressIndicator(
            controller,
            allowScrubbing: true,
            padding: const EdgeInsets.symmetric(vertical: 8),
            colors: const VideoProgressColors(
              playedColor: AppColors.create,
              bufferedColor: Color(0xFFE0DBD2),
              backgroundColor: Color(0xFFF2EEE7),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Text(
                _formatDuration(value.position),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                _formatDuration(value.duration),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ElevatedButton.icon(
            key: const Key('video-play-button'),
            onPressed: onPlayToggle,
            icon: Icon(
              isPlaying
                  ? Icons.pause_circle_rounded
                  : Icons.play_circle_rounded,
            ),
            label: Text(
              isPlaying ? pauseLabel : playLabel,
              overflow: TextOverflow.ellipsis,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.create,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoErrorView extends StatelessWidget {
  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  const _VideoErrorView({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.videocam_off_rounded,
              size: 54,
              color: Color(0xFFDDDDDD),
            ),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              key: const Key('video-retry-button'),
              onPressed: onRetry,
              child: Text(retryLabel, overflow: TextOverflow.ellipsis),
            ),
          ],
        ),
      ),
    );
  }
}
