import 'package:flutter/material.dart';
import '../data/match_repository.dart';
import '../data/models/match_player_model.dart';
import '../../onboarding/data/models/profile_model.dart';

class TacticalPitchScreen extends StatefulWidget {
  final String matchId;

  const TacticalPitchScreen({super.key, required this.matchId});

  @override
  State<TacticalPitchScreen> createState() => _TacticalPitchScreenState();
}

class _TacticalPitchScreenState extends State<TacticalPitchScreen> {
  final MatchRepository _repository = MatchRepository();
  List<MatchPlayerModel> _players = [];
  bool _isLoading = true;

  // Pitch dimensions for normalization
  final double _pitchAspectRatio = 2 / 3; // Standard-ish vertical pitch

  @override
  void initState() {
    super.initState();
    _fetchPlayers();
  }

  Future<void> _fetchPlayers() async {
    setState(() => _isLoading = true);
    try {
      final players = await _repository.getMatchPlayers(widget.matchId);
      setState(() {
        _players = players.where((p) => p.status == PlayerStatus.IN).toList();
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

  Future<void> _updatePosition(
    MatchPlayerModel player,
    double x,
    double y,
  ) async {
    // Optimistic update
    setState(() {
      final index = _players.indexWhere((p) => p.id == player.id);
      if (index != -1) {
        _players[index] = _players[index].copyWith(pitchX: x, pitchY: y);
      }
    });

    try {
      await _repository.updatePlayerPosition(
        matchPlayerId: player.id,
        x: x.clamp(0.0, 1.0),
        y: y.clamp(0.0, 1.0),
      );
    } catch (e) {
      // Revert if failed (requires keeping old state, simplified for now)
      _fetchPlayers();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tactics Board')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : LayoutBuilder(
              builder: (context, constraints) {
                return Column(
                  children: [
                    Expanded(
                      flex: 3,
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: _pitchAspectRatio,
                          child: Stack(
                            children: [
                              // Pitch Background
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.green[800],
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Stack(
                                  children: [
                                    // Center Circle
                                    Center(
                                      child: Container(
                                        width: 80,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.white70,
                                            width: 2,
                                          ),
                                          shape: BoxShape.circle,
                                        ),
                                      ),
                                    ),
                                    Center(
                                      child: Container(
                                        height: 2,
                                        color: Colors.white70,
                                      ),
                                    ),
                                    // Penalty Areas (Simplified)
                                    Align(
                                      alignment: Alignment.topCenter,
                                      child: Container(
                                        width: 150,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            bottom: BorderSide(
                                              color: Colors.white70,
                                              width: 2,
                                            ),
                                            left: BorderSide(
                                              color: Colors.white70,
                                              width: 2,
                                            ),
                                            right: BorderSide(
                                              color: Colors.white70,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Align(
                                      alignment: Alignment.bottomCenter,
                                      child: Container(
                                        width: 150,
                                        height: 80,
                                        decoration: BoxDecoration(
                                          border: Border(
                                            top: BorderSide(
                                              color: Colors.white70,
                                              width: 2,
                                            ),
                                            left: BorderSide(
                                              color: Colors.white70,
                                              width: 2,
                                            ),
                                            right: BorderSide(
                                              color: Colors.white70,
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              // Players on Pitch
                              // We use the Draggable Area Wrapper for rendering tokens
                              // But we need to handle "static" tokens if we don't want them draggable?
                              // For now, all are draggable

                              // Draggable Area Wrapper
                              LayoutBuilder(
                                builder: (ctx, pitchConstraints) {
                                  return Stack(
                                    children: _players.map((player) {
                                      // Defaults if not set (off-pitch logic to be handled separately)
                                      // If pitchX is null, we don't render them ON the pitch via this loop?
                                      // But loop iterates all players.
                                      if (player.pitchX == null ||
                                          player.pitchY == null)
                                        return const SizedBox.shrink();

                                      final x = player.pitchX!;
                                      final y = player.pitchY!;

                                      return Positioned(
                                        left:
                                            x * pitchConstraints.maxWidth -
                                            20, // Center token
                                        top:
                                            y * pitchConstraints.maxHeight - 20,
                                        child: Draggable<MatchPlayerModel>(
                                          data: player,
                                          feedback: _buildPlayerToken(
                                            player,
                                            1.2,
                                          ),
                                          childWhenDragging: Opacity(
                                            opacity: 0.5,
                                            child: _buildPlayerToken(player),
                                          ),
                                          onDragEnd: (details) {
                                            // Calculate new relative position
                                            final RenderBox box =
                                                ctx.findRenderObject()
                                                    as RenderBox;
                                            final localPos = box.globalToLocal(
                                              details.offset,
                                            );
                                            final newX =
                                                localPos.dx /
                                                pitchConstraints.maxWidth;
                                            final newY =
                                                localPos.dy /
                                                pitchConstraints.maxHeight;

                                            _updatePosition(player, newX, newY);
                                          },
                                          child: _buildPlayerToken(player),
                                        ),
                                      );
                                    }).toList(),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    // Unassigned Players / Bench
                    Expanded(
                      flex: 1,
                      child: Container(
                        color: Colors.grey[200],
                        padding: const EdgeInsets.all(8),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Bench / Unassigned',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: _players
                                  .where((p) => p.pitchX == null)
                                  .map((player) {
                                    return InkWell(
                                      onTap: () => _updatePosition(
                                        player,
                                        0.5,
                                        0.5,
                                      ), // Move to center
                                      child: _buildPlayerToken(player),
                                    );
                                  })
                                  .toList(),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildPlayerToken(MatchPlayerModel player, [double scale = 1.0]) {
    return Transform.scale(
      scale: scale,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: Colors.white,
            backgroundImage: player.profile?.avatarUrl != null
                ? NetworkImage(player.profile!.avatarUrl!)
                : null,
            child: player.profile?.avatarUrl == null
                ? Text(
                    player.profile?.firstName?[0] ?? '?',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  )
                : null,
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.black54,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              player.profile?.firstName ?? 'Unk',
              style: const TextStyle(color: Colors.white, fontSize: 10),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
