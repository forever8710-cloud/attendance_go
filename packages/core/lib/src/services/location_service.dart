import 'dart:math';

class LatLng {
  const LatLng(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

class LocationService {
  /// Calculate distance between two points using Haversine formula (meters)
  static double calculateDistance(LatLng p1, LatLng p2) {
    const earthRadius = 6371000.0; // meters
    final dLat = _toRadians(p2.latitude - p1.latitude);
    final dLng = _toRadians(p2.longitude - p1.longitude);
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(p1.latitude)) *
            cos(_toRadians(p2.latitude)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degrees) => degrees * pi / 180;

  static bool isWithinRadius(LatLng userLocation, LatLng siteLocation, double radiusMeters) {
    return calculateDistance(userLocation, siteLocation) <= radiusMeters;
  }
}
