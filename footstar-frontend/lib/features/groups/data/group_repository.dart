import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/group_model.dart';
import 'models/group_member_model.dart';

class GroupRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  Future<void> createGroup({
    required String name,
    required bool isPublic,
    String? city,
    double? latitude,
    double? longitude,
  }) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    final inviteCode = _generateInviteCode();

    // 1. Create Group
    final groupResponse = await _supabase
        .from('groups')
        .insert({
          'name': name,
          'invite_code': inviteCode,
          'owner_id': user.id,
          'is_public': isPublic,
          'city': city,
          'latitude': latitude,
          'longitude': longitude,
        })
        .select()
        .single();

    final group = GroupModel.fromMap(groupResponse);

    // 2. Add Owner as Admin Member
    await _supabase.from('group_members').insert({
      'group_id': group.id,
      'profile_id': user.id,
      'role': 'ADMIN',
      'status': 'ACCEPTED',
    });
  }

  Future<void> joinGroup(String inviteCode) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    // 1. Find Group ID
    final groupResponse = await _supabase
        .from('groups')
        .select('id')
        .eq('invite_code', inviteCode)
        .maybeSingle();

    if (groupResponse == null) {
      throw Exception('Invalid invite code');
    }

    final groupId = groupResponse['id'] as String;

    // 2. Request to Join
    await _supabase.from('group_members').insert({
      'group_id': groupId,
      'profile_id': user.id,
      'role': 'PLAYER',
      'status': 'PENDING',
    });
  }

  Future<List<GroupModel>> getMyGroups() async {
    final user = _supabase.auth.currentUser;
    if (user == null) return [];

    // Fetch groups where I am a member (ACCEPTED)
    final response = await _supabase
        .from('group_members')
        .select('groups(*)')
        .eq('profile_id', user.id)
        .eq('status', 'ACCEPTED');

    final List<GroupModel> groups = [];
    for (final row in response) {
      if (row['groups'] != null) {
        groups.add(GroupModel.fromMap(row['groups']));
      }
    }
    return groups;
  }

  Future<List<GroupModel>> searchGroups(String query) async {
    // Simple search by name or city
    final response = await _supabase
        .from('groups')
        .select()
        .eq('is_public', true)
        .or(
          'name.ilike.%$query%,city.ilike.%$query%',
        ); // case-insensitive search

    return (response as List).map((e) => GroupModel.fromMap(e)).toList();
  }

  Future<List<GroupMemberModel>> getGroupMembers(String groupId) async {
    final response = await _supabase
        .from('group_members')
        .select('*, profiles(*)')
        .eq('group_id', groupId);

    return (response as List).map((e) => GroupMemberModel.fromMap(e)).toList();
  }

  Future<void> requestToJoin(String groupId) async {
    final user = _supabase.auth.currentUser;
    if (user == null) throw Exception('User not logged in');

    try {
      await _supabase.from('group_members').insert({
        'group_id': groupId,
        'profile_id': user.id,
        'role': 'PLAYER',
        'status': 'PENDING',
      });
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw Exception('You are already a member or have a pending request.');
      }
      rethrow;
    }
  }

  Future<void> updateMemberStatus(
    String memberId,
    GroupMemberStatus status,
  ) async {
    await _supabase
        .from('group_members')
        .update({'status': status.name})
        .eq('id', memberId);
  }

  Future<void> removeMember(String memberId) async {
    await _supabase.from('group_members').delete().eq('id', memberId);
  }

  String _generateInviteCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rnd = Random();
    return String.fromCharCodes(
      Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))),
    );
  }
}
