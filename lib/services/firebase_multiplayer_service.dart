import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class OnlineRoom {
  final String code, hostId, status, turnPlayerId;
  final List<String> players;
  final Map<String, dynamic> board;
  const OnlineRoom({required this.code, required this.hostId, required this.status, required this.players, required this.turnPlayerId, required this.board});
  factory OnlineRoom.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? {};
    return OnlineRoom(code: doc.id, hostId: d['hostId'] ?? '', status: d['status'] ?? 'waiting',
      players: List<String>.from(d['players'] ?? const []), turnPlayerId: d['turnPlayerId'] ?? '',
      board: Map<String, dynamic>.from(d['board'] ?? const {}));
  }
}

class FirebaseMultiplayerService {
  FirebaseMultiplayerService._();
  static final instance = FirebaseMultiplayerService._();
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  Future<String> ensurePlayer() async {
    if (_auth.currentUser == null) await _auth.signInAnonymously();
    return _auth.currentUser!.uid;
  }
  String _newCode() => (100000 + Random.secure().nextInt(900000)).toString();

  Future<OnlineRoom> createRoom() async {
    final uid = await ensurePlayer();
    for (var i=0; i<5; i++) {
      final code = _newCode();
      final ref = _db.collection('rooms').doc(code);
      if (!(await ref.get()).exists) {
        await ref.set({'hostId': uid, 'players': [uid], 'status': 'waiting', 'turnPlayerId': uid,
          'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
          'board': {'score1': 0, 'score2': 0, 'lastMove': null}});
        return OnlineRoom.fromDoc(await ref.get());
      }
    }
    throw StateError('Unable to create room');
  }

  Stream<OnlineRoom?> watchRoom(String code) => _db.collection('rooms').doc(code).snapshots().map(
    (doc) => doc.exists ? OnlineRoom.fromDoc(doc) : null);

  Future<void> joinRoom(String code) async {
    final uid = await ensurePlayer();
    final ref = _db.collection('rooms').doc(code.trim());
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw StateError('Room not found');
      final d = snap.data()!;
      final players = List<String>.from(d['players'] ?? const []);
      if (!players.contains(uid)) {
        if (players.length >= 2) throw StateError('Room is full');
        players.add(uid);
      }
      tx.update(ref, {'players': players, 'status': players.length >= 2 ? 'active' : 'waiting',
        'updatedAt': FieldValue.serverTimestamp()});
    });
  }

  Future<void> submitMove(String code, Map<String, dynamic> move) async {
    final uid = await ensurePlayer();
    final ref = _db.collection('rooms').doc(code);
    await _db.runTransaction((tx) async {
      final snap = await tx.get(ref);
      if (!snap.exists) throw StateError('Room not found');
      final d = snap.data()!;
      if (d['turnPlayerId'] != uid) throw StateError('Not your turn');
      final players = List<String>.from(d['players'] ?? const []);
      final next = players.firstWhere((id) => id != uid, orElse: () => uid);
      tx.update(ref, {'turnPlayerId': next, 'board': {'lastMove': {...move, 'playerId': uid}},
        'updatedAt': FieldValue.serverTimestamp()});
    });
  }

  Future<void> leaveRoom(String code) async {
    final uid = await ensurePlayer();
    await _db.collection('rooms').doc(code).update({'players': FieldValue.arrayRemove([uid]),
      'status': 'waiting', 'updatedAt': FieldValue.serverTimestamp()});
  }
}
