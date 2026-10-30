import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mocktail/mocktail.dart';
import 'package:avaliacao_final_sctec/data/repositories/location_repository.dart';
import 'package:avaliacao_final_sctec/data/services/location_service.dart';

class MockLocationService extends Mock implements LocationService {}

void main() {
  late MockLocationService mockLocationService;
  late LocationRepository locationRepository;

  setUp(() {
    mockLocationService = MockLocationService();
    locationRepository = LocationRepository(mockLocationService);
  });

  group('LocationRepository', () {
    test('getCurrentPosition returns Position when LocationService returns a position', () async {
      final mockPosition = Position(
        longitude: -48.5,
        latitude: -27.5,
        timestamp: DateTime.now(),
        accuracy: 10.0,
        altitude: 0.0,
        altitudeAccuracy: 0.0,
        heading: 0.0,
        headingAccuracy: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
      );

      when(() => mockLocationService.getCurrentPosition())
          .thenAnswer((_) async => mockPosition);

      final result = await locationRepository.getCurrentPosition();

      expect(result, equals(mockPosition));
      verify(() => mockLocationService.getCurrentPosition()).called(1);
    });

    test(
      'getCurrentPosition returns null when LocationService returns null',
      () async {
        when(() => mockLocationService.getCurrentPosition())
            .thenAnswer((_) async => null);

        final result = await locationRepository.getCurrentPosition();

        expect(result, isNull);
        verify(() => mockLocationService.getCurrentPosition()).called(1);
      },
    );
  });
}
