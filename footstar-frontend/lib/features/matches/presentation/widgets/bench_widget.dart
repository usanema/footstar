import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../data/models/match_player_model.dart';

class BenchWidget extends StatelessWidget {
  final List<MatchPlayerModel> players;
  final bool isAdmin;
  final String? currentUserId;
  final Function(MatchPlayerModel player) onPlayerDropped;

  const BenchWidget({
    super.key,
    required this.players,
    required this.isAdmin,
    this.currentUserId,
    required this.onPlayerDropped,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<MatchPlayerModel>(
      onWillAcceptWithDetails: (_) => true,
      onAcceptWithDetails: (details) => onPlayerDropped(details.data),
      builder: (context, candidateData, rejectedData) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: candidateData.isNotEmpty
                  ? AppColors.primary
                  : Colors.white10,
              width: candidateData.isNotEmpty ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.chair_alt,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'BENCH / UNPLACED (${players.length})',
                    style: AppTextStyles.labelSmall.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.5,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (players.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Center(
                    child: Text(
                      'All active players are on the pitch.',
                      style: TextStyle(color: Colors.white30, fontSize: 12),
                    ),
                  ),
                )
              else
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: players
                      .map((p) => _buildDraggablePlayer(p))
                      .toList(),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDraggablePlayer(MatchPlayerModel player) {
    final bool canMove = isAdmin || (player.profileId == currentUserId);
    final child = _BenchPlayerChip(player: player);

    if (!canMove) return child;

    return Draggable<MatchPlayerModel>(
      data: player,
      feedback: Transform.scale(scale: 1.1, child: child),
      childWhenDragging: Opacity(opacity: 0.5, child: child),
      child: child,
    );
  }
}

class _BenchPlayerChip extends StatelessWidget {
  final MatchPlayerModel player;

  const _BenchPlayerChip({required this.player});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1F2833),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundImage: player.profile?.avatarUrl != null
                ? NetworkImage(player.profile!.avatarUrl!)
                : null,
            backgroundColor: AppColors.primary.withOpacity(0.2),
            child: player.profile?.avatarUrl == null
                ? Text(
                    player.profile?.firstName?[0] ?? '?',
                    style: const TextStyle(
                      fontSize: 10,
                      color: AppColors.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 8),
          Text(
            player.profile?.firstName ?? 'Unknown',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
