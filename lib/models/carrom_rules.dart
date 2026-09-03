import 'game_models.dart';

class TurnOutcome {
  final bool keepTurn;
  final int scoreDelta;
  final bool strikerFoul;
  final bool queenNeedsCover;
  const TurnOutcome({required this.keepTurn, required this.scoreDelta, required this.strikerFoul, required this.queenNeedsCover});
}

/// A compact, app-friendly rule engine. It is intentionally separated from UI
/// so the same logic can later run in online multiplayer validation.
class CarromRules {
  bool queenPocketed = false;
  bool queenCovered = false;

  TurnOutcome resolveTurn(List<CoinKind> pocketed) {
    final strikerFoul = pocketed.contains(CoinKind.striker);
    final queen = pocketed.contains(CoinKind.queen);
    final normalCount = pocketed.where((c) => c == CoinKind.white || c == CoinKind.black).length;
    if (queen) queenPocketed = true;
    if (queenPocketed && normalCount > 0) queenCovered = true;
    final score = normalCount + (queen && queenCovered ? 3 : 0) - (strikerFoul ? 1 : 0);
    return TurnOutcome(
      keepTurn: normalCount > 0 && !strikerFoul,
      scoreDelta: score,
      strikerFoul: strikerFoul,
      queenNeedsCover: queenPocketed && !queenCovered,
    );
  }

  bool get gameFinished => queenPocketed && queenCovered;
}
