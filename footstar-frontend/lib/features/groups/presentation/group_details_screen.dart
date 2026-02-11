import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/group_repository.dart';
import '../data/models/group_model.dart';
import '../data/models/group_member_model.dart';
import '../../matches/presentation/create_match_screen.dart';
import '../../matches/data/match_repository.dart';
import '../../matches/data/models/match_model.dart';
import '../../matches/presentation/match_details_screen.dart';

class GroupDetailsScreen extends StatefulWidget {
  final GroupModel group;

  const GroupDetailsScreen({super.key, required this.group});

  @override
  State<GroupDetailsScreen> createState() => _GroupDetailsScreenState();
}

class _GroupDetailsScreenState extends State<GroupDetailsScreen> {
  final GroupRepository _groupRepository = GroupRepository();
  final MatchRepository _matchRepository = MatchRepository();
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;

  List<GroupMemberModel>? _members;
  List<MatchModel>? _matches;
  bool _isLoading = true;
  GroupMemberModel? _currentUserMember;

  @override
  void initState() {
    super.initState();
    _fetchGroupDetails();
  }

  Future<void> _fetchGroupDetails() async {
    setState(() => _isLoading = true);
    try {
      final members = await _groupRepository.getGroupMembers(widget.group.id);
      final matches = await _matchRepository.getGroupMatches(widget.group.id);
      setState(() {
        _members = members;
        _matches = matches;
        // Check current user status
        try {
          _currentUserMember = members.firstWhere(
            (m) => m.profileId == _currentUserId,
          );
        } catch (e) {
          _currentUserMember = null;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading members: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _joinGroup() async {
    try {
      await _groupRepository.requestToJoin(widget.group.id);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Request sent!')));
      _fetchGroupDetails();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error joining group: $e')));
    }
  }

  Future<void> _updateMemberStatus(
    String memberId,
    GroupMemberStatus status,
  ) async {
    try {
      if (status == GroupMemberStatus.REJECTED) {
        await _groupRepository.removeMember(memberId);
      } else {
        await _groupRepository.updateMemberStatus(memberId, status);
      }
      _fetchGroupDetails();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
    }
  }

  bool get _isAdmin {
    return _currentUserMember?.role == GroupRole.ADMIN &&
        _currentUserMember?.status == GroupMemberStatus.ACCEPTED;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.group.name)),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchGroupDetails,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                    if (_isAdmin) _buildAdminSection(),
                    const SizedBox(height: 24),
                    _buildMatchesSection(),
                    const SizedBox(height: 24),
                    _buildMembersList(),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.group.name,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  widget.group.city ?? 'Unknown location',
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Members: ${_members?.where((m) => m.status == GroupMemberStatus.ACCEPTED).length ?? 0}',
            ),
            if (widget.group.isPublic)
              const Chip(
                label: Text('Public Group'),
                backgroundColor: Colors.greenAccent,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    if (_currentUserMember == null) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _joinGroup,
          child: const Text('Request to Join'),
        ),
      );
    } else if (_currentUserMember!.status == GroupMemberStatus.PENDING) {
      return const SizedBox(
        width: double.infinity,
        child: Card(
          color: Colors.orangeAccent,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Your request is pending approval.',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildAdminSection() {
    final pendingMembers =
        _members
            ?.where((m) => m.status == GroupMemberStatus.PENDING)
            .toList() ??
        [];

    if (pendingMembers.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pending Requests',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: pendingMembers.length,
          itemBuilder: (context, index) {
            final member = pendingMembers[index];
            return Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: member.profile?.avatarUrl != null
                      ? NetworkImage(member.profile!.avatarUrl!)
                      : null,
                  child: member.profile?.avatarUrl == null
                      ? Text((member.profile?.firstName ?? '?')[0])
                      : null,
                ),
                title: Text(
                  '${member.profile?.firstName ?? 'Unknown'} ${member.profile?.lastName ?? ''}',
                ),
                subtitle: Text(
                  'Positions: ${member.profile?.positionPrimary ?? '-'}',
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.check, color: Colors.green),
                      onPressed: () => _updateMemberStatus(
                        member.id,
                        GroupMemberStatus.ACCEPTED,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      onPressed: () => _updateMemberStatus(
                        member.id,
                        GroupMemberStatus.REJECTED,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMembersList() {
    final acceptedMembers =
        _members
            ?.where((m) => m.status == GroupMemberStatus.ACCEPTED)
            .toList() ??
        [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Members',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        if (acceptedMembers.isEmpty)
          const Text('No members yet.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: acceptedMembers.length,
            itemBuilder: (context, index) {
              final member = acceptedMembers[index];
              final isMe = member.profileId == _currentUserId;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: member.profile?.avatarUrl != null
                      ? NetworkImage(member.profile!.avatarUrl!)
                      : null,
                  child: member.profile?.avatarUrl == null
                      ? Text((member.profile?.firstName ?? '?')[0])
                      : null,
                ),
                title: Text(
                  '${member.profile?.firstName ?? 'Unknown'} ${member.profile?.lastName ?? ''} ${isMe ? '(You)' : ''}',
                ),
                subtitle: Text('Role: ${member.role.name}'),
                trailing: member.role == GroupRole.ADMIN
                    ? const Icon(Icons.star, color: Colors.amber)
                    : null,
              );
            },
          ),
      ],
    );
  }

  Widget _buildMatchesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Upcoming Matches',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            if (_isAdmin)
              IconButton(
                icon: const Icon(Icons.add_circle, color: Colors.blue),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          CreateMatchScreen(groupId: widget.group.id),
                    ),
                  ).then((val) {
                    if (val == true) _fetchGroupDetails();
                  });
                },
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (_matches?.isEmpty ?? true)
          const Text('No upcoming matches.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _matches!.length,
            itemBuilder: (context, index) {
              final match = _matches![index];
              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.sports_soccer,
                    color: Colors.green,
                    size: 32,
                  ),
                  title: Text(
                    '${match.date.day}/${match.date.month} ${match.date.hour}:${match.date.minute.toString().padLeft(2, '0')}',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(match.location),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            MatchDetailsScreen(match: match, isAdmin: _isAdmin),
                      ),
                    );
                  },
                ),
              );
            },
          ),
      ],
    );
  }
}
