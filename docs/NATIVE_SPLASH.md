# Native splash (black + icon)

The app uses **only the native splash** (no custom Flutter splash UI):

- **Android:** Black background + app icon centered (`res/drawable/launch_background.xml` uses `ic_launcher_foreground`).
- **iOS:** Black background + image from `LaunchImage` imageset (`Runner/Assets.xcassets/LaunchImage.imageset/`).

The first Flutter screen is a black screen that runs the same navigation logic (onboarding / sign in / home), so the transition from native splash to app is seamless.

---

## Using a different image on native splash (e.g. your logo)

- **Android:** To show a custom image (e.g. same logo as in the app) instead of the app icon, add a drawable (e.g. `res/drawable/splash_logo.png`) and in `launch_background.xml` replace `@drawable/ic_launcher_foreground` with `@drawable/splash_logo`. Your logo asset should be PNG (native splash cannot use SVG).
- **iOS:** Replace the images in `ios/Runner/Assets.xcassets/LaunchImage.imageset/` with your logo:
  - `LaunchImage.png` (1x)
  - `LaunchImage@2x.png` (2x)
  - `LaunchImage@3x.png` (3x)
  You can export your logo (e.g. from `assets/logo/image.png` or your SVG) at 1x, 2x, 3x and drop them there. The storyboard already uses `LaunchImage`, so no code change is needed.
