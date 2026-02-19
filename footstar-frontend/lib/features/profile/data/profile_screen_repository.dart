import 'package:supabase_flutter/supabase_flutter.dart';
import '../../onboarding/data/models/profile_model.dart';
import '../data/models/player_match_result_model.dart';

class ProfileScreenRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<ProfileModel?> getProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      if (response == null) return null;
      return ProfileModel.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  /// Returns the last [limit] matches (with results) where the player played (status = IN).
  Future<List<PlayerMatchResultModel>> getLastMatchResults(
    String userId, {
    int limit = 5,
  }) async {
    try {
      final response = await _supabase
          .from('match_players')
          .select('team, matches(id, date, result)')
          .eq('profile_id', userId)
          .eq('status', 'IN')
          .not('matches.result', 'eq', 'NOT_PLAYED')
          .order('matches(date)', ascending: false)
          .limit(limit);

      return (response as List)
          .map((row) => PlayerMatchResultModel.fromMap(row))
          .toList();
    } catch (e) {
      return [];
    }
  }
}
