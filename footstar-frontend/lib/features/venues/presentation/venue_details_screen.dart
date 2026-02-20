import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:footstars/core/app_theme.dart';
import 'package:footstars/features/venues/data/models/venue_model.dart';
import 'package:footstars/features/venues/data/venue_repository.dart';
import 'package:footstars/features/matches/data/models/match_model.dart';
import 'package:footstars/features/matches/presentation/match_details_screen.dart';

class VenueDetailsScreen extends StatefulWidget {
  final VenueModel venue;

  const VenueDetailsScreen({super.key, required this.venue});

  @override
  State<VenueDetailsScreen> createState() => _VenueDetailsScreenState();
}

class _VenueDetailsScreenState extends State<VenueDetailsScreen> {
  final _repo = VenueRepository();
  List<MatchModel> _upcomingMatches = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMatches();
  }

  Future<void> _loadMatches() async {
    try {
      final matches = await _repo.fetchUpcomingMatches(widget.venue.id);
      if (mounted)
        setState(() {
          _upcomingMatches = matches;
          _isLoading = false;
        });
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final venue = widget.venue;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // ─── Hero AppBar ───
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.surface,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                venue.name,
                style: AppTextStyles.headlineSmall.copyWith(
                  fontSize: 16,
                  shadows: [const Shadow(blurRadius: 4, color: Colors.black54)],
                ),
              ),
              background: venue.photoUrl != null
                  ? Image.network(venue.photoUrl!, fit: BoxFit.cover)
                  : _buildPlaceholderHero(),
            ),
          ),

          // ─── Info section ───
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _InfoRow(Icons.location_on_outlined, venue.address),
                  const SizedBox(height: 8),
                  _InfoRow(
                    Icons.grass_outlined,
                    venue.surfaceLabel,
                    unknownStyle: venue.surface == null,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    Icons.lightbulb_outline,
                    venue.hasLights == null
                        ? 'Oświetlenie: nieznane'
                        : venue.hasLights!
                        ? 'Oświetlenie: tak'
                        : 'Oświetlenie: brak',
                    unknownStyle: venue.hasLights == null,
                  ),
                  if (venue.description != null &&
                      venue.description!.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      venue.description!,
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Divider(color: Colors.white12),
                  const SizedBox(height: 16),
                  // ─── Upcoming matches ───
                  Text(
                    'NADCHODZĄCE MECZE',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textSecondary,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),

          // ─── Matches list ───
          if (_isLoading)
            const SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: CircularProgressIndicator(),
                ),
              ),
            )
          else if (_upcomingMatches.isEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 8,
                ),
                child: Text(
                  'Brak zaplanowanych meczów w tym obiekcie.',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final match = _upcomingMatches[index];
                return _MatchTile(match: match);
              }, childCount: _upcomingMatches.length),
            ),

          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  Widget _buildPlaceholderHero() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [AppColors.primary.withOpacity(0.6), AppColors.background],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.stadium,
          size: 80,
          color: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool unknownStyle;

  const _InfoRow(this.icon, this.text, {this.unknownStyle = false});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyMedium.copyWith(
              color: unknownStyle
                  ? AppColors.textSecondary
                  : AppColors.textPrimary,
              fontStyle: unknownStyle ? FontStyle.italic : FontStyle.normal,
            ),
          ),
        ),
      ],
    );
  }
}

class _MatchTile extends StatelessWidget {
  final MatchModel match;

  const _MatchTile({required this.match});

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat(
      'EEE, d MMM • HH:mm',
      'pl_PL',
    ).format(match.date);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => MatchDetailsScreen(match: match, isAdmin: false),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.sports_soccer,
                  color: AppColors.primary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      match.groupName ?? 'Mecz',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppColors.textSecondary,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
