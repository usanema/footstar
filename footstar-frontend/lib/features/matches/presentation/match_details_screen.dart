import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../data/match_repository.dart';
import '../data/models/match_model.dart';
import '../data/models/match_player_model.dart';
import '../domain/services/team_balancer_service.dart';
import '../domain/services/pitch_positioning_service.dart';
import 'widgets/tactical_board_widget.dart';
import 'widgets/bench_widget.dart'; // Added

import 'package:footstars/core/app_theme.dart';
import 'widgets/match_hero_section.dart';
import 'widgets/status_selector.dart';
import 'widgets/player_list_card.dart';
import 'widgets/weather_widget.dart';

class MatchDetailsScreen extends StatefulWidget {
  final MatchModel match;
  final bool isAdmin;

  const MatchDetailsScreen({
    super.key,
    required this.match,
    this.isAdmin = false,
  });

  @override
  State<MatchDetailsScreen> createState() => _MatchDetailsScreenState();
}

class _MatchDetailsScreenState extends State<MatchDetailsScreen> {
  final MatchRepository _repository = MatchRepository();
  String? _currentUserId;

  List<MatchPlayerModel> _players = [];
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
  bool _isMember = false; // true when user is ACCEPTED group member

  @override
  void initState() {
    super.initState();
    _currentUserId = Supabase.instance.client.auth.currentUser?.id;
    _isAdmin = widget.isAdmin;
    if (widget.isAdmin) {
      // If admin flag is pre-set, user is obviously a member.
      _isMember = true;
    } else {
      _checkMembershipAndAdminStatus();
    }
    _fetchMatchDetails();
  }

  Future<void> _checkMembershipAndAdminStatus() async {
    if (_currentUserId == null) return;
    try {
      final response = await Supabase.instance.client
          .from('group_members')
          .select('role, status')
          .eq('group_id', widget.match.groupId)
          .eq('profile_id', _currentUserId!)
          .maybeSingle();

      if (mounted) {
        if (response != null) {
          final role = response['role'] as String;
          final status = response['status'] as String;
          setState(() {
            _isMember = status == 'ACCEPTED';
            _isAdmin = role == 'ADMIN' && status == 'ACCEPTED';
          });
        } else {
          setState(() {
            _isMember = false;
            _isAdmin = false;
          });
        }
      }
    } catch (e) {
      debugPrint('Error checking membership: $e');
    }
  }

  Future<void> _fetchMatchDetails() async {
    setState(() => _isLoading = true);
    try {
      final players = await _repository.getMatchPlayers(widget.match.id);
      if (mounted) {
        setState(() {
          _players = players;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading match details: $e')),
        );
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
        _players = players.map((p) {
          final positionedPlayer = positioned.firstWhere(
            (bp) => bp.id == p.id,
            orElse: () => p,
          );
          return positionedPlayer;
        }).toList();
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

    final currentUserPlayer = _currentUserPlayer;
    final currentStatus = currentUserPlayer?.status ?? PlayerStatus.UNKNOWN;

    // Filter players for display
    final inPlayers = _players
        .where((p) => p.status == PlayerStatus.IN)
        .toList();

    final placedPlayers = inPlayers
        .where((p) => p.pitchX != null && p.pitchY != null)
        .toList();

    final unplacedPlayers = inPlayers
        .where((p) => p.pitchX == null || p.pitchY == null)
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: MatchHeroSection(
                  match: widget.match,
                  userStatus: currentStatus,
                  onCheckIn: () => _updateStatus(PlayerStatus.IN),
                ),
              ),
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: WeatherWidget(match: widget.match),
              ),
              // --- MEMBER-ONLY CONTENT ---
              if (_isMember) ...[
                const SizedBox(height: 24),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: StatusSelector(
                    currentStatus: currentStatus,
                    isLoading: _isLoading,
                    onStatusChanged: (newStatus) => _updateStatus(newStatus),
                  ),
                ),
                const SizedBox(height: 24),

                if (_currentUserId != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: PlayerListCard(
                      players: inPlayers,
                      currentUserId: _currentUserId!,
                      onToggleCar: (val) => _toggleCar(val),
                      onUpdateSeats: (seats) => _updateSeats(seats),
                      maxPlayers: widget.match.maxPlayers,
                    ),
                  ),
                if (_currentUserId != null) const SizedBox(height: 24),

                if (placedPlayers.isNotEmpty || unplacedPlayers.isNotEmpty) ...[
                  TacticalBoardWidget(
                    players: placedPlayers,
                    isAdmin: _isAdmin,
                    currentUserId: _currentUserId,
                    onPlayerMovedTeam: _onPlayerMoved,
                    onPlayerMovedPitch: _updatePosition,
                    onExpand: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TacticalBoardWidget(
                            players: placedPlayers,
                            isAdmin: _isAdmin,
                            currentUserId: _currentUserId,
                            isFullScreen: true,
                            onPlayerMovedTeam: _onPlayerMoved,
                            onPlayerMovedPitch: _updatePosition,
                          ),
                        ),
                      ).then((_) => _fetchMatchDetails());
                    },
                  ),

