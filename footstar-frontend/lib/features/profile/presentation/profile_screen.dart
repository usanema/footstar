import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:footstars/core/app_theme.dart';
import 'package:footstars/features/onboarding/data/models/profile_model.dart';
import 'package:footstars/features/onboarding/presentation/widgets/skill_hexagon.dart';
import 'package:footstars/features/profile/data/models/player_match_result_model.dart';
import 'package:footstars/features/profile/data/profile_screen_repository.dart';
import 'package:footstars/features/profile/presentation/widgets/badges_widget.dart';
import 'package:footstars/features/profile/presentation/widgets/form_strip_widget.dart';
import 'package:footstars/features/profile/presentation/widgets/profile_header_widget.dart';
import 'package:footstars/features/profile/presentation/widgets/stats_grid_widget.dart';

class ProfileScreen extends StatefulWidget {
  final String?
  profileId; // null = current user, non-null = other player (read-only)

  const ProfileScreen({super.key, this.profileId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repo = ProfileScreenRepository();

  ProfileModel? _profile;
  List<PlayerMatchResultModel> _lastMatches = [];
  bool _isLoading = true;
  String? _error;

  bool get _isViewingOther => widget.profileId != null;

  String? get _targetUserId =>
      widget.profileId ?? Supabase.instance.client.auth.currentUser?.id;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = _targetUserId;
      if (userId == null) {
        setState(() {
          _error = 'Nie jesteś zalogowany';
          _isLoading = false;
        });
        return;
      }

      final results = await Future.wait([
        _repo.getProfile(userId),
        _repo.getLastMatchResults(userId),
      ]);

      setState(() {
        _profile = results[0] as ProfileModel?;
        _lastMatches = results[1] as List<PlayerMatchResultModel>;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Wystąpił błąd ładowania profilu';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await Supabase.instance.client.auth.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: _isViewingOther ? const BackButton(color: Colors.white) : null,
        title: Text(
          _isViewingOther ? 'Profil gracza' : 'Profil',
          style: AppTextStyles.headlineSmall.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          if (!_isViewingOther)
            IconButton(
              onPressed: _logout,
              icon: const Icon(Icons.logout, color: Colors.white54),
              tooltip: 'Wyloguj',
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : _error != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 12),
                  Text(
                    _error!,
                    style: AppTextStyles.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadData,
                    child: const Text('Spróbuj ponownie'),
                  ),
                ],
              ),
            )
          : _profile == null
          ? Center(
              child: Text(
                'Profil nie istnieje',
                style: AppTextStyles.bodyMedium,
              ),
            )
          : RefreshIndicator(
              color: AppColors.primary,
              onRefresh: _loadData,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header
                    ProfileHeaderWidget(profile: _profile!),

                    const SizedBox(height: 32),
                    const _Divider(),
                    const SizedBox(height: 24),

                    // 2. Form strip
                    FormStripWidget(lastMatches: _lastMatches),

                    const SizedBox(height: 24),
                    const _Divider(),
                    const SizedBox(height: 24),

                    // 3. Stats
                    StatsGridWidget(profile: _profile!),

                    const SizedBox(height: 24),
                    const _Divider(),
                    const SizedBox(height: 24),

                    // 4. Badges (own profile only)
                    if (!_isViewingOther) ...[
                      BadgesWidget(profile: _profile!),
                      const SizedBox(height: 24),
                      const _Divider(),
                      const SizedBox(height: 24),
                    ],

                    // 5. Radar chart
                    Text(
                      'ATRYBUTY',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.textSecondary,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Center(
                      child: SkillHexagon(
                        skills: _profile!.skillsMap,
                        size: 240,
                      ),
                    ),

                    const SizedBox(height: 48),
                  ],
                ),
              ),
            ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.transparent, Colors.white12, Colors.transparent],
        ),
      ),
    );
  }
}
