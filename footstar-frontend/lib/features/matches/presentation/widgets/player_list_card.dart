import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../data/models/match_player_model.dart';

class PlayerListCard extends StatefulWidget {
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
  State<PlayerListCard> createState() => _PlayerListCardState();
}

class _PlayerListCardState extends State<PlayerListCard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 1. Filter players based on tab
    // We'll use AnimatedBuilder or just setState from TabBar listener?
    // TabBarView is better for "carousel" feel.

    return Card(
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Header with Tabs
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'ROSTERS',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  '${widget.players.length}/${widget.maxPlayers > 0 ? widget.maxPlayers : "?"} Players',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Custom Tab Bar
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(20),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.primary.withOpacity(0.5)),
              ),
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              dividerColor: Colors.transparent,
              indicatorSize: TabBarIndicatorSize.tab,
              tabs: const [
                Tab(text: 'ALL'),
                Tab(text: 'TEAM A'),
                Tab(text: 'TEAM B'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Tab Views
          SizedBox(
            height: 400, // Fixed height or expandable?
            // ListView inside Column needs height or shrinkWrap.
            // TabBarView needs height.
            // Let's use constraints or Calculate based on content?
            // "Carousel" implies swiping. TabBarView provides that.
            // But height issue is tricky.
            // Let's use AnimatedSize or just a fixed constraint for now, or IntrinsicHeight (expensive).
            // Actually, we can use a container with a reasonable min-height or adapt.
            // Let's try shrinkWrap in ListView inside TabBarView but TabBarView needs expanded/height.
            // Given it's a Card in a ScrollView (MatchDetailsScreen), we probably want it to size to content.
            // But TabBarView forces viewport.
            // ALTERNATIVE: Don't use TabBarView if we want auto-height. Use Filter + AnimatedSwitcher.
            // BUT User asked for "Carousel (slider)". TabBarView gives swipe.
            // Let's pick a fixed height for now or use a custom "Swipeable" container.
            // Safest for scrolling parent: AnimatedSwitcher with buttons if logic is simple.
            // But TabController is nice.
            // Let's stick to TabBarView with a fix: ConstrainedBox.
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildPlayerList(widget.players),
                _buildPlayerList(
                  widget.players.where((p) => p.team == Team.A).toList(),
                ),
                _buildPlayerList(
                  widget.players.where((p) => p.team == Team.B).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildPlayerList(List<MatchPlayerModel> filteredPlayers) {
    // Sort: Me first, then Name
    final sorted = List<MatchPlayerModel>.from(filteredPlayers);
    sorted.sort((a, b) {
      if (a.profileId == widget.currentUserId) return -1;
      if (b.profileId == widget.currentUserId) return 1;
      return (a.profile?.firstName ?? '').compareTo(b.profile?.firstName ?? '');
    });

    if (sorted.isEmpty) {
      return Center(
        child: Text(
          'No players yet',
          style: AppTextStyles.bodyMedium.copyWith(color: Colors.white30),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: sorted.length,
      separatorBuilder: (_, __) => const Divider(color: Colors.white10),
      itemBuilder: (context, index) {
        final player = sorted[index];
        final isMe = player.profileId == widget.currentUserId;
        return _buildPlayerTile(context, player, isMe);
      },
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
                    Row(
                      children: [
                        if (player.team != null)
                          Container(
                            margin: const EdgeInsets.only(right: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: player.team == Team.A
                                  ? Colors.redAccent.withOpacity(0.2)
                                  : Colors.blueAccent.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                              border: Border.all(
                                color: player.team == Team.A
                                    ? Colors.redAccent
                                    : Colors.blueAccent,
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              player.team == Team.A ? 'TEAM A' : 'TEAM B',
                              style: TextStyle(
                                fontSize: 9,
                                color: player.team == Team.A
                                    ? Colors.redAccent
                                    : Colors.blueAccent,
                                fontWeight: FontWeight.bold,
                              ),
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
                    onChanged: widget.onToggleCar,
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
                    onPressed: () => widget.onUpdateSeats(
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
                    onPressed: () => widget.onUpdateSeats(player.carSeats + 1),
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
