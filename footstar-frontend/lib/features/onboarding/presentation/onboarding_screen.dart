import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
  String? _positionPrimary;
  String? _positionSecondary;
  String? _positionTertiary;
  String? _foot;

  // Step 2: Attributes (1-5), Budget 30
  int _speed = 1;
  int _technique = 1;
  int _stamina = 1;
  int _defense = 1;
  int _shooting = 1;
  int _tactics = 1;
  int _vision = 1;
  int _charisma = 1;

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
        const SnackBar(content: Text('You exceeded the point budget!')),
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
        positionPrimary: _positionPrimary,
        positionSecondary: _positionSecondary,
        positionTertiary: _positionTertiary,
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
        // Navigate to Home via AuthGate refresh or explicit navigation
        // For AuthGate to pick up changes, we might need to trigger a stream or just pushReplacement
        // But since AuthGate checks stream, and profile is separate...
        // We need a way to tell the app "Profile is ready".
        // For now, let's just push replacement to Home.
        Navigator.of(context).pushReplacementNamed('/');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Profile')),
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(), // Disable swipe
        children: [_buildStep1(), _buildStep2(), _buildStep3()],
      ),
    );
  }

  Widget _buildStep1() {
    const positions = ['GK', 'DEF', 'MID', 'FWD'];
    const feet = ['LEFT', 'RIGHT', 'BOTH'];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKeyStep1,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Basic Info',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
                validator: (v) => v!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _positionPrimary,
                decoration: const InputDecoration(
                  labelText: 'Primary Position',
                ),
                items: positions
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _positionPrimary = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _positionSecondary,
                decoration: const InputDecoration(
                  labelText: 'Secondary Position (Optional)',
                ),
                items: positions
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _positionSecondary = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _positionTertiary,
                decoration: const InputDecoration(
                  labelText: 'Tertiary Position (Optional)',
                ),
                items: positions
                    .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                    .toList(),
                onChanged: (v) => setState(() => _positionTertiary = v),
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _foot,
                decoration: const InputDecoration(labelText: 'Preferred Foot'),
                items: feet
                    .map((f) => DropdownMenuItem(value: f, child: Text(f)))
                    .toList(),
                onChanged: (v) => setState(() => _foot = v),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(onPressed: _nextPage, child: const Text('Next')),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStep2() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Skills Assessment',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Points Left: $remainingPoints',
                  style: TextStyle(
                    color: remainingPoints < 0 ? Colors.red : Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text('Rate yourself 1-5. Total max: 30.'),
            const Divider(),
            _buildSlider('Speed', _speed, (v) => setState(() => _speed = v)),
            _buildSlider(
              'Technique',
              _technique,
              (v) => setState(() => _technique = v),
            ),
            _buildSlider(
              'Stamina',
              _stamina,
              (v) => setState(() => _stamina = v),
            ),
            _buildSlider(
              'Defense',
              _defense,
              (v) => setState(() => _defense = v),
            ),
            _buildSlider(
              'Shooting',
              _shooting,
              (v) => setState(() => _shooting = v),
            ),
            _buildSlider(
              'Tactics',
              _tactics,
              (v) => setState(() => _tactics = v),
            ),
            _buildSlider('Vision', _vision, (v) => setState(() => _vision = v)),
            _buildSlider(
              'Charisma',
              _charisma,
              (v) => setState(() => _charisma = v),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _previousPage,
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: remainingPoints >= 0 ? _nextPage : null,
                    child: const Text('Next'),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label: $value'),
        Slider(
          value: value.toDouble(),
          min: 1,
          max: 5,
          divisions: 4,
          onChanged: (v) => onChanged(v.toInt()),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Social & Extras',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _clubController,
              decoration: const InputDecoration(
                labelText: 'Favorite Club (Optional)',
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _playerController,
              decoration: const InputDecoration(
                labelText: 'Favorite Player (Optional)',
              ),
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _previousPage,
                          child: const Text('Back'),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: _submitProfile,
                          child: const Text('Finish'),
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
