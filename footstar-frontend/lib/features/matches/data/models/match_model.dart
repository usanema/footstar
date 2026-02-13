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
    };
  }
}
