import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';
import '../../data/models/match_player_model.dart';

class TacticalBoardWidget extends StatefulWidget {
  final List<MatchPlayerModel> players;
  final bool isAdmin;
  final bool isFullScreen;
  final String? currentUserId;
  final Function(MatchPlayerModel player, Team targetTeam) onPlayerMovedTeam;
  final Function(MatchPlayerModel player, double x, double y)?
  onPlayerMovedPitch;
  final VoidCallback? onExpand;

  const TacticalBoardWidget({
    super.key,
    required this.players,
    required this.isAdmin,
    this.currentUserId,
    this.isFullScreen = false,
    required this.onPlayerMovedTeam,
    this.onPlayerMovedPitch,
    this.onExpand,
  });

  @override
  State<TacticalBoardWidget> createState() => _TacticalBoardWidgetState();
}

class _TacticalBoardWidgetState extends State<TacticalBoardWidget> {
  final GlobalKey _pitchKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    // If embedded, we might want a header or container
    if (widget.isFullScreen) {
      return Scaffold(
        backgroundColor: const Color(0xFF0B0C10),
        appBar: AppBar(
          title: const Text(
            'TACTICAL BOARD',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: Center(
          child: AspectRatio(
            aspectRatio: 2 / 3, // Vertical viewing for full screen
            child: _buildPitch(context),
          ),
        ),
      );
    }

    return Column(
      children: [
        if (widget.onExpand != null)
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'TACTICAL BOARD',
                  style: AppTextStyles.labelSmall.copyWith(
                    color: AppColors.textSecondary,
                    letterSpacing: 1.5,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.fullscreen, color: AppColors.accent),
                  onPressed: widget.onExpand,
                ),
              ],
            ),
          ),
        AspectRatio(
          aspectRatio: 3 / 2, // Horizontal for embedded view
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            clipBehavior: Clip.antiAlias,
            child: _buildPitch(context),
          ),
        ),
      ],
    );
  }

  Widget _buildPitch(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          key: _pitchKey,
          children: [
            // 1. Pitch Painting
            Positioned.fill(
              child: CustomPaint(painter: TacticalPitchPainter()),
            ),

            // 2. Drag Target
            Positioned.fill(
              child: DragTarget<MatchPlayerModel>(
                onWillAcceptWithDetails: (_) => true,
                onAcceptWithDetails: (details) => _handleDrop(details),
                builder: (context, candidateData, rejectedData) {
                  return Container(color: Colors.transparent);
                },
              ),
            ),

            // 3. Players
            ...widget.players.map((p) => _buildPlayerToken(p, constraints)),
          ],
        );
      },
    );
  }

  Widget _buildPlayerToken(
    MatchPlayerModel player,
    BoxConstraints constraints,
  ) {
    // If no position, don't show on pitch (should be on bench)
    if (player.pitchX == null || player.pitchY == null)
      return const SizedBox.shrink();

    final x = player.pitchX! * constraints.maxWidth;
    final y = player.pitchY! * constraints.maxHeight;
    const size = 32.0;

    final canMove =
        widget.isAdmin || (player.profileId == widget.currentUserId);

    final token = _PlayerToken(player: player, size: size);

    return Positioned(
      left: x - (size / 2),
      top: y - (size / 2),
      child: canMove
          ? Draggable<MatchPlayerModel>(
              data: player,
              feedback: Transform.scale(scale: 1.2, child: token),
              childWhenDragging: Opacity(opacity: 0.3, child: token),
              child: token,
            )
          : token,
    );
  }

  void _handleDrop(DragTargetDetails<MatchPlayerModel> details) {
    final RenderBox? box =
        _pitchKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null) return;

    final localPos = box.globalToLocal(details.offset);
    final w = box.size.width;
    final h = box.size.height;

    double newX = localPos.dx / w;
    double newY = localPos.dy / h;

    // Clamp
    newX = newX.clamp(0.05, 0.95);
    newY = newY.clamp(0.05, 0.95);

    if (widget.onPlayerMovedPitch != null) {
      widget.onPlayerMovedPitch!(details.data, newX, newY);
    }

    // Auto-detect team based on side
    final bool isVertical = h > w;
    Team? newTeam;

    if (isVertical) {
      // Vertical: Top (0.0 - 0.5) = Team B, Bottom (0.5 - 1.0) = Team A
      if (newY < 0.5) {
        newTeam = Team.B;
      } else {
        newTeam = Team.A;
      }
    } else {
      // Horizontal: Left (0.0 - 0.5) = Team A, Right (0.5 - 1.0) = Team B
      if (newX < 0.5) {
        newTeam = Team.A;
      } else {
        newTeam = Team.B;
      }
    }

    // Only update if changed and team is not null (game mode might have no teams?)
    // Assuming Team enum is always valid if we are on tactical board.
    if (newTeam != details.data.team) {
      widget.onPlayerMovedTeam(details.data, newTeam);
    }
  }
}

