# CLAUDE.md

## Project Overview

**OldDragons Sheet** (`ods`) is a cross-platform Flutter app for creating and playing Old Dragon RPG characters. The user builds their character (race, class, attributes) and then plays with it through an interactive interface that replaces the traditional paper sheet — with inventory management, equipment, item shop, dice rolling, and everything needed to run an RPG campaign session.

- **Version:** 2.1.0+12
- **Dart SDK:** >=3.0.0 <4.0.0
- **Flutter channel:** stable
- **Language:** Portuguese (Brazilian)

## Common Commands

```bash
flutter pub get          # Install dependencies
flutter analyze          # Run Dart linting
flutter test             # Run tests (currently minimal)
flutter build web        # Build web release
flutter run -d chrome    # Run in debug mode (web)
```

## Project Structure

```
lib/
├── main.dart                  # Entry point: Firebase init, Provider setup
├── app.dart                   # Root widget, Material theme (dark red)
├── firebase_options.dart      # Firebase config (all platforms)
├── controllers/
│   ├── character_controller.dart   # Race data (static, hardcoded)
│   ├── class_controller.dart       # Class data (static, hardcoded)
│   ├── sheet_controller.dart       # SheetModel (ChangeNotifier, Firestore realtime)
│   ├── inventory_controller.dart   # Item CRUD (Firestore subcollection, realtime)
│   ├── shop_controller.dart        # Static item catalog (75 items from rulebook)
│   └── dice_controller.dart        # Dice rolling logic + history
├── middlewares/
│   └── auth_middleware.dart        # Firebase Auth gate (StreamBuilder)
├── models/
│   ├── character_model.dart        # Race model
│   ├── class_model.dart            # Class model
│   ├── sheet_model.dart            # Character sheet (attributes, stats, money, XP)
│   └── item_model.dart             # Item model (weapons, armor, gear)
├── screens/
│   ├── custom_signin_screen.dart   # Google Sign-In only
│   ├── sheets_screen.dart          # Character list + "Jogar" button
│   ├── play_screen.dart            # Gameplay screen (4 tabs: Ficha/Inventário/Loja/Dados)
│   ├── add_sheet_screen.dart       # Character creation (attributes, gold rolling)
│   ├── race_selection_screen.dart  # Race picker (carousel)
│   ├── race_details_screen.dart    # Race info display
│   ├── class_selection_screen.dart # Class picker (carousel)
│   ├── profile_screen.dart         # User profile
│   └── about_screen.dart           # About page
├── widgets/
│   ├── attribute_card_widget.dart   # Attribute card (value + modifier)
│   ├── pv_bar_widget.dart           # HP bar with +/- buttons
│   ├── stat_card_widget.dart        # Derived stat card (CA, JP, BA, MOV)
│   ├── item_card_widget.dart        # Inventory item card
│   ├── shop_item_card_widget.dart   # Shop item card with buy button
│   ├── dice_roller_widget.dart      # Dice roller with combat shortcuts
│   ├── layout_widget.dart           # Main scaffold & navigation
│   ├── appdrawer_widget.dart        # Navigation drawer
│   ├── race_card_widget.dart        # Race card component
│   └── loading_widget.dart          # Loading spinner
└── utils/
    ├── color_tools_util.dart        # Material color generation
    └── custom_scroll_behavior_util.dart
```

## Architecture

- **Pattern:** MVC with Provider state management
- **State:** `SheetModel` extends `ChangeNotifier`, provided via `MultiProvider` in `main.dart`
- **Realtime sync:** Both `SheetModel` and `InventoryController` use Firestore `.snapshots().listen()` for cross-device sync
- **Auth:** Google Sign-In via `google_sign_in` package → `signInWithCredential` (NOT `signInWithPopup` — has bugs)
- **Data:** Sheets in `sheets` collection, items in `sheets/{id}/items` subcollection. Race/class data is static in controllers
- **Gameplay:** `PlayScreen` with 4 tabs: Stats, Inventory, Shop, Dice. Sheet doc listener for realtime updates

