import '../../../onboarding/data/models/profile_model.dart';

enum GroupRole {
  ADMIN,
  PLAYER;

  static GroupRole fromString(String value) {
    return GroupRole.values.firstWhere((e) => e.name == value);
  }
}

enum GroupMemberStatus {
  PENDING,
  ACCEPTED,
  REJECTED;

  static GroupMemberStatus fromString(String value) {
    return GroupMemberStatus.values.firstWhere((e) => e.name == value);
  }
}

class GroupMemberModel {
  final String id;
  final String groupId;
  final String profileId;
  final GroupRole role;
  final GroupMemberStatus status;
  final DateTime joinedAt;
  final ProfileModel? profile;

  GroupMemberModel({
    required this.id,
    required this.groupId,
    required this.profileId,
    required this.role,
    required this.status,
    required this.joinedAt,
    this.profile,
  });

  factory GroupMemberModel.fromMap(Map<String, dynamic> map) {
    return GroupMemberModel(
      id: map['id'] as String,
      groupId: map['group_id'] as String,
      profileId: map['profile_id'] as String,
      role: GroupRole.fromString(map['role'] as String),
      status: GroupMemberStatus.fromString(map['status'] as String),
      joinedAt: DateTime.parse(map['joined_at'] as String),
      profile: map['profiles'] != null
          ? ProfileModel.fromJson(map['profiles'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'profile_id': profileId,
      'role': role.name,
      'status': status.name,
      // joined_at handled by DB
    };
  }
}
