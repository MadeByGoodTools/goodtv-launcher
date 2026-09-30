import 'package:goodtv_launcher/providers/update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("isAbiSplitApk", () {
    test("detects ABI-split release assets", () {
      expect(isAbiSplitApk("arclauncher-1.0.5-arm64-v8a.apk"), isTrue);
      expect(isAbiSplitApk("arclauncher-1.0.5-armeabi-v7a.apk"), isTrue);
      expect(isAbiSplitApk("arclauncher-1.0.5-x86_64.apk"), isTrue);
      expect(isAbiSplitApk("arclauncher-1.0.5-x86.apk"), isTrue);
    });

    test("treats universal assets as non-split", () {
      expect(isAbiSplitApk("arclauncher-1.0.5.apk"), isFalse);
      expect(isAbiSplitApk("arclauncher.apk"), isFalse);
      expect(isAbiSplitApk("goodtv-launcher-universal-release.apk"), isFalse);
    });
  });

  group("pickReleaseApk", () {
    test("prefers universal APK over ABI splits", () {
      final picked = pickReleaseApk([
        {
          "name": "arclauncher-1.0.5-arm64-v8a.apk",
          "browser_download_url": "https://example.com/arm64.apk",
        },
        {
          "name": "arclauncher-1.0.5-armeabi-v7a.apk",
          "browser_download_url": "https://example.com/armeabi.apk",
        },
        {
          "name": "arclauncher-1.0.5.apk",
          "browser_download_url": "https://example.com/universal.apk",
        },
      ]);

      expect(picked?.name, "arclauncher-1.0.5.apk");
      expect(picked?.url, "https://example.com/universal.apk");
    });

    test("falls back to first APK when no universal exists", () {
      final picked = pickReleaseApk([
        {
          "name": "arclauncher-1.0.5-arm64-v8a.apk",
          "browser_download_url": "https://example.com/arm64.apk",
        },
        {
          "name": "arclauncher-1.0.5-armeabi-v7a.apk",
          "browser_download_url": "https://example.com/armeabi.apk",
        },
      ]);

      expect(picked?.name, "arclauncher-1.0.5-arm64-v8a.apk");
    });
  });
}
