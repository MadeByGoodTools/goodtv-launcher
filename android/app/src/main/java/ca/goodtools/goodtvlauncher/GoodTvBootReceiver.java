package ca.goodtools.goodtvlauncher;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Handler;
import android.os.Looper;

public class GoodTvBootReceiver extends BroadcastReceiver {
    @Override public void onReceive(Context context, Intent intent) {
        if (!Intent.ACTION_BOOT_COMPLETED.equals(intent.getAction())) return;
        boolean enabled = context.getSharedPreferences(GoodTvHomeRedirectService.PREFS, Context.MODE_PRIVATE)
                .getBoolean(GoodTvHomeRedirectService.ENABLED,
                        GoodTvAccessibilityHelper.isEnabled(context));
        if (!enabled) return;
        new Handler(Looper.getMainLooper()).postDelayed(() -> context.startActivity(
                new Intent(context, MainActivity.class).setAction(Intent.ACTION_MAIN)
                        .addCategory(Intent.CATEGORY_HOME)
                        .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP)), 2500);
    }
}
