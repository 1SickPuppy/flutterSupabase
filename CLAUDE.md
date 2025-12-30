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
| **Android** | ✅ **READY** | All permissions configured, ready to build and deploy |
| **iOS** | ✅ **READY** | All permissions configured, requires macOS for building |
| **Windows** | ⚠️ Not Priority | May work but not actively tested |

## Recommended Development Workflow

**For Active Development** (Start here! 🚀):

**Quick Start (Recommended):**

**On Windows:**
```cmd
rem Easy shortcut - automatically loads API keys from .env file
run.bat          # Runs on Chrome (default)
run.bat chrome   # Explicitly run on Chrome
run.bat android  # Run on Android emulator/device
```

**On Linux/Mac:**
```bash
# Easy shortcut - automatically loads API keys from .env file
./run.sh          # Runs on Chrome (default)
./run.sh chrome   # Explicitly run on Chrome
./run.sh android  # Run on Android emulator/device
```

**IMPORTANT**: Always use `run.bat` (Windows) or `run.sh` (Linux/Mac) to ensure environment variables are loaded!

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

**For Mobile Testing**:
```bash
# Check available devices
flutter devices

# Run on Android emulator
flutter emulators --launch Medium_Phone
flutter run

# Run on iOS simulator (macOS only)
flutter run -d "iPhone 15"

# Run on connected physical device
flutter run -d <device_id>
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
│   ├── security/                         # Encrypted storage service (AES + platform keystore)
│   └── theme/                            # Theme system (AppTheme, ThemeNotifier)
├── features/                             # Each feature has domain/data/presentation layers
│   ├── voice_input/                      # Danish speech-to-text (da-DK locale)
│   ├── data_extraction/                  # Job info extraction with Gemini AI
│   ├── pdf_generation/                   # Quotation PDF creation
│   ├── supabase_integration/             # Auth and database operations
│   ├── customer_management/              # Customer database with CSV import
│   ├── calendar/                         # Appointment calendar and scheduling
│   ├── quote/                            # Quote/tilbud sending service
│   └── job_flow/job_flow_notifier.dart   # Cross-feature state orchestration
├── models/                               # JSON-serializable data models
└── presentation/
    ├── components/                       # Reusable UI components (StatusBadge, DashboardCard)
    └── screens/                          # App screens (home_screen with dashboard)
```

### Key Architectural Patterns

1. **Dependency Injection**: All services registered in `core/di/service_locator.dart` using GetIt as lazy singletons
2. **Interface Segregation**: Each feature defines a domain interface (`features/*/domain/`) with implementation in `features/*/data/`
3. **State Management**: Provider pattern via `JobFlowNotifier` for app-wide state coordination
4. **Import Aliases**: Used to resolve naming conflicts (e.g., `import 'x.dart' as alias;`)

### State Orchestration

**JobFlowNotifier** (lib/features/job_flow/job_flow_notifier.dart) is the central coordinator that:
- Manages bottom navigation tab switching (6 tabs: Voice, Data, PDF, Supabase, Kunder, Kalender)
- Stores extracted conversation data
- Triggers automatic navigation (e.g., auto-switch to Data tab after voice analysis)

**AuthNotifier** (lib/core/auth/auth_notifier.dart) manages global authentication state:
- Tracks user login/logout across the app
- Provides authentication status to all widgets via Provider
- Used by features requiring authentication (e.g., CSV import, database operations)

**ThemeNotifier** (lib/core/theme/theme_notifier.dart) manages app theme:
- Manual light/dark mode toggle
- Persists user preference via SharedPreferences
- Provides theme state to entire app via Provider

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

### Calendar Management

Complete calendar and appointment scheduling system:
- **Calendar Views**: Month and week views with table_calendar package
- **Danish Locale**: Full Danish date formatting (e.g., "søndag 29. december 2024")
- **Appointment CRUD**: Create, read, update appointments with detailed form
- **Customer Integration**: Link appointments to customers from database
- **Status Tracking**: Visual status with color coding
  - Planlagt (planned) = Blue
  - I gang (in_progress) = Orange
  - Afventer dele (awaiting_parts) = Purple
  - Færdig (completed) = Green
  - Aflyst (cancelled) = Red
- **Time Management**: Start/end time pickers, duration calculation
- **Location Field**: Optional location/address for appointments

Implementation:
- Service: `lib/features/calendar/domain/appointment_service.dart`
- Implementation: `lib/features/calendar/data/appointment_service_impl.dart`
- Calendar UI: `lib/features/calendar/presentation/calendar_widget.dart`
- Dialog: `lib/features/calendar/presentation/appointment_dialog.dart`
- Model: `lib/models/appointment_model.dart` (with location field)

