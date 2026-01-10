# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Flutter mobile application for the Psychology career at UNAM's FES Iztacala SUAyED system. It provides news, events, knowledge areas, teacher information, bookmarks, and push notifications to students.

## Development Commands

### Setup
```bash
flutter pub get          # Install dependencies
```

### Running
```bash
flutter run              # Run on connected device or emulator
flutter run -d <id>      # Run on specific device
```

### Building
```bash
flutter build apk        # Build Android APK (release)
flutter build ios        # Build iOS app
flutter build web        # Build web version
```

### Asset Generation
```bash
dart run flutter_launcher_icons:generate -f flutter_launcher_icons.yaml   # Generate app icons
dart run flutter_native_splash:create --path=flutter_native_splash.yaml   # Generate splash screen
```

### Code Quality
```bash
dart analyze             # Run linter
flutter clean            # Clean build artifacts
```

## Architecture

### State Management
- Uses **Provider** package (v6.1.2) for state management
- Two main providers:
  - `HomeProvider` (lib/providers/home_provider.dart): Manages posts/news data
  - `BookmarkProvider` (lib/providers/bookmark_provider.dart): Manages bookmarked posts
- Simple ChangeNotifier pattern without complex architecture

### Service Layer
The application follows a clean separation between API calls and business logic:

- **SuayedServices** (lib/services/suayed_service.dart): High-level API operations for posts
- **HttpService** (lib/services/http_service.dart): Low-level Dio configuration with caching
  - Base URL: `https://suayed.iztacala.unam.mx/`
  - Request timeouts: 5s connect, 3s receive
  - Cache policy: 7-day max stale with MemCacheStore
  - Uses DioCacheInterceptor for request-level caching

- **FirebaseService** (lib/services/firebase_service.dart): Firebase initialization and analytics
- **LocalService** (lib/services/local_service.dart): Local storage operations
- **PushNotificationService** (lib/utils/messaging_push.dart): Firebase Cloud Messaging setup

### Data Models
Located in lib/models/:
- `PostModel`: News/post data from WordPress API
- `StoragePostModel`: Bookmark data stored locally
- `AreaModel`: Knowledge area information
- `TeacherModel`: Professor information

### Navigation
Routes are centralized in lib/routes/routes.dart:
- home: HomeScreen
- teachers: TeachersPage
- areas: AreasPage
- bookmarks: BookmarksPage
- privacy: PrivacyNotice
- about: AboutScreen

### UI Structure
- **lib/screens/**: Application screens/pages
- **lib/widgets/**: Reusable components (AppDrawer, Avatar, ThumbnailImage, etc.)
- **lib/theme.dart**: Material Design theme configuration (primary color: #d81b60)
- **lib/utils/app_constants.dart**: Global constants and scaffoldMessengerKey

## Key Dependencies

- **flutter_widget_from_html_core**: Renders HTML content from WordPress posts
- **firebase_messaging**: Push notifications (v16.0.3)
- **firebase_analytics**: App analytics
- **dio**: HTTP client with timeout handling
- **dio_cache_interceptor**: Intelligent request caching
- **localstore**: Local persistence for bookmarks
- **shared_preferences**: Simple key-value storage
- **provider**: State management
- **cached_network_image**: Image caching and display

## Firebase Configuration

The app is connected to Firebase project: `app-de-psicologia-suayed`

Configuration files:
- Android: android/app/google-services.json
- iOS: ios/Runner/GoogleService-Info.plist
- macOS: macos/Runner/GoogleService-Info.plist
- Dart: lib/firebase_options.dart (auto-generated)

## Common Patterns

### Adding a New Screen
1. Create a StatelessWidget or StatefulWidget in lib/screens/
2. Define a `routeName` constant in the screen class
3. Add route to lib/routes/routes.dart
4. Add icon/menu item to AppDrawer (lib/widgets/app_drawer.dart)

### Fetching Data from API
1. Add method to SuayedServices (lib/services/suayed_service.dart)
2. Create corresponding provider if needed (lib/providers/)
3. Use provider in screen with Consumer/context.watch()

### Storing Bookmarks
- Use BookmarkProvider (lib/providers/bookmark_provider.dart)
- Data persists via LocalService which uses localstore package
- StoragePostModel maps to storage format, PostModel maps to API format

### Handling Errors
- Services throw exceptions with user-friendly messages in Spanish
- Providers catch exceptions and store in _errorMessage
- UI displays errors via ScaffoldMessenger with showSnackBar (lib/widgets/show_snack_bar.dart)

## Assets & Resources

- Assets location: assets/ directory
- Images: assets/images/
- Icons: assets/icon/
- JSON data: assets/areas.json, assets/teachers.json (local fallback data)

## Important Notes

- API base URL is defined in Constants.uriHttp (lib/utils/app_constants.dart)
- All error messages are in Spanish (es-MX)
- Image placeholder: assets/images/no_image.jpg
- Main app color: #d81b60 (defined in theme)
- Flutter SDK requirement: ^3.9.2
