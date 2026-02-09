import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/profile_model.dart'; // Ensure correct import path

class ProfileRepository {
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
      // Handle error or return null
      return null;
    }
  }

  Future<void> createProfile(ProfileModel profile) async {
    await _supabase.from('profiles').insert(profile.toJson());
  }

  Future<void> updateProfile(ProfileModel profile) async {
    await _supabase
        .from('profiles')
        .update(profile.toJson())
        .eq('id', profile.id);
  }
}
