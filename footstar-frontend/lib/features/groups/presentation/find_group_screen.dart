import 'package:flutter/material.dart';
import '../data/group_repository.dart';
import '../data/models/group_model.dart';
import 'group_details_screen.dart';

class FindGroupScreen extends StatefulWidget {
  const FindGroupScreen({super.key});

  @override
  State<FindGroupScreen> createState() => _FindGroupScreenState();
}

class _FindGroupScreenState extends State<FindGroupScreen> {
  final _searchController = TextEditingController();
  final _repository = GroupRepository();
  List<GroupModel> _results = [];
  bool _isLoading = false;

  Future<void> _search() async {
    setState(() => _isLoading = true);
    try {
      final results = await _repository.searchGroups(
        _searchController.text.trim(),
      );
      setState(() => _results = results);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: const InputDecoration(
            hintText: 'Search groups...',
            border: InputBorder.none,
          ),
          onSubmitted: (_) => _search(),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.search), onPressed: _search),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _results.length,
              itemBuilder: (context, index) {
                final group = _results[index];
                return ListTile(
                  leading: const Icon(Icons.group),
                  title: Text(group.name),
                  subtitle: Text(group.city ?? 'No location'),
                  trailing: const Icon(Icons.chevron_right),
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
            ),
    );
  }
}
