import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../data/models/match_player_model.dart'; // For PlayerStatus enum

class StatusSelector extends StatelessWidget {
  final PlayerStatus currentStatus;
  final Function(PlayerStatus) onStatusChanged;
  final bool isLoading;

  const StatusSelector({
    super.key,
    required this.currentStatus,
    required this.onStatusChanged,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 8.0),
          child: Text(
            'YOUR STATUS',
            style: AppTextStyles.labelSmall.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.5,
            ),
          ),
        ),
        SizedBox(
          height: 80,
          child: Row(
            children: [
              Expanded(
                child: _buildStatusButton(
                  context,
                  status: PlayerStatus.IN,
                  label: 'IN',
                  color: AppColors.primary, // Greenish
                  icon: Icons.check_circle_outline,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusButton(
                  context,
                  status: PlayerStatus.OUT,
                  label: 'OUT',
                  color: AppColors.error, // Red
                  icon: Icons.cancel_outlined,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusButton(
                  context,
                  status: PlayerStatus.RESERVE,
                  label: 'MAYBE', // Or RESERVE
                  color: AppColors.secondary, // Yellowish/Gold
                  icon: Icons.help_outline,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusButton(
    BuildContext context, {
    required PlayerStatus status,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    final isSelected = currentStatus == status;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: isLoading ? null : () => onStatusChanged(status),
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? color.withOpacity(0.2) : AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? color : Colors.white10,
              width: isSelected ? 2 : 1,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isSelected ? color : Colors.white24, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.labelLarge.copyWith(
                  color: isSelected ? color : Colors.white24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
