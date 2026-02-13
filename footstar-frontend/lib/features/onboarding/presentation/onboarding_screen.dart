import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/app_theme.dart';
import '../../auth/presentation/widgets/stadium_background.dart';
import 'widgets/skill_hexagon.dart';
import 'widgets/position_selector.dart';
import '../data/models/profile_model.dart';
import '../data/profile_repository.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _formKeyStep1 = GlobalKey<FormState>();
  final _profileRepository = ProfileRepository();
  bool _isLoading = false;

  // Step 1: Basic Info
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _ageController = TextEditingController();

  // Positions List (Max 3)
  List<String> _selectedPositions = [];

  String? _foot;

  // Step 2: Attributes (1-5), Budget 30
  int _speed = 0;
  int _technique = 0;
  int _stamina = 0;
  int _defense = 0;
  int _shooting = 0;
  int _tactics = 0;
  int _vision = 0;
  int _charisma = 0;

  // Step 3: Social/Optional
  final _clubController = TextEditingController();
  final _playerController = TextEditingController();

  static const int maxBudget = 30;

  int get currentPoints =>
      _speed +
      _technique +
      _stamina +
      _defense +
      _shooting +
      _tactics +
      _vision +
      _charisma;

  int get remainingPoints => maxBudget - currentPoints;

  void _nextPage() {
    if (_pageController.page == 0) {
      if (_formKeyStep1.currentState!.validate()) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  Future<void> _submitProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    if (currentPoints > maxBudget) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You exceeded the point budget!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final profile = ProfileModel(
        id: user.id,
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        age: int.tryParse(_ageController.text) ?? 18,

        positionPrimary: _selectedPositions.isNotEmpty
            ? _selectedPositions[0]
            : null,
        positionSecondary: _selectedPositions.length > 1
            ? _selectedPositions[1]
            : null,
        positionTertiary: _selectedPositions.length > 2
            ? _selectedPositions[2]
            : null,
        foot: _foot,
        speed: _speed,
        technique: _technique,
        stamina: _stamina,
        defense: _defense,
        shooting: _shooting,
        tactics: _tactics,
        vision: _vision,
        charisma: _charisma,
        favoriteClub: _clubController.text.trim(),
        favoritePlayer: _playerController.text.trim(),
      );

      await _profileRepository.createProfile(profile);

      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Allow background to show through app bar
      appBar: AppBar(
        title: Text(
          'CREATE PROFILE',
          style: AppTextStyles.titleMedium.copyWith(
            letterSpacing: 1.5,
            color: AppColors.secondary,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: Stack(
        children: [
          // --- BACKGROUND ---
          const Positioned.fill(child: StadiumBackground()),

          // --- CONTENT ---
          SafeArea(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [_buildStep1(), _buildStep2(), _buildStep3()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep1() {
    const feet = ['LEFT', 'RIGHT', 'BOTH'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Form(
        key: _formKeyStep1,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'BASIC INFO',
                style: AppTextStyles.displayMedium.copyWith(
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tell us who you are on the pitch.',
                style: AppTextStyles.bodyMedium,
              ),
              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _firstNameController,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(
                        labelText: 'FIRST NAME',
                      ),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _lastNameController,
                      style: AppTextStyles.bodyLarge,
                      decoration: const InputDecoration(labelText: 'LAST NAME'),
                      validator: (v) => v!.isEmpty ? 'Required' : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                style: AppTextStyles.bodyLarge,
                decoration: const InputDecoration(labelText: 'AGE'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              // --- POSITION SELECTOR (MINI-PITCH) ---
              Center(
                child: PositionSelector(
                  selectedPositions: _selectedPositions,
                  onPositionsChanged: (positions) =>
                      setState(() => _selectedPositions = positions),
                ),
              ),
              if (_selectedPositions.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Center(
                    child: Text(
                      'Select at least one position',
                      style: AppTextStyles.labelSmall.copyWith(
                        color: AppColors.error,
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _foot,
                style: AppTextStyles.bodyLarge,
                dropdownColor: AppColors.surface,
                decoration: const InputDecoration(labelText: 'PREFERRED FOOT'),
                items: feet
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setState(() => _foot = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _nextPage,
                child: const Text('NEXT STEP'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    final skills = {
      'SPD': _speed, // Shortened labels for chart
      'TEC': _technique,
      'STM': _stamina,
      'DEF': _defense,
      'SHT': _shooting,
      'TAC': _tactics,
      'VIS': _vision,
      'CHA': _charisma,
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SKILLS',
                  style: AppTextStyles.displayMedium.copyWith(
                    color: AppColors.primary,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: remainingPoints < 0
                        ? AppColors.error.withValues(alpha: 0.2)
                        : SkillHexagon.neonTurf.withValues(
                            alpha: 0.2,
                          ), // Use Neon
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: remainingPoints < 0
                          ? AppColors.error
                          : SkillHexagon.neonTurf, // Use Neon
                    ),
                  ),
                  child: Text(
                    'PTS: $remainingPoints',
                    style: AppTextStyles.labelLarge.copyWith(
                      color: remainingPoints < 0
                          ? AppColors.error
                          : SkillHexagon.neonTurf,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // --- HEXAGON CHART ---
            Center(child: SkillHexagon(skills: skills, size: 220)),
            const SizedBox(height: 30),

            Text(
              'Distribute 30 points (1-5).',
              style: AppTextStyles.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            _buildSlider('SPEED', _speed, (v) => setState(() => _speed = v)),
            _buildSlider(
              'TECHNIQUE',
              _technique,
              (v) => setState(() => _technique = v),
            ),
            _buildSlider(
              'STAMINA',
              _stamina,
              (v) => setState(() => _stamina = v),
            ),
            _buildSlider(
              'DEFENSE',
              _defense,
              (v) => setState(() => _defense = v),
            ),
            _buildSlider(
              'SHOOTING',
              _shooting,
              (v) => setState(() => _shooting = v),
            ),
            _buildSlider(
              'TACTICS',
              _tactics,
              (v) => setState(() => _tactics = v),
            ),
            _buildSlider('VISION', _vision, (v) => setState(() => _vision = v)),
            _buildSlider(
              'CHARISMA',
              _charisma,
              (v) => setState(() => _charisma = v),
            ),

            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousPage,
                    child: const Text('BACK'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: remainingPoints >= 0 ? _nextPage : null,
                    // Update button style to match Neon if valid?
                    // Or keep generic primary. Let's keep generic for now to avoid mess.
                    child: const Text('NEXT STEP'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, int value, ValueChanged<int> onChanged) {
    // Neon glow effect logic? Simple color swap for now.
    final isActive = value > 1;
    final color = isActive ? SkillHexagon.neonTurf : AppColors.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: AppTextStyles.labelMedium),
            Text(
              value.toString(),
              style: AppTextStyles.titleMedium.copyWith(color: color),
            ),
          ],
        ),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: color,
            inactiveTrackColor: AppColors.surface,
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
            trackHeight: 2.0, // Thinner lines as per "Neon Sliders (lines)"
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6.0),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 0,
            max: 5,
            divisions: 5,
            onChanged: (v) {
              final newValue = v.toInt();
              if (newValue > value && remainingPoints <= 0) return;
              onChanged(newValue);
            },
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'EXTRAS',
              style: AppTextStyles.displayMedium.copyWith(
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text('Show your colors.', style: AppTextStyles.bodyMedium),
            const SizedBox(height: 32),
            TextFormField(
              controller: _clubController,
              style: AppTextStyles.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'FAVORITE CLUB (OPTIONAL)',
                prefixIcon: Icon(Icons.shield_outlined),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _playerController,
              style: AppTextStyles.bodyLarge,
              decoration: const InputDecoration(
                labelText: 'FAVORITE PLAYER (OPTIONAL)',
                prefixIcon: Icon(Icons.star_outline),
              ),
            ),
            const SizedBox(height: 48),

            _isLoading
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  )
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousPage,
                          child: const Text('BACK'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submitProfile,
                          child: const Text('FINISH'),
                        ),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
