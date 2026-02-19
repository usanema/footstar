import 'package:footstars/features/matches/data/models/match_model.dart';

/// Represents the result of a single match from the perspective of one player.
enum PlayerFormResult { win, draw, loss, unknown }

class PlayerMatchResultModel {
  final String matchId;
  final DateTime matchDate;
  final String? playerTeam; // 'A' or 'B'
  final MatchResult matchResult;

  PlayerMatchResultModel({
    required this.matchId,
    required this.matchDate,
    this.playerTeam,
    required this.matchResult,
  });

  factory PlayerMatchResultModel.fromMap(Map<String, dynamic> map) {
    final matchData = map['matches'] as Map<String, dynamic>? ?? {};
    return PlayerMatchResultModel(
      matchId: matchData['id'] as String? ?? '',
      matchDate: matchData['date'] != null
          ? DateTime.parse(matchData['date'] as String).toLocal()
          : DateTime.now(),
      playerTeam: map['team'] as String?,
      matchResult: matchResultFromString(matchData['result'] as String?),
    );
  }

  /// Converts the match result into a personal W/D/L from this player's perspective.
  PlayerFormResult get formResult {
    if (matchResult == MatchResult.DRAW) return PlayerFormResult.draw;
    if (playerTeam == 'A' && matchResult == MatchResult.WIN_A) {
      return PlayerFormResult.win;
    }
    if (playerTeam == 'B' && matchResult == MatchResult.WIN_B) {
      return PlayerFormResult.win;
    }
    if (matchResult == MatchResult.NOT_PLAYED) return PlayerFormResult.unknown;
    return PlayerFormResult.loss;
  }
}
