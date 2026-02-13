import 'dart:async';
import 'package:flutter/material.dart';
import 'package:footstars/core/app_theme.dart';
import 'package:footstars/features/explore/data/search_repository.dart';
import 'package:footstars/features/explore/presentation/widgets/match_search_card.dart';
import 'package:footstars/features/explore/presentation/widgets/group_search_card.dart';
import 'package:footstars/features/explore/presentation/widgets/player_search_card.dart';
import 'package:footstars/features/matches/data/models/match_model.dart';
import 'package:footstars/features/groups/data/models/group_model.dart';
import 'package:footstars/features/groups/presentation/group_details_screen.dart';
import 'package:footstars/features/onboarding/data/models/profile_model.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  final SearchRepository _searchRepository = SearchRepository();
  final TextEditingController _searchController = TextEditingController();
  late TabController _tabController;

  Timer? _debounce;
  bool _isLoading = false;

  List<MatchModel> _matches = [];
  List<GroupModel> _groups = [];
  List<ProfileModel> _players = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      _performSearch(_searchController.text);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.isEmpty) {
      setState(() {
        _matches = [];
        _groups = [];
        _players = [];
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _searchRepository.searchMatches(query),
        _searchRepository.searchGroups(query),
        _searchRepository.searchPlayers(query),
      ]);

      setState(() {
        _matches = results[0] as List<MatchModel>;
        _groups = results[1] as List<GroupModel>;
        _players = results[2] as List<ProfileModel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Search failed: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.surface,
        elevation: 0,
        title: Text(
          'Explore',
          style: AppTextStyles.headlineMedium.copyWith(
            color: AppColors.textPrimary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(110),
          child: Column(
            children: [
              // Search Field
              Padding(
                padding: const EdgeInsets.all(16),
                child: TextField(
                  controller: _searchController,
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Search matches, groups, or players...',
                    hintStyle: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    prefixIcon: Icon(Icons.search, color: AppColors.primary),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              Icons.clear,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              _searchController.clear();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: AppColors.background,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppColors.primary.withOpacity(0.3),
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary),
                    ),
                  ),
                ),
              ),
              // Tabs
              TabBar(
                controller: _tabController,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.sports_soccer, size: 18),
                        const SizedBox(width: 4),
                        Text('Matches (${_matches.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.group, size: 18),
                        const SizedBox(width: 4),
                        Text('Groups (${_groups.length})'),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.person, size: 18),
                        const SizedBox(width: 4),
                        Text('Players (${_players.length})'),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : TabBarView(
              controller: _tabController,
              children: [
                _buildMatchesList(),
                _buildGroupsList(),
                _buildPlayersList(),
              ],
            ),
    );
  }

  Widget _buildMatchesList() {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search,
        message: 'Start typing to search for matches',
      );
    }

    if (_matches.isEmpty) {
      return _buildEmptyState(
        icon: Icons.sports_soccer,
        message: 'No matches found',
      );
    }

    return ListView.builder(
      itemCount: _matches.length,
      itemBuilder: (context, index) {
        final match = _matches[index];
        return MatchSearchCard(
          match: match,
          onTap: () {
            // TODO: Navigate to match details
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Match details coming soon')),
            );
          },
        );
      },
    );
  }

  Widget _buildGroupsList() {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search,
        message: 'Start typing to search for groups',
      );
    }

    if (_groups.isEmpty) {
      return _buildEmptyState(icon: Icons.group, message: 'No groups found');
    }

    return ListView.builder(
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        return GroupSearchCard(
          group: group,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GroupDetailsScreen(group: group),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildPlayersList() {
    if (_searchController.text.isEmpty) {
      return _buildEmptyState(
        icon: Icons.search,
        message: 'Start typing to search for players',
      );
    }

    if (_players.isEmpty) {
      return _buildEmptyState(icon: Icons.person, message: 'No players found');
    }

    return ListView.builder(
      itemCount: _players.length,
      itemBuilder: (context, index) {
        final player = _players[index];
        return PlayerSearchCard(
          player: player,
          onTap: () {
            // TODO: Navigate to player profile
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Player profile coming soon')),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState({required IconData icon, required String message}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondary.withOpacity(0.5)),
          const SizedBox(height: 16),
          Text(
            message,
            style: AppTextStyles.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
