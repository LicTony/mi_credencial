# Mi Credencial — Flutter Project

## Project Overview

**Mi Credencial** (also referred to as **BailaMás Card App**) is a Flutter mobile application designed to digitize dance class attendance cards for the **Evolución • Baila Más** dance studio. The app replaces physical cardboard attendance cards with an interactive digital version that allows students to track their classes with date and time, persist data between sessions, and share their card status via WhatsApp.

### Key Features (v1.0)
- Digital attendance card with gradient UI (pink/orange/violet)
- Editable student name with auto-save
- Selectable class packs: 4, 8, or 16 classes
- Class slot registration with date and time selection (17:00, 19:30, 20:30)
- Support for multiple classes per day with different time slots
- Share card as PNG image via native sharing menu
- Local persistence using SharedPreferences

### Technology Stack
| Layer | Technology | Version |
|-------|-----------|---------|
| Framework | Flutter | ^3.x |
| Language | Dart | ^3.11.3 |
| State Management | flutter_riverpod | ^3.3.1 |
| Code Generation | riverpod_generator + riverpod_annotation | ^4.0.x |
| Build Tool | build_runner | ^2.13.1 |
| Persistence | shared_preferences | ^2.3.2 |
| Screenshot | screenshot | ^2.1.0 |
| File Sharing | share_plus | ^9.0.0 |
| Date Formatting | intl | ^0.19.0 |

## Architecture

The project follows a **feature-based architecture** with Riverpod for state management:

```
lib/
├── main.dart                          # Entry point, ProviderScope
├── core/                              # Shared core utilities (empty)
├── features/
│   ├── auth/                          # Authentication feature
│   │   ├── data/                      # Data sources, repositories
│   │   ├── domain/                    # Entities, use cases
│   │   └── presentation/              # UI components, screens
│   └── credentials/                   # Credentials management feature (empty)
└── shared/                            # Shared utilities (empty)
```

### State Management Pattern
```
UI (ref.watch) ──→ Notifier (AsyncNotifier) ──→ Service ──→ SharedPreferences
                         ↑
               ref.read(...notifier).method()
```

- Models are **immutable** (use `copyWith`)
- Notifiers are **AsyncNotifier** because `build()` reads from disk asynchronously
- Each state modification updates memory and persists to disk in the same operation

## Building and Running

### Prerequisites
- Flutter SDK ^3.11.3
- Dart SDK ^3.11.3
- Android Studio / VS Code with Flutter extensions

### Setup Commands

```bash
# Navigate to project directory
cd C:\_Tony\Flutter\mi_credencial

# Install dependencies
flutter pub get

# Generate Riverpod code (required after creating/modifying providers)
dart run build_runner build --delete-conflicting-outputs

# Watch mode (auto-regenerates on file save)
dart run build_runner watch
```

### Running the App

```bash
# Run on connected device or emulator
flutter run

# Run on specific device
flutter devices                    # List available devices
flutter run -d <device_id>

# Run in debug/release mode
flutter run --debug
flutter run --release
```

### Building for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle (for Play Store)
flutter build appbundle --release

# iOS (requires macOS)
flutter build ios --release
```

### Testing

```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

## Development Conventions

### Code Style
- The project uses `package:flutter_lints/flutter.yaml` as the base linting rules
- Configuration is in `analysis_options.yaml`
- Run static analysis before committing:
  ```bash
  flutter analyze
  ```

### Project Structure Conventions
- **Features**: Each feature (e.g., `auth`, `credentials`) follows a clean architecture pattern with `data`, `domain`, and `presentation` subdirectories
- **Models**: Immutable models with `copyWith` methods
- **Providers**: Use Riverpod annotations with `@riverpod` for code generation
- **Services**: Encapsulate external dependencies (SharedPreferences, file system, etc.)

### State Management Patterns
- Use `AsyncNotifier` for state that involves async operations (disk I/O, network)
- Use `Notifier` for synchronous state
- Always generate providers with `@riverpod` annotation and run `build_runner`

### Testing Practices
- Widget tests for UI components
- Unit tests for business logic (notifiers, services, use cases)
- Integration tests for critical user flows

## Platform Configuration

### Android
Add to `android/app/src/main/AndroidManifest.xml`:
```xml
<uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
```

### iOS
Add to `ios/Runner/Info.plist`:
```xml
<key>NSPhotoLibraryUsageDescription</key>
<string>Se necesita acceso para guardar la tarjeta de clases</string>
```

## Key Files

| File | Description |
|------|-------------|
| `pubspec.yaml` | Project dependencies and Flutter configuration |
| `analysis_options.yaml` | Dart analyzer linting rules |
| `lib/main.dart` | Application entry point with ProviderScope |
| `20260329_1000_PRD.md` | Product Requirements Document (v1.0) |
| `test/widget_test.dart` | Basic widget test template |

## Common Tasks

### Creating a New Provider
1. Create provider file with `@riverpod` annotation
2. Run code generation: `dart run build_runner build --delete-conflicting-outputs`
3. Import the generated `.g.dart` file

### Modifying Existing Providers
After any change to provider files:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Adding New Features
1. Create feature directory under `lib/features/<feature_name>/`
2. Follow the `data/domain/presentation` structure
3. Create models in `lib/features/<feature_name>/domain/`
4. Create providers in `lib/features/<feature_name>/data/` or dedicated `providers/` folder
5. Create UI in `lib/features/<feature_name>/presentation/`

## Troubleshooting

### Build Runner Issues
If you encounter conflicting outputs:
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Dependency Conflicts
```bash
flutter pub upgrade
flutter pub get
```

### Clean Build
```bash
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## References

- [Flutter Documentation](https://docs.flutter.dev/)
- [Riverpod Documentation](https://riverpod.dev/)
- [Dart Language Tour](https://dart.dev/guides/language/language-tour)

---
*Last updated: 29/03/2026*
