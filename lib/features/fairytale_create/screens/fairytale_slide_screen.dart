import 'package:flutter/material.dart';

import 'package:csa_frontend/features/fairytale_create/models/fairytale_generate_response.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/shared/services/tts_service.dart';
import 'package:csa_frontend/utils/app_colors.dart';

class FairytaleSlideScreen extends StatefulWidget {
  final FairytaleGenerateResponse fairytale;
  final String lang;
  final String voiceType;

  const FairytaleSlideScreen({
    super.key,
    required this.fairytale,
    required this.lang,
    required this.voiceType,
  });

  @override
  State<FairytaleSlideScreen> createState() => _FairytaleSlideScreenState();
}

class _FairytaleSlideScreenState extends State<FairytaleSlideScreen> {
  late final PageController _pageController;
  int _currentIndex = 0;

  List<FairytalePageResponse> get _pages => widget.fairytale.pages;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    if (TtsService.instance.isSpeaking.value) {
      TtsService.instance.stop();
    }
    super.dispose();
  }

  Future<void> _moveTo(int index) async {
    if (index < 0 || index >= _pages.length) return;
    await _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
    );
  }

  Future<void> _onPageChanged(int index) async {
    setState(() => _currentIndex = index);
    if (!TtsService.instance.isSpeaking.value) return;
    await _speakCurrentPage();
  }

  Future<void> _toggleNarration() async {
    if (TtsService.instance.isSpeaking.value) {
      await TtsService.instance.stop();
      return;
    }
    await _speakCurrentPage();
  }

  Future<void> _speakCurrentPage() async {
    if (_pages.isEmpty) return;
    final text = _pages[_currentIndex].text.trim();
    if (text.isEmpty) return;
    await TtsService.instance.speak(
      text,
      lang: widget.lang,
      voice: widget.voiceType,
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
            _SlideTopBar(
              title: widget.fairytale.title,
              pageText: _pages.isEmpty
                  ? '0 / 0'
                  : '${_currentIndex + 1} / ${_pages.length}',
              closeLabel: materialL10n.closeButtonTooltip,
            ),
            Expanded(
              child: _pages.isEmpty
                  ? Center(child: Text(l10n.ttsNoContent))
                  : PageView.builder(
                      controller: _pageController,
                      itemCount: _pages.length,
                      onPageChanged: _onPageChanged,
                      itemBuilder: (context, index) {
                        return _SlidePage(page: _pages[index]);
                      },
                    ),
            ),
            _SlideControls(
              canGoPrev: _currentIndex > 0,
              canGoNext: _currentIndex < _pages.length - 1,
              prevLabel: materialL10n.previousPageTooltip,
              nextLabel: materialL10n.nextPageTooltip,
              playLabel: l10n.detailReadBtn,
              stopLabel: l10n.detailDownloadCancel,
              onPrev: () => _moveTo(_currentIndex - 1),
              onNext: () => _moveTo(_currentIndex + 1),
              onPlayToggle: _toggleNarration,
            ),
          ],
        ),
      ),
    );
  }
}

class _SlideTopBar extends StatelessWidget {
  final String title;
  final String pageText;
  final String closeLabel;

  const _SlideTopBar({
    required this.title,
    required this.pageText,
    required this.closeLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 16, 8),
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
          const SizedBox(width: 12),
          Text(
            pageText,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _SlidePage extends StatelessWidget {
  final FairytalePageResponse page;

  const _SlidePage({required this.page});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
      child: Column(
        children: [
          Expanded(
            flex: 6,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: DecoratedBox(
                decoration: const BoxDecoration(color: Color(0xFFFFF4E5)),
                child: SizedBox.expand(child: _SlideImage(url: page.imageUrl)),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            flex: 4,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Text(
                  page.text,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    height: 1.6,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SlideImage extends StatelessWidget {
  final String? url;

  const _SlideImage({required this.url});

  @override
  Widget build(BuildContext context) {
    final imageUrl = url;
    if (imageUrl == null || imageUrl.isEmpty) {
      return const _ImagePlaceholder();
    }
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: AppColors.create),
        );
      },
      errorBuilder: (_, _, _) => const _ImagePlaceholder(),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(
        Icons.image_not_supported_outlined,
        color: Color(0xFFD8C6B8),
        size: 56,
      ),
    );
  }
}

class _SlideControls extends StatelessWidget {
  final bool canGoPrev;
  final bool canGoNext;
  final String prevLabel;
  final String nextLabel;
  final String playLabel;
  final String stopLabel;
  final VoidCallback onPrev;
  final VoidCallback onNext;
  final VoidCallback onPlayToggle;

  const _SlideControls({
    required this.canGoPrev,
    required this.canGoNext,
    required this.prevLabel,
    required this.nextLabel,
    required this.playLabel,
    required this.stopLabel,
    required this.onPrev,
    required this.onNext,
    required this.onPlayToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        children: [
          _RoundControlButton(
            key: const Key('slide-prev-button'),
            icon: Icons.chevron_left_rounded,
            tooltip: prevLabel,
            enabled: canGoPrev,
            onTap: onPrev,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ValueListenableBuilder<bool>(
              valueListenable: TtsService.instance.isSpeaking,
              builder: (context, speaking, _) {
                return ElevatedButton.icon(
                  key: const Key('slide-play-button'),
                  onPressed: onPlayToggle,
                  icon: Icon(
                    speaking
                        ? Icons.stop_circle_rounded
                        : Icons.play_circle_rounded,
                  ),
                  label: Text(
                    speaking ? stopLabel : playLabel,
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
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          _RoundControlButton(
            key: const Key('slide-next-button'),
            icon: Icons.chevron_right_rounded,
            tooltip: nextLabel,
            enabled: canGoNext,
            onTap: onNext,
          ),
        ],
      ),
    );
  }
}

class _RoundControlButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onTap;

  const _RoundControlButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton.filled(
      tooltip: tooltip,
      onPressed: enabled ? onTap : null,
      icon: Icon(icon, size: 28),
      style: IconButton.styleFrom(
        backgroundColor: Colors.white,
        disabledBackgroundColor: const Color(0xFFF2EEE7),
        foregroundColor: AppColors.create,
        disabledForegroundColor: const Color(0xFFCCC5BA),
        minimumSize: const Size(52, 52),
      ),
    );
  }
}
