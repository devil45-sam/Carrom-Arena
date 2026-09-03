# Free Online Multiplayer Setup
1. Run `flutter pub get`.
2. Create a free Firebase project.
3. Enable Authentication > Anonymous.
4. Create Cloud Firestore.
5. Install FlutterFire CLI: `dart pub global activate flutterfire_cli`.
6. Run `flutterfire configure`.
7. Initialize Firebase before `runApp()`:
   `WidgetsFlutterBinding.ensureInitialized();`
   `await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);`
8. Import `firebase_core` and generated `firebase_options.dart`.
9. Deploy `firebase/firestore.rules`.
10. Test with two devices: one creates a room and the other joins with the 6-digit code.

This v1.2 upgrade provides room creation, joining, live Firestore room state, anonymous sign-in, two-player status, turn ownership, and move submission. The existing carrom physics remains local and should be connected to synchronized move validation for production online play.
