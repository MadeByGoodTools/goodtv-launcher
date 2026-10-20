import 'dart:async';

import 'package:flutter/material.dart';
import 'package:goodtv_launcher/flauncher_channel.dart';

/// Keeps only the launcher window awake; never changes device-wide timers.
class KeepAwake extends StatefulWidget {
  final bool enabled;
  final Widget child;

  const KeepAwake({super.key, required this.enabled, required this.child});

  @override
  State<KeepAwake> createState() => _KeepAwakeState();
}

class _KeepAwakeState extends State<KeepAwake> {
  void _apply(bool enabled) {
    unawaited(
      FLauncherChannel().setKeepAwake(enabled).catchError((Object error) {
        debugPrint('Unable to update GoodTV keep-awake mode: $error');
      }),
    );
  }

  @override
  void initState() {
    super.initState();
    _apply(widget.enabled);
  }

  @override
  void didUpdateWidget(KeepAwake oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.enabled != widget.enabled) _apply(widget.enabled);
  }

  @override
  void dispose() {
    _apply(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
