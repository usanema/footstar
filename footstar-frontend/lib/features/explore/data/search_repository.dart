import 'package:supabase_flutter/supabase_flutter.dart';
import '../../matches/data/models/match_model.dart';
import '../../groups/data/models/group_model.dart';
import '../../onboarding/data/models/profile_model.dart';
import '../../venues/data/models/venue_model.dart';

class SearchRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Search for matches from user's groups by location
  Future<List<MatchModel>> searchMatches(String query) async {
    if (query.isEmpty) return [];

    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    try {
      // First, get user's group IDs
      final memberResponse = await _supabase
          .from('group_members')
          .select('group_id')
          .eq('profile_id', user.id)
          .eq('status', 'ACCEPTED');

      final groupIds = (memberResponse as List)
          .map((e) => e['group_id'] as String)
          .toList();

      if (groupIds.isEmpty) return [];

      // Then search matches in those groups
      final response = await _supabase
          .from('matches')
          .select('*, groups!inner(name)')
          .inFilter('group_id', groupIds)
          .ilike('location', '%$query%')
          .order('date', ascending: false)
          .limit(20);

      return (response as List).map((e) => MatchModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to search matches: $e');
    }
  }

  /// Search for public groups by name or city
  Future<List<GroupModel>> searchGroups(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _supabase
          .from('groups')
          .select()
          .eq('is_public', true)
          .or('name.ilike.%$query%,city.ilike.%$query%')
          .order('created_at', ascending: false)
          .limit(20);

      return (response as List).map((e) => GroupModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to search groups: $e');
    }
  }

  /// Search for players by name or position
  Future<List<ProfileModel>> searchPlayers(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _supabase
          .from('profiles')
          .select()
          .or(
            'first_name.ilike.%$query%,last_name.ilike.%$query%,position_primary.ilike.%$query%,position_secondary.ilike.%$query%',
          )
          .order('first_name', ascending: true)
          .limit(20);

      return (response as List).map((e) => ProfileModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Failed to search players: $e');
    }
  }

  /// Search for venues by name, city or address
  Future<List<VenueModel>> searchVenues(String query) async {
    if (query.isEmpty) return [];

    try {
      final response = await _supabase
          .from('venues')
          .select()
          .or('name.ilike.%$query%,address.ilike.%$query%,city.ilike.%$query%')
          .order('name', ascending: true)
          .limit(20);

      return (response as List).map((e) => VenueModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to search venues: $e');
    }
  }
}
