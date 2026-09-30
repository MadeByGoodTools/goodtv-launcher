import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:goodtv_launcher/l10n/app_localizations.dart';
import 'package:goodtv_launcher/providers/pin_service.dart';
import 'package:provider/provider.dart';

import 'focusable_settings_tile.dart';

class PinProtectionPage extends StatelessWidget {
  static const String routeName = 'pin_protection';

  const PinProtectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final pinService = context.watch<PinService>();
    return Column(
      children: [
        Text(l10n.pinProtection, style: Theme.of(context).textTheme.titleLarge),
        const Divider(),
        Expanded(
          child: ListView(
            children: [
              FocusableSettingsTile(
                autofocus: true,
                leading: Icon(
                  pinService.enabled ? Icons.lock : Icons.lock_open,
                ),
                title: Text(
                  pinService.enabled ? l10n.changePin : l10n.createPin,
                ),
                onPressed: () => _setPin(context),
              ),
              if (pinService.enabled)
                FocusableSettingsTile(
                  leading: const Icon(Icons.no_encryption_outlined),
                  title: Text(l10n.disablePin),
                  onPressed: () => _disablePin(context),
                ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  l10n.pinProtectionDescription,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _setPin(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final first = await _askForPin(context, l10n.enterNewPin);
    if (first == null || !context.mounted) return;
    final second = await _askForPin(context, l10n.confirmPin);
    if (second == null || !context.mounted) return;
    if (first != second) {
      _message(context, l10n.pinsDoNotMatch);
      return;
    }
    try {
      await context.read<PinService>().setPin(first);
      if (context.mounted) _message(context, l10n.pinEnabled);
    } on FormatException {
      if (context.mounted) _message(context, l10n.pinLengthError);
    }
  }

  Future<void> _disablePin(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final pin = await _askForPin(context, l10n.enterCurrentPin);
    if (pin == null || !context.mounted) return;
    final disabled = await context.read<PinService>().disable(pin);
    if (context.mounted) {
      _message(context, disabled ? l10n.pinDisabled : l10n.incorrectPin);
    }
  }

  void _message(BuildContext context, String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
}

Future<String?> showPinEntryDialog(BuildContext context, String title) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        obscureText: true,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        maxLength: 8,
        onSubmitted: (value) => Navigator.pop(dialogContext, value),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(dialogContext),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () => Navigator.pop(dialogContext, controller.text),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    ),
  ).whenComplete(controller.dispose);
}

Future<String?> _askForPin(BuildContext context, String title) =>
    showPinEntryDialog(context, title);