**Important**: Requires `initializeDateFormatting('da', null)` for Danish locale support.

### Theme System (Industrial Scandinavian Dashboard Design)

Complete professional theme system optimized for driving usage:

- **Design Philosophy**: Industrial Scandinavian Dashboard - high contrast minimalist aesthetic
- **Typography**:
  - Headings: Rajdhani (700 weight for headings, 600 for labels)
  - Body text: IBM Plex Sans (regular/medium/semibold)
  - Monospace: IBM Plex Mono (for code and technical data)
  - Optimized for readability while driving
- **Color Palette**:
  - Primary accent: Safety Orange (#FF6B35) - high visibility
  - Success: Green (#10B981)
  - Warning: Amber (#F59E0B)
  - Error: Red (#EF4444)
  - Info: Blue (#3B82F6)
  - Purple: (#8B5CF6) for special status (awaiting_parts)
- **Theme Features**:
  - Manual light/dark toggle (LYS/MØRK buttons in AppBar)
  - Persistent theme preference via SharedPreferences
  - Theme-aware status backgrounds (separate dark/light variants)
  - 60px+ touch targets for driving safety
  - 8px spacing scale for consistent layouts
  - 3px borders for high contrast
- **Dashboard-First Navigation**:
  - Index 0 = Dashboard with stats and feature cards
  - Indices 1-6 = Feature pages (Voice, Data, PDF, Supabase, Kunder, Kalender)
  - Large tappable DashboardCard components
  - StatusBadge components for color-coded status indicators
- **Reusable Components**:
  - `StatusBadge`: 5 status types (planned, in_progress, awaiting_parts, completed, cancelled)
  - `DashboardCard`: Large cards with icon, title, description, badge, meta info

Implementation:
- Theme definition: `lib/core/theme/app_theme.dart`
- Theme state: `lib/core/theme/theme_notifier.dart`
- Dashboard UI: `lib/presentation/screens/home_screen.dart`
- Status badge: `lib/presentation/components/status_badge.dart`
- Dashboard card: `lib/presentation/components/dashboard_card.dart`
- Design preview: `design_preview.html`

**Important**: All widgets use `AppTheme` constants instead of hardcoded colors for consistency and theme awareness.

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
- **Calendar/appointment management** with month/week views and status tracking
- **Industrial Scandinavian theme system** with light/dark modes and dashboard-first navigation
- Global authentication state management (AuthNotifier)
- Global theme state management (ThemeNotifier)
- Secure encrypted storage
- Dashboard-first navigation (index 0 = Dashboard, 1-6 = features)
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

### Completed in Fase 2 (Calendar/Planner) - December 2024
- ✅ AppointmentService interface and implementation
- ✅ Calendar widget with table_calendar package
- ✅ Month and week view toggle
- ✅ Appointment creation dialog with full form
- ✅ Appointment editing functionality
- ✅ Customer selection integration
- ✅ Status tracking with color-coded UI (5 statuses)
- ✅ Time pickers for start/end times
- ✅ Location field for appointments
- ✅ Danish locale initialization (initializeDateFormatting)
- ✅ Event markers on calendar days
- ✅ Click day to view appointments
- ✅ Authentication-aware creation

### Completed: Theme System & Dashboard UI - December 2024
- ✅ **Complete Theme System**:
  - Industrial Scandinavian design with high contrast minimalist aesthetic
  - Google Fonts integration (Rajdhani, IBM Plex Sans, IBM Plex Mono)
  - Safety Orange (#FF6B35) primary accent for high visibility
  - Complete status color palette (success/warning/error/info/purple)
  - Theme-aware status backgrounds (separate dark/light variants)
  - Manual light/dark toggle with SharedPreferences persistence
  - ThemeNotifier for global theme state management
  - 60px+ touch targets optimized for driving safety
  - 8px spacing scale and 3px borders for consistency
- ✅ **Dashboard-First Navigation**:
  - Redesigned home screen with dashboard at index 0
  - Stats overview (customers, appointments, today's count)
  - 2x3 grid of feature cards using DashboardCard component
  - Fixed navigation indices across all features (off-by-one bugs)
  - Auto-navigation fixes in JobFlowNotifier (voice→data, load→data)
  - LYS/MØRK theme toggle buttons in AppBar
- ✅ **Reusable Components**:
  - StatusBadge: Color-coded status indicators (5 types)
  - DashboardCard: Large tappable cards with icons and status
- ✅ **Complete Theme Migration**:
  - Replaced ALL hardcoded colors with AppTheme constants
  - All 7 widgets now fully theme-aware (voice, data, pdf, supabase, customer, calendar, appointment)
  - Consistent visual language across entire app
  - Perfect light/dark mode support everywhere
- ✅ **Design Preview**: HTML preview file (design_preview.html) for visual documentation

### Completed: Mobile Platform Support - December 2024
- ✅ **Android Platform Configuration**:
  - Added INTERNET permission for Supabase and Gemini API
  - Added RECORD_AUDIO permission for voice input
  - Updated AndroidManifest.xml with required permissions
- ✅ **iOS Platform Configuration**:
  - Created Podfile for CocoaPods dependency management
  - Added NSMicrophoneUsageDescription with Danish text
  - Added NSSpeechRecognitionUsageDescription with Danish text
  - Updated Info.plist with required permissions
- ✅ **Cross-Platform Code Refactoring**:
  - Added url_launcher package for cross-platform URL handling
  - Refactored quote_service_impl.dart to work on all platforms
  - Replaced web-only universal_html with platform-aware code
  - Added platform checks (kIsWeb) for web vs mobile logic
  - Implemented cross-platform mailto link handling

**Result**: App now fully supports Android and iOS platforms with all features functional!

### Next Steps (Roadmap)
- 📤 **Google Calendar Export** (Optional enhancement)
  - Export appointments to .ics format
  - Integration with Google Calendar
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
- Quick run scripts: `run.sh` / `run.bat` (loads .env and runs app)
- App root: `lib/presentation/app.dart`
- DI setup: `lib/core/di/service_locator.dart`
- Auth state: `lib/core/auth/auth_notifier.dart`
- Theme system: `lib/core/theme/app_theme.dart`, `lib/core/theme/theme_notifier.dart`
- State orchestration: `lib/features/job_flow/job_flow_notifier.dart`
- Dashboard UI: `lib/presentation/screens/home_screen.dart`

### Data Models
- Job analysis: `lib/models/job_analysis_model.dart`
- Customer: `lib/models/customer_model.dart`
- Appointment: `lib/models/appointment_model.dart`
- Parts order: `lib/models/parts_order_model.dart`

### Feature Implementations
- AI extraction: `lib/features/data_extraction/data/data_extraction_service_impl.dart`
- PDF generation: `lib/features/pdf_generation/data/pdf_generation_service_impl.dart`
- Quote service: `lib/features/quote/data/quote_service_impl.dart`
- Customer service: `lib/features/customer_management/data/customer_service_impl.dart`
- CSV import: `lib/features/customer_management/data/csv_import_service.dart`
- Customer UI: `lib/features/customer_management/presentation/customer_list_widget.dart`
- Appointment service: `lib/features/calendar/data/appointment_service_impl.dart`
- Calendar UI: `lib/features/calendar/presentation/calendar_widget.dart`
- Appointment dialog: `lib/features/calendar/presentation/appointment_dialog.dart`

### UI Components
- Status badge: `lib/presentation/components/status_badge.dart`
- Dashboard card: `lib/presentation/components/dashboard_card.dart`
- Design preview: `design_preview.html`

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

**CRITICAL**: Environment variables must be passed at build/run time using `--dart-define`.

**✅ CORRECT - Use the run scripts:**
```cmd
# Windows
run.bat android

# Linux/Mac
./run.sh android
```

**❌ WRONG - This will fail with "no host specified":**
```bash
flutter run  # Missing environment variables!
```

**Manual method** (if not using run scripts):
```bash
flutter run --dart-define=SUPABASE_URL=<your_url> --dart-define=SUPABASE_ANON_KEY=<your_key> --dart-define=GEMINI_API_KEY=<your_key>
```

The `.env` file is only used by `run.bat`/`run.sh` scripts to automatically load and pass variables.

### Project Structure Note
✅ **FIXED**: Nested Flutter project in `android/` directory has been cleaned up. Current structure is correct:
- `android/` - Android platform configuration (clean, no nested project)
- `ios/` - iOS platform configuration
- `lib/` - Main application code

### Android Build Status
✅ **READY FOR MOBILE**: Android platform is now fully configured and ready to build!

**What's Been Fixed**:
- ✅ All required permissions added (INTERNET, RECORD_AUDIO)
- ✅ AndroidManifest.xml properly configured
- ✅ Cross-platform code refactored (url_launcher integration)
- ✅ Nested project structure cleaned up

**First Time Build**:
If you encounter Gradle cache issues on first build:
1. Ensure all IDEs are closed
2. Run `flutter clean && flutter pub get`
3. If problems persist, delete `C:\Users\<username>\.gradle\caches` directory
4. Try `flutter run` with emulator running

**iOS Build** (requires macOS):
1. Run `cd ios && pod install` to install CocoaPods dependencies
2. Open in Xcode or run `flutter run -d "iPhone 15"`
