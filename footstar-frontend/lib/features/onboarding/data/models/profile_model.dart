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

  // Stats
  final int strMatchesPlayed;
  final int strMatchesWon;
  final int strMatchesDrawn;
  final int strMatchesLost;
  final int strGoalsScored;

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
    this.strMatchesPlayed = 0,
    this.strMatchesWon = 0,
    this.strMatchesDrawn = 0,
    this.strMatchesLost = 0,
    this.strGoalsScored = 0,
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
      strMatchesPlayed: json['str_matches_played'] as int? ?? 0,
      strMatchesWon: json['str_matches_won'] as int? ?? 0,
      strMatchesDrawn: json['str_matches_drawn'] as int? ?? 0,
      strMatchesLost: json['str_matches_lost'] as int? ?? 0,
      strGoalsScored: json['str_goals_scored'] as int? ?? 0,
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
      'str_matches_played': strMatchesPlayed,
      'str_matches_won': strMatchesWon,
      'str_matches_drawn': strMatchesDrawn,
      'str_matches_lost': strMatchesLost,
      'str_goals_scored': strGoalsScored,
    };
  }

  // --- Computed helpers ---

  int get totalPoints =>
      speed +
      technique +
      stamina +
      defense +
      shooting +
      tactics +
      vision +
      charisma;

  double get winRate =>
      strMatchesPlayed > 0 ? strMatchesWon / strMatchesPlayed : 0.0;

  double get goalsPerMatch =>
      strMatchesPlayed > 0 ? strGoalsScored / strMatchesPlayed : 0.0;

  List<String> get positions {
    return [
      positionPrimary,
      positionSecondary,
      positionTertiary,
    ].whereType<String>().toList();
  }

  Map<String, int> get skillsMap => {
    'Speed': speed,
    'Tech': technique,
    'Stamina': stamina,
    'Defense': defense,
    'Shoot': shooting,
    'Tactics': tactics,
    'Vision': vision,
    'Charisma': charisma,
  };
}
