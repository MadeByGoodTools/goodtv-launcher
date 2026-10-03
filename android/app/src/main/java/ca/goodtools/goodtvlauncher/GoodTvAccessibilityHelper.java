package ca.goodtools.goodtvlauncher;

import android.content.Context;
import android.content.pm.PackageManager;
import android.provider.Settings;
import android.text.TextUtils;

final class GoodTvAccessibilityHelper {
    private GoodTvAccessibilityHelper() {}

    private static String serviceId(Context context) {
        return context.getPackageName() + "/ca.goodtools.goodtvlauncher.GoodTvHomeRedirectService";
    }

    static boolean hasSecureSettings(Context context) {
        return context.checkSelfPermission("android.permission.WRITE_SECURE_SETTINGS") == PackageManager.PERMISSION_GRANTED;
    }

    static boolean isEnabled(Context context) {
        String current = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES);
        if (TextUtils.isEmpty(current)) return false;
        for (String entry : current.split(":")) {
            if (entry.equals(serviceId(context)) || entry.endsWith("/.GoodTvHomeRedirectService")) return true;
        }
        return false;
    }

    static boolean setEnabled(Context context, boolean enabled) {
        try {
            String current = Settings.Secure.getString(context.getContentResolver(), Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES);
            StringBuilder updated = new StringBuilder();
            if (!TextUtils.isEmpty(current)) {
                for (String entry : current.split(":")) {
                    if (entry.equals(serviceId(context)) || entry.endsWith("/.GoodTvHomeRedirectService")) continue;
                    if (updated.length() > 0) updated.append(":");
                    updated.append(entry);
                }
            }
            if (enabled) {
                if (updated.length() > 0) updated.append(":");
                updated.append(serviceId(context));
            }
            Settings.Secure.putString(context.getContentResolver(), Settings.Secure.ENABLED_ACCESSIBILITY_SERVICES, updated.toString());
            if (enabled) Settings.Secure.putInt(context.getContentResolver(), Settings.Secure.ACCESSIBILITY_ENABLED, 1);
            return isEnabled(context) == enabled;
        } catch (SecurityException ignored) {
            return false;
        }
    }
}
