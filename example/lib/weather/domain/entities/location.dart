class Location {
  const Location({
    required this.name,
    required this.country,
    required this.admin1,
    required this.latitude,
    required this.longitude,
    required this.timezone,
  });

  final String name;
  final String country;
  final String admin1;
  final double latitude;
  final double longitude;
  final String timezone;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Location &&
          name == other.name &&
          country == other.country &&
          admin1 == other.admin1 &&
          latitude == other.latitude &&
          longitude == other.longitude &&
          timezone == other.timezone;

  @override
  int get hashCode =>
      Object.hash(name, country, admin1, latitude, longitude, timezone);
}
