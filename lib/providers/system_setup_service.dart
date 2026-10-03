import '../flauncher_channel.dart';
import 'settings_service.dart';

class SystemSetupService {
  final FLauncherChannel _channel;
  final SettingsService _settings;

  SystemSetupService(this._channel, this._settings);

  Future<Map<String, dynamic>> inspect() => _channel.getSystemProfile();

  Future<DisplayPreset> applyRecommended(Map<String, dynamic> profile) async {
    final preset = recommendedDisplayPreset(profile);
    await _settings.applyDisplayPreset(preset);
    await _settings.applyGoodTvRecommendedDefaults();
    if (profile['isFireTv'] == true) {
      await _channel.setHomeRedirectEnabled(true);
    }
    return preset;
  }

  Future<bool> openHomeSettings() => _channel.openHomeSettings();
}

DisplayPreset recommendedDisplayPreset(Map<String, dynamic> profile) {
  final isFireTv = profile['isFireTv'] == true;
  final sdkInt = profile['sdkInt'] as int? ?? 0;
  if (isFireTv || sdkInt < 28) return DisplayPreset.compact;
  return DisplayPreset.cinema;
}
