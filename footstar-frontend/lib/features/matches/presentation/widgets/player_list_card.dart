import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../data/models/match_player_model.dart';

class PlayerListCard extends StatelessWidget {
  final List<MatchPlayerModel> players;
  final String currentUserId;
  final Function(bool) onToggleCar;
  final Function(int) onUpdateSeats;

  final int maxPlayers;

  const PlayerListCard({
    super.key,
    required this.players,
    required this.currentUserId,
    required this.onToggleCar,
    required this.onUpdateSeats,
    this.maxPlayers = 0,
  });

  @override
  Widget build(BuildContext context) {
    // Sort players: Current user first, then by name
    final sortedPlayers = List<MatchPlayerModel>.from(players);
    sortedPlayers.sort((a, b) {
      if (a.profileId == currentUserId) return -1;
      if (b.profileId == currentUserId) return 1;
      return (a.profile?.firstName ?? '').compareTo(b.profile?.firstName ?? '');
    });

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SQUAD LIST',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  '${players.length}/${maxPlayers > 0 ? maxPlayers : "?"} Players',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedPlayers.length,
              separatorBuilder: (_, __) => const Divider(color: Colors.white10),
              itemBuilder: (context, index) {
                final player = sortedPlayers[index];
                final isMe = player.profileId == currentUserId;

                return _buildPlayerTile(context, player, isMe);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerTile(
    BuildContext context,
    MatchPlayerModel player,
    bool isMe,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        children: [
          Row(
            children: [
              // Avatar
              CircleAvatar(
                radius: 20,
                backgroundColor: AppColors.background,
                backgroundImage: player.profile?.avatarUrl != null
                    ? NetworkImage(player.profile!.avatarUrl!)
                    : null,
                child: player.profile?.avatarUrl == null
                    ? Text(
                        (player.profile?.firstName ?? '?')[0].toUpperCase(),
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),

              // Name & Role
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${player.profile?.firstName} ${player.profile?.lastName}' +
                          (isMe ? ' (You)' : ''),
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: isMe ? AppColors.primary : Colors.white,
                        fontWeight: isMe ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (player.profile?.positionPrimary != null)
                      Text(
                        player.profile!.positionPrimary!.toUpperCase(),
                        style: AppTextStyles.labelSmall.copyWith(
                          color: Colors.white54,
                          fontSize: 10,
                        ),
                      ),
                  ],
                ),
              ),

              // Car Icon if driving
              if (player.hasCar)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.secondary.withOpacity(0.5),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.directions_car,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${player.carSeats} seats',
                        style: const TextStyle(
                          color: AppColors.secondary,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          // Carpooling Controls (Only for Me)
          if (isMe) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.background.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.commute, color: Colors.white54, size: 20),
                  const SizedBox(width: 12),
                  Text(
                    'I can drive',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: Colors.white70,
                    ),
                  ),
                  const Spacer(),
                  Switch(
                    value: player.hasCar,
                    onChanged: onToggleCar,
                    activeColor: AppColors.secondary,
                    activeTrackColor: AppColors.secondary.withOpacity(0.3),
                  ),
                ],
              ),
            ),
            if (player.hasCar) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text('Available Seats:', style: AppTextStyles.labelSmall),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.remove_circle_outline,
                      color: Colors.white54,
                    ),
                    onPressed: () => onUpdateSeats(
                      (player.carSeats > 0) ? player.carSeats - 1 : 0,
                    ),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '${player.carSeats}',
                      style: AppTextStyles.bodyLarge.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.add_circle_outline,
                      color: Colors.white54,
                    ),
                    onPressed: () => onUpdateSeats(player.carSeats + 1),
                    constraints: const BoxConstraints(),
                    padding: EdgeInsets.zero,
                  ),
                ],
              ),
            ],
          ],
        ],
      ),
    );
  }
}
