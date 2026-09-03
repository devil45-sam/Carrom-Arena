import 'dart:math';

class RoomState {
  final String code;
  final List<String> players;
  const RoomState({required this.code, required this.players});
}

/// Free offline room adapter. Replace this adapter later with Firebase,
/// Supabase, or another realtime backend without changing the game screens.
abstract class MultiplayerService {
  Future<RoomState> createRoom(String host);
  Future<RoomState?> joinRoom(String code, String player);
  Future<void> submitMove(String roomCode, Map<String, dynamic> move);
}

class LocalMultiplayerService implements MultiplayerService {
  final Map<String, RoomState> _rooms = {};
  @override
  Future<RoomState> createRoom(String host) async {
    final code = (100000 + Random().nextInt(900000)).toString();
    final room = RoomState(code: code, players: [host]);
    _rooms[code] = room;
    return room;
  }
  @override
  Future<RoomState?> joinRoom(String code, String player) async {
    final room = _rooms[code];
    if (room == null || room.players.length >= 2) return null;
    final next = RoomState(code: room.code, players: [...room.players, player]);
    _rooms[code] = next;
    return next;
  }
  @override
  Future<void> submitMove(String roomCode, Map<String, dynamic> move) async {}
}
