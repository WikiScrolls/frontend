# WikiScrolls Frontend – Onboarding Pages

This is a minimal Flutter app that implements three startup (onboarding) pages based on the provided Figma mockups.

## Highlights
- Full-screen background image with a dark overlay per page
- Large serif headline (Google Fonts – Playfair Display)
- Animated dots indicator
- Prominent "Get Started" button
- Footer legal copy

## Structure
- `lib/main.dart` – App entry and theming
- `lib/screens/onboarding_screen.dart` – PageView + indicator + CTA
- `lib/widgets/onboarding_page.dart` – A single onboarding page widget
- `lib/widgets/primary_button.dart` – Reusable CTA button
- `lib/screens/home_screen.dart` – Placeholder destination after onboarding
- `assets/images/` – Put your background images here (see below)

## Assets
Add three background images in the following paths:

```
assets/images/bg1.jpg
assets/images/bg2.jpg
assets/images/bg3.jpg
```

You can replace them with any JPEG/PNG files. The names can be changed, but then also update the paths referenced in `onboarding_screen.dart`.

## Run locally
Make sure Flutter SDK is installed and available in your PATH.

```powershell
# From the repo root
cd "c:\Users\fatha\OneDrive\Documents\TugasKuliah\Semester5\RPL\Project\frontend"

# (One-time) create missing platform folders based on the existing pubspec/lib
flutter create .

# Fetch packages and run
flutter pub get
flutter run
```

If you want to tweak colors/fonts:
- Primary color is a warm orange `#DE8E54`.
- Title uses `Playfair Display` via `google_fonts`.
- Body and captions use `Inter` via `google_fonts`.

## Notes
- The onboarding copy is embedded directly in the code so you can localize or fetch it from an API later.
- If you prefer bundling a custom font instead of Google Fonts, add it under `assets/fonts/` and declare it in `pubspec.yaml`.
