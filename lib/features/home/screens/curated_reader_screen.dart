import 'package:flutter/material.dart';

import 'package:csa_frontend/features/character/models/saved_character.dart';
import 'package:csa_frontend/features/character/services/character_service.dart';
import 'package:csa_frontend/features/character/widgets/character_preview.dart';
import 'package:csa_frontend/features/home/models/curated_slides_manifest.dart';
import 'package:csa_frontend/features/home/services/fairytale_service.dart';
import 'package:csa_frontend/l10n/app_localizations.dart';
import 'package:csa_frontend/utils/locale_provider.dart';

class CuratedReaderScreen extends StatefulWidget {
  final int fairytaleId;
  final String title;

  const CuratedReaderScreen({
    super.key,
    required this.fairytaleId,
    required this.title,
  });

  @override
  State<CuratedReaderScreen> createState() => _CuratedReaderScreenState();
}

class _CuratedReaderScreenState extends State<CuratedReaderScreen> {
  final PageController _pageController = PageController();
  Future<_ReaderData>? _readerDataFuture;
  SavedCharacter? _selectedCharacter;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _readerDataFuture = _loadReaderData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<_ReaderData> _loadReaderData() async {
    final manifest = await FairytaleService.instance.getCuratedSlides(
      widget.fairytaleId,
    );
    if (!manifest.characterSupported ||
        manifest.characterRenderMode != 'LOCAL_OVERLAY') {
      return _ReaderData(manifest: manifest, characters: const []);
    }

    try {
      final characters = await CharacterService.instance.fetchMyCharacters();
      final renderableCharacters = characters
          .where((character) => character.hasRenderableVariants)
          .toList();
      if (mounted &&
          _selectedCharacter == null &&
          renderableCharacters.isNotEmpty) {
        _selectedCharacter = renderableCharacters.first;
      }
      return _ReaderData(manifest: manifest, characters: renderableCharacters);
    } catch (_) {
      return _ReaderData(manifest: manifest, characters: const []);
    }
  }

  void _retry() {
    setState(() {
      _selectedCharacter = null;
      _currentPage = 0;
      _readerDataFuture = _loadReaderData();
    });
  }

