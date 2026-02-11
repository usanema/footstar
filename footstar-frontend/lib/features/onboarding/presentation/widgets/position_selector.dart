import 'package:flutter/material.dart';
import '../../../../core/app_theme.dart';

class PositionSelector extends StatefulWidget {
  final List<String> selectedPositions;
  final ValueChanged<List<String>> onPositionsChanged;

  const PositionSelector({
    super.key,
    required this.selectedPositions,
    required this.onPositionsChanged,
  });

  @override
  State<PositionSelector> createState() => _PositionSelectorState();
}

class _PositionSelectorState extends State<PositionSelector> {
  String? _focusedPosition;

  @override
  void initState() {
    super.initState();
    // Default focus to first selected or null
    if (widget.selectedPositions.isNotEmpty) {
      _focusedPosition = widget.selectedPositions.first;
    }
  }

  void _handleTap(String code) {
    setState(() => _focusedPosition = code);

    final current = List<String>.from(widget.selectedPositions);
    if (current.contains(code)) {
      current.remove(code);
    } else {
      if (current.length < 3) {
        current.add(code);
      } else {
        // Already 3 selected. Maybe replace the last one?
        // Or just notify user? For now, strict limit.
        return;
      }
    }
    widget.onPositionsChanged(current);
  }

  @override
  Widget build(BuildContext context) {
    // 12 Positions Data
    final positions = [
      _Pos(
        'ST',
        'STRIKER',
        const Alignment(0, -0.8),
        desc: 'Goal Machine',
        traits: ['Finishing', 'Strength'],
        examples: ['Lewandowski', 'Haaland'],
      ),
      _Pos(
        'LW',
        'LEFT WING',
        const Alignment(-0.8, -0.7),
        desc: 'Speedster',
        traits: ['Pace', 'Dribbling'],
        examples: ['Vinicius Jr', 'Neymar'],
      ),
      _Pos(
        'RW',
        'RIGHT WING',
        const Alignment(0.8, -0.7),
        desc: 'Speedster',
        traits: ['Pace', 'Cut-inside'],
        examples: ['Salah', 'Saka'],
      ),
      _Pos(
        'CAM',
        'ATTACKING MID',
        const Alignment(0, -0.4),
        desc: 'Playmaker',
        traits: ['Vision', 'Passing'],
        examples: ['De Bruyne', 'Bellingham'],
      ),
      _Pos(
        'LM',
        'LEFT MID',
        const Alignment(-0.8, -0.1),
        desc: 'Wide Engine',
        traits: ['Stamina', 'Crosses'],
        examples: ['Son', 'Kostic'],
      ),
      _Pos(
        'CM',
        'CENTER MID',
        const Alignment(0, -0.1),
        desc: 'Orchestrator',
        traits: ['Control', 'Passing'],
        examples: ['Modrić', 'Kroos'],
      ),
      _Pos(
        'RM',
        'RIGHT MID',
        const Alignment(0.8, -0.1),
        desc: 'Wide Engine',
        traits: ['Stamina', 'Workrate'],
        examples: ['Valverde', 'Beckham'],
      ),
      _Pos(
        'CDM',
        'DEFENSIVE MID',
        const Alignment(0, 0.25),
        desc: 'The Wall',
        traits: ['Tackling', 'Intercepting'],
        examples: ['Rodri', 'Casemiro'],
      ),
      _Pos(
        'LB',
        'LEFT BACK',
        const Alignment(-0.8, 0.6),
        desc: 'Fullback',
        traits: ['Speed', 'Defense'],
        examples: ['Davies', 'Robertson'],
      ),
      _Pos(
        'CB',
        'CENTER BACK',
        const Alignment(0, 0.6),
        desc: 'Tower',
        traits: ['Strength', 'Heading'],
        examples: ['Van Dijk', 'Rüdiger'],
      ),
      _Pos(
        'RB',
        'RIGHT BACK',
        const Alignment(0.8, 0.6),
        desc: 'Fullback',
        traits: ['Speed', 'Overlap'],
        examples: ['Hakimi', 'Trent'],
      ),
      _Pos(
        'GK',
        'GOALKEEPER',
        const Alignment(0, 0.9),
        desc: 'Guardian',
        traits: ['Reflexes', 'Diving'],
        examples: ['Courtois', 'Alisson'],
      ),
    ];

    // Determine data for info panel
    final infoData = _focusedPosition != null
        ? positions.firstWhere((p) => p.code == _focusedPosition)
        : (widget.selectedPositions.isNotEmpty
              ? positions.firstWhere(
                  (p) => p.code == widget.selectedPositions.first,
                )
              : positions[0]);

    return SizedBox(
      height: 320,
      child: Row(
        children: [
          // LEFT: Mini Pitch (2/3 -> Flex 2)
          Expanded(
            flex: 2,
            child: AspectRatio(
              aspectRatio: 3 / 4,
              child: Container(
                margin: const EdgeInsets.only(right: 12),
                decoration: BoxDecoration(
                  color: AppColors.surface.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.secondary.withValues(alpha: 0.3),
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _PitchPainter(
                          color: AppColors.secondary.withValues(alpha: 0.3),
                        ),
                      ),
                    ),
                    ...positions.map((p) => _buildPositionNode(p)),
                  ],
                ),
              ),
            ),
          ),

          // RIGHT: Info Panel (1/3 -> Flex 1)
          Expanded(
            flex: 1,
            child: widget.selectedPositions.isEmpty && _focusedPosition == null
                ? Center(
                    child: Text(
                      'Select up to 3 positions',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  )
                : _buildInfoCard(infoData),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(_Pos data) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: Container(
        key: ValueKey(data.code),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Code & Name
            Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                data.code,
                style: AppTextStyles.labelSmall.copyWith(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              data.label,
              style: AppTextStyles.labelSmall.copyWith(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            const Divider(color: AppColors.secondary, thickness: 0.5),
            const SizedBox(height: 8),

            // Description
            Text(
              data.desc.toUpperCase(),
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.secondary,
                fontSize: 9,
                letterSpacing: 1.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            // Traits
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: data.traits
                  .map(
                    (t) => Text(
                      t,
                      style: AppTextStyles.bodySmall.copyWith(
                        fontSize: 9,
                        color: Colors.white70,
                      ),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 12),

            // Examples
            Text(
              'players:',
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.secondary,
                fontSize: 10,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              data.examples.join(', '),
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPositionNode(_Pos pos) {
    final isSelected = widget.selectedPositions.contains(pos.code);
    final isFocused = _focusedPosition == pos.code;

    final selectionIndex = widget.selectedPositions.indexOf(pos.code) + 1;
    final primaryColor = AppColors.primary;

    return Align(
      alignment: pos.align,
      child: GestureDetector(
        onTap: () => _handleTap(pos.code),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isSelected ? primaryColor : AppColors.surface,
            border: Border.all(
              color: isSelected
                  ? primaryColor
                  : (isFocused
                        ? Colors.white
                        : AppColors.secondary.withValues(alpha: 0.5)),
              width: isSelected ? 2 : 1.5,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: primaryColor.withValues(alpha: 0.5),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: isSelected
                ? Text(
                    '$selectionIndex',
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 14,
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : Text(
                    pos.code,
                    style: AppTextStyles.labelSmall.copyWith(
                      fontSize: 9,
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _Pos {
  final String code;
  final String label;
  final Alignment align;
  final String desc;
  final List<String> traits;
  final List<String> examples;

  _Pos(
    this.code,
    this.label,
    this.align, {
    required this.desc,
    required this.traits,
    required this.examples,
  });
}

class _PitchPainter extends CustomPainter {
  final Color color;

  _PitchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    final w = size.width;
    final h = size.height;

    // Boundary
    // canvas.drawRect(Rect.fromLTWH(0, 0, w, h), paint); // Optional if container has border

    // Halfway line
    canvas.drawLine(Offset(0, h / 2), Offset(w, h / 2), paint);
    canvas.drawCircle(Offset(w / 2, h / 2), w * 0.12, paint);

    // Penalty Boxes
    // Top (Opponent)
    final boxW = w * 0.6;
    final boxH = h * 0.15;
    canvas.drawRect(Rect.fromLTWH((w - boxW) / 2, 0, boxW, boxH), paint);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w / 2, boxH),
        width: boxW * 0.4,
        height: boxW * 0.4,
      ),
      0,
      3.14,
      false,
      paint,
    );

    // Bottom (Home)
    canvas.drawRect(Rect.fromLTWH((w - boxW) / 2, h - boxH, boxW, boxH), paint);
    canvas.drawArc(
      Rect.fromCenter(
        center: Offset(w / 2, h - boxH),
        width: boxW * 0.4,
        height: boxW * 0.4,
      ),
      3.14,
      3.14,
      false,
      paint,
    );

    // Goals (Small filled rects)
    paint.style = PaintingStyle.fill;
    paint.color = color.withValues(alpha: 0.5);
    canvas.drawRect(Rect.fromLTWH((w - 50) / 2, -5, 50, 5), paint);
    canvas.drawRect(Rect.fromLTWH((w - 50) / 2, h, 50, 5), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
