# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

DeveloperCat DK is a Danish-language Flutter application for voice-based business assistance, focusing on job analysis, quotation generation, and data management. The app uses Clean Architecture with SOLID principles and Supabase as the backend.

**Primary Target Platforms**: Android and iOS phones/tablets (mobile-first development)

**Current Development Platform**: Web (Chrome) - fully functional and recommended for active development

## Platform Support Status

| Platform | Status | Notes |
|----------|--------|-------|
| **Web (Chrome)** | ✅ **RECOMMENDED** | Use for daily development - fast hot reload, full functionality |
| **Android** | 🔧 In Progress | Being configured - Gradle setup issues being resolved |
| **iOS** | ✅ Configured | Requires macOS for building |
| **Windows** | ⚠️ Not Priority | May work but not actively tested |

## Recommended Development Workflow

**For Active Development** (Start here! 🚀):
```bash
# Run in Chrome for fast development with hot reload
flutter run -d chrome

# With Supabase environment variables
flutter run -d chrome --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key>

# With AI extraction enabled (requires Google Gemini API key)
flutter run -d chrome \
  --dart-define=SUPABASE_URL=<url> \
  --dart-define=SUPABASE_ANON_KEY=<key> \
  --dart-define=GEMINI_API_KEY=<your_gemini_api_key>
```

**Get Gemini API Key**:
1. Visit https://makersuite.google.com/app/apikey
2. Create a new API key
3. Use it with `--dart-define=GEMINI_API_KEY=<key>`

**For Mobile Testing** (when Android is fixed):
```bash
# Check available devices
flutter devices

# Run on Android emulator
flutter emulators --launch Medium_Phone
flutter run
```

## Essential Commands

### Development
```bash
# Install dependencies
flutter pub get

# Generate JSON serialization code (required after model changes)
flutter pub run build_runner build

# Force regenerate (when conflicts occur)
flutter pub run build_runner build --delete-conflicting-outputs

# Run app (requires .env file with SUPABASE_URL and SUPABASE_ANON_KEY)
flutter run

# Run with explicit environment variables
flutter run --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key>
```

### Build

```bash
# Android (primary platform)
flutter build apk           # Debug APK
flutter build apk --release # Release APK
flutter build appbundle     # App Bundle for Play Store

# iOS (requires macOS)
flutter build ios           # iOS build
flutter build ipa           # iOS App Store package

# Web (for testing/development)
flutter build web           # Production web build

# Check available devices
flutter devices

# List Android emulators
flutter emulators

# Launch specific emulator
flutter emulators --launch <emulator_id>
```

### Running on Devices

```bash
# Run on specific device
flutter run -d <device_id>

# Run on Android emulator
flutter run -d Medium_Phone

# Run on web browser
flutter run -d chrome

# Run with environment variables
flutter run --dart-define=SUPABASE_URL=<url> --dart-define=SUPABASE_ANON_KEY=<key>
```

### Code Quality
```bash
flutter analyze             # Run static analysis
flutter test                # Run all tests
```

## Architecture Overview

### Clean Architecture Structure

The app follows feature-based modular architecture with strict layer separation:

```
lib/
├── core/
│   ├── di/service_locator.dart          # GetIt dependency injection setup
│   └── security/                         # Encrypted storage service (AES + platform keystore)
├── features/                             # Each feature has domain/data/presentation layers
│   ├── voice_input/                      # Danish speech-to-text (da-DK locale)
│   ├── data_extraction/                  # Job info extraction (currently mock data)
│   ├── pdf_generation/                   # Quotation PDF creation
│   ├── supabase_integration/             # Auth and database operations
│   └── job_flow/job_flow_notifier.dart   # Cross-feature state orchestration
├── models/                               # JSON-serializable data models
└── presentation/                         # App-wide UI components
```

### Key Architectural Patterns

1. **Dependency Injection**: All services registered in `core/di/service_locator.dart` using GetIt as lazy singletons
2. **Interface Segregation**: Each feature defines a domain interface (`features/*/domain/`) with implementation in `features/*/data/`
3. **State Management**: Provider pattern via `JobFlowNotifier` for app-wide state coordination
4. **Import Aliases**: Used to resolve naming conflicts (e.g., `import 'x.dart' as alias;`)

### State Orchestration

`JobFlowNotifier` (lib/features/job_flow/job_flow_notifier.dart) is the central coordinator that:
- Manages bottom navigation tab switching (4 tabs: Voice, Data, PDF, Supabase)
- Stores extracted conversation data
- Triggers automatic navigation (e.g., auto-switch to Data tab after voice analysis)

## Critical Implementation Details

### JSON Serialization

Models use `json_serializable`. After modifying any model in `lib/models/`:
```bash
flutter pub run build_runner build
```

Models must include:
```dart
import 'package:json_annotation/json_annotation.dart';
part 'model_name.g.dart';

@JsonSerializable()
class ModelName {
  // fields...

  factory ModelName.fromJson(Map<String, dynamic> json) => _$ModelNameFromJson(json);
  Map<String, dynamic> toJson() => _$ModelNameToJson(this);
}
```

### Environment Configuration

