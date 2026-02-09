import 'package:flutter/material.dart';
import '../data/group_repository.dart';
import '../../common/services/city_service.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  bool _isPublic = true;
  bool _isLoading = false;
  final _repository = GroupRepository();
  final _cityService = CityService();

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      await _repository.createGroup(
        name: _nameController.text.trim(),
        isPublic: _isPublic,
        city: _cityController.text.trim().isEmpty
            ? null
            : _cityController.text.trim(),
        // TODO: Add refined location picking (lat/lng)
      );
      if (mounted) {
        Navigator.pop(context, true); // Return true to refresh list
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
      appBar: AppBar(title: const Text('Create New Group')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Group Name',
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),
              Autocomplete<String>(
                optionsBuilder: (TextEditingValue textEditingValue) {
                  if (textEditingValue.text == '') {
                    return const Iterable<String>.empty();
                  }
                  return _cityService.searchCities(textEditingValue.text);
                },
                onSelected: (String selection) {
                  _cityController.text = selection;
                },
                fieldViewBuilder:
                    (
                      BuildContext context,
                      TextEditingController fieldTextEditingController,
                      FocusNode fieldFocusNode,
                      VoidCallback onFieldSubmitted,
                    ) {
                      // Sync internal controller with our _cityController if needed,
                      // or just use _cityController as the source of truth.
                      // Note: Autocomplete's controller is separate.
                      // We should sync them or just rely on onSelected and valid submission.
                      // Simpler approach: Use the Autocomplete's controller for display
                      // and sync to _cityController on change.

                      // Ideally we want to bind _cityController to this.
                      // However, Autocomplete creates its own controller if we don't provide one?
                      // Actually fieldViewBuilder gives us a controller.
                      // Let's hook up our _cityController logic here.

                      // Wait, we can't easily swap the controller instance.
                      // Instead, let's just use the builder to return our TextFormField
                      // and manually attach the controller and focus node.
                      // BUT `Autocomplete` manages the text.

                      // Better approach: Let Autocomplete manage the input,
                      // and we update _cityController.text on selected or changed.
                      // Actually, we can just assign _cityController to the fieldViewBuilder's controller?
                      // No, we should use the controller provided by the builder.

                      // To ensure our _cityController has the value when we save:
                      fieldTextEditingController.addListener(() {
                        _cityController.text = fieldTextEditingController.text;
                      });

                      // Initialize with existing value if any
                      if (_cityController.text.isNotEmpty &&
                          fieldTextEditingController.text.isEmpty) {
                        fieldTextEditingController.text = _cityController.text;
                      }

                      return TextFormField(
                        controller: fieldTextEditingController,
                        focusNode: fieldFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'City (Optional)',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.location_city),
                        ),
                      );
                    },
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Public Group'),
                subtitle: const Text('Allow anyone to find this group'),
                value: _isPublic,
                onChanged: (v) => setState(() => _isPublic = v),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createGroup,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Create Group'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
