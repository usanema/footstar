import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/match_repository.dart';
import '../data/models/match_model.dart';
import '../data/models/match_player_model.dart';
import '../domain/services/team_balancer_service.dart';
import '../domain/services/pitch_positioning_service.dart'; // Added
import 'widgets/tactical_board_widget.dart';

import 'package:footstars/core/app_theme.dart';
import 'widgets/match_hero_section.dart';
import 'widgets/status_selector.dart';
import 'widgets/player_list_card.dart';

class MatchDetailsScreen extends StatefulWidget {
  final MatchModel match;
  final bool isAdmin; // Added

  const MatchDetailsScreen({
    super.key,
    required this.match,
    this.isAdmin = false, // Default false
  });

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  final MatchRepository _repository = MatchRepository();
  String? _currentUserId;

  List<MatchPlayerModel> _players = []; // Changed from nullable
  bool _isLoading = true;
  final TeamBalancerService _balancer = TeamBalancerService();
  final PitchPositioningService _positioner = PitchPositioningService();

  MatchPlayerModel? get _currentUserPlayer {
    if (_currentUserId == null) return null;
    try {
      return _players.firstWhere((p) => p.profileId == _currentUserId);
    } catch (_) {
      return null;
    }
  }

  bool _isAdmin = false;

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;
    _isAdmin = widget.isAdmin;
    if (!_isAdmin) {
      _checkAdminStatus();
    }
    _fetchMatchDetails();
  }

  Future<void> _checkAdminStatus() async {
    if (_currentUserId == null) return;
    try {
      final response = await Supabase.instance.client
          .from('group_members')
          .select('role')
          .eq('group_id', widget.match.groupId)
          .eq('profile_id', _currentUserId!)
          .maybeSingle();

      if (response != null && mounted) {
        final role = response['role'] as String;
        if (role == 'ADMIN') {
          setState(() => _isAdmin = true);
        }
      }
    } catch (e) {
      debugPrint('Error checking admin status: $e');
    }
  }

  Future<void> _fetchMatchDetails() async {
    setState(() => _isLoading = true);
    try {
      final players = await _repository.getMatchPlayers(widget.match.id);
      if (mounted) {
        setState(() {
          _players = players;
          // _currentUserPlayer logic removed, now derived in build
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading match details: $e')),
        ); // Updated message
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _updateStatus(PlayerStatus status) async {
    if (_currentUserId == null) return;
    try {
      await _repository.updatePlayerStatus(
        matchId: widget.match.id,
        status: status,
      );

      if (status == PlayerStatus.IN) {
        await _autoBalanceTeams();
      } else {
        _fetchMatchDetails();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _autoBalanceTeams() async {
    final players = await _repository.getMatchPlayers(widget.match.id);
    final inPlayers = players
        .where((p) => p.status == PlayerStatus.IN)
        .toList();

    // 1. Balance Teams
    final balanced = _balancer.balanceTeams(inPlayers);

    // 2. Assign Positions
    final positioned = _positioner.assignPositions(balanced);

    if (mounted) {
      setState(() {
        _players = players.map(
          (p) {
            final positionedPlayer = positioned.firstWhere(
              (bp) => bp.id == p.id,
              orElse: () => p,
            );
            return positionedPlayer;
          },
        ).toList(); // Fixed: Added .toList() and cast if needed, but map returns Iterable<MatchPlayerModel> effectively if all returns are such.
      });
    }

    // 3. Save to DB
    for (var p in positioned) {
      if (p.team != null) {
        await _repository.updatePlayerTeam(p.id, p.team!);
      }
      if (p.pitchX != null && p.pitchY != null) {
        await _repository.updatePlayerPosition(
          matchPlayerId: p.id,
          x: p.pitchX!,
          y: p.pitchY!,
        );
      }
    }
  }

  Future<void> _onPlayerMoved(MatchPlayerModel player, Team targetTeam) async {
    setState(() {
      final index = _players.indexWhere((p) => p.id == player.id);
      if (index != -1) {
        _players[index] = _players[index].copyWith(team: targetTeam);
      }
    });
    try {
      await _repository.updatePlayerTeam(player.id, targetTeam);
    } catch (e) {
      _fetchMatchDetails();
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error moving player: $e')));
    }
  }

  Future<void> _toggleCar(bool? hasCar) async {
    final player = _currentUserPlayer;
    if (player == null) return;
    try {
      await _repository.updatePlayerStatus(
        matchId: widget.match.id,
        status: player.status,
        hasCar: hasCar,
        carSeats: player.carSeats,
      );
      _fetchMatchDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating car status: $e')),
        );
      }
    }
  }

  Future<void> _updateSeats(int seats) async {
    final player = _currentUserPlayer;
    if (player == null) return;
    try {
      await _repository.updatePlayerStatus(
        matchId: widget.match.id,
        status: player.status,
        hasCar: player.hasCar,
        carSeats: seats,
      );
      _fetchMatchDetails();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating car seats: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
      );
    }

    // Determine current user status from list (more reliable than local state sometimes)
    final currentUserPlayer = _currentUserPlayer;
    final currentStatus = currentUserPlayer?.status ?? PlayerStatus.UNKNOWN;

    // Filter players for display
    final inPlayers = _players
        .where((p) => p.status == PlayerStatus.IN)
        .toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'MATCH HUB',
          style: AppTextStyles.headlineSmall.copyWith(fontSize: 20),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: RefreshIndicator(
        onRefresh: _fetchMatchDetails,
        color: AppColors.primary,
        backgroundColor: AppColors.surface,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 100), // Top spacing for AppBar
              // 1. Hero Section ("Stadium Pass")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: MatchHeroSection(match: widget.match),
              ),
              const SizedBox(height: 24),

              // 2. Attendance Controls ("Locker Room")
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: StatusSelector(
                  currentStatus: currentStatus,
                  isLoading: _isLoading,
                  onStatusChanged: (newStatus) => _updateStatus(newStatus),
                ),
              ),
              const SizedBox(height: 24),

              // 3. Player List & Carpooling ("The Squad")
              // Only show if user is part of the match context (even if OUT or RESERVE)
              if (_currentUserId != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: PlayerListCard(
                    players: inPlayers,
                    currentUserId: _currentUserId!,
                    onToggleCar: (val) => _toggleCar(val),
                    onUpdateSeats: (seats) => _updateSeats(seats),
                  ),
                ),
              if (_currentUserId != null) const SizedBox(height: 24),

              // 4. Team Composition ("Tactical Board")
              // Only show if there are players IN
              if (inPlayers.isNotEmpty)
                TacticalBoardWidget(
                  players: inPlayers,
                  isAdmin: _isAdmin,
                  currentUserId: _currentUserId, // Passed here
                  onPlayerMovedTeam: _onPlayerMoved,
                  onPlayerMovedPitch: _updatePosition,
                  onExpand: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => Scaffold(
                          backgroundColor: Colors.black,
                          body: SafeArea(
                            child: Stack(
                              children: [
                                TacticalBoardWidget(
                                  players: _players
                                      .where((p) => p.status == PlayerStatus.IN)
                                      .toList(),
                                  isAdmin: _isAdmin,
                                  currentUserId: _currentUserId, // Passed here
                                  isFullScreen: true,
                                  onPlayerMovedTeam: _onPlayerMoved,
                                  onPlayerMovedPitch: _updatePosition,
                                ),
                                Positioned(
                                  top: 10,
                                  right: 10,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ).then((_) => _fetchMatchDetails());
                  },
                ),
              const SizedBox(height: 100), // Bottom spacing
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _updatePosition(
    MatchPlayerModel player,
    double x,
    double y,
  ) async {
    setState(() {
      final index = _players.indexWhere((p) => p.id == player.id);
      if (index != -1) {
        _players[index] = _players[index].copyWith(pitchX: x, pitchY: y);
      }
    });

    try {
      await _repository.updatePlayerPosition(
        matchPlayerId: player.id,
        x: x.clamp(0.0, 1.0),
        y: y.clamp(0.0, 1.0),
      );
    } catch (e) {
      _fetchMatchDetails();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error updating position: $e')));
      }
    }
  }

  // Helper methods like _buildHeader, _buildAttendanceControls etc. are removed
  // as they are replaced by standalone widgets.
}
