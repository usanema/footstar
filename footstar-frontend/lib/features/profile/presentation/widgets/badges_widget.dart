import 'package:flutter/material.dart';
import 'package:footstars/core/app_theme.dart';
import 'package:footstars/features/onboarding/data/models/profile_model.dart';

class _Badge {
  final String label;
  final String description;
  final IconData icon;
  final Color color;
  final bool earned;

  const _Badge({
    required this.label,
    required this.description,
    required this.icon,
    required this.color,
    required this.earned,
  });
}

class BadgesWidget extends StatelessWidget {
  final ProfileModel profile;

  const BadgesWidget({super.key, required this.profile});

  List<_Badge> _buildBadges() {
    return [
      _Badge(
        label: 'Debiutant',
        description: '1 mecz',
        icon: Icons.sports_soccer,
        color: const Color(0xFF4CAF50),
        earned: profile.strMatchesPlayed >= 1,
      ),
      _Badge(
        label: 'Stały bywalec',
        description: '10 meczów',
        icon: Icons.calendar_month,
        color: const Color(0xFF2196F3),
        earned: profile.strMatchesPlayed >= 10,
      ),
      _Badge(
        label: 'Snajper',
        description: '5 goli',
        icon: Icons.sports_score,
        color: const Color(0xFFFFC107),
        earned: profile.strGoalsScored >= 5,
      ),
      _Badge(
        label: 'Nieustraszony',
        description: '10 wygranych',
        icon: Icons.emoji_events,
        color: const Color(0xFFFF9800),
        earned: profile.strMatchesWon >= 10,
      ),
      _Badge(
        label: 'Weteran',
        description: '50 meczów',
        icon: Icons.military_tech,
        color: const Color(0xFF9C27B0),
        earned: profile.strMatchesPlayed >= 50,
      ),
      _Badge(
        label: 'Nieprzegrany',
        description: '5 meczów bez porażki',
        icon: Icons.shield,
        color: const Color(0xFF00BCD4),
        earned: profile.strMatchesLost == 0 && profile.strMatchesPlayed >= 5,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final badges = _buildBadges();
    final earned = badges.where((b) => b.earned).toList();
    final unearned = badges.where((b) => !b.earned).toList();
    final sorted = [...earned, ...unearned];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'ODZNAKI',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                '${earned.length}/${badges.length}',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 1.05,
          children: sorted.map((badge) => _BadgeCard(badge: badge)).toList(),
        ),
      ],
    );
  }
}

class _BadgeCard extends StatelessWidget {
  final _Badge badge;
  // ignore: unused_element
  const _BadgeCard({required this.badge});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: badge.earned ? 1.0 : 0.35,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: badge.earned ? badge.color.withOpacity(0.5) : Colors.white10,
          ),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: badge.color.withOpacity(badge.earned ? 0.2 : 0.05),
              ),
              child: Icon(badge.icon, color: badge.color, size: 22),
            ),
            const SizedBox(height: 6),
            Text(
              badge.label,
              style: AppTextStyles.labelSmall.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              badge.description,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 9,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
