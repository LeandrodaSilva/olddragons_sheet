# CLAUDE.md

## Project Overview

**OldDragons Sheet** (`ods`) is a cross-platform Flutter app for creating and playing Old Dragon RPG characters. The user builds their character (race, class, attributes) and then plays with it through an interactive interface that replaces the traditional paper sheet — with inventory management, equipment, item shop, dice rolling, and everything needed to run an RPG campaign session.

- **Version:** 2.1.0+12
- **Dart SDK:** >=2.16.1 <3.0.0
- **Flutter channel:** stable
- **Language:** Portuguese (Brazilian)

## Common Commands

```bash
flutter pub get          # Install dependencies
flutter analyze          # Run Dart linting
flutter test             # Run tests (currently minimal)
flutter build web        # Build web release
flutter run              # Run in debug mode
```

## Project Structure

```
lib/
├── main.dart                  # Entry point: Firebase init, Provider setup
├── app.dart                   # Root widget, Material theme (dark red)
├── firebase_options.dart      # Firebase config (all platforms)
├── controllers/               # Business logic & static data
│   ├── character_controller.dart   # Race data with descriptions
│   ├── class_controller.dart       # Class data with descriptions
│   └── sheet_controller.dart       # SheetModel (ChangeNotifier/Provider)
├── middlewares/
│   └── auth_middleware.dart        # Firebase Auth gate (StreamBuilder)
├── models/                    # Data classes
│   ├── character_model.dart        # Race model
│   ├── class_model.dart            # Class model
│   └── sheet_model.dart            # Character sheet model
├── screens/                   # Full-page UI views
│   ├── custom_signin_screen.dart   # Email & Google sign-in
│   ├── sheets_screen.dart          # Main sheet list
│   ├── profile_screen.dart         # User profile
│   ├── race_selection_screen.dart  # Race picker
│   ├── race_details_screen.dart    # Race info display
│   ├── class_selection_screen.dart # Class picker
│   ├── add_sheet_screen.dart       # Create/edit sheet form
│   └── about_screen.dart           # About page
├── widgets/                   # Reusable components
│   ├── layout_widget.dart          # Main scaffold & navigation
│   ├── appdrawer_widget.dart       # Navigation drawer
│   ├── race_card_widget.dart       # Race card component
│   └── loading_widget.dart         # Loading spinner
└── utils/                     # Utilities
    ├── color_tools_util.dart       # Material color generation
    └── custom_scroll_behavior_util.dart
```

### Other directories

- `test/` — Widget tests (template exists, not yet implemented)
- `assets/images/` — Race, class, and background images
- `android/`, `ios/`, `macos/`, `windows/`, `web/` — Platform-specific native code
- `.github/workflows/` — CI/CD (Firebase Hosting deploy)

## Architecture

- **Pattern:** MVC with Provider state management
- **State:** `SheetModel` extends `ChangeNotifier`, provided via `MultiProvider` in `main.dart`
- **Auth flow:** `AuthMiddleware` listens to Firebase Auth stream → unauthenticated users go to sign-in screen
- **Data:** Character sheets persisted in Firestore; race/class data is static in controllers
- **UI:** Material Design with custom dark red theme (RGB 172, 25, 20)

## Key Dependencies

| Package | Purpose |
|---------|---------|
| `firebase_core`, `firebase_auth`, `cloud_firestore` | Firebase backend |
| `google_sign_in` | Google authentication |
| `provider` | State management |
| `adaptive_navigation` | Responsive navigation |
| `carousel_slider` | Image carousels |
| `flutter_gravatar` | User avatars |

## Naming Conventions

- **Files:** `snake_case` with suffix indicating type (e.g., `sheet_model.dart`, `auth_middleware.dart`)
- **Classes:** `PascalCase` (e.g., `SheetsScreen`, `SheetModel`)
- **Methods/variables:** `camelCase`
- **Suffixes:** `*Screen` for pages, `*Widget` for components, `*Model` for data, `*Controller` for logic

## CI/CD

Two GitHub Actions workflows in `.github/workflows/`:

1. **firebase-hosting-merge.yml** — On push to `master`: builds web, deploys to Firebase Hosting (live)
2. **firebase-hosting-pull-request.yml** — On PR: builds web, deploys preview channel

Both run: `flutter pub get` → `flutter build web` → Firebase deploy.

Required secret: `FIREBASE_SERVICE_ACCOUNT_OLDDRAGONS_SHEET`

## Linting

Uses `flutter_lints` with config in `analysis_options.yaml`. Always run `flutter analyze` before committing.

## Notes for AI Assistants

- Firebase config is in `lib/firebase_options.dart` — do not modify API keys
- The app targets Dart SDK <3.0.0; do not use null safety features beyond what's already in the codebase
- Tests are minimal (`test/widget_test.dart` is a commented-out template) — add tests when creating new features
- The `web/manifest.json` PWA theme color (#0175C2 blue) differs from the app's red theme — this is intentional
- No `.env` files exist; Firebase config is embedded in source
