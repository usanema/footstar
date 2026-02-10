import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/match_repository.dart';
import '../data/models/match_model.dart';
import '../data/models/match_player_model.dart';
import 'tactical_pitch_screen.dart';

import 'team_generation_screen.dart';
// Added this import based on the diff

class MatchDetailsScreen extends StatefulWidget {
  final MatchModel match;
  final bool isAdmin; // Added

  const MatchDetailsScreen({
    super.key,
    required this.match,
    this.isAdmin = false, // Default false
  });

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  final MatchRepository _repository = MatchRepository();
  String? _currentUserId;

  List<MatchPlayerModel> _players = []; // Changed from nullable
  bool _isLoading = true;

  MatchPlayerModel? get _currentUserPlayer {
    if (_currentUserId == null) return null;
    try {
      return _players.firstWhere((p) => p.profileId == _currentUserId);
    } catch (_) {
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    _currentUserId =
        Supabase.instance.client.auth.currentUser?.id; // Initialized here
    _fetchMatchDetails(); // Renamed
  }

  Future<void> _fetchMatchDetails() async {
    setState(() => _isLoading = true);
    try {
      final players = await _repository.getMatchPlayers(widget.match.id);
      if (mounted) {
        setState(() {
          _players = players;
          // _currentUserPlayer logic removed, now derived in build
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading match details: $e')),
        ); // Updated message
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(PlayerStatus status) async {
    if (_currentUserId == null) return;
    try {
      await _repository.updatePlayerStatus(
        matchId: widget.match.id,
        status: status,
      );
      _fetchMatchDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _toggleCar(bool? hasCar) async {
    final player = _currentUserPlayer;
    if (player == null) return;
    try {
      await _repository.updatePlayerStatus(
        matchId: widget.match.id,
        status: player.status,
        hasCar: hasCar,
        carSeats: player.carSeats,
      );
      _fetchMatchDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating car status: $e')),
        );
      }
    }
  }

  Future<void> _updateSeats(int seats) async {
    final player = _currentUserPlayer;
    if (player == null) return;
    try {
      await _repository.updatePlayerStatus(
        matchId: widget.match.id,
        status: player.status,
        hasCar: player.hasCar,
        carSeats: seats,
      );
      _fetchMatchDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating car seats: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Match Details'),
        actions: [
          if (widget.isAdmin)
            IconButton(
              icon: const Icon(Icons.group_work),
              tooltip: 'Generate Teams',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => TeamGenerationScreen(
                      match: widget.match,
                      currentPlayers: _players,
                    ),
                  ),
                ).then((val) {
                  if (val == true) _fetchMatchDetails();
                });
              },
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchMatchDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              const SizedBox(height: 24),
              _buildAttendanceControls(),
              const SizedBox(height: 24),
              _buildPlayerList(),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TacticalPitchScreen(
                matchId: widget.match.id,
                players: _players
                    .where((p) => p.status == PlayerStatus.IN)
                    .toList(),
              ),
            ),
          ).then((_) => _fetchMatchDetails());
        },
        icon: const Icon(Icons.sports_soccer),
        label: const Text('Tactics Board'),
      ),
    );
  }

  Widget _buildHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: Text(
                '${widget.match.date.day}/${widget.match.date.month}/${widget.match.date.year}',
              ),
              subtitle: Text(
                '${widget.match.date.hour}:${widget.match.date.minute.toString().padLeft(2, '0')}',
              ),
            ),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(widget.match.location),
            ),
            if (widget.match.description != null)
              ListTile(
                leading: const Icon(Icons.description),
                title: Text(widget.match.description!),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceControls() {
    final status = _currentUserPlayer?.status ?? PlayerStatus.UNKNOWN;

    return Column(
      children: [
        if (_currentUserPlayer?.status == PlayerStatus.IN) ...[
          _buildCarpoolingSection(),
          const SizedBox(height: 24),
        ],
        const Text(
          'Are you playing?',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _AttendanceButton(
              label: 'IN',
              color: Colors.green,
              isSelected: status == PlayerStatus.IN,
              onTap: () => _updateStatus(PlayerStatus.IN),
            ),
            _AttendanceButton(
              label: 'OUT',
              color: Colors.red,
              isSelected: status == PlayerStatus.OUT,
              onTap: () => _updateStatus(PlayerStatus.OUT),
            ),
            _AttendanceButton(
              label: 'RESERVE',
              color: Colors.orange,
              isSelected: status == PlayerStatus.RESERVE,
              onTap: () => _updateStatus(PlayerStatus.RESERVE),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCarpoolingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CheckboxListTile(
              title: const Text('I can drive (have a car)'),
              value: _currentUserPlayer?.hasCar ?? false,
              onChanged: _toggleCar,
            ),
            if (_currentUserPlayer?.hasCar == true)
              Row(
                children: [
                  const Text('Available Seats: '),
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () =>
                        _updateSeats((_currentUserPlayer?.carSeats ?? 0) - 1),
                  ),
                  Text('${_currentUserPlayer?.carSeats ?? 0}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () =>
                        _updateSeats((_currentUserPlayer?.carSeats ?? 0) + 1),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerList() {
    final inPlayers = _players
        .where((p) => p.status == PlayerStatus.IN)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Confirmed Players (${inPlayers.length}/${widget.match.maxPlayers})',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: inPlayers.length,
          itemBuilder: (context, index) {
            final player = inPlayers[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: player.profile?.avatarUrl != null
                    ? NetworkImage(player.profile!.avatarUrl!)
                    : null,
                child: player.profile?.avatarUrl == null
                    ? Text((player.profile?.firstName ?? '?')[0])
                    : null,
              ),
              title: Text(
                '${player.profile?.firstName} ${player.profile?.lastName}',
              ),
              trailing: player.hasCar
                  ? Icon(Icons.directions_car, color: Colors.blue, size: 20)
                  : null,
            );
          },
        ),
      ],
    );
  }
}

class _AttendanceButton extends StatelessWidget {
  final String label;
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _AttendanceButton({
    required this.label,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? color : Colors.grey[200],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      onPressed: onTap,
      child: Text(label),
    );
  }
}
