import '../../data/models/match_player_model.dart';

class TeamBalancerService {
  // Weights (The PhD Approach)
  static const double _weightTechnique = 1.0;
  static const double _weightPhysicality = 0.8;
  static const double _weightWinningMentality = 1.4;
  static const double _weightGoalThreat = 0.6;

  /// Balances players into two teams (A and B) using Greedy Multi-Objective Partitioning.
  /// Returns a list of players with updated [Team] assignments.
  List<MatchPlayerModel> balanceTeams(List<MatchPlayerModel> players) {
    if (players.isEmpty) return [];

    // 1. Filter only valid players (with profiles)
    final validPlayers = players.where((p) => p.profile != null).toList();
    if (validPlayers.isEmpty) return players;

    // 2. Normalize and Calculate Power Scores
    final scoredPlayers = _calculatePowerScores(validPlayers);

    // 3. Sort by Power Score Descending
    scoredPlayers.sort((a, b) => b.score.compareTo(a.score));

    // 4. Partition using Modified Snake Draft (A-B-B-A...)
    // Sequence: A, B, B, A, A, B, B, A ...
    final List<MatchPlayerModel> balancedList = [];

    // We'll use a local list to keep track of assignments before returning
    // Map to store assignment: true = Team A, false = Team B
    Map<String, Team> assignments = {};

    for (int i = 0; i < scoredPlayers.length; i++) {
      final playerWithScore = scoredPlayers[i];
      final Team team;

      // Zero-based index logic for A-B-B-A pattern
      // Pattern repeats every 4: 0->A, 1->B, 2->B, 3->A
      final int patternIndex = i % 4;
      if (patternIndex == 0 || patternIndex == 3) {
        team = Team.A;
      } else {
        team = Team.B;
      }

      assignments[playerWithScore.player.id] = team;
    }

    // 5. Construct Result List
    for (var p in players) {
      if (assignments.containsKey(p.id)) {
        balancedList.add(p.copyWith(team: assignments[p.id]));
      } else {
        // Keep original or set to null if not in valid list
        balancedList.add(p);
      }
    }

    return balancedList;
  }

  List<_PlayerScore> _calculatePowerScores(List<MatchPlayerModel> players) {
    if (players.isEmpty) return [];

    // Find Max/Min for Normalization
    // Skills are fixed 1-5, so Min=1, Max=5 (known bounds).
    // Stats (Wins/Goals) are dynamic, so we find actual min/max in the set.

    double maxWinRate = 0.0;
    double maxGoalRate = 0.0;

    for (var p in players) {
      final profile = p.profile!;
      if (profile.strMatchesPlayed > 0) {
        final winRate = profile.strMatchesWon / profile.strMatchesPlayed;
        final goalRate = profile.strGoalsScored / profile.strMatchesPlayed;
        if (winRate > maxWinRate) maxWinRate = winRate;
        if (goalRate > maxGoalRate) maxGoalRate = goalRate;
      }
    }

    // Avoid division by zero if all are 0
    if (maxWinRate == 0) maxWinRate = 1.0;
    if (maxGoalRate == 0) maxGoalRate = 1.0;

    return players.map((p) {
      final profile = p.profile!;

      // --- 1. Technique/Skills (Weight 1.0) ---
      // Defined: Technique, Defense, Shooting, Tactics, Vision, Charisma
      // Range 1-5. Normalize to 0-1. Average them first?
      // Or sum them and normalize the sum? Let's average the normalized values.
      // (Value - 1) / 4 gives 0.0 to 1.0 range.
      final double normTech = (profile.technique - 1) / 4;
      final double normDef = (profile.defense - 1) / 4;
      final double normShoot = (profile.shooting - 1) / 4;
      final double normTactics = (profile.tactics - 1) / 4;
      final double normVision = (profile.vision - 1) / 4;
      final double normCharisma = (profile.charisma - 1) / 4;

      final double avgTechniqueScore =
          (normTech +
              normDef +
              normShoot +
              normTactics +
              normVision +
              normCharisma) /
          6;

      // --- 2. Physicality (Weight 0.8) ---
      // Defined: Speed, Stamina
      final double normSpeed = (profile.speed - 1) / 4;
      final double normStamina = (profile.stamina - 1) / 4;

      final double avgPhysicalityScore = (normSpeed + normStamina) / 2;

      // --- 3. Winning Mentality (Weight 1.4) ---
      double winRate = 0.0;
      if (profile.strMatchesPlayed > 0) {
        winRate = profile.strMatchesWon / profile.strMatchesPlayed;
      }
      // Normalize against the best player in this group (The Winner Effect normalization logic)
      final double normWinScore = winRate / maxWinRate;

      // --- 4. Goal Threat (Weight 0.6) ---
      double goalRate = 0.0;
      if (profile.strMatchesPlayed > 0) {
        goalRate = profile.strGoalsScored / profile.strMatchesPlayed;
      }
      final double normGoalScore = goalRate / maxGoalRate;

      // --- TOTAL POWER SCORE ---
      final double totalScore =
          (avgTechniqueScore * _weightTechnique) +
          (avgPhysicalityScore * _weightPhysicality) +
          (normWinScore * _weightWinningMentality) +
          (normGoalScore * _weightGoalThreat);

      return _PlayerScore(p, totalScore);
    }).toList();
  }
}

class _PlayerScore {
  final MatchPlayerModel player;
  final double score;

  _PlayerScore(this.player, this.score);
}