class _PlayerToken extends StatelessWidget {
  final MatchPlayerModel player;
  final double size;

  const _PlayerToken({required this.player, required this.size});

  @override
  Widget build(BuildContext context) {
    Color ringColor = Colors.white;
    if (player.team == Team.A) ringColor = Colors.redAccent;
    if (player.team == Team.B) ringColor = Colors.blueAccent;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFF1F2833),
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        player.profile?.firstName?.substring(0, 1).toUpperCase() ?? '?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.4,
        ),
      ),
    );
  }
}

class TacticalPitchPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final grassPaint = Paint()
      ..color = const Color(0xFF1B5E20)
      ..style = PaintingStyle.fill;

    // 1. Grass
    canvas.drawRect(Offset.zero & size, grassPaint);
    _drawGrassStrips(canvas, size);

    // 2. Lines
    final w = size.width;
    final h = size.height;
    final center = Offset(w / 2, h / 2);

    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint); // Outer

    // Determine orientation based on aspect ratio
    bool isVertical = h > w;

    if (isVertical) {
      // Vertical Pitch
      canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), paint); // Center Line

      // Goals / Penalties
      final penaltyW = w * 0.6;
      final penaltyH = h * 0.15;

      canvas.drawRect(
        Rect.fromLTWH((w - penaltyW) / 2, 0, penaltyW, penaltyH),
        paint,
      ); // Top
      canvas.drawRect(
        Rect.fromLTWH((w - penaltyW) / 2, h - penaltyH, penaltyW, penaltyH),
        paint,
      ); // Bottom
    } else {
      // Horizontal Pitch
      canvas.drawLine(Offset(w / 2, 0), Offset(w / 2, h), paint); // Center Line

      final penaltyH = h * 0.6;
      final penaltyW = w * 0.15;

      canvas.drawRect(
        Rect.fromLTWH(0, (h - penaltyH) / 2, penaltyW, penaltyH),
        paint,
      ); // Left
      canvas.drawRect(
        Rect.fromLTWH(w - penaltyW, (h - penaltyH) / 2, penaltyW, penaltyH),
        paint,
      ); // Right
    }

    // Center Circle
    canvas.drawCircle(center, (isVertical ? w : h) * 0.15, paint);
    canvas.drawCircle(center, 3, paint..style = PaintingStyle.fill);
  }

  void _drawGrassStrips(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.black.withOpacity(0.05)
      ..style = PaintingStyle.fill;

    // Draw strips based on orientation?
    // Traditionally strips are perpendicular to touchline.
    // Let's just draw generic grid or strips.

    bool isVertical = size.height > size.width;
    int strips = 10;

    if (isVertical) {
      final stripHeight = size.height / strips;
      for (int i = 0; i < strips; i += 2) {
        canvas.drawRect(
          Rect.fromLTWH(0, i * stripHeight, size.width, stripHeight),
          paint,
        );
      }
    } else {
      final stripWidth = size.width / strips;
      for (int i = 0; i < strips; i += 2) {
        canvas.drawRect(
          Rect.fromLTWH(i * stripWidth, 0, stripWidth, size.height),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
