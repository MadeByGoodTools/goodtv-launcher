/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:math';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:goodtv_launcher/actions.dart';
import 'package:goodtv_launcher/custom_traversal_policy.dart';
import 'package:goodtv_launcher/providers/apps_service.dart';
import 'package:goodtv_launcher/providers/launcher_state.dart';
import 'package:goodtv_launcher/providers/settings_service.dart';
import 'package:goodtv_launcher/providers/wallpaper_service.dart';
import 'package:goodtv_launcher/providers/watch_next_service.dart';
import 'package:goodtv_launcher/widgets/app_card.dart';
import 'package:goodtv_launcher/widgets/cached_blur_backdrop.dart';
import 'package:goodtv_launcher/widgets/category_row.dart';
import 'package:goodtv_launcher/widgets/launcher_alternative_view.dart';
import 'package:goodtv_launcher/widgets/focus_aware_app_bar.dart';
import 'package:goodtv_launcher/widgets/wallpaper_video_background.dart';
import 'package:goodtv_launcher/widgets/watch_next_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';
import 'package:goodtv_launcher/l10n/app_localizations.dart';

import 'models/app.dart';
import 'models/category.dart';

const _kDockOuterPadding = EdgeInsets.only(
  left: kLauncherSectionHorizontalPadding,
  right: kLauncherSectionHorizontalPadding,
  top: 10,
  bottom: 16,
);

class FLauncher extends StatefulWidget {
  const FLauncher({super.key});

  @override
  State<FLauncher> createState() => _FLauncherState();
}

