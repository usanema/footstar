import 'package:flutter/material.dart';
import 'package:footstars/core/app_theme.dart';
import 'package:footstars/features/onboarding/data/models/profile_model.dart';

class ProfileHeaderWidget extends StatelessWidget {
  final ProfileModel profile;

  const ProfileHeaderWidget({super.key, required this.profile});

  @override
  Widget build(BuildContext context) {
    final initials = [
      profile.firstName?.isNotEmpty == true ? profile.firstName![0] : '',
      profile.lastName?.isNotEmpty == true ? profile.lastName![0] : '',
    ].join().toUpperCase();

    return Column(
      children: [
        // Avatar
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.surface,
            border: Border.all(color: AppColors.primary, width: 2.5),
            image: profile.avatarUrl != null
                ? DecorationImage(
                    image: NetworkImage(profile.avatarUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: profile.avatarUrl == null
              ? Center(
                  child: Text(
                    initials.isEmpty ? '?' : initials,
                    style: AppTextStyles.headlineMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : null,
        ),

        const SizedBox(height: 16),

        // Name
        Text(
          '${profile.firstName ?? ''} ${profile.lastName ?? ''}'.trim(),
          style: AppTextStyles.headlineMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 8),

        // Age + Foot
        if (profile.age != null || profile.foot != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (profile.age != null) ...[
                Icon(
                  Icons.cake_outlined,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${profile.age} lat',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
              if (profile.age != null && profile.foot != null)
                const SizedBox(width: 16),
              if (profile.foot != null) ...[
                Icon(
                  Icons.sports_soccer,
                  size: 14,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${profile.foot} foot',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ],
          ),

        const SizedBox(height: 12),

        // Positions
        if (profile.positions.isNotEmpty)
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            children: profile.positions
                .map((pos) => _PositionChip(pos))
                .toList(),
          ),

        const SizedBox(height: 12),

        // Favorite club / player
        if (profile.favoriteClub != null || profile.favoritePlayer != null)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (profile.favoriteClub != null)
                  _InfoItem(
                    icon: Icons.shield_outlined,
                    label: 'Klub',
                    value: profile.favoriteClub!,
                  ),
                if (profile.favoriteClub != null &&
                    profile.favoritePlayer != null)
                  Container(width: 1, height: 32, color: Colors.white12),
                if (profile.favoritePlayer != null)
                  _InfoItem(
                    icon: Icons.star_outline,
                    label: 'Idol',
                    value: profile.favoritePlayer!,
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

class _PositionChip extends StatelessWidget {
  final String position;
  const _PositionChip(this.position);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.5)),
      ),
      child: Text(
        position.toUpperCase(),
        style: AppTextStyles.labelSmall.copyWith(
          color: AppColors.primary,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, size: 12, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(
              label,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: AppTextStyles.bodyMedium.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
