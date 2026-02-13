import 'package:flutter/material.dart';
import 'package:footstars/core/app_theme.dart';
import 'package:footstars/features/matches/data/match_repository.dart';
import 'package:footstars/features/matches/data/models/match_model.dart';
import '../../groups/data/group_repository.dart';
import '../../groups/data/models/group_model.dart';
import 'widgets/next_match_card.dart';
import 'widgets/groups_carousel.dart';
import 'widgets/compact_match_list.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _matchRepository = MatchRepository();
  final _groupRepository = GroupRepository();

  List<MatchModel>? _upcomingMatches;
  List<GroupModel>? _myGroups;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final matchesFuture = _matchRepository.getMyUpcomingMatches();
      final groupsFuture = _groupRepository.getMyGroups();

      final results = await Future.wait([matchesFuture, groupsFuture]);

      if (mounted) {
        setState(() {
          _upcomingMatches = results[0] as List<MatchModel>;
          _myGroups = results[1] as List<GroupModel>;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading dashboard: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    final nextMatch = _upcomingMatches != null && _upcomingMatches!.isNotEmpty
        ? _upcomingMatches!.first
        : null;

    final otherMatches =
        _upcomingMatches != null && _upcomingMatches!.length > 1
        ? _upcomingMatches!.sublist(1)
        : <MatchModel>[];

    // If no matches at all, use empty list for "other matches" to pass down.
    // We will handle empty states inside the widgets or here.

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'FOOTSTAR',
          style: AppTextStyles.displayMedium.copyWith(
            color: AppColors.primary,
            letterSpacing: 2.0,
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.notifications_outlined,
              color: AppColors.textPrimary,
            ),
            onPressed: () {}, // TODO: Notifications
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HERO SECTION
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: NextMatchCard(match: nextMatch),
            ),

            const SizedBox(height: 16),

            // GROUPS CAROUSEL
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'YOUR SQUADS',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),
            GroupsCarousel(groups: _myGroups ?? [], onRefresh: _loadData),

            const SizedBox(height: 24),

            // UPCOMING MATCHES LIST
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Text(
                'UPCOMING FIXTURES',
                style: AppTextStyles.labelLarge.copyWith(
                  color: AppColors.textSecondary,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 8),
            CompactMatchList(matches: otherMatches),
          ],
        ),
      ),
    );
  }
}
