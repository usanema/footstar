import 'package:flutter/material.dart';
import '../../data/models/match_player_model.dart';

class TeamCompositionWidget extends StatefulWidget {
  final List<MatchPlayerModel> players;
  final bool isAdmin;
  final Function(MatchPlayerModel player, Team targetTeam) onPlayerMoved;

  const TeamCompositionWidget({
    super.key,
    required this.players,
    required this.isAdmin,
    required this.onPlayerMoved,
  });

  @override
  State<TeamCompositionWidget> createState() => _TeamCompositionWidgetState();
}

class _TeamCompositionWidgetState extends State<TeamCompositionWidget> {
  // Calculate average rating for a list of players
  double _calculateAvgRating(List<MatchPlayerModel> teamPlayers) {
    if (teamPlayers.isEmpty) return 0.0;
    double total = 0;
    for (var p in teamPlayers) {
      if (p.profile != null) {
        total += p.profile!.totalPoints;
      }
    }
    return total / teamPlayers.length;
  }

  @override
  Widget build(BuildContext context) {
    final teamA = widget.players.where((p) => p.team == Team.A).toList();
    final teamB = widget.players.where((p) => p.team == Team.B).toList();

    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Team Composition',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
        SizedBox(
          height: 400, // Fixed height for embedded view
          child: Row(
            children: [
              _buildTeamColumn(
                'Team A',
                Team.A,
                teamA,
                Colors.red.shade100,
                context,
              ),
              const VerticalDivider(width: 1),
              _buildTeamColumn(
                'Team B',
                Team.B,
                teamB,
                Colors.blue.shade100,
                context,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamColumn(
    String title,
    Team team,
    List<MatchPlayerModel> teamPlayers,
    Color color,
    BuildContext context,
  ) {
    final avg = _calculateAvgRating(teamPlayers);

    return Expanded(
      child: DragTarget<MatchPlayerModel>(
        onWillAccept: (data) {
          if (!widget.isAdmin) return false;
          return data != null && data.team != team;
        },
        onAccept: (data) => widget.onPlayerMoved(data, team),
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
                      // Use Draggable only if admin, otherwise just the tile
                      if (widget.isAdmin) {
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
                      } else {
                        return _buildPlayerTile(player);
                      }
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
        subtitle: Text('Power: ${profile?.totalPoints ?? 0}'),
        trailing: widget.isAdmin
            ? const Icon(Icons.drag_handle, size: 16)
            : null,
      ),
    );
  }
}
