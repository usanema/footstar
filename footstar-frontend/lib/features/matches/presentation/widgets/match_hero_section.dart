import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../../core/app_theme.dart';
import '../../data/models/match_model.dart';
import '../../data/models/match_player_model.dart';

class MatchHeroSection extends StatefulWidget {
  final MatchModel match;
  final PlayerStatus? userStatus;
  final VoidCallback? onCheckIn;

  const MatchHeroSection({
    super.key,
    required this.match,
    this.userStatus,
    this.onCheckIn,
  });

  @override
  State<MatchHeroSection> createState() => _MatchHeroSectionState();
}

class _MatchHeroSectionState extends State<MatchHeroSection> {
  // ... existing timer logic ...
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _calculateTimeLeft();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _calculateTimeLeft();
    });
  }

  void _calculateTimeLeft() {
    final now = DateTime.now();
    final difference = widget.match.date.difference(now);
    if (mounted) {
      setState(() {
        _timeLeft = difference.isNegative ? Duration.zero : difference;
      });
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} DAYS';
    } else {
      final hours = duration.inHours;
      final minutes = duration.inMinutes.remainder(60);
      return '${hours}H ${minutes}M';
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('EEEE, d MMMM');
    final timeFormat = DateFormat('HH:mm');

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.primary.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.15),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          // 1. Background (Stadium Vibe)
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.5),
                  radius: 1.2,
                  colors: [
                    AppColors.surface.withOpacity(0.9), // Lighter center
                    Colors.black, // Dark edges
                  ],
                ),
              ),
            ),
          ),

          // Mesh Pattern Overlay
          Positioned.fill(child: CustomPaint(painter: GridPainter())),

          // 2. Content
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Status Badge & Group/Players
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatusBadge(),
                    if (widget.match.groupName != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          widget.match.groupName!.toUpperCase(),
                          style: GoogleFonts.oswald(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.6),
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 32),

                // Center: Big Countdown or Result
                Center(
                  child: Column(
                    children: [
                      Text(
                        _timeLeft == Duration.zero ? 'KICKOFF' : 'KICKOFF IN',
                        style: GoogleFonts.oswald(
                          fontSize: 14,
                          color: AppColors.primary,
                          letterSpacing: 2.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _timeLeft == Duration.zero
                            ? timeFormat.format(widget.match.date)
                            : _formatDuration(_timeLeft),
                        style: GoogleFonts.oswald(
                          fontSize: 56,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          height: 1.0,
                          shadows: [
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.6),
                              blurRadius: 30,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        dateFormat.format(widget.match.date).toUpperCase(),
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white70,
                          letterSpacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Bottom Row: Location & Check-in CTA
                Row(
                  children: [
                    const Icon(
                      Icons.location_on,
                      color: AppColors.secondary,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        widget.match.location,
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.userStatus != PlayerStatus.IN &&
                        _timeLeft.inHours > 0)
                      Padding(
                        padding: const EdgeInsets.only(left: 16.0),
                        child: ElevatedButton(
                          onPressed: widget.onCheckIn,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: Text(
                            'CHECK IN',
                            style: GoogleFonts.oswald(
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;
    IconData icon;

    switch (widget.userStatus) {
      case PlayerStatus.IN:
        color = AppColors.primary;
        text = 'YOU ARE IN';
        icon = Icons.check_circle;
        break;
      case PlayerStatus.OUT:
        color = AppColors.error;
        text = 'YOU ARE OUT';
        icon = Icons.cancel;
        break;
      case PlayerStatus.RESERVE:
        color = AppColors.secondary;
        text = 'RESERVE';
        icon = Icons.access_time;
        break;
      default:
        color = Colors.grey;
        text = 'NOT ANSWERED';
        icon = Icons.help_outline;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: GoogleFonts.oswald(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.03)
      ..strokeWidth = 1;

    const double step = 20;

    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
