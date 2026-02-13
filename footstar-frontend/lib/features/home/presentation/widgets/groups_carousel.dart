import 'package:flutter/material.dart';
import 'package:footstars/core/app_theme.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/presentation/create_group_screen.dart';
import '../../../groups/presentation/group_details_screen.dart';

class GroupsCarousel extends StatelessWidget {
  final List<GroupModel> groups;
  final VoidCallback onRefresh;

  const GroupsCarousel({
    super.key,
    required this.groups,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        itemCount: groups.length + 1, // +1 for "Add Group" button
        separatorBuilder: (_, __) => const SizedBox(width: 16),
        itemBuilder: (context, index) {
          if (index == groups.length) {
            return _buildAddGroupButton(context);
          }
          return _buildGroupItem(context, groups[index]);
        },
      ),
    );
  }

  Widget _buildGroupItem(BuildContext context, GroupModel group) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => GroupDetailsScreen(group: group)),
        ).then((_) => onRefresh());
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.secondary.withAlpha(51),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(51),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Text(
                group.name.substring(0, 1).toUpperCase(),
                style: AppTextStyles.headlineMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 72,
            child: Text(
              group.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: AppTextStyles.labelSmall.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddGroupButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const CreateGroupScreen()),
        );
        if (result == true) {
          onRefresh();
        }
      },
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(25),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary,
                width: 1,
                style: BorderStyle.solid,
              ), // Dashed border is hard in Flutter without custom painter, solid is fine for now
            ),
            child: const Center(
              child: Icon(Icons.add, color: AppColors.primary, size: 32),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Create',
            style: AppTextStyles.labelSmall.copyWith(color: AppColors.primary),
          ),
        ],
      ),
    );
  }
}