Required `.env` file at project root:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
API_ENDPOINT=https://api.example.com
```

Access via: `String.fromEnvironment('SUPABASE_URL')`

### Security Implementation

The app uses double encryption for sensitive data:
1. AES encryption with auto-generated 32-byte key and 16-byte IV
2. Platform-specific secure storage (Android Keystore / iOS Keychain)

Implementation: `lib/core/security/secure_storage_service_impl.dart`

### Voice Input Service

Configured for Danish speech recognition:
- Locale: `da-DK`
- Listening duration: 60 seconds
- Pause tolerance: 15 seconds (prevents early stop)
- Uses `speech_to_text` package
- Exposes streams for real-time transcription and listening status
- **Known Web Limitation**: Browser may enforce ~15 second recording limit for security

### AI Data Extraction Service

Uses Google Gemini for intelligent data extraction:
- Model: `gemini-2.5-flash` (free tier available, up to 1M token context)
- Package: `google_generative_ai ^0.4.7`
- Extracts: customer name, phone, email, address, job type, materials, prices, dates
- Generates realistic Danish pricing estimates (incl. labor 400-800 kr/hour)
- Fallback to mock data if API key missing or request fails
- Returns structured JSON matching `JobAnalysisModel`

### PDF Generation

Creates A4 PDFs with Danish formatting:
- Currency: DKK (Danish Krone)
- Includes customer details, parts table, labor costs, total estimate
- Saves to device storage via `path_provider`

Implementation: `lib/features/pdf_generation/data/pdf_generation_service_impl.dart`

## Language and Conventions

- **UI Language**: Danish (da-DK)
- **Code Comments**: Mix of Danish and English
- **Variable Naming**: Primarily English, some Danish
- **Stream Usage**: Services expose broadcast streams for real-time updates
- **Late Initialization**: Services use `late final` and initialize in `initState()`
- **Error Handling**: Services return structured maps with `success` and `error` keys

## Current Development Status

### Implemented
- Voice input with Danish speech recognition (60s recording, 15s pause tolerance)
- **AI-powered data extraction with Google Gemini** (extracts customer info, job details, materials, prices)
- PDF generation with Danish currency formatting and Unicode support
- Full-featured PDF generation UI with preview and success states
- Supabase authentication and CRUD operations with complete UI
- Secure encrypted storage
- Tab-based navigation with state coordination
- Comprehensive data extraction UI with structured display
- JobFlowNotifier with loading states and error handling

### Completed in Fase 1 & 2
- ✅ Enhanced UI for all 4 tabs (Voice, Data, PDF, Supabase)
- ✅ Gemini AI integration for intelligent data extraction
- ✅ Fixed voice input singleton disposal issue
- ✅ Fixed PDF Unicode support (removed fontWeight dependencies)
- ✅ Real-time transcription display in notes field

## Important File References

- Entry point: `lib/main.dart`
- DI setup: `lib/core/di/service_locator.dart`
- State orchestration: `lib/features/job_flow/job_flow_notifier.dart`
- Main data model: `lib/models/job_analysis_model.dart`
- Home navigation: `lib/presentation/screens/home_screen.dart`

## Testing

Current test file (`test/widget_test.dart`) is outdated and needs updating to match actual app features. When writing tests:
- Use widget tests for presentation layer
- Use unit tests for domain/data layers
- Mock services registered in GetIt for isolated testing

## Troubleshooting

### Android Build Issues

#### Gradle Cache Corruption
If you encounter errors like `Could not read workspace metadata from C:\Users\...\metadata.bin`:

**Solution 1: Clean and Rebuild**
```bash
# Stop all Gradle daemons
cd android && ./gradlew --stop

# Clean Flutter build
flutter clean
flutter pub get

# Try building again
flutter build apk --debug
```

**Solution 2: Clear Gradle Cache (Windows)**
```bash
# Stop Gradle daemons first
cd android && ./gradlew --stop

# Manually delete cache directory
# Close Android Studio and any IDEs first
# Then delete: C:\Users\<username>\.gradle\caches
```

**Solution 3: Configure Java Version**
Ensure Flutter uses the correct Java version:
```bash
flutter config --jdk-dir="C:\Program Files\Android\Android Studio\jbr"
```

#### Missing Asset Directories
If build fails with `unable to find directory entry in pubspec.yaml`:
```bash
# Create the required asset directories
mkdir -p assets/images
mkdir -p assets/icons
```

### Environment Variables
Environment variables must be passed at runtime using `--dart-define`:
```bash
flutter run --dart-define=SUPABASE_URL=<your_url> --dart-define=SUPABASE_ANON_KEY=<your_key>
```

The `.env` file is not automatically loaded - variables must be provided via command line.

### Project Structure Note
✅ **FIXED**: Nested Flutter project in `android/` directory has been cleaned up. Current structure is correct:
- `android/` - Android platform configuration (clean, no nested project)
- `ios/` - iOS platform configuration
- `lib/` - Main application code

### Android Build Status
🔧 **Currently In Progress**: Android builds are experiencing Gradle cache corruption issues. For now:
- **Use Chrome for development** (fully functional)
- Android configuration will be fixed in a future session
- The nested project structure has been cleaned up
- Gradle cache needs additional troubleshooting

When ready to fix Android completely:
1. Ensure all IDEs are closed
2. Delete entire `C:\Users\<username>\.gradle\caches` directory manually
3. Run `flutter clean && flutter pub get`
4. Try `flutter run` with emulator running
