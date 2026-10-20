import 'dart:async';
import 'package:flutter/material.dart';

const wallpaperCrossfadeDuration = Duration(milliseconds: 800);

typedef WallpaperContentBuilder =
    Widget Function(
      BuildContext context,
      VoidCallback onReady,
      VoidCallback onFailed,
      bool playing,
    );

/// Keeps the previous wallpaper alive while the next image/frame loads.
/// Only two media surfaces are retained, including during rapid feed changes.
class WallpaperTransition extends StatefulWidget {
  final Object sourceKey;
  final WallpaperContentBuilder builder;
  final Widget fallback;
  final DateTime? startAt;

  const WallpaperTransition({
    super.key,
    required this.sourceKey,
    required this.builder,
    required this.fallback,
    this.startAt,
  });

  @override
  State<WallpaperTransition> createState() => _WallpaperTransitionState();
}

class _WallpaperTransitionState extends State<WallpaperTransition>
    with SingleTickerProviderStateMixin {
  late final AnimationController _fade;
  late final CurvedAnimation _opacity;
  _WallpaperEntry? _visible;
  _WallpaperEntry? _incoming;
  Timer? _startTimer;

  @override
  void initState() {
    super.initState();
    _fade = AnimationController(
      vsync: this,
      duration: wallpaperCrossfadeDuration,
    )..addStatusListener(_onStatus);
    _opacity = CurvedAnimation(parent: _fade, curve: Curves.easeInOutCubic);
    _prepare();
  }

  void _prepare() {
    _startTimer?.cancel();
    _incoming = _WallpaperEntry(
      widget.sourceKey,
      widget.builder,
      widget.startAt,
    );
    _fade.value = 0;
  }

  @override
  void didUpdateWidget(WallpaperTransition oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.sourceKey == oldWidget.sourceKey || _fade.isAnimating) return;
    if (widget.sourceKey == _visible?.sourceKey) {
      _startTimer?.cancel();
      _incoming = null;
    } else {
      _prepare();
    }
  }

  void _ready(_WallpaperEntry entry) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _incoming != entry || entry.ready) return;
      entry.ready = true;
      final delay = entry.startAt?.difference(DateTime.now()) ?? Duration.zero;
      if (delay > Duration.zero) {
        _startTimer = Timer(delay, () => _begin(entry));
      } else {
        _begin(entry);
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _begin(_WallpaperEntry entry) {
    if (!mounted || _incoming != entry) return;
    setState(() => entry.playing = true);
    _fade.forward();
  }

  void _failed(_WallpaperEntry entry) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _incoming != entry) return;
      _startTimer?.cancel();
      _fade.stop();
      setState(() => _incoming = null);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _onStatus(AnimationStatus status) {
    if (status != AnimationStatus.completed || !mounted) return;
    setState(() {
      _visible = _incoming;
      _incoming = null;
      if (widget.sourceKey != _visible?.sourceKey) _prepare();
    });
  }

  @override
  void dispose() {
    _startTimer?.cancel();
    _opacity.dispose();
    _fade.dispose();
    super.dispose();
  }

  Widget _surface(_WallpaperEntry entry, Animation<double> opacity) =>
      FadeTransition(
        key: ObjectKey(entry),
        opacity: opacity,
        child: entry.builder(
          context,
          () => _ready(entry),
          () => _failed(entry),
          entry.playing,
        ),
      );

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      widget.fallback,
      if (_visible != null)
        _surface(_visible!, const AlwaysStoppedAnimation(1)),
      if (_incoming != null)
        // Keep the media mounted at zero opacity so it can prepare a frame.
        _surface(_incoming!, _opacity),
    ],
  );
}

class _WallpaperEntry {
  final Object sourceKey;
  final WallpaperContentBuilder builder;
  bool ready = false;
  bool playing = false;
  final DateTime? startAt;

  _WallpaperEntry(this.sourceKey, this.builder, this.startAt);
}
