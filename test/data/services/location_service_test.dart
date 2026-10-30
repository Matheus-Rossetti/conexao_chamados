import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:avaliacao_final_sctec/data/services/location_service.dart';

class MockGeolocatorPlatform extends Mock
    with MockPlatformInterfaceMixin
    implements GeolocatorPlatform {}

void main() {
  late MockGeolocatorPlatform mockPlatform;
  late LocationServiceImpl locationService;

  final testPosition = Position(
    longitude: -48.5457,
    latitude: -27.5969,
    timestamp: DateTime.now(),
    accuracy: 5.0,
    altitude: 10.0,
    altitudeAccuracy: 1.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  );

  final lastKnownPosition = Position(
    longitude: -48.5000,
    latitude: -27.5000,
    timestamp: DateTime.now(),
    accuracy: 15.0,
    altitude: 5.0,
    altitudeAccuracy: 1.0,
    heading: 0.0,
    headingAccuracy: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
  );

  setUp(() {
    mockPlatform = MockGeolocatorPlatform();
    GeolocatorPlatform.instance = mockPlatform;
    locationService = LocationServiceImpl();
  });

  group('LocationServiceImpl', () {
    test('returns position and caches it when service is enabled and permission granted', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => true);
      when(() => mockPlatform.checkPermission())
          .thenAnswer((_) async => LocationPermission.whileInUse);
      when(
        () => mockPlatform.getCurrentPosition(
          locationSettings: any(named: 'locationSettings'),
        ),
      ).thenAnswer((_) async => testPosition);

      final result = await locationService.getCurrentPosition();

      expect(result, equals(testPosition));

      // Second call when location service is disabled should return cached position
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => false);

      final cachedResult = await locationService.getCurrentPosition();
      expect(cachedResult, equals(testPosition));
    });

    test('returns last known position when location service is disabled and no position cached', () async {
      when(() => mockPlatform.isLocationServiceEnabled())
          .thenAnswer((_) async => false);
      when(() => mockPlatform.getLastKnownPosition(forceLocationManager: false))
          .thenAnswer((_) async => lastKnownPosition);

      final result = await locationService.getCurrentPosition();

      expect(result, equals(lastKnownPosition));
    });

    test(
      'requests permission when permission is denied and handles denied result',
      () async {
        when(() => mockPlatform.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockPlatform.checkPermission())
            .thenAnswer((_) async => LocationPermission.denied);
        when(() => mockPlatform.requestPermission())
            .thenAnswer((_) async => LocationPermission.denied);
        when(
          () => mockPlatform.getLastKnownPosition(forceLocationManager: false),
        ).thenAnswer((_) async => lastKnownPosition);

        final result = await locationService.getCurrentPosition();

        expect(result, equals(lastKnownPosition));
        verify(() => mockPlatform.requestPermission()).called(1);
      },
    );

    test(
      'returns last known position when permission is deniedForever',
      () async {
        when(() => mockPlatform.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockPlatform.checkPermission())
            .thenAnswer((_) async => LocationPermission.deniedForever);
        when(
          () => mockPlatform.getLastKnownPosition(forceLocationManager: false),
        ).thenAnswer((_) async => lastKnownPosition);

        final result = await locationService.getCurrentPosition();

        expect(result, equals(lastKnownPosition));
      },
    );

    test(
      'returns fallback position when getCurrentPosition throws an exception',
      () async {
        when(() => mockPlatform.isLocationServiceEnabled())
            .thenAnswer((_) async => true);
        when(() => mockPlatform.checkPermission())
            .thenAnswer((_) async => LocationPermission.always);
        when(
          () => mockPlatform.getCurrentPosition(
            locationSettings: any(named: 'locationSettings'),
          ),
        ).thenThrow(Exception('Location error'));
        when(
          () => mockPlatform.getLastKnownPosition(forceLocationManager: false),
        ).thenAnswer((_) async => lastKnownPosition);

        final result = await locationService.getCurrentPosition();

        expect(result, equals(lastKnownPosition));
      },
    );
  });
}
