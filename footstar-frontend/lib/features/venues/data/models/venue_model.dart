class VenueModel {
  final String id;
  final String name;
  final String address;
  final String city;
  final double latitude;
  final double longitude;
  final String?
  surface; // 'natural_grass' | 'artificial_turf' | 'indoor' | null
  final bool? hasLights;
  final String? photoUrl;
  final String? description;
  final DateTime createdAt;

  VenueModel({
    required this.id,
    required this.name,
    required this.address,
    required this.city,
    required this.latitude,
    required this.longitude,
    this.surface,
    this.hasLights,
    this.photoUrl,
    this.description,
    required this.createdAt,
  });

  factory VenueModel.fromMap(Map<String, dynamic> map) {
    return VenueModel(
      id: map['id'] as String,
      name: map['name'] as String,
      address: map['address'] as String,
      city: map['city'] as String,
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      surface: map['surface'] as String?,
      hasLights: map['has_lights'] as bool?,
      photoUrl: map['photo_url'] as String?,
      description: map['description'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Human-readable surface label.
  String get surfaceLabel {
    switch (surface) {
      case 'natural_grass':
        return 'Trawa naturalna';
      case 'artificial_turf':
        return 'Sztuczna trawa';
      case 'indoor':
        return 'Hala';
      default:
        return 'Nieznana';
    }
  }
}