class _FLauncherState extends State<FLauncher> with WidgetsBindingObserver {
  final GlobalKey<FocusAwareAppBarState> _appBarKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _dockKey = GlobalKey();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      context.read<WatchNextService>().refreshPermissionAndItems();
    }
  }

  @override
  Widget build(BuildContext context) => Actions(
    actions: <Type, Action<Intent>>{
      MoveFocusToSettingsIntent: CallbackAction<MoveFocusToSettingsIntent>(
        onInvoke: (_) => _appBarKey.currentState?.focusSettings(),
      ),
    },
    child: FocusTraversalGroup(
      policy: RowByRowTraversalPolicy(),
      child: Stack(
        children: [
          RepaintBoundary(
            child: Consumer<WallpaperService>(
              builder: (_, wallpaperService, __) =>
                  _wallpaper(context, wallpaperService),
            ),
          ),
          const Positioned.fill(
            child: IgnorePointer(child: ColoredBox(color: Color(0x66000000))),
          ),
          Selector3<
            LauncherState,
            SettingsService,
            WallpaperService,
            (bool, bool, bool)
          >(
            selector: (_, launcherState, settings, wallpaperService) => (
              launcherState.appGridFocused,
              settings.backgroundBlurDisabled,
              wallpaperService.wallpaperVideoFile != null ||
                  wallpaperService.wallpaperVideoUrl != null,
            ),
            builder: (_, data, __) {
              final (appGridFocused, blurDisabled, hasVideoWallpaper) = data;
              if (hasVideoWallpaper) {
                return const SizedBox.shrink();
              }
              return Positioned.fill(
                child: IgnorePointer(
                  child: AnimatedOpacity(
                    opacity: appGridFocused && !blurDisabled ? 1 : 0,
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeInOut,
                    child: const CachedBlurLayer(sigma: 10),
                  ),
                ),
              );
            },
          ),
          Consumer<LauncherState>(
            builder: (_, state, child) => Visibility(
              replacement: const Center(child: AlternativeLauncherView()),
              visible: state.launcherVisible,
              child: child!,
            ),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              appBar: FocusAwareAppBar(
                key: _appBarKey,
                categories: context.watch<AppsService>().categories,
                selectedCategoryId: _selectedCategoryId,
                onCategorySelected: (categoryId) {
                  setState(() => _selectedCategoryId = categoryId);
                  if (_scrollController.hasClients) {
                    _scrollController.jumpTo(0);
                  }
                },
              ),
              body:
                  Selector2<
                    AppsService,
                    SettingsService,
                    (bool, int, bool, double, double)
                  >(
                    selector: (_, appsService, settingsService) => (
                      appsService.initialized,
                      appsService.layoutVersion,
                      settingsService.showAppNamesBelowIcons,
                      settingsService.appCardHorizontalSpacing,
                      settingsService.appCardVerticalSpacing,
                    ),
                    builder: (context, data, _) {
                      if (data.$1) {
                        return _tvOSLayout(
                          context,
                          context.read<AppsService>(),
                          showAppNames: data.$3,
                          cardHorizontalSpacing: data.$4,
                          cardVerticalSpacing: data.$5,
                        );
                      } else {
                        return _emptyState(context);
                      }
                    },
                  ),
            ),
          ),
        ],
      ),
    ),
  );

  void _setAppGridFocused(bool focused) {
    context.read<LauncherState>().setAppGridFocused(focused);
  }

  void _onAppGridFocused({VoidCallback? onFirstSectionFocused}) {
    _setAppGridFocused(true);
    onFirstSectionFocused?.call();
  }

  void _onHomeSectionFocused() {
    _setAppGridFocused(false);
  }

  Widget _tvOSLayout(
    BuildContext context,
    AppsService appsService, {
    required bool showAppNames,
    required double cardHorizontalSpacing,
    required double cardVerticalSpacing,
  }) {
    final favoritesCategory = appsService.categories.firstWhereOrNull(
      (c) => c.name == 'Favorites',
    );
    final showingHome = _selectedCategoryId == null;
    final configuredFavorites =
        favoritesCategory?.applications
            .where((app) => !app.hidden && !_isThisLauncher(app.packageName))
            .toList(growable: false) ??
        const <App>[];
    // A fresh install may have no manually chosen favorites yet. In that case
    // the Apple TV-style dock is immediately useful as a horizontal scroller
    // for every visible app instead of showing an empty bar.
    final favoriteApps = showingHome
        ? (configuredFavorites.isNotEmpty
              ? configuredFavorites
              : appsService.applications
                    .where(
                      (app) => !app.hidden && !_isThisLauncher(app.packageName),
                    )
                    .toList(growable: false))
        : const <App>[];

    final otherSections = appsService.launcherSections.where((section) {
      if (section is Category && section.name == 'Favorites') return false;
      return _selectedCategoryId == null ||
          (section is Category && section.id == _selectedCategoryId);
    }).toList();

    final showWatchNextSection =
        showingHome &&
        context.select<SettingsService, bool>((s) => s.showWatchNextSection);
    final watchNextVisible = context.select<WatchNextService, bool>(
      (s) => s.hasVisibleSection,
    );
    final reserveWatchNextSpace = showWatchNextSection && watchNextVisible;

    if (favoriteApps.isEmpty && otherSections.isEmpty)
      return _emptyState(context);

    return CustomScrollView(
      controller: _scrollController,
      slivers: [
        if (favoriteApps.isNotEmpty || showWatchNextSection) ...[
          SliverToBoxAdapter(
            child: SizedBox(
              height:
                  MediaQuery.of(context).size.height -
                  MediaQuery.of(context).padding.top -
                  kToolbarHeight -
                  (reserveWatchNextSpace ? 410 : 150),
            ),
          ),
          if (showWatchNextSection)
            SliverToBoxAdapter(
              child: WatchNextRow(
                isFirstSection: false,
                isAboveDock: true,
                onItemFocused: _onHomeSectionFocused,
              ),
            ),
          if (favoriteApps.isNotEmpty)
            SliverToBoxAdapter(
              child: KeyedSubtree(
                key: _dockKey,
                child: Padding(
                  padding: _kDockOuterPadding,
                  child: _dock(
                    context,
                    favoritesCategory!,
                    favoriteApps,
                    appsService,
                    handleUpNavigationToSettings: !reserveWatchNextSpace,
                  ),
                ),
              ),
            ),
        ],
        ..._buildSectionSlivers(
          otherSections,
          firstCategoryAlreadyFound: favoriteApps.isNotEmpty,
          showAppNames: showAppNames,
          cardHorizontalSpacing: cardHorizontalSpacing,
          cardVerticalSpacing: cardVerticalSpacing,
          onFirstSectionFocused: favoriteApps.isNotEmpty
              ? _scrollDockToTop
              : null,
        ),
        SliverToBoxAdapter(
          child: SizedBox(
            height: _bottomScrollPadding(
              context,
              hasDock: favoriteApps.isNotEmpty,
            ),
          ),
        ),
      ],
    );
  }

  double _bottomScrollPadding(BuildContext context, {required bool hasDock}) {
    if (!hasDock) {
      return 64;
    }
    return MediaQuery.of(context).size.height -
        MediaQuery.of(context).padding.top -
        kToolbarHeight;
  }

  List<Widget> _buildSectionSlivers(
    List<LauncherSection> sections, {
    bool firstCategoryAlreadyFound = false,
    required bool showAppNames,
    required double cardHorizontalSpacing,
    required double cardVerticalSpacing,
    VoidCallback? onFirstSectionFocused,
  }) {
    final List<Widget> slivers = [];
    bool firstCategoryFound = firstCategoryAlreadyFound;
    bool firstBuiltSectionFound = false;

    for (final section in sections) {
      final Key sectionKey = Key(section.id.toString());

      if (section is LauncherSpacer) {
        slivers.add(
          SliverToBoxAdapter(
            key: sectionKey,
            child: SizedBox(height: section.height.toDouble()),
          ),
        );
        continue;
      }

      final category = section as Category;
      final filteredApps = category.applications;
      if (filteredApps.isEmpty) continue;

      final bool isFirstSection = !firstCategoryFound;
      if (isFirstSection) firstCategoryFound = true;
      final onAppFocused = !firstBuiltSectionFound
          ? () =>
                _onAppGridFocused(onFirstSectionFocused: onFirstSectionFocused)
          : () => _onAppGridFocused();
      firstBuiltSectionFound = true;

      slivers.add(
        SliverToBoxAdapter(
          child: Selector<SettingsService, bool>(
            selector: (context, service) => service.showCategoryTitles,
            builder: (context, showTitle, _) {
              if (showTitle) {
                return Padding(
                  padding: const EdgeInsets.only(left: 40, bottom: 8, top: 8),
                  child: Text(
                    category.name,
                    style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      shadows: const [
                        Shadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
      );

      switch (category.type) {
        case CategoryType.row:
          slivers.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: kLauncherSectionHorizontalPadding,
                  right: kLauncherSectionHorizontalPadding,
                  bottom: 8,
                ),
                child: CategoryRow(
                  key: sectionKey,
                  category: category,
                  applications: filteredApps,
                  isFirstSection: isFirstSection,
                  showTitle: false,
                  onAppFocused: onAppFocused,
                ),
              ),
            ),
          );
          break;
        case CategoryType.grid:
          final gridContentWidth =
              MediaQuery.sizeOf(context).width -
              2 * kLauncherSectionHorizontalPadding;
          final gridAspectRatio = showAppNames
              ? appCardGridAspectRatio(gridContentWidth, category.columnsCount)
              : kAppCardAspectRatio;
          slivers.add(
            SliverPadding(
              padding: const EdgeInsets.only(
                left: kLauncherSectionHorizontalPadding,
                right: kLauncherSectionHorizontalPadding,
                bottom: 8,
              ),
              sliver: SliverGrid(
                key: sectionKey,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: category.columnsCount,
                  childAspectRatio: gridAspectRatio,
                  mainAxisSpacing: cardVerticalSpacing,
                  crossAxisSpacing: 0,
                ),
                delegate: SliverChildBuilderDelegate(
                  childCount: filteredApps.length,
                  findChildIndexCallback: (Key key) {
                    final valueKey = key as ValueKey<String>;
                    final index = filteredApps.indexWhere(
                      (app) => app.packageName == valueKey.value,
                    );
                    return index >= 0 ? index : null;
                  },
                  (context, index) => Padding(
                    key: Key(filteredApps[index].packageName),
                    padding: EdgeInsets.symmetric(
                      horizontal: cardHorizontalSpacing,
                      vertical: cardVerticalSpacing,
                    ),
                    child: AppCard(
                      category: category,
                      application: filteredApps[index],
                      autofocus: index == 0,
                      handleUpNavigationToSettings:
                          isFirstSection && index < category.columnsCount,
                      enforceAspectRatio: false,
                      onFocused: index < category.columnsCount
                          ? onAppFocused
                          : null,
                      ensureVisibleOnFocus: index >= category.columnsCount,
                      onlyScrollWhenNearBottom: true,
                      onMove: (direction) => _onGridMove(
                        context,
                        category,
                        index,
                        direction,
                        filteredApps,
                      ),
                      onMoveEnd: () => context
                          .read<AppsService>()
                          .saveApplicationOrderInCategory(category),
                    ),
                  ),
                ),
              ),
            ),
          );
          break;
      }
    }

    return slivers;
  }

  Future<void> _scrollDockToTop() async {
    final targetOffset = _dockTopScrollOffset();
    if (targetOffset == null) {
      return;
    }

    final position = _scrollController.position;
    if ((targetOffset - position.pixels).abs() < 16) {
      return;
    }

    await _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 100),
      curve: Curves.easeOut,
    );
  }

  double? _dockTopScrollOffset() {
    final dockContext = _dockKey.currentContext;
    final renderObject = dockContext?.findRenderObject();
    if (!_scrollController.hasClients || renderObject == null) {
      return null;
    }

    final viewport = RenderAbstractViewport.of(renderObject);
    final position = _scrollController.position;
    return viewport
        .getOffsetToReveal(renderObject, 0)
        .offset
        .clamp(position.minScrollExtent, position.maxScrollExtent);
  }

  // TO DO : refractor duplicate _onMove code
  void _onGridMove(
    BuildContext context,
    Category category,
    int index,
    AxisDirection direction,
    List<App> filteredApps,
  ) {
    final currentRow = (index / category.columnsCount).floor();
    final totalRows = ((filteredApps.length - 1) / category.columnsCount)
        .floor();

    int? newIndex;
    switch (direction) {
      case AxisDirection.up:
        if (currentRow > 0) newIndex = index - category.columnsCount;
        break;
      case AxisDirection.right:
        if (index < filteredApps.length - 1) newIndex = index + 1;
        break;
      case AxisDirection.down:
        if (currentRow < totalRows)
          newIndex = min(
            index + category.columnsCount,
            filteredApps.length - 1,
          );
        break;
      case AxisDirection.left:
        if (index > 0) newIndex = index - 1;
        break;
    }

    if (newIndex != null) {
      final appsService = context.read<AppsService>();
      final movingApp = filteredApps[index];
      final realOldIndex = category.applications.indexOf(movingApp);
      final realNewIndex = category.applications.indexOf(
        filteredApps[newIndex],
      );
      if (realOldIndex >= 0 && realNewIndex >= 0) {
        appsService.reorderApplication(category, realOldIndex, realNewIndex);
        appsService.setPendingReorderFocus(movingApp.packageName, category.id);
      }
    }
  }

  Widget _dock(
    BuildContext context,
    Category category,
    List<App> apps,
    AppsService appsService, {
    required bool handleUpNavigationToSettings,
  }) {
    final backdropDisabled = context.select<SettingsService, bool>(
      (s) => s.dockBackdropFilterDisabled,
    );
    final darkBackground = context.select<SettingsService, bool>(
      (s) => s.dockDarkBackground,
    );
    final shadowEnabled = context.select<SettingsService, bool>(
      (s) => s.dockShadowEnabled,
    );

    const dockBorderRadius = 24.0;
    final borderRadius = BorderRadius.circular(dockBorderRadius);

    final content = Container(
      padding: const EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        color: darkBackground
            ? Colors.black.withOpacity(0.3)
            : Colors.white.withOpacity(0.1),
        borderRadius: borderRadius,
        border: Border.all(
          color: darkBackground
              ? Colors.black.withOpacity(0.15)
              : Colors.white.withOpacity(0.15),
          width: 1.5,
        ),
      ),
      child: CategoryRow(
        category: category,
        applications: apps,
        isFirstSection: handleUpNavigationToSettings,
        showTitle: false,
        onAppFocused: _onHomeSectionFocused,
      ),
    );

    return Center(
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          boxShadow: shadowEnabled
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 20,
                    spreadRadius: 2,
                  ),
                ]
              : null,
        ),
        child: ClipRRect(
          borderRadius: borderRadius,
          clipBehavior: Clip.antiAlias,
          child: backdropDisabled
              ? content
              : CachedBlurBackdrop(sigma: 5, child: content),
        ),
      ),
    );
  }

  bool _isThisLauncher(String packageName) =>
      packageName == 'ca.goodtools.goodtvlauncher' ||
      packageName == 'ca.goodtools.goodtvlauncher.debug';

  Widget _wallpaper(BuildContext context, WallpaperService wallpaperService) {
    final screenSize = MediaQuery.sizeOf(context);
    final dpr = MediaQuery.devicePixelRatioOf(context);
    final videoUrl = wallpaperService.wallpaperVideoUrl;
    if (videoUrl != null) {
      return SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: WallpaperVideoBackground.network(
          videoUrl,
          key: ValueKey(
            "background_network_video_${wallpaperService.wallpaperRevision}",
          ),
        ),
      );
    }
    final videoFile = wallpaperService.wallpaperVideoFile;
    if (videoFile != null) {
      return SizedBox(
        width: screenSize.width,
        height: screenSize.height,
        child: WallpaperVideoBackground.file(
          videoFile,
          key: ValueKey(
            "background_video_${wallpaperService.wallpaperRevision}",
          ),
        ),
      );
    }
    if (wallpaperService.wallpaper != null) {
      return Image(
        image: ResizeImage(
          wallpaperService.wallpaper!,
          width: (screenSize.width * dpr).round(),
        ),
        key: ValueKey("background_${wallpaperService.wallpaperRevision}"),
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
        height: screenSize.height,
        width: screenSize.width,
      );
    } else {
      return _CachedGradientBackground(
        key: const Key("background"),
        gradient: wallpaperService.gradient.gradient,
      );
    }
  }

  Widget _emptyState(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            localizations.loading,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }
}

