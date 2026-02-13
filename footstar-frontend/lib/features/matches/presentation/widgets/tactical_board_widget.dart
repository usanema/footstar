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
  @override
  Widget build(BuildContext context) {
    if (widget.isFullScreen) {
      return _buildFullScreenPitch(context);
    }
    return _buildEmbeddedView(context);
  }

  // ---------------------------------------------------------------------------
  // 1. Embedded View: Team Lists (Cards)
  // ---------------------------------------------------------------------------
  Widget _buildEmbeddedView(BuildContext context) {
    final teamA = widget.players.where((p) => p.team == Team.A).toList();
    final teamB = widget.players.where((p) => p.team == Team.B).toList();

    int strengthA = _calculateTeamStrength(teamA);
    int strengthB = _calculateTeamStrength(teamB);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'SQUAD TACTICS',
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.5,
                ),
              ),
              if (widget.onExpand != null)
                IconButton(
                  icon: const Icon(Icons.fullscreen, color: AppColors.accent),
                  onPressed: widget.onExpand,
                  tooltip: 'Open Tactical Pitch',
                ),
            ],
          ),
        ),

        // Team Lists
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Team A Card
              Expanded(
                child: _buildTeamCard(
                  team: Team.A,
                  players: teamA,
                  strength: strengthA,
                  color: Colors.redAccent.withOpacity(0.8),
                ),
              ),
              const SizedBox(width: 12),
              // Team B Card
              Expanded(
                child: _buildTeamCard(
                  team: Team.B,
                  players: teamB,
                  strength: strengthB,
                  color: Colors.blueAccent.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTeamCard({
    required Team team,
    required List<MatchPlayerModel> players,
    required int strength,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1F2833), // Carbon Grey
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white10),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                team == Team.A ? "TEAM A" : "TEAM B",
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  "$strength",
                  style: const TextStyle(
                    color: AppColors.accent, // Golden/Neon
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white10),
          // Player List
          if (players.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                "- Empty -",
                style: TextStyle(color: Colors.white30, fontSize: 12),
              ),
            )
          else
            ...players.map(
              (p) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 10,
                      backgroundColor: color.withOpacity(0.2),
                      backgroundImage: p.profile?.avatarUrl != null
                          ? NetworkImage(p.profile!.avatarUrl!)
                          : null,
                      child: p.profile?.avatarUrl == null
                          ? Text(
                              p.profile?.firstName?[0] ?? '?',
                              style: TextStyle(color: color, fontSize: 10),
                            )
                          : null,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        p.profile?.firstName ?? 'Unknown',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // 2. Full Screen Pitch View
  // ---------------------------------------------------------------------------
  Widget _buildFullScreenPitch(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B0C10), // Pitch Black
      appBar: AppBar(
        title: const Text(
          'TACTICAL BOARD',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(child: _buildInteractivePitch(constraints));
        },
      ),
    );
  }

  Widget _buildInteractivePitch(BoxConstraints constraints) {
    // Aspect Ratio 3:2 for Horizontal Pitch
    double aspectRatio = 3 / 2;
    double width = constraints.maxWidth;
    double height = width / aspectRatio;

    if (height > constraints.maxHeight) {
      height = constraints.maxHeight;
      width = height * aspectRatio;
    }

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        children: [
          // 1. The Pitch (Background)
          _buildPitchBackground(),

          // 2. Drag Target (Touch Handling)
          Positioned.fill(
            child: Builder(
              builder: (pitchContext) {
                return DragTarget<MatchPlayerModel>(
                  onWillAcceptWithDetails: (details) {
                    return true; // Draggable prevents unauthorized drags, so we can accept all valid data types
                  },
                  onAcceptWithDetails: (details) {
                    _handleDrop(pitchContext, details, width, height);
                  },
                  builder: (ctx, _, __) =>
                      Container(color: Colors.white.withOpacity(0.01)),
                );
              },
            ),
          ),

          // 3. Players (Draggable Tokens)
          ...widget.players.map((p) => _buildPlayerToken(p, width, height)),
        ],
      ),
    );
  }

  Widget _buildPitchBackground() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF1B5E20).withOpacity(0.8),
            const Color(0xFF0D3312).withOpacity(0.9),
          ],
        ),
        border: Border.all(color: Colors.white24, width: 4),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Stack(
        children: [
          // Center Line
          Center(
            child: Container(
              width: 2,
              height: double.infinity,
              color: Colors.white24,
            ),
          ),
          // Center Circle
          Center(
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white24, width: 2),
              ),
            ),
          ),
          // Team Labels (Overlay)
          Positioned(
            top: 20,
            left: 20,
            child: Text(
              "TEAM A",
              style: TextStyle(
                color: Colors.redAccent.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
          Positioned(
            top: 20,
            right: 20,
            child: Text(
              "TEAM B",
              style: TextStyle(
                color: Colors.blueAccent.withOpacity(0.5),
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerToken(
    MatchPlayerModel player,
    double pitchW,
    double pitchH,
  ) {
    // Default coords if null
    double x = player.pitchX ?? 0.5;
    double y = player.pitchY ?? 0.5;

    // Fix if unassigned
    if (player.pitchX == null) {
      if (player.team == Team.A) x = 0.25;
      if (player.team == Team.B) x = 0.75;
    }

    bool canMove = widget.isAdmin || (player.profileId == widget.currentUserId);

    Widget token = _buildTokenVisual(player);

    return Positioned(
      left: x * pitchW - 20, // Center radius 20
      top: y * pitchH - 20,
      child: canMove
          ? Draggable<MatchPlayerModel>(
              data: player,
              feedback: Transform.scale(scale: 1.2, child: token),
              childWhenDragging: Opacity(opacity: 0.5, child: token),
              child: token,
            )
          : token,
    );
  }

  Widget _buildTokenVisual(MatchPlayerModel player) {
    Color ringColor = Colors.white;
    if (player.team == Team.A) ringColor = Colors.redAccent;
    if (player.team == Team.B) ringColor = Colors.blueAccent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.all(2), // Ring width
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: ringColor,
            boxShadow: [
              BoxShadow(color: ringColor.withOpacity(0.5), blurRadius: 8),
            ],
          ),
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF1F2833),
            backgroundImage: player.profile?.avatarUrl != null
                ? NetworkImage(player.profile!.avatarUrl!)
                : null,
            child: player.profile?.avatarUrl == null
                ? Text(
                    player.profile?.firstName?[0] ?? '?',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            player.profile?.firstName ?? "Uni",
            style: const TextStyle(color: Colors.white, fontSize: 10),
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // 3. Logic: Strength & Drop Handling
  // ---------------------------------------------------------------------------
  int _calculateTeamStrength(List<MatchPlayerModel> teamPlayers) {
    return teamPlayers.fold(0, (sum, p) => sum + (p.profile?.totalPoints ?? 0));
  }

  void _handleDrop(
    BuildContext context,
    DragTargetDetails<MatchPlayerModel> details,
    double w,
    double h,
  ) {
    final RenderBox box = context.findRenderObject() as RenderBox;
    final localPos = box.globalToLocal(details.offset);

    double newX = localPos.dx / w;
    double newY = localPos.dy / h;

    // Clamp to pitch
    newX = newX.clamp(0.05, 0.95);
    newY = newY.clamp(0.05, 0.95);

    // Update XY
    if (widget.onPlayerMovedPitch != null) {
      widget.onPlayerMovedPitch!(details.data, newX, newY);
    }

    // Determine Team based on side (Left < 0.5 > Right)
    Team newTeam = newX < 0.5 ? Team.A : Team.B;
    if (details.data.team != newTeam) {
      widget.onPlayerMovedTeam(details.data, newTeam);
    }
  }
}
