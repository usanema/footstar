import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/venue_model.dart';
import '../../matches/data/models/match_model.dart';

class VenueRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Fetch all venues, optionally filtered by query (name/city/address).
  Future<List<VenueModel>> fetchVenues({String? query}) async {
    try {
      var request = _supabase.from('venues').select();

      if (query != null && query.isNotEmpty) {
        request = request.or(
          'name.ilike.%$query%,address.ilike.%$query%,city.ilike.%$query%',
        );
      }

      final response = await request.order('name', ascending: true);
      return (response as List).map((e) => VenueModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch venues: $e');
    }
  }

  /// Fetch a single venue by id.
  Future<VenueModel?> fetchVenueById(String id) async {
    try {
      final response = await _supabase
          .from('venues')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) return null;
      return VenueModel.fromMap(response);
    } catch (e) {
      throw Exception('Failed to fetch venue: $e');
    }
  }

  /// Fetch upcoming matches at a given venue (future dates only).
  Future<List<MatchModel>> fetchUpcomingMatches(String venueId) async {
    try {
      final now = DateTime.now().toUtc().toIso8601String();
      final response = await _supabase
          .from('matches')
          .select('*, groups!inner(name)')
          .eq('venue_id', venueId)
          .gte('date', now)
          .order('date', ascending: true)
          .limit(10);
      return (response as List).map((e) => MatchModel.fromMap(e)).toList();
    } catch (e) {
      throw Exception('Failed to fetch upcoming matches: $e');
    }
  }
}
