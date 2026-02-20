enum MatchResult { WIN_A, WIN_B, DRAW, NOT_PLAYED }

MatchResult matchResultFromString(String? s) {
  switch (s) {
    case 'WIN_A':
      return MatchResult.WIN_A;
    case 'WIN_B':
      return MatchResult.WIN_B;
    case 'DRAW':
      return MatchResult.DRAW;
    default:
      return MatchResult.NOT_PLAYED;
  }
}

class MatchModel {
  final String id;
  final String groupId;
  final String? groupName; // Added for UI display
  final DateTime date;
  final String location;
  final int maxPlayers;
  final String? description;
  final bool isRecurring;
  final String? recurrencePattern;
  final DateTime createdAt;
  final MatchResult result;
  final String? venueId;

  MatchModel({
    required this.id,
    required this.groupId,
    this.groupName,
    required this.date,
    required this.location,
    required this.maxPlayers,
    this.description,
    required this.isRecurring,
    this.recurrencePattern,
    required this.createdAt,
    this.result = MatchResult.NOT_PLAYED,
    this.venueId,
  });

  factory MatchModel.fromMap(Map<String, dynamic> map) {
    return MatchModel(
      id: map['id'],
      groupId: map['group_id'],
      groupName: map['groups'] != null ? map['groups']['name'] : null,
      date: DateTime.parse(map['date']).toLocal(),
      location: map['location'],
      maxPlayers: map['max_players'],
      description: map['description'],
      isRecurring: map['is_recurring'] ?? false,
      recurrencePattern: map['recurrence_pattern'],
      createdAt: DateTime.parse(map['created_at']),
      result: matchResultFromString(map['result'] as String?),
      venueId: map['venue_id'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'group_id': groupId,
      'date': date.toIso8601String(),
      'location': location,
      'max_players': maxPlayers,
      'description': description,
      'is_recurring': isRecurring,
      'recurrence_pattern': recurrencePattern,
      if (venueId != null) 'venue_id': venueId,
    };
  }
}
