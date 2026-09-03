import 'dart:ui';

enum CoinKind { white, black, queen, striker }

class CarromCoin {
  CarromCoin({required this.id, required this.kind, required this.position, required this.radius, this.velocity = Offset.zero, this.pocketed = false});
  final String id;
  final CoinKind kind;
  Offset position;
  Offset velocity;
  final double radius;
  bool pocketed;
  bool get isStriker => kind == CoinKind.striker;
  int get points => switch (kind) { CoinKind.queen => 3, CoinKind.striker => 0, _ => 1 };
}

class GameResult {
  final int playerScore;
  final int opponentScore;
  final String message;
  const GameResult(this.playerScore, this.opponentScore, this.message);
}
