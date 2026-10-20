/*
 * FLauncher
 * Copyright (C) 2026 Meddouri Badis
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:io';
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class WallpaperVideoBackground extends StatefulWidget {
  const WallpaperVideoBackground.file(
    this.file, {
    super.key,
    this.onReady,
    this.onFailed,
    this.onEnding,
    this.playing = true,
  }) : url = null;

  const WallpaperVideoBackground.network(
    this.url, {
    super.key,
    this.onReady,
    this.onFailed,
    this.onEnding,
    this.playing = true,
  }) : file = null;

  final File? file;
  final String? url;
  final VoidCallback? onReady;
  final VoidCallback? onFailed;
  final ValueChanged<Duration>? onEnding;
  final bool playing;

  String get sourceKey => url ?? file!.path;

  @override
  State<WallpaperVideoBackground> createState() =>
      _WallpaperVideoBackgroundState();
}

class _WallpaperVideoBackgroundState extends State<WallpaperVideoBackground>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  bool _reportedReady = false;
  bool _reportedFailure = false;
  bool _appActive = true;
  bool _reportedCompleted = false;
  Timer? _firstFrameTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initController();
  }

  @override
  void didUpdateWidget(WallpaperVideoBackground oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.sourceKey != widget.sourceKey) {
      _disposeController();
      _initController();
    } else if (oldWidget.playing != widget.playing) {
      _syncPlayback();
    }
  }

  Future<void> _initController() async {
    final controller = widget.url != null
        ? VideoPlayerController.networkUrl(
            Uri.parse(widget.url!),
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          )
        : VideoPlayerController.file(
            widget.file!,
            videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
          );
    _controller = controller;
    _reportedReady = false;
    _reportedFailure = false;
    _reportedCompleted = false;
    controller.addListener(_checkFrame);
    try {
      await controller.initialize();
      if (!mounted || _controller != controller) return;
      await controller.setLooping(widget.onEnding == null);
      await controller.setVolume(0);
      if (!mounted || _controller != controller) return;
      if (_appActive && widget.playing) await controller.play();
      if (mounted && _controller == controller) {
        setState(() {});
        // A paused, initialized texture renders the opening frame. Let it
        // reach the compositor before reporting ready; playback starts only
        // when the parent begins the crossfade.
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _controller != controller) return;
          _firstFrameTimer = Timer(const Duration(milliseconds: 150), () {
            if (!mounted ||
                _controller != controller ||
                _reportedReady ||
                controller.value.hasError)
              return;
            _reportedReady = true;
            widget.onReady?.call();
          });
        });
      }
    } catch (error) {
      debugPrint('Video wallpaper initialization failed: $error');
      if (mounted && _controller == controller) {
        _reportFailure();
        setState(() {});
      }
    }
  }

  void _reportFailure() {
    if (_reportedFailure) return;
    _reportedFailure = true;
    widget.onFailed?.call();
  }

  void _checkFrame() {
    final value = _controller?.value;
    if (!mounted || value == null) return;
    if (value.hasError) {
      _reportFailure();
    } else if (!_reportedReady &&
        value.isInitialized &&
        value.position > Duration.zero) {
      _reportedReady = true;
      widget.onReady?.call();
    }
    if (!_reportedCompleted &&
        !value.hasError &&
        value.isInitialized &&
        value.duration > Duration.zero &&
        value.isPlaying &&
        widget.playing &&
        value.duration - value.position <= const Duration(seconds: 2) &&
        widget.onEnding != null) {
      _reportedCompleted = true;
      widget.onEnding!(value.duration - value.position);
    }
  }

  void _disposeController() {
    _firstFrameTimer?.cancel();
    _controller?.removeListener(_checkFrame);
    _controller?.dispose();
    _controller = null;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeController();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _appActive = state == AppLifecycleState.resumed;
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.resumed) {
      _syncPlayback();
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      controller.pause();
    }
  }

  void _syncPlayback() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;
    final future = _appActive && widget.playing
        ? controller.play()
        : controller.pause();
    future.catchError((Object error) {
      if (mounted && _controller == controller) _reportFailure();
    });
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return const ColoredBox(color: Colors.black);
    }

    final size = controller.value.size;
    return RepaintBoundary(
      child: SizedBox.expand(
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: RepaintBoundary(child: VideoPlayer(controller)),
          ),
        ),
      ),
    );
  }
}
