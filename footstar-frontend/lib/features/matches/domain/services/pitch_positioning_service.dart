import '../../data/models/match_player_model.dart';

class PitchPositioningService {
  // Standard 7-a-side coords (HORIZONTAL)
  // Team A (Left Side) x < 0.5
  static const _posA_GK = _Point(0.05, 0.5);
  static const _posA_DEF_L = _Point(0.2, 0.2); // Top-Left
  static const _posA_DEF_C = _Point(0.2, 0.5);
  static const _posA_DEF_R = _Point(0.2, 0.8); // Bottom-Left
  static const _posA_MID_L = _Point(0.35, 0.3);
  static const _posA_MID_R = _Point(0.35, 0.7);
  static const _posA_ATT = _Point(0.45, 0.5);

  // Team B (Right Side) x > 0.5
  static const _posB_GK = _Point(0.95, 0.5);
  static const _posB_DEF_L = _Point(
    0.8,
    0.2,
  ); // Top-Right (relative to pitch view top)
  static const _posB_DEF_C = _Point(0.8, 0.5);
  static const _posB_DEF_R = _Point(0.8, 0.8); // Bottom-Right
  static const _posB_MID_L = _Point(0.65, 0.3);
  static const _posB_MID_R = _Point(0.65, 0.7);
  static const _posB_ATT = _Point(0.55, 0.5);

  // Pool of slots for generic filling
  static const List<_Point> _slotsA = [
    _posA_GK,
    _posA_DEF_C,
    _posA_ATT,
    _posA_MID_L,
    _posA_MID_R,
    _posA_DEF_L,
    _posA_DEF_R,
  ];

  static const List<_Point> _slotsB = [
    _posB_GK,
    _posB_DEF_C,
    _posB_ATT,
    _posB_MID_L,
    _posB_MID_R,
    _posB_DEF_L,
    _posB_DEF_R,
  ];

  List<MatchPlayerModel> assignPositions(List<MatchPlayerModel> players) {
    List<MatchPlayerModel> updatedPlayers = [];
    List<_Point> occupiedA = [];
    List<_Point> occupiedB = [];

    // Separate by team
    final teamA = players.where((p) => p.team == Team.A).toList();
    final teamB = players.where((p) => p.team == Team.B).toList();

    // Assign A
    updatedPlayers.addAll(_assignTeam(teamA, _slotsA, occupiedA, true));
    // Assign B
    updatedPlayers.addAll(_assignTeam(teamB, _slotsB, occupiedB, false));

    return updatedPlayers;
  }

  List<MatchPlayerModel> _assignTeam(
    List<MatchPlayerModel> teamPlayers,
    List<_Point> allSlots,
    List<_Point> occupied,
    bool isTeamA,
  ) {
    List<MatchPlayerModel> result = [];
    List<MatchPlayerModel> unassigned = [];

    // 1. Try Preferences
    for (var player in teamPlayers) {
      if (player.profile == null) {
        unassigned.add(player);
        continue;
      }

      final p1 = player.profile!.positionPrimary;
      final p2 = player.profile!.positionSecondary;
      final p3 = player.profile!.positionTertiary;

      _Point? assignedPoint;

      // Try Primary
      if (p1 != null)
        assignedPoint = _findSlotForRole(p1, allSlots, occupied, isTeamA);

      // Try Secondary
      if (assignedPoint == null && p2 != null)
        assignedPoint = _findSlotForRole(p2, allSlots, occupied, isTeamA);

      // Try Tertiary
      if (assignedPoint == null && p3 != null)
        assignedPoint = _findSlotForRole(p3, allSlots, occupied, isTeamA);

      if (assignedPoint != null) {
        occupied.add(assignedPoint);
        result.add(
          player.copyWith(pitchX: assignedPoint.x, pitchY: assignedPoint.y),
        );
      } else {
        unassigned.add(player);
      }
    }

    // 2. Fill Remaining
    for (var player in unassigned) {
      // Find first free slot from allSlots
      _Point? freeSlot;
      for (var slot in allSlots) {
        if (!_isOccupied(slot, occupied)) {
          freeSlot = slot;
          break;
        }
      }

      if (freeSlot != null) {
        occupied.add(freeSlot);
        result.add(player.copyWith(pitchX: freeSlot.x, pitchY: freeSlot.y));
      } else {
        // Overflow? Just put them on sidelines or center of their half
        double splitX = isTeamA ? 0.25 : 0.75;
        result.add(player.copyWith(pitchX: splitX, pitchY: 0.9));
      }
    }

    return result;
  }

  _Point? _findSlotForRole(
    String role,
    List<_Point> slots,
    List<_Point> occupied,
    bool isTeamA,
  ) {
    List<_Point> candidateSlots = [];

    final r = role.toUpperCase();

    if (r.contains('GK') || r.contains('BRAMKARZ')) {
      candidateSlots.add(isTeamA ? _posA_GK : _posB_GK);
    } else if (r.contains('DEF') ||
        r.contains('CB') ||
        r.contains('LB') ||
        r.contains('RB') ||
        r.contains('OBROŃCA')) {
      candidateSlots.add(isTeamA ? _posA_DEF_C : _posB_DEF_C);
      candidateSlots.add(isTeamA ? _posA_DEF_L : _posB_DEF_L);
      candidateSlots.add(isTeamA ? _posA_DEF_R : _posB_DEF_R);
    } else if (r.contains('MID') ||
        r.contains('CM') ||
        r.contains('POMOCNIK')) {
      candidateSlots.add(isTeamA ? _posA_MID_L : _posB_MID_L);
      candidateSlots.add(isTeamA ? _posA_MID_R : _posB_MID_R);
    } else if (r.contains('ATT') ||
        r.contains('ST') ||
        r.contains('FW') ||
        r.contains('NAPASTNIK')) {
      candidateSlots.add(isTeamA ? _posA_ATT : _posB_ATT);
    }

    for (var slot in candidateSlots) {
      if (!_isOccupied(slot, occupied)) return slot;
    }

    return null;
  }

  bool _isOccupied(_Point p, List<_Point> occupied) {
    // fuzzy match?
    for (var o in occupied) {
      if ((o.x - p.x).abs() < 0.01 && (o.y - p.y).abs() < 0.01) return true;
    }
    return false;
  }
}

class _Point {
  final double x;
  final double y;
  const _Point(this.x, this.y);
}
