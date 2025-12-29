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

**Quick Start (Recommended):**
```bash
# Easy shortcut - automatically loads API keys from .env file
./run.sh          # Runs on Chrome (default)
./run.sh chrome   # Explicitly run on Chrome
./run.sh android  # Run on Android emulator (when fixed)
```

**Manual Start:**
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

**Environment Setup**:
1. Create a `.env` file in the project root:
```bash
GEMINI_API_KEY=your_gemini_api_key_here
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
```

2. Get Gemini API Key from https://makersuite.google.com/app/apikey
3. Get Supabase credentials from your Supabase project dashboard
4. Run with `./run.sh` - it automatically loads the .env file!

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
│   ├── auth/auth_notifier.dart           # Global authentication state management
│   ├── di/service_locator.dart           # GetIt dependency injection setup
│   └── security/                         # Encrypted storage service (AES + platform keystore)
├── features/                             # Each feature has domain/data/presentation layers
│   ├── voice_input/                      # Danish speech-to-text (da-DK locale)
│   ├── data_extraction/                  # Job info extraction with Gemini AI
│   ├── pdf_generation/                   # Quotation PDF creation
│   ├── supabase_integration/             # Auth and database operations
│   ├── customer_management/              # Customer database with CSV import
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

**JobFlowNotifier** (lib/features/job_flow/job_flow_notifier.dart) is the central coordinator that:
- Manages bottom navigation tab switching (5 tabs: Voice, Data, PDF, Supabase, Kunder)
- Stores extracted conversation data
- Triggers automatic navigation (e.g., auto-switch to Data tab after voice analysis)

**AuthNotifier** (lib/core/auth/auth_notifier.dart) manages global authentication state:
- Tracks user login/logout across the app
- Provides authentication status to all widgets via Provider
- Used by features requiring authentication (e.g., CSV import, database operations)

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

### Customer Management

Full-featured customer database with CSV import:
- **CSV Import**: Bulk import from `developercatfiles/1dscoolcustomers.csv`
- **Search & Filter**: Multi-field search (name, email, phone, address) with category filters
- **Categories**: Erhverv (Business), Privat (Private), Offentlig (Public)
- **Authentication Required**: RLS policies enforce authentication for data operations
- **Models**: CustomerModel, AppointmentModel, PartsOrderModel
- **Database**: Supabase PostgreSQL with BIGSERIAL primary keys

Implementation:
- Service: `lib/features/customer_management/domain/customer_service.dart`
- CSV Import: `lib/features/customer_management/data/csv_import_service.dart`
- UI: `lib/features/customer_management/presentation/customer_list_widget.dart`
- Schema: `supabase_schema_fase1_v2.sql`

**Important**: Users must log in via Supabase tab before importing customers due to RLS policies.

## Language and Conventions

- **UI Language**: Danish (da-DK)
- **Code Comments**: Mix of Danish and English
- **Variable Naming**: Primarily English, some Danish
- **Stream Usage**: Services expose broadcast streams for real-time updates
- **Late Initialization**: Services use `late final` and initialize in `initState()`
- **Error Handling**: Services return structured maps with `success` and `error` keys

## Current Development Status

### Implemented ✅
- Voice input with Danish speech recognition (60s recording, 15s pause tolerance)
- **AI-powered data extraction with Google Gemini** (extracts customer info, job details, materials, prices)
- PDF generation with Danish currency formatting and Unicode support
- Full-featured PDF generation UI with preview and success states
- Supabase authentication and CRUD operations with complete UI
- **Customer management system** with CSV import, search, and filters
- Global authentication state management (AuthNotifier)
- Secure encrypted storage
- 5-tab navigation (Voice, Data, PDF, Supabase, Kunder)
- Comprehensive data extraction UI with structured display
- JobFlowNotifier with loading states and error handling

### Completed in Fase 1-3 (Core Features)
- ✅ Enhanced UI for all tabs with consistent design
- ✅ Gemini AI integration for intelligent data extraction
- ✅ Fixed voice input singleton disposal issue
- ✅ Fixed PDF Unicode support (removed fontWeight dependencies)
- ✅ Real-time transcription display in notes field
- ✅ Google Gemini 2.5 Flash integration (free tier, 1M token context)
- ✅ Web platform PDF generation with auto-download
- ✅ Danish character sanitization for PDF compatibility (æ→ae, ø→o, å→aa)
- ✅ Cross-platform support via universal_html package
- ✅ Fixed all model compatibility issues with Gemini API

### Completed in Fase 1 (Customer Management) - December 2024
- ✅ Customer database schema (customers, appointments, parts_orders tables)
- ✅ CustomerModel, AppointmentModel, PartsOrderModel with JSON serialization
- ✅ CSV import service with bulk insert and error handling
- ✅ CustomerService with full CRUD operations
- ✅ Customer list UI with search and category filters
- ✅ Authentication-aware UI with warnings for unauthenticated users
- ✅ RLS policies for secure data access
- ✅ Integration with existing Supabase authentication

### Next Steps (Roadmap)
- 📅 **Fase 2**: Calendar/Planner implementation
  - Dag/Uge/Måned views
  - Appointment scheduling
  - Google Calendar export
  - Status colors for appointments
- 💼 **Fase 3**: Quote/Tilbud workflow
  - Convert PDF to formal quote
  - Email sending via mailto
  - Accept/Reject tracking
  - Auto-create appointments on acceptance
- 🔧 **Fase 4**: Parts tracking system
  - Parts order management
  - Status progression (not ordered → ordered → arrived → installed)
  - Integration with appointments

## Important File References

### Core Files
- Entry point: `lib/main.dart`
- Quick run script: `run.sh` (loads .env and runs app)
- DI setup: `lib/core/di/service_locator.dart`
- Auth state: `lib/core/auth/auth_notifier.dart`
- State orchestration: `lib/features/job_flow/job_flow_notifier.dart`
- Home navigation: `lib/presentation/screens/home_screen.dart`

### Data Models
- Job analysis: `lib/models/job_analysis_model.dart`
- Customer: `lib/models/customer_model.dart`
- Appointment: `lib/models/appointment_model.dart`
- Parts order: `lib/models/parts_order_model.dart`

### Feature Implementations
- AI extraction: `lib/features/data_extraction/data/data_extraction_service_impl.dart`
- PDF generation: `lib/features/pdf_generation/data/pdf_generation_service_impl.dart`
- Customer service: `lib/features/customer_management/data/customer_service_impl.dart`
- CSV import: `lib/features/customer_management/data/csv_import_service.dart`
- Customer UI: `lib/features/customer_management/presentation/customer_list_widget.dart`

### Database
- Customer schema: `supabase_schema_fase1_v2.sql`
- Customer CSV: `developercatfiles/1dscoolcustomers.csv`

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