                  const SizedBox(height: 16),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: BenchWidget(
                      players: unplacedPlayers,
                      isAdmin: _isAdmin,
                      currentUserId: _currentUserId,
                      onPlayerDropped: _clearPosition,
                    ),
                  ),
                ],
              ] else ...[
                // Non-member banner
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: _buildNonMemberBanner(),
                ),
              ],
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  /// Banner shown to users who are not accepted members of this group.
  Widget _buildNonMemberBanner() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Column(
        children: [
          Icon(Icons.lock_outline, color: AppColors.primary, size: 40),
          const SizedBox(height: 12),
          Text(
            'Members Only',
            style: AppTextStyles.headlineSmall.copyWith(
              color: AppColors.primary,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Join the group to declare attendance, see the roster and tactical board.',
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
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

  Future<void> _clearPosition(MatchPlayerModel player) async {
    setState(() {
      final index = _players.indexWhere((p) => p.id == player.id);
      if (index != -1) {
        // Create a copy with null pitchX/Y.
        // Note: copyWith arguments are nullable, but if I pass null, does it set to null or keep existing?
        // Usually copyWith(val: val ?? this.val) checks for null.
        // If I want to FORCE null, I might need to change MatchPlayerModel copyWith logic or use a specific method.
        // Let's check MatchPlayerModel copyWith.
        // It does: pitchX: pitchX ?? this.pitchX.
        // So passing null will NOT clear it.
        // I need to modify MatchPlayerModel or use a workaround.
        // For now, I'll assumre I can't easily clear it with copyWith unless I change it.
        // Workaround: Use a sentinel value if needed, OR modify MatchPlayerModel.
        // Best approach: Modofy MatchPlayerModel to allow clearing.
        // Or direct assignment if mutable (it's final).
        // I will modify MatchPlayerModel to accept a flag or nullable wrapper.
        // OR better: Create a new instance manually.
        _players[index] = MatchPlayerModel(
          id: player.id,
          matchId: player.matchId,
          profileId: player.profileId,
          status: player.status,
          team: player.team,
          pitchX: null,
          pitchY: null,
          hasCar: player.hasCar,
          carSeats: player.carSeats,
          profile: player.profile,
        );
      }
    });

    try {
      // Repository needs a method to clear position.
      // updatePlayerPosition takes double x, double y. Not nullable?
      // I should check `MatchRepository`.
      // If Supabase table allows null, I can send null.
      // But `updatePlayerPosition` might require doubles.
      await _repository.clearPlayerPosition(player.id);
    } catch (e) {
      _fetchMatchDetails();
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error clearing position: $e')));
      }
    }
  }
}