## Key Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | ^4.6.0 | Firebase backend |
| `firebase_auth` | ^6.3.0 | Authentication |
| `cloud_firestore` | ^6.2.0 | Database (realtime) |
| `google_sign_in` | ^6.2.2 | Google OAuth |
| `provider` | ^6.1.2 | State management |
| `carousel_slider` | ^5.0.0 | Image carousels |

## Naming Conventions

- **Files:** `snake_case` with suffix (e.g., `sheet_model.dart`, `auth_middleware.dart`)
- **Classes:** `PascalCase` (e.g., `SheetsScreen`, `SheetModel`)
- **Methods/variables:** `camelCase`
- **Suffixes:** `*Screen` for pages, `*Widget` for components, `*Model` for data, `*Controller` for logic

## CI/CD

Two GitHub Actions workflows in `.github/workflows/`:

1. **firebase-hosting-merge.yml** — On push to `master`: builds web, deploys to Firebase Hosting
2. **firebase-hosting-pull-request.yml** — On PR: builds web, deploys preview channel

Required secret: `FIREBASE_SERVICE_ACCOUNT_OLDDRAGONS_SHEET`

## Design System

### Theme
- **Style:** Medieval/fantasy RPG — dark browns, golds, reds. NOT generic Material
- **Login screen:** Dragon frame image with brown background, gold-bordered button
- **Assets:** Custom logo (dragon eye), background (dragon battle scene), frame (dragon border)

### Colors
| Token | Value | Usage |
|-------|-------|-------|
| Primary | `#AC1914` | AppBar, buttons, titles, borders |
| Gold accent | `#D4A855` | Button borders, highlights (login) |
| Brown dark | `RGBA(40, 22, 10, 0.85)` | Frame background (login) |
| Background | `#FFFFFF` | Scaffold, AppBar background |

### Spacing
- Border Radius: Input `8px`, Card `16px`, Button `6-8px`
- Elevation: Default `3`, Selected `6-10`
- Max Width: Forms/Cards `600px`, Login frame `520px`

## Old Dragon Game Reference

### Attribute Modifiers (Table T1-1, Livro Básico)
| Value | Modifier |
|-------|----------|
| 1 | -5 |
| 2-3 | -4 |
| 4-5 | -3 |
| 6-7 | -2 |
| 8-9 | -1 |
| 10-11 | 0 |
| 12-13 | +1 |
| 14-15 | +2 |
| 16-17 | +3 |
| 18-19 | +4 |
| 20-21 | +5 |

### Derived Stats
```
PV = Class Hit Die + CON mod (per level, up to 10th)
CA = 10 + DES mod + Armor + Shield + Others
BAC (melee) = Class BA + FOR mod + Others
BAD (ranged) = Class BA + DES mod + Others
JP = Base JP + attribute mod (DES/CON/SAB depending on type)
MV = Race base - Armor reduction
```

### Money System
```
10 PC (Cobre) = 1 PP (Prata)
10 PP (Prata) = 1 PO (Ouro)
Starting gold: 3d6 × 10 PO
```

## Gotchas

- **Google Sign-In web:** Do NOT use `signInWithPopup` — causes "TypeError: t is not iterable". Use `google_sign_in` package with `signInWithCredential` instead
- **People API:** Must be enabled in Google Cloud Console for `google_sign_in` to work
- **OAuth domains:** Production domain `ods.leandrodasilva.dev` must be in authorized origins/redirects in Google Cloud Console
- **Web client ID:** `315957121112-dcjoq388bbk80vlifjk7v4a0fv57h76k` (meta tag in `web/index.html`)
- **Firebase config:** In `lib/firebase_options.dart` — do not modify API keys
- **Tests:** Minimal (`test/widget_test.dart` is a template) — add tests when creating new features
