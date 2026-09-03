# Carrom Arena v1.1

An offline-first Flutter carrom game based on the provided mobile UI designs.

## Included
- Home, Play, Social, Tournament, Profile and Settings screens
- Practice mode, VS AI and Pass & Play UI
- Real-time drag aim, striker power, coin collisions, wall bounce, friction and pockets
- Basic turn retention, striker foul penalty, queen-cover tracking and match completion
- Easy/Normal/Hard/Expert AI entry point
- Generated local sound effects
- Flutter haptic feedback
- Saved gameplay settings using SharedPreferences
- Android platform project structure
- Multiplayer service interface plus local room implementation, ready to swap for a realtime backend

## Free tools used
- Flutter
- Dart
- Android SDK / Gradle
- audioplayers package
- shared_preferences package

## Build Android
1. Install the Flutter SDK and Android SDK.
2. Run `flutter doctor` and fix Android setup issues.
3. In this project run:
   `flutter pub get`
   `flutter run`
4. Release APK:
   `flutter build apk --release`

The output is normally under `build/app/outputs/flutter-apk/`.

## Multiplayer later
Keep the game rules in `lib/models/carrom_rules.dart`. Replace `LocalMultiplayerService` with a Firebase/Supabase realtime adapter and validate moves server-side before ranked play.


See ONLINE_SETUP.md for the free Firebase multiplayer setup.
