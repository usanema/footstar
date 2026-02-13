import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/match_model.dart';
import 'models/match_player_model.dart';

class MatchRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createMatch({
    required String groupId,
    required DateTime date,
    required String location,
    required int maxPlayers,
    String? description,
    bool isRecurring = false,
    String? recurrencePattern,
  }) async {
    await _supabase.from('matches').insert({
      'group_id': groupId,
      'date': date.toIso8601String(),
      'location': location,
      'max_players': maxPlayers,
      'description': description,
      'is_recurring': isRecurring,
      'recurrence_pattern': recurrencePattern,
    });
  }

  Future<List<MatchModel>> getGroupMatches(String groupId) async {
    final response = await _supabase
        .from('matches')
        .select()
        .eq('group_id', groupId)
        .gte('date', DateTime.now().toIso8601String())
        .order('date', ascending: true);

    return (response as List).map((e) => MatchModel.fromMap(e)).toList();
  }

  Future<MatchModel> getMatch(String matchId) async {
    final response = await _supabase
        .from('matches')
        .select()
        .eq('id', matchId)
        .single();
    return MatchModel.fromMap(response);
  }

  Future<List<MatchPlayerModel>> getMatchPlayers(String matchId) async {
    final response = await _supabase
        .from('match_players')
        .select('*, profiles(*)')
        .eq('match_id', matchId);

    return (response as List).map((e) => MatchPlayerModel.fromMap(e)).toList();
  }

  Future<void> updatePlayerStatus({
    required String matchId,
    required PlayerStatus status,
    bool? hasCar,
    int? carSeats,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // Check if record exists
    final existingHelper = await _supabase
        .from('match_players')
        .select()
        .eq('match_id', matchId)
        .eq('profile_id', user.id)
        .maybeSingle();

    if (existingHelper != null) {
      await _supabase
          .from('match_players')
          .update({
            'status': status.name,
            if (hasCar != null) 'has_car': hasCar,
            if (carSeats != null) 'car_seats': carSeats,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('id', existingHelper['id']);
    } else {
      await _supabase.from('match_players').insert({
        'match_id': matchId,
        'profile_id': user.id,
        'status': status.name,
        'has_car': hasCar ?? false,
        'car_seats': carSeats ?? 0,
      });
    }
  }

  Future<void> updatePlayerPosition({
    required String matchPlayerId,
    required double? x,
    required double? y,
  }) async {
    await _supabase
        .from('match_players')
        .update({'pitch_x': x, 'pitch_y': y})
        .eq('id', matchPlayerId);
  }

  Future<void> updatePlayerTeam(String matchPlayerId, Team team) async {
    await _supabase
        .from('match_players')
        .update({'team': team.name})
        .eq('id', matchPlayerId);
  }

  Future<List<MatchModel>> getMyUpcomingMatches() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    final response = await _supabase
        .from('match_players')
        .select('matches!inner(*, groups(name))')
        .eq('profile_id', user.id)
        .gte('matches.date', DateTime.now().toIso8601String());
    // .order('matches(date)', ascending: true); // Complex ordering, sorting in Dart for now

    final matches = (response as List).map((e) {
      return MatchModel.fromMap(e['matches']);
    }).toList();

    matches.sort((a, b) => a.date.compareTo(b.date));

    return matches;
  }
}