/// Renders a [Gradient] once into a rasterized [ui.Image] and blits it as a
/// texture instead of evaluating the gradient shader every frame.
///
/// On low-end GPUs (e.g. Android TV sticks) a full-screen live gradient is
/// noticeably more expensive to raster than a cached texture, so this keeps the
/// background as cheap as a static image wallpaper.
class _CachedGradientBackground extends StatefulWidget {
  final Gradient gradient;

  const _CachedGradientBackground({super.key, required this.gradient});

  @override
  State<_CachedGradientBackground> createState() =>
      _CachedGradientBackgroundState();
}

class _CachedGradientBackgroundState extends State<_CachedGradientBackground> {
  ui.Image? _image;
  Size _renderedSize = Size.zero;
  Gradient? _renderedGradient;
  bool _rendering = false;

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  Future<void> _render(Size size) async {
    if (_rendering) {
      return;
    }
    _rendering = true;
    final recorder = ui.PictureRecorder();
    final rect = Offset.zero & size;
    Canvas(
      recorder,
    ).drawRect(rect, Paint()..shader = widget.gradient.createShader(rect));
    final picture = recorder.endRecording();
    final image = await picture.toImage(
      size.width.round(),
      size.height.round(),
    );
    picture.dispose();
    _rendering = false;
    if (!mounted) {
      image.dispose();
      return;
    }
    setState(() {
      _image?.dispose();
      _image = image;
      _renderedSize = size;
      _renderedGradient = widget.gradient;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final needsRender =
            size != _renderedSize || widget.gradient != _renderedGradient;
        if (needsRender && size.width > 0 && size.height > 0) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted &&
                (size != _renderedSize ||
                    widget.gradient != _renderedGradient)) {
              _render(size);
            }
          });
        }
        final image = _image;
        if (image != null && !needsRender) {
          return RawImage(
            image: image,
            width: size.width,
            height: size.height,
            fit: BoxFit.fill,
          );
        }
        // First frame (and while re-rendering): paint the gradient live once to avoid a flash.
        return DecoratedBox(
          decoration: BoxDecoration(gradient: widget.gradient),
        );
      },
    );
  }
}
