# GoodTV Launcher 1.0.16

* Expand the Snoopy library to 65 catalogued 1080p H.264 clips.
* Enable automatic Canadian-style seasonal availability by default: everyday
  clips remain year-round; spring is March–May, summer June–August, autumn
  September–November, and winter November–March. November and March intentionally
  overlap neighbouring seasons. This is a local calendar, not live weather.
* Add calendar windows for Halloween, the December holiday season, New Year,
  Valentine's, Canada Day, and Canadian Thanksgiving (second Monday in October).
* Re-evaluate seasonal availability at clip boundaries, keeping the current
  clip playing to its end and retaining the existing paused preload and
  0.8-second crossfade. An Automatic seasons toggle can unlock all clips.
* Add an optional double-Back shortcut on Home to enter the background-only
  screensaver. It does not intercept Back in settings or another app, and key
  releases no longer immediately wake a manually activated screensaver.

# GoodTV Launcher 1.0.15

* Add Keep awake while GoodTV is open in Settings > System > Screensaver Settings.
  This opt-in setting keeps GoodTV's backgrounds and idle screensaver playing
  without changing device-wide sleep timers or the television's power timer.
* Include a built-in collection of 18 Snoopy video backgrounds, usable for both
  wallpaper and the background-only idle screensaver, with offline playback.
* Shuffle the local video collection without repeating a clip until the set ends.
* Crossfade switching wallpapers over 0.8 seconds, retaining the previous image
  or video until the next one is ready. Applies to images, Reddit feeds, aerials,
  local video collections, and the in-launcher background-only screensaver.
* Let playlist videos play to their end, with the crossfade in the final 0.8
  seconds. Preload the next video paused, preserving its opening frames.
* Avoid audio-focus interruptions and keep the active video texture alive during
  handoff. Leave the current background visible if the next one fails to load.

# GoodTV Launcher 1.0.12

* Open Fire TV system settings directly and protect the transition from the Home override.

# GoodTV Launcher 1.0.11

* Enable Check for updates in locally built public releases.

# GoodTV Launcher 1.0.10

* Docks fit up to five apps evenly; six or more scroll horizontally with consistent card spacing.
* Long-press All Apps to open dock settings and add apps.
* Long-press any app to add or remove it from a dock, with a dock picker when multiple docks exist.

# Changes from the original

### Features
* Allow users to customize the date widget format, making it possible to display the [date, time](https://pub.dev/documentation/intl/latest/intl/DateFormat-class.html), and any arbitrary text, or to hide it completely.
* Choose what the back button does while being in the launcher: Nothing, Show a fullscreen clock, Show screensaver (a.k.a Ambient Mode).
* Show the active network status next to the date widget.
* Allow users to hide the application category titles.
* Clicking or tapping on an application card now opens it.
* Ability to disable the navigation keys sound.
* The app bar can now hide automatically while not focused.
* Map "Escape" key to the "Back" action.
* Translate to Spanish.

### Removals
* Firebase analytics and crashlytics services.
* Unsplash integration.

### Misc
* Upgrade Flutter version from 3.7.5 to 3.24.5.
* Replace Kotlin code with Java.
* Set new language versions: Java (17), Dart (greater than or equal to 3.4.3).
* Change versioning scheme to \<year>.\<month>.\<monthly release number>
