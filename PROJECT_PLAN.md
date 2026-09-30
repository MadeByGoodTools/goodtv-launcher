# GoodTV Launcher roadmap

GoodTV Launcher starts from Arc Launcher 1.0.8 and keeps its complete existing
feature set. New work is additive and remains GPL-3.0.

## Baseline retained

- Image, gradient, scheduled, and video wallpapers
- Watch Next
- Custom categories, grids, rows, sorting, and favourites
- Custom app banners and sideloaded apps
- Status bar, clock, network, and data-usage widgets
- OLED screensaver
- Brightness scheduling
- Remote-first focus and navigation
- Android TV, Google TV, and Fire TV support

## Evolution milestones

1. Reproduce a debug APK and validate it on a real target device.
2. Add configuration backup and restore. **Completed:** rotating local backups
   now include layout, settings, categories, favourites, hidden apps, custom
   banners, and image/video wallpapers.
3. Add display profiles and layout presets.
4. Add deeper card, icon, type, spacing, alignment, and colour controls.
5. Add optional PIN-protected settings and parental controls.
6. Add boot targets, shortcuts, and device-aware input actions where supported.
7. Add wallpaper providers and polished media-source management.
8. Complete accessibility, performance, migration, and device-compatibility QA.

## Baseline verification note

Dependencies resolve with Flutter 3.41.9. At the upstream revision cloned on
2026-09-30, a subset of the inherited test suite does not compile because old
tests and generated mocks still reference removed category APIs. This predates
our feature work and will be repaired before relying on the complete test suite
as a release gate.
