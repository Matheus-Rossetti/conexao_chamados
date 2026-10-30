import 'package:geolocator/geolocator.dart';

abstract class LocationService {
  Future<Position?> getCurrentPosition();
}

class LocationServiceImpl implements LocationService {
  Position? _cachedPosition;

  @override
  Future<Position?> getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return _cachedPosition ?? await Geolocator.getLastKnownPosition();
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return _cachedPosition ?? await Geolocator.getLastKnownPosition();
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return _cachedPosition ?? await Geolocator.getLastKnownPosition();
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _cachedPosition = position;
      return position;
    } catch (_) {
      return _cachedPosition ?? await Geolocator.getLastKnownPosition();
    }
  }
}
