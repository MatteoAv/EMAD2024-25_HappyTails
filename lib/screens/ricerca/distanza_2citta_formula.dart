import 'dart:math' as math;


/*
Dopo aver calcolato il geohash lato backend, abbiamo una lista di città vicine, ma non sappiamo quanto vicine. 
Allora usiamo la Harversine distance, che dati longitudine e latitudine di due città, calcola la distanza circolare tra i due
*/

class HaversineCalculator {
  static const double _earthRadiusKm = 6371.0;

  /// Calculate the Haversine distance between two points
  static double calculateDistance(
    double lat1, 
    double lon1, 
    double lat2, 
    double lon2
  ) {
    // Convert latitude and longitude to radians
    final double radLat1 = _degreesToRadians(lat1);
    final double radLon1 = _degreesToRadians(lon1);
    final double radLat2 = _degreesToRadians(lat2);
    final double radLon2 = _degreesToRadians(lon2);

    // Haversine formula
    final double dLat = radLat2 - radLat1;
    final double dLon = radLon2 - radLon1;

    final double a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(radLat1) * 
        math.cos(radLat2) * 
        math.pow(math.sin(dLon / 2), 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return _earthRadiusKm * c;
  }
  static double _degreesToRadians(double degrees) {
    return degrees * (math.pi / 180.0);
  }
}
