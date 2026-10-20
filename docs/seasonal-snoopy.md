# Seasonal Snoopy (1.0.16 test build)

The catalogue in `assets/video_collections/Snoopy/catalog.json` identifies 65
available scene uploads. It does not claim to enumerate every Apple animation,
overlay, or future tvOS scene. Media remains separate from the GPL software
license; obtain download and redistribution permission before packaging it.

## Canadian-style calendar

Everyday clips always remain eligible. Seasonal groups join that same shuffle
pool during these local-device-date windows:

| Group | Window |
| --- | --- |
| Spring | March–May |
| Summer | June–August |
| Autumn | September–November |
| Winter | November–March |
| Halloween | October 1–November 2 |
| Holiday season | December 1–January 6 |
| New Year | December 26–January 7 |
| Valentine's | February 1–15 |
| Canadian Thanksgiving | October 1 through two days after the second Monday |
| Canada Day | June 25–July 2 |

The overlapping shoulder months are intentional. This is a broad seasonal
calendar, not actual weather for every Canadian region. No location permission
or weather service is used. The device's date must be correct.

Settings → Interface → Wallpaper → Online & aerial backgrounds contains the
Snoopy collection and **Automatic seasons · Canada**. Turning that toggle off
unlocks all scenes. On October 20, 2026, 46 of 65 clips are eligible: everyday,
autumn, and Halloween. Selecting Snoopy refreshes the playlist after first-use
extraction, including when an older installation already had the 18-clip pack.

Seasonal availability is checked at clip boundaries. A midnight date change or
return from sleep does not interrupt a playing scene. The next eligible clip
uses the existing paused preload and 800 ms crossfade, including in the
background-only idle screensaver.

## Manual screensaver shortcut

Double-press Back within 400 ms on the launcher screen to enter background-only
mode. A single press waits for that window, then runs the configured ordinary
Back action. Settings and dialogs keep their own Back navigation. Other input,
Home, and app switching cancel a pending shortcut. Key releases do not wake a
screensaver that was just activated. Any new button press wakes it, respecting
the existing first-button-only-wakes preference.

The shortcut defaults on and is configurable under Settings → System →
Screensaver Settings → **Double-press Back for screensaver**. It does not invoke
Fire TV's separate system screensaver.

## Packaging and checks

`node scripts/fetch-snoopy-media.mjs` fetches only the explicitly catalogued
uploads, preserves existing media, and validates new clips as short 1080p H.264
videos before moving them into the asset folder. It does not search or download
arbitrary results. The 65 clips total 523,156,614 bytes. The universal release APK is
about 567 MB; first-use extraction also needs about 523 MB of app-owned storage.

68 automated tests passed with one pre-existing skipped test. Coverage includes
every day of a leap year, seasonal and holiday boundaries, Canadian Thanksgiving,
year-round availability, non-repeating rotation, transition deadlines, the
all-clips override, and double-Back timing/cancellation. Native testing confirmed
the shortcut, waking, ordinary Back in settings, and the 65-clip picker. An
approximately 79-second on-device recording showed several clip changes with no
detected black intervals. This is sample playback verification, not an exhaustive
test of every possible clip pair or every TV model.

Release build: 1.0.16+4125. Existing users should open Online & aerial backgrounds
and select Snoopy once after updating to extract and load the expanded collection.
