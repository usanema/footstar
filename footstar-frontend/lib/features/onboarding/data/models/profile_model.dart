class ProfileModel {
  final String id;
  final String? firstName;
  final String? lastName;
  final int? age;
  final String? avatarUrl;

  final String? positionPrimary;
  final String? positionSecondary;
  final String? positionTertiary;
  final String? foot;

  final int speed;
  final int technique;
  final int stamina;
  final int defense;
  final int shooting;
  final int tactics;
  final int vision;
  final int charisma;

  final String? favoriteClub;
  final String? favoritePlayer;

  ProfileModel({
    required this.id,
    this.firstName,
    this.lastName,
    this.age,
    this.avatarUrl,
    this.positionPrimary,
    this.positionSecondary,
    this.positionTertiary,
    this.foot,
    this.speed = 1,
    this.technique = 1,
    this.stamina = 1,
    this.defense = 1,
    this.shooting = 1,
    this.tactics = 1,
    this.vision = 1,
    this.charisma = 1,
    this.favoriteClub,
    this.favoritePlayer,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      age: json['age'] as int?,
      avatarUrl: json['avatar_url'] as String?,
      positionPrimary: json['position_primary'] as String?,
      positionSecondary: json['position_secondary'] as String?,
      positionTertiary: json['position_tertiary'] as String?,
      foot: json['foot'] as String?,
      speed: json['speed'] as int? ?? 1,
      technique: json['technique'] as int? ?? 1,
      stamina: json['stamina'] as int? ?? 1,
      defense: json['defense'] as int? ?? 1,
      shooting: json['shooting'] as int? ?? 1,
      tactics: json['tactics'] as int? ?? 1,
      vision: json['vision'] as int? ?? 1,
      charisma: json['charisma'] as int? ?? 1,
      favoriteClub: json['favorite_club'] as String?,
      favoritePlayer: json['favorite_player'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'first_name': firstName,
      'last_name': lastName,
      'age': age,
      'avatar_url': avatarUrl,
      'position_primary': positionPrimary,
      'position_secondary': positionSecondary,
      'position_tertiary': positionTertiary,
      'foot': foot,
      'speed': speed,
      'technique': technique,
      'stamina': stamina,
      'defense': defense,
      'shooting': shooting,
      'tactics': tactics,
      'vision': vision,
      'charisma': charisma,
      'favorite_club': favoriteClub,
      'favorite_player': favoritePlayer,
    };
  }

  // Helper to calculate total points
  int get totalPoints =>
      speed +
      technique +
      stamina +
      defense +
      shooting +
      tactics +
      vision +
      charisma;
}
