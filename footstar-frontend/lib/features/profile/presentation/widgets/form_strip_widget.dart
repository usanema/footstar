import 'package:flutter/material.dart';
import 'package:footstars/core/app_theme.dart';
import 'package:footstars/features/profile/data/models/player_match_result_model.dart';

class FormStripWidget extends StatelessWidget {
  final List<PlayerMatchResultModel> lastMatches;

  const FormStripWidget({super.key, required this.lastMatches});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'FORMA',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '(ostatnie 5 meczów)',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        if (lastMatches.isEmpty)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Center(
              child: Text(
                'Brak rozegranych meczów',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: lastMatches.reversed
                  .map((m) => _FormDot(m.formResult))
                  .toList(),
            ),
          ),
      ],
    );
  }
}

class _FormDot extends StatelessWidget {
  final PlayerFormResult result;
  const _FormDot(this.result);

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;

    switch (result) {
      case PlayerFormResult.win:
        color = const Color(0xFF4CAF50);
        label = 'W';
        break;
      case PlayerFormResult.draw:
        color = const Color(0xFFFFC107);
        label = 'D';
        break;
      case PlayerFormResult.loss:
        color = const Color(0xFFEF5350);
        label = 'L';
        break;
      case PlayerFormResult.unknown:
        color = Colors.white24;
        label = '?';
        break;
    }

    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withOpacity(0.2),
            border: Border.all(color: color, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}