  Future<void> _selectCharacter(List<SavedCharacter> characters) async {
    final l10n = AppLocalizations.of(context)!;
    final selection = await showModalBottomSheet<_CharacterSelection>(
      context: context,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.curatedReaderCharacterPickerTitle,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.person_off_outlined),
                title: Text(l10n.curatedReaderNoCharacter),
                onTap: () =>
                    Navigator.of(context).pop(const _CharacterSelection()),
              ),
              ...characters.map(
                (character) => ListTile(
                  leading: _CharacterThumbnail(character: character),
                  title: Text(character.name),
                  trailing: _selectedCharacter?.id == character.id
                      ? const Icon(Icons.check_rounded)
                      : null,
                  onTap: () => Navigator.of(
                    context,
                  ).pop(_CharacterSelection(character: character)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    if (!mounted || selection == null) return;
    setState(() => _selectedCharacter = selection.character);
  }

  void _goToPage(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDF5),
      appBar: AppBar(
        title: Text(widget.title, overflow: TextOverflow.ellipsis),
        actions: [
          FutureBuilder<_ReaderData>(
            future: _readerDataFuture,
            builder: (context, snapshot) {
              final List<SavedCharacter> characters =
                  snapshot.data?.characters ?? const [];
              if (characters.isEmpty) return const SizedBox.shrink();
              return IconButton(
                tooltip: l10n.curatedReaderCharacterPicker,
                icon: const Icon(Icons.face_rounded),
                onPressed: () => _selectCharacter(characters),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<_ReaderData>(
        future: _readerDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return _ReaderError(onRetry: _retry);
          }
          return _ReaderBody(
            data: snapshot.data!,
            pageController: _pageController,
            selectedCharacter: _selectedCharacter,
            currentPage: _currentPage,
            onPageChanged: (page) => setState(() => _currentPage = page),
            onPrevious: _currentPage == 0
                ? null
                : () => _goToPage(_currentPage - 1),
            onNext: _currentPage >= snapshot.data!.manifest.pages.length - 1
                ? null
                : () => _goToPage(_currentPage + 1),
          );
        },
      ),
    );
  }
}

class _ReaderData {
  final CuratedSlidesManifest manifest;
  final List<SavedCharacter> characters;

  const _ReaderData({required this.manifest, required this.characters});
}

class _CharacterSelection {
  final SavedCharacter? character;

  const _CharacterSelection({this.character});
}

class _ReaderBody extends StatelessWidget {
  final _ReaderData data;
  final PageController pageController;
  final SavedCharacter? selectedCharacter;
  final int currentPage;
  final ValueChanged<int> onPageChanged;
  final VoidCallback? onPrevious;
  final VoidCallback? onNext;

  const _ReaderBody({
    required this.data,
    required this.pageController,
    required this.selectedCharacter,
    required this.currentPage,
    required this.onPageChanged,
    required this.onPrevious,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pages = data.manifest.pages;
    if (pages.isEmpty) return const _ReaderError(onRetry: null);
    return SafeArea(
      top: false,
      child: Column(
        children: [
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: pages.length,
              onPageChanged: onPageChanged,
              itemBuilder: (context, index) => _ReaderPage(
                page: pages[index],
                character:
                    data.manifest.characterSupported &&
                        data.manifest.characterRenderMode == 'LOCAL_OVERLAY'
                    ? selectedCharacter
                    : null,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
            child: Row(
              children: [
                IconButton(
                  tooltip: l10n.curatedReaderPrevious,
                  onPressed: onPrevious,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      l10n.curatedReaderPage(currentPage + 1, pages.length),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: l10n.curatedReaderNext,
                  onPressed: onNext,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ReaderPage extends StatelessWidget {
  final CuratedSlidePage page;
  final SavedCharacter? character;

  const _ReaderPage({required this.page, required this.character});

  @override
  Widget build(BuildContext context) {
    final locale = localeNotifier.value.languageCode;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Column(
        children: [
          Expanded(
            child: _CuratedScene(page: page, character: character),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Text(
              page.text.forLocale(locale),
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(height: 1.6),
            ),
          ),
        ],
      ),
    );
  }
}

class _CuratedScene extends StatefulWidget {
  final CuratedSlidePage page;
  final SavedCharacter? character;

  const _CuratedScene({required this.page, required this.character});

  @override
  State<_CuratedScene> createState() => _CuratedSceneState();
}

class _CuratedSceneState extends State<_CuratedScene> {
  ImageStream? _imageStream;
  ImageStreamListener? _imageListener;
  Size? _imageSize;
  bool _imageFailed = false;

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  @override
  void didUpdateWidget(covariant _CuratedScene oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.page.imageUrl != widget.page.imageUrl) _resolveImage();
  }

  @override
  void dispose() {
    if (_imageStream != null && _imageListener != null) {
      _imageStream!.removeListener(_imageListener!);
    }
    super.dispose();
  }

  void _resolveImage() {
    if (_imageStream != null && _imageListener != null) {
      _imageStream!.removeListener(_imageListener!);
    }
    _imageSize = null;
    _imageFailed = false;
    final stream = NetworkImage(
      widget.page.imageUrl,
    ).resolve(ImageConfiguration.empty);
    _imageStream = stream;
    _imageListener = ImageStreamListener(
      (image, _) {
        if (mounted) {
          setState(
            () => _imageSize = Size(
              image.image.width.toDouble(),
              image.image.height.toDouble(),
            ),
          );
        }
      },
      onError: (Object error, StackTrace? stackTrace) {
        if (mounted) {
          setState(() => _imageFailed = true);
        }
      },
    );
    stream.addListener(_imageListener!);
  }

  @override
  Widget build(BuildContext context) {
    if (_imageFailed) {
      return Center(
        child: Text(AppLocalizations.of(context)!.curatedReaderImageError),
      );
    }
    if (_imageSize == null) {
      return const Center(child: CircularProgressIndicator());
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final imageBounds = _containBounds(constraints.biggest, _imageSize!);
        return Center(
          child: SizedBox(
            width: imageBounds.width,
            height: imageBounds.height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.network(widget.page.imageUrl, fit: BoxFit.fill),
                if (widget.character != null &&
                    widget
                            .page
                            .characterPlacement
                            ?.isRenderableStandingOverlay ==
                        true)
                  _CharacterOverlay(
                    placement: widget.page.characterPlacement!,
                    character: widget.character!,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Size _containBounds(Size available, Size image) {
    final imageAspect = image.width / image.height;
    final availableAspect = available.width / available.height;
    if (availableAspect > imageAspect) {
      return Size(available.height * imageAspect, available.height);
    }
    return Size(available.width, available.width / imageAspect);
  }
}

class _CharacterOverlay extends StatelessWidget {
  final CharacterPlacement placement;
  final SavedCharacter character;

  const _CharacterOverlay({required this.placement, required this.character});

  @override
  Widget build(BuildContext context) {
    return Positioned.fill(
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: LayoutBuilder(
            builder: (context, constraints) => Stack(
              children: [
                Positioned(
                  left: placement.x * constraints.maxWidth,
                  top: placement.y * constraints.maxHeight,
                  width: placement.width * constraints.maxWidth,
                  height: placement.height * constraints.maxHeight,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    alignment: Alignment.topLeft,
                    child: Transform.flip(
                      flipX: placement.flipX,
                      child: CustomPaint(
                        size: const Size(120, 148),
                        painter: CharacterPainter(
                          hatVariant: character.variants[0],
                          topVariant: character.variants[1],
                          bottomVariant: character.variants[2],
                          glassesVariant: character.variants[3],
                          accessoryVariant: character.variants[4],
                          faceVariant: character.variants[5],
                          eyesVariant: character.variants[6],
                          noseVariant: character.variants[7],
                          mouthVariant: character.variants[8],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CharacterThumbnail extends StatelessWidget {
  final SavedCharacter character;

  const _CharacterThumbnail({required this.character});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 32,
      height: 40,
      child: FittedBox(
        child: CustomPaint(
          size: const Size(120, 148),
          painter: CharacterPainter(
            hatVariant: character.variants[0],
            topVariant: character.variants[1],
            bottomVariant: character.variants[2],
            glassesVariant: character.variants[3],
            accessoryVariant: character.variants[4],
            faceVariant: character.variants[5],
            eyesVariant: character.variants[6],
            noseVariant: character.variants[7],
            mouthVariant: character.variants[8],
          ),
        ),
      ),
    );
  }
}

class _ReaderError extends StatelessWidget {
  final VoidCallback? onRetry;

  const _ReaderError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(l10n.curatedReaderError),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            FilledButton(
              onPressed: onRetry,
              child: Text(l10n.curatedReaderRetry),
            ),
          ],
        ],
      ),
    );
  }
}
