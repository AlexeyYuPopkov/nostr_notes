# Simple Splash View Usage

## 1. Configure `pubspec.yaml`

Add the configuration block under the root of your `pubspec.yaml`:

```yaml
simple_splash_view:
  lottie: assets/splash.json
  lottie_dark: null
  image: assets/logo.png
  image_dark: null
  sound: assets/intro.mp3
  text: Loading...
  background_color: "#FDFCF9"
  background_color_dark: "#1A1A1A"
  text_color: "#FFFFFF"
  text_color_dark: "#FFFFFF"
  indicator_color: "#FFFFFF"
  indicator_color_dark: "#FFFFFF"
  duration: 300
  indicator: false
  indicator_position: auto
  text_position: auto
  theme:
    mode: system
    app_theme: null
    splash_theme: null
    light_background_color: "#FDFCF9"
    dark_background_color: "#1A1A1A"
```

Run the generator whenever you change these values:

```
flutter pub run simple_splash_view
```

## 2. Native Changes Snapshot

- **Android**
  - Generates `SplashActivity.kt` with timed transition into `MainActivity`.
  - Creates or updates `activity_splash.xml`, themes, color resources, and night-mode resource variants.
  - Copies images, audio, and Lottie assets into `android/app/src/main/res` (including `drawable-night`/`raw-night` when dark variants are supplied).
  - Patches `AndroidManifest.xml` to set the splash screen as the launcher.
  - Ensures Gradle dependencies for AppCompat, Material Components, and Lottie.

- **iOS**
  - Generates `SplashViewController.swift` and integrates it into `AppDelegate.swift`.
  - Copies assets into `ios/Runner/Resources` and keeps CocoaPods in sync.
  - Adds `pod 'lottie-ios'` when Lottie animations are used.
  - Loads light/dark image and Lottie variants automatically when both are provided.

All modifications are idempotent; re-running keeps files stable and removes duplicates automatically.

## 3. Manual Overrides

- Android:
  - Override the splash theme by adding `theme: splash_theme: "CustomSplashTheme"` and define it in `styles.xml`.
  - Change the main app theme via `theme: app_theme: "YourAppTheme"`.
  - Provide `background_color` for light mode and `background_color_dark` for dark mode; or override system-driven colors with `theme.light_background_color` / `theme.dark_background_color`. Defaults remain `#FFFFFF` and `#000000`.
  - Supply dedicated visuals with `image`/`image_dark` and `lottie`/`lottie_dark`; dark variants fall back to the light ones when omitted.
  - Tint the spinner with `indicator_color`; optionally supply `indicator_color_dark` for night mode (both fall back to `text_color` when omitted).
  - To customize the layout, edit `android/app/src/main/res/layout/activity_splash.xml`.
  - Toggle the loading indicator with `indicator: true`, choose its placement via `indicator_position` (`below_visual` or `above_text`), and adjust label colours through `text_color`.
  - Position the status text either below the visual or pinned to the bottom by setting `text_position` to `below_visual` or `bottom`.

- iOS:
  - Adjust animation sizing or labels inside `ios/Runner/SplashViewController.swift`.
  - Update timing or behavior by editing `EasySplashNativeConfig` inside the generated controller.
  - Supply `image_dark` and `lottie_dark` to show alternate visuals when the device is in dark mode.
  - Provide `indicator_color`/`indicator_color_dark` to tint the native loader across light and dark appearances; they fall back to `text_color` (or system defaults).

## 4. Troubleshooting

- **Assets missing**: The generator warns when files cannot be found. Ensure paths are correct and assets are listed in `pubspec.yaml`.
- **iOS pods failing**: Install CocoaPods (`sudo gem install cocoapods`) and rerun `pod install` inside `ios/`.
- **Launcher intent still on MainActivity**: Delete manual edits inside `AndroidManifest.xml`—the generator manages launcher flags.
- **Sound not playing**: Verify the audio format is supported (`.mp3` or `.wav`) and that the device is not in silent mode.

## 5. Theme Logic

- `mode: system` - Follows the platform appearance without forcing brightness or colors; defaults to white in light mode and black in dark mode unless you supply `background_color` / `background_color_dark` or the explicit `theme.light_background_color` / `theme.dark_background_color`.
- `mode: light` - Uses a light AppCompat splash theme and the `background_color` value (default `#FFFFFF`).
- `mode: dark` - Matches dark surfaces and prefers `background_color_dark`, falling back to `background_color` or `#000000`.
- `app_theme` - Assigns the provided style to `MainActivity`, allowing existing themes to continue during Flutter runtime.
- `splash_theme` - Overrides the generated `EasySplashTheme` entirely; use this for advanced layout or immersive options.
- `text_color` - Overrides the loading text color; use `text_color_dark` for dark mode (both fall back to system defaults when omitted).

---

Generated automatically by `simple_splash_view`.
