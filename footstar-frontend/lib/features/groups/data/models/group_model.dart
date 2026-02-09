class GroupModel {
  final String id;
  final String name;
  final String inviteCode;
  final String ownerId;
  final bool isPublic;
  final double? latitude;
  final double? longitude;
  final String? city;
  final DateTime createdAt;

  GroupModel({
    required this.id,
    required this.name,
    required this.inviteCode,
    required this.ownerId,
    required this.isPublic,
    this.latitude,
    this.longitude,
    this.city,
    required this.createdAt,
  });

  factory GroupModel.fromMap(Map<String, dynamic> map) {
    return GroupModel(
      id: map['id'] as String,
      name: map['name'] as String,
      inviteCode: map['invite_code'] as String,
      ownerId: map['owner_id'] as String,
      isPublic: map['is_public'] as bool? ?? true,
      latitude: map['latitude'] as double?,
      longitude: map['longitude'] as double?,
      city: map['city'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'invite_code': inviteCode,
      'owner_id': ownerId,
      'is_public': isPublic,
      'latitude': latitude,
      'longitude': longitude,
      'city': city,
      // created_at is usually handled by DB default
    };
  }
}
