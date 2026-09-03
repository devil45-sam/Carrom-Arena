# CARROM ARENA: FINAL FREE CONNECTION PLAN

## What is completed in this source
- 12+ Flutter UI screens
- playable local physics prototype
- practice mode
- VS AI
- private online room flow
- Firebase anonymous authentication architecture
- Firestore room synchronization
- online lobby
- turn validation foundation
- settings, sound and haptics architecture
- backend starter for authoritative Socket.IO matches
- Android project structure

## One-time connections you must do
### 1. Firebase (free Spark plan)
Create Firebase project, enable Anonymous Authentication, create Firestore, then run:
`dart pub global activate flutterfire_cli`
`flutterfire configure`
This replaces the placeholder `lib/services/firebase_options.dart` with your real configuration.

### 2. Deploy Firestore rules
Use `firebase/firestore.rules`.

### 3. Authoritative server
The `server/` folder is included. Deploy it to a host with persistent WebSocket support. Keep this separate from serverless frontend hosting.

### 4. Connect production multiplayer
Firestore should handle profiles, friends, rooms, history, leaderboard and tournaments.
The Socket.IO server should handle active-match input, sequence validation, turn ownership, reconnect and authoritative shot results.

## Honest status
The app source is not yet a finished production game. The remaining work is integrating the existing physics state into the authoritative server so every online client renders server-approved coin positions. That requires a real hosted server URL and Firebase project configuration, which cannot be invented or safely embedded without your accounts.
