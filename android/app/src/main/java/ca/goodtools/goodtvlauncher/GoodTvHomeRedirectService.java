package ca.goodtools.goodtvlauncher;

import android.accessibilityservice.AccessibilityService;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Handler;
import android.os.Looper;
import android.view.accessibility.AccessibilityEvent;

public class GoodTvHomeRedirectService extends AccessibilityService {
    static final String PREFS = "goodtv_home_redirect";
    static final String ENABLED = "enabled";
    private static final long ESCAPE_WINDOW_MS = 1600;
    private final Handler handler = new Handler(Looper.getMainLooper());
    private long lastRedirectAt;
    private final BroadcastReceiver screenReceiver = new BroadcastReceiver() {
        @Override public void onReceive(Context context, Intent intent) {
            if (Intent.ACTION_SCREEN_ON.equals(intent.getAction()) && redirectEnabled()) {
                handler.postDelayed(() -> launchGoodTv(), 650);
            }
        }
    };

    @Override protected void onServiceConnected() {
        super.onServiceConnected();
        registerReceiver(screenReceiver, new IntentFilter(Intent.ACTION_SCREEN_ON));
    }

    @Override public void onDestroy() {
        try { unregisterReceiver(screenReceiver); } catch (Exception ignored) {}
        super.onDestroy();
    }

    @Override public void onAccessibilityEvent(AccessibilityEvent event) {
        if (!redirectEnabled() || event == null || event.getEventType() != AccessibilityEvent.TYPE_WINDOW_STATE_CHANGED) return;
        String pkg = event.getPackageName() == null ? "" : event.getPackageName().toString();
        String cls = event.getClassName() == null ? "" : event.getClassName().toString();
        boolean amazonHome = pkg.equals("com.amazon.firehomestarter") ||
                (pkg.equals("com.amazon.tv.launcher") && (cls.contains("HomeActivity") || cls.contains("NavigationActivity")));
        if (!amazonHome) return;
        long now = System.currentTimeMillis();
        if (now - lastRedirectAt <= ESCAPE_WINDOW_MS) {
            lastRedirectAt = 0;
            return;
        }
        lastRedirectAt = now;
        handler.postDelayed(this::launchGoodTv, 80);
    }

    @Override public void onInterrupt() {}

    private boolean redirectEnabled() {
        return getSharedPreferences(PREFS, MODE_PRIVATE).getBoolean(
                ENABLED, GoodTvAccessibilityHelper.isEnabled(this));
    }

    private void launchGoodTv() {
        startActivity(new Intent(this, MainActivity.class)
                .setAction(Intent.ACTION_MAIN)
                .addCategory(Intent.CATEGORY_HOME)
                .addFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_SINGLE_TOP));
    }
}
