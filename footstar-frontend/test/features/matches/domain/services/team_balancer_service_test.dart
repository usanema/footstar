import 'package:flutter_test/flutter_test.dart';
import 'package:footstars/features/matches/data/models/match_player_model.dart';
import 'package:footstars/features/onboarding/data/models/profile_model.dart';
import 'package:footstars/features/matches/domain/services/team_balancer_service.dart';

void main() {
  group('TeamBalancerService', () {
    late TeamBalancerService service;

    setUp(() {
      service = TeamBalancerService();
    });

    ProfileModel createProfile({
      required String id,
      int speed = 1,
      int technique = 1,
      int matchesPlayed = 0,
      int matchesWon = 0,
      int goalsScored = 0,
    }) {
      return ProfileModel(
        id: id,
        firstName: 'Player',
        lastName: id,
        speed: speed,
        technique: technique,
        strMatchesPlayed: matchesPlayed,
        strMatchesWon: matchesWon,
        strGoalsScored: goalsScored,
      );
    }

    MatchPlayerModel createPlayer(String id, ProfileModel profile) {
      return MatchPlayerModel(
        id: id,
        matchId: 'match_1',
        profileId: profile.id,
        status: PlayerStatus.IN,
        hasCar: false,
        carSeats: 0,
        profile: profile,
      );
    }

    test('should distribute 4 players evenly (A-B-B-A)', () {
      // 4 Players with distinct skill levels to ensure sorting is predictable
      // P1: Best (High stats)
      // P2: Good
      // P3: Medium
      // P4: Weak
      final p1 = createPlayer(
        '1',
        createProfile(id: '1', technique: 5, matchesPlayed: 10, matchesWon: 10),
      ); // Score ~ high
      final p2 = createPlayer(
        '2',
        createProfile(id: '2', technique: 4, matchesPlayed: 10, matchesWon: 8),
      );
      final p3 = createPlayer(
        '3',
        createProfile(id: '3', technique: 3, matchesPlayed: 10, matchesWon: 5),
      );
      final p4 = createPlayer(
        '4',
        createProfile(id: '4', technique: 1, matchesPlayed: 10, matchesWon: 0),
      );

      final players = [p4, p2, p1, p3]; // Unsorted input

      final result = service.balanceTeams(players);

      // Sort by original ID to check assignments easily, or check by ID lookups
      final assignedA = result
          .where((p) => p.team == Team.A)
          .map((p) => p.id)
          .toList();
      final assignedB = result
          .where((p) => p.team == Team.B)
          .map((p) => p.id)
          .toList();

      // Expected Order by Score: P1, P2, P3, P4
      // A-B-B-A pattern:
      // P1 -> A
      // P2 -> B
      // P3 -> B
      // P4 -> A

      expect(assignedA, containsAll(['1', '4']));
      expect(assignedB, containsAll(['2', '3']));
    });

    test('should handle empty list', () {
      final result = service.balanceTeams([]);
      expect(result, isEmpty);
    });
  });
}
