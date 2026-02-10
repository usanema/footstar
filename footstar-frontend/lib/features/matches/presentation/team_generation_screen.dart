import 'package:flutter/material.dart';
import '../data/models/match_model.dart';
import '../data/models/match_player_model.dart';
import '../domain/services/team_balancer_service.dart';
import '../data/match_repository.dart';

class TeamGenerationScreen extends StatefulWidget {
  final MatchModel match;
  final List<MatchPlayerModel> currentPlayers;

  const TeamGenerationScreen({
    super.key,
    required this.match,
    required this.currentPlayers,
  });

  @override
  State<TeamGenerationScreen> createState() => _TeamGenerationScreenState();
}

class _TeamGenerationScreenState extends State<TeamGenerationScreen> {
  late List<MatchPlayerModel> _players;
  final TeamBalancerService _balancer = TeamBalancerService();
  final MatchRepository _repository = MatchRepository();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Filter only IN players for team generation
    _players = widget.currentPlayers
        .where((p) => p.status == PlayerStatus.IN)
        .toList();
  }

  void _generateTeams() {
    setState(() {
      _players = _balancer.balanceTeams(_players);
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Teams generated based on algorithm!')),
    );
  }

  // Calculate average rating for a list of players
  double _calculateAvgRating(List<MatchPlayerModel> teamPlayers) {
    if (teamPlayers.isEmpty) return 0.0;
    double total = 0;
    for (var p in teamPlayers) {
      if (p.profile != null) {
        total += p.profile!.totalPoints;
      }
    }
    return total / teamPlayers.length; // Raw average of total points
  }

  List<MatchPlayerModel> get _teamA =>
      _players.where((p) => p.team == Team.A).toList();
  List<MatchPlayerModel> get _teamB =>
      _players.where((p) => p.team == Team.B).toList();

  Future<void> _saveTeams() async {
    setState(() => _isLoading = true);
    try {
      // Update each player's team in the DB
      // Ideally this should be a batch update, but we'll loop for now or add a batch method to Repo
      // For MVP, loop is okay for < 30 players
      for (var p in _players) {
        if (p.team != null) {
          await _repository.updatePlayerTeam(p.id, p.team!);
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Teams saved successfully!')),
        );
        Navigator.pop(context, true); // Return true to refresh parent
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving teams: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final teamA = _teamA;
    final teamB = _teamB;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Team Generator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _isLoading ? null : _saveTeams,
            tooltip: 'Save Teams',
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton.icon(
              onPressed: _generateTeams,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text('Generate Balanced Teams'),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _buildTeamColumn('Team A', Team.A, teamA, Colors.red.shade100),
                const VerticalDivider(width: 1),
                _buildTeamColumn('Team B', Team.B, teamB, Colors.blue.shade100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamColumn(
    String title,
    Team team,
    List<MatchPlayerModel> teamPlayers,
    Color color,
  ) {
    final avg = _calculateAvgRating(teamPlayers);

    return Expanded(
      child: DragTarget<MatchPlayerModel>(
        onWillAccept: (data) => data != null && data.team != team,
        onAccept: (data) {
          setState(() {
            final index = _players.indexWhere((p) => p.id == data.id);
            if (index != -1) {
              _players[index] = _players[index].copyWith(team: team);
            }
          });
        },
        builder: (context, candidateData, rejectedData) {
          return Container(
            color: candidateData.isNotEmpty
                ? color.withOpacity(0.7)
                : color.withOpacity(0.3),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Avg Rating: ${avg.toStringAsFixed(1)}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      Text('${teamPlayers.length} Players'),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: teamPlayers.length,
                    itemBuilder: (context, index) {
                      final player = teamPlayers[index];
                      return Draggable<MatchPlayerModel>(
                        data: player,
                        feedback: Material(
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            color: Colors.white,
                            child: Text(
                              '${player.profile?.firstName} ${player.profile?.lastName}',
                            ),
                          ),
                        ),
                        childWhenDragging: Opacity(
                          opacity: 0.5,
                          child: _buildPlayerTile(player),
                        ),
                        child: _buildPlayerTile(player),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerTile(MatchPlayerModel player) {
    final profile = player.profile;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        dense: true,
        leading: CircleAvatar(
          backgroundImage: profile?.avatarUrl != null
              ? NetworkImage(profile!.avatarUrl!)
              : null,
          child: profile?.avatarUrl == null
              ? Text(profile?.firstName?[0] ?? '?')
              : null,
          radius: 16,
        ),
        title: Text('${profile?.firstName} ${profile?.lastName}'),
        subtitle: Text(
          'Power: ${profile?.totalPoints ?? 0}',
        ), // Using simplified total points for display
        trailing: const Icon(Icons.drag_handle, size: 16),
      ),
    );
  }
}
