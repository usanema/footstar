import 'package:flutter/material.dart';
import '../../groups/data/group_repository.dart';
import '../../groups/data/models/group_model.dart';
import '../../groups/presentation/create_group_screen.dart';
import '../../groups/presentation/find_group_screen.dart';
import '../../groups/presentation/group_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _groupRepository = GroupRepository();
  List<GroupModel>? _myGroups;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final groups = await _groupRepository.getMyGroups();
      if (mounted) {
        setState(() {
          _myGroups = groups;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading groups: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FootStar'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FindGroupScreen()),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _myGroups == null || _myGroups!.isEmpty
          ? _buildEmptyState()
          : _buildGroupList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
          );
          if (result == true) _loadGroups();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.groups, size: 80, color: Colors.grey),
          const SizedBox(height: 16),
          const Text(
            'No groups yet!',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text('Create a team or join an existing one.'),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
              );
              if (result == true) _loadGroups();
            },
            icon: const Icon(Icons.add),
            label: const Text('Create Group'),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const FindGroupScreen()),
              );
            },
            icon: const Icon(Icons.search),
            label: const Text('Find Group'),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupList() {
    return ListView.builder(
      itemCount: _myGroups!.length,
      itemBuilder: (context, index) {
        final group = _myGroups![index];
        return ListTile(
          leading: const CircleAvatar(child: Icon(Icons.shield)),
          title: Text(group.name),
          subtitle: Text(group.city ?? 'No location'),
          trailing: const Icon(Icons.chevron_right),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => GroupDetailsScreen(group: group),
              ),
            ).then((_) => _loadGroups()); // Refresh on return
          },
        );
      },
    );
  }
}
