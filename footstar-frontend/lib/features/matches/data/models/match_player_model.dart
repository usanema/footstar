import '../../../onboarding/data/models/profile_model.dart';

enum PlayerStatus { IN, OUT, RESERVE, UNKNOWN }

enum Team { A, B }

class MatchPlayerModel {
  final String id;
  final String matchId;
  final String profileId;
  final PlayerStatus status;
  final Team? team;
  final double? pitchX;
  final double? pitchY;
  final bool hasCar;
  final int carSeats;
  final ProfileModel? profile;

  MatchPlayerModel({
    required this.id,
    required this.matchId,
    required this.profileId,
    required this.status,
    this.team,
    this.pitchX,
    this.pitchY,
    required this.hasCar,
    required this.carSeats,
    this.profile,
  });

  factory MatchPlayerModel.fromMap(Map<String, dynamic> map) {
    return MatchPlayerModel(
      id: map['id'],
      matchId: map['match_id'],
      profileId: map['profile_id'],
      status: PlayerStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PlayerStatus.UNKNOWN,
      ),
      team: map['team'] != null
          ? Team.values.firstWhere((e) => e.name == map['team'])
          : null,
      pitchX: map['pitch_x']?.toDouble(),
      pitchY: map['pitch_y']?.toDouble(),
      hasCar: map['has_car'] ?? false,
      carSeats: map['car_seats'] ?? 0,
      profile: map['profiles'] != null
          ? ProfileModel.fromJson(map['profiles'])
          : null,
    );
  }
  MatchPlayerModel copyWith({
    String? id,
    String? matchId,
    String? profileId,
    PlayerStatus? status,
    Team? team,
    double? pitchX,
    double? pitchY,
    bool? hasCar,
    int? carSeats,
    ProfileModel? profile,
  }) {
    return MatchPlayerModel(
      id: id ?? this.id,
      matchId: matchId ?? this.matchId,
      profileId: profileId ?? this.profileId,
      status: status ?? this.status,
      team: team ?? this.team,
      pitchX: pitchX ?? this.pitchX,
      pitchY: pitchY ?? this.pitchY,
      hasCar: hasCar ?? this.hasCar,
      carSeats: carSeats ?? this.carSeats,
      profile: profile ?? this.profile,
    );
  }
}
