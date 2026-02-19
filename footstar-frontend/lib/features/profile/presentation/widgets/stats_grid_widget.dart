import 'package:flutter/material.dart';
import 'package:footstars/core/app_theme.dart';
import 'package:footstars/features/onboarding/data/models/profile_model.dart';

class StatsGridWidget extends StatelessWidget {
  final ProfileModel profile;

  const StatsGridWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final winPct = (profile.winRate * 100).toStringAsFixed(0);
    final gpg = profile.goalsPerMatch.toStringAsFixed(2);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel('STATYSTYKI'),
        const SizedBox(height: 12),

        // 4 match stat cards in a 2x2 grid
        GridView.count(
          crossAxisCount: 4,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
          childAspectRatio: 0.9,
          children: [
            _StatCard(
              value: '${profile.strMatchesPlayed}',
              label: 'Mecze',
              color: AppColors.primary,
              icon: Icons.sports_soccer,
            ),
            _StatCard(
              value: '${profile.strMatchesWon}',
              label: 'Wygrane',
              color: const Color(0xFF4CAF50),
              icon: Icons.emoji_events_outlined,
            ),
            _StatCard(
              value: '${profile.strMatchesDrawn}',
              label: 'Remisy',
              color: const Color(0xFFFFC107),
              icon: Icons.handshake_outlined,
            ),
            _StatCard(
              value: '${profile.strMatchesLost}',
              label: 'Przegrane',
              color: const Color(0xFFEF5350),
              icon: Icons.close_outlined,
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Goals + Win% row
        Row(
          children: [
            Expanded(
              child: _StatCardWide(
                value: '${profile.strGoalsScored}',
                subValue: '$gpg / mecz',
                label: 'Gole',
                color: AppColors.secondary,
                icon: Icons.sports_score,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _StatCardWide(
                value: '$winPct%',
                subValue: 'skuteczność',
                label: 'Win Rate',
                color: AppColors.primary,
                icon: Icons.trending_up,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: AppTextStyles.labelSmall.copyWith(
        color: AppColors.textSecondary,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.value,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.all(10),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: AppTextStyles.headlineSmall.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              fontSize: 9,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StatCardWide extends StatelessWidget {
  final String value;
  final String subValue;
  final String label;
  final Color color;
  final IconData icon;

  const _StatCardWide({
    required this.value,
    required this.subValue,
    required this.label,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.headlineSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                subValue,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 10,
                ),
              ),
              Text(
                label,
                style: AppTextStyles.labelSmall.copyWith(
                  color: color,
                  fontSize: 9,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
