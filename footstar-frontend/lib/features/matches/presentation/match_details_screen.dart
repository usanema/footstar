import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/match_repository.dart';
import '../data/models/match_model.dart';
import '../data/models/match_player_model.dart';
import 'tactical_pitch_screen.dart';

class MatchDetailsScreen extends StatefulWidget {
  final MatchModel match;

  const MatchDetailsScreen({super.key, required this.match});

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  final MatchRepository _repository = MatchRepository();
  final String _currentUserId = Supabase.instance.client.auth.currentUser!.id;

  List<MatchPlayerModel>? _players;
  bool _isLoading = true;
  MatchPlayerModel? _currentUserPlayer;

  @override
  void initState() {
    super.initState();
    _fetchDetails();
  }

  Future<void> _fetchDetails() async {
    setState(() => _isLoading = true);
    try {
      final players = await _repository.getMatchPlayers(widget.match.id);
      setState(() {
        _players = players;
        try {
          _currentUserPlayer = players.firstWhere(
            (p) => p.profileId == _currentUserId,
          );
        } catch (_) {
          _currentUserPlayer = null;
        }
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(PlayerStatus status) async {
    try {
      await _repository.updatePlayerStatus(
        matchId: widget.match.id,
        status: status,
      );
      _fetchDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating status: $e')));
      }
    }
  }

  Future<void> _toggleCar(bool? hasCar) async {
    if (_currentUserPlayer == null) return;
    try {
      await _repository.updatePlayerStatus(
        matchId: widget.match.id,
        status: _currentUserPlayer!.status,
        hasCar: hasCar,
        carSeats: _currentUserPlayer!.carSeats,
      );
      _fetchDetails();
    } catch (e) {
      // Error handling
    }
  }

  Future<void> _updateSeats(int seats) async {
    if (_currentUserPlayer == null) return;
    try {
      await _repository.updatePlayerStatus(
        matchId: widget.match.id,
        status: _currentUserPlayer!.status,
        hasCar: _currentUserPlayer!.hasCar,
        carSeats: seats,
      );
      _fetchDetails();
    } catch (e) {
      // Error handling
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Match Details')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _fetchDetails,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildAttendanceControls(),
                    const SizedBox(height: 24),
                    if (_currentUserPlayer?.status == PlayerStatus.IN)
                      _buildCarpoolingSection(),
                    const SizedBox(height: 24),
                    _buildPlayerList(),
                    const SizedBox(height: 80), // Fab space
                  ],
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => TacticalPitchScreen(matchId: widget.match.id),
            ),
          );
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
    final inPlayers =
        _players?.where((p) => p.status == PlayerStatus.IN).toList() ?? [];

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
