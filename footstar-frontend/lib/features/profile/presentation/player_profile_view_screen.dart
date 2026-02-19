import 'package:flutter/material.dart';
import '../../../core/app_theme.dart';
import '../../onboarding/data/models/profile_model.dart';
import '../../onboarding/presentation/widgets/skill_hexagon.dart';

/// Read-only profile screen for viewing another player's profile.
/// Used when navigating from search results.
class PlayerProfileViewScreen extends StatelessWidget {
  final ProfileModel player;

  const PlayerProfileViewScreen({super.key, required this.player});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          '${player.firstName ?? ''} ${player.lastName ?? ''}'.trim(),
          style: AppTextStyles.headlineSmall.copyWith(fontSize: 18),
        ),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 100),
            _buildHeader(context),
            const SizedBox(height: 20),
            if (player.skillsMap.isNotEmpty) ...[
              _buildSectionTitle('Attributes'),
              const SizedBox(height: 8),
              Center(child: SkillHexagon(skills: player.skillsMap, size: 240)),
              const SizedBox(height: 20),
            ],
            _buildSectionTitle('Stats'),
            const SizedBox(height: 8),
            _buildStatsRow(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Card(
        color: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar
              CircleAvatar(
                radius: 44,
                backgroundColor: AppColors.primary.withOpacity(0.15),
                backgroundImage: player.avatarUrl != null
                    ? NetworkImage(player.avatarUrl!)
                    : null,
                child: player.avatarUrl == null
                    ? Text(
                        '${player.firstName?.isNotEmpty == true ? player.firstName![0] : '?'}',
                        style: AppTextStyles.headlineMedium.copyWith(
                          color: AppColors.primary,
                          fontSize: 36,
                        ),
                      )
                    : null,
              ),
              const SizedBox(height: 12),
              // Name
              Text(
                '${player.firstName ?? ''} ${player.lastName ?? ''}'.trim(),
                style: AppTextStyles.headlineMedium.copyWith(fontSize: 20),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              // Age & foot
              if (player.age != null || player.foot != null)
                Text(
                  [
                    if (player.age != null) '${player.age} yrs',
                    if (player.foot != null) player.foot!,
                  ].join(' · '),
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              const SizedBox(height: 10),
              // Position chips
              Wrap(
                spacing: 8,
                runSpacing: 6,
                alignment: WrapAlignment.center,
                children: player.positions.map((pos) {
                  return Chip(
                    label: Text(
                      pos,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    backgroundColor: AppColors.primary.withOpacity(0.12),
                    side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                    padding: EdgeInsets.zero,
                  );
                }).toList(),
              ),
              // Fav club / player
              if (player.favoriteClub != null ||
                  player.favoritePlayer != null) ...[
                const SizedBox(height: 12),
                const Divider(color: Colors.white10),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (player.favoriteClub != null)
                      _infoChip(Icons.stadium_outlined, player.favoriteClub!),
                    if (player.favoritePlayer != null)
                      _infoChip(Icons.star_outline, player.favoritePlayer!),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          label,
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Text(
        title.toUpperCase(),
        style: AppTextStyles.bodySmall.copyWith(
          color: AppColors.textSecondary,
          letterSpacing: 1.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    final stats = [
      _StatItem('Played', '${player.strMatchesPlayed}', Icons.sports_soccer),
      _StatItem('Won', '${player.strMatchesWon}', Icons.emoji_events_outlined),
      _StatItem(
        'Goals',
        '${player.strGoalsScored}',
        Icons.sports_soccer_outlined,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: stats.map((s) {
          return Expanded(
            child: Card(
              color: AppColors.surface,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Column(
                  children: [
                    Icon(s.icon, color: AppColors.primary, size: 22),
                    const SizedBox(height: 6),
                    Text(
                      s.value,
                      style: AppTextStyles.headlineSmall.copyWith(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      s.label,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final IconData icon;
  const _StatItem(this.label, this.value, this.icon);
}
