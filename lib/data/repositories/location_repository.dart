import 'package:geolocator/geolocator.dart';

import '../services/location_service.dart';

class LocationRepository {
  final LocationService _locationService;

  LocationRepository(this._locationService);

  Future<Position?> getCurrentPosition() async {
    return await _locationService.getCurrentPosition();
  }
}
