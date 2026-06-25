import '../../domain/entities/location.dart';

class GeoLocationModel {
  const GeoLocationModel({
    required this.name,
    required this.country,
    required this.admin1,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  factory GeoLocationModel.fromJson(Map<String, dynamic> json) {
    return GeoLocationModel(
      name: json['name'] as String,
      country: json['country'] as String? ?? '',
      admin1: json['admin1'] as String? ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      timezone: json['timezone'] as String? ?? '',
    );
  }

  final String name;
  final String country;
  final String admin1;
  final double latitude;
  final double longitude;
  final String timezone;

  Location toEntity() => Location(
        name: name,
        country: country,
        admin1: admin1,
        latitude: latitude,
        longitude: longitude,
        timezone: timezone,
      );
}
