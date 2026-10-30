import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:avaliacao_final_sctec/data/models/service_model.dart';
import 'package:avaliacao_final_sctec/data/repositories/location_repository.dart';
import 'package:avaliacao_final_sctec/data/repositories/ticket_repository.dart';
import 'package:avaliacao_final_sctec/views/home/home_viewmodel.dart';

class MockTicketRepository extends Mock implements TicketRepository {}

class MockLocationRepository extends Mock implements LocationRepository {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockTicketRepository mockTicketRepo;
  late MockLocationRepository mockLocationRepo;
  late MockFlutterSecureStorage mockSecureStorage;
  late HomeViewmodel viewModel;

  setUp(() {
    GetIt.I.reset();

    mockTicketRepo = MockTicketRepository();
    mockLocationRepo = MockLocationRepository();
    mockSecureStorage = MockFlutterSecureStorage();

    GetIt.I.registerSingleton<TicketRepository>(mockTicketRepo);
    GetIt.I.registerSingleton<LocationRepository>(mockLocationRepo);
    GetIt.I.registerSingleton<FlutterSecureStorage>(mockSecureStorage);

    viewModel = HomeViewmodel();
  });

  tearDown(() {
    GetIt.I.reset();
  });

  group('HomeViewmodel.syncServices', () {
    test('returns 0 when there are no pending services to sync', () async {
      final syncedServices = [
        ServiceModel(
          id: 1,
          ticketFk: 10,
          synchronized: 1,
          conclusion: 'Done',
          description: 'Desc',
          date: '2026-02-20',
        ),
      ];

      when(() => mockTicketRepo.getStoredServices())
          .thenAnswer((_) async => syncedServices);

      final count = await viewModel.syncServices();

      expect(count, equals(0));
      expect(viewModel.isOfflineMode, isFalse);
      verifyNever(() => mockTicketRepo.uploadServices(any()));
    });

    test(
      'uploads pending services and returns count of synced items',
      () async {
        final pendingService = ServiceModel(
          id: 2,
          ticketFk: 20,
          synchronized: 0,
          conclusion: 'Done',
          description: 'Desc',
          date: '2026-02-20',
        );

        final syncedService = ServiceModel(
          id: 2,
          ticketFk: 20,
          synchronized: 1,
          conclusion: 'Done',
          description: 'Desc',
          date: '2026-02-20',
        );

        var callCount = 0;
        when(() => mockTicketRepo.getStoredServices()).thenAnswer((_) async {
          callCount++;
          return callCount == 1 ? [pendingService] : [syncedService];
        });

        when(() => mockTicketRepo.uploadServices([pendingService]))
            .thenAnswer((_) async {});

        final count = await viewModel.syncServices();

        expect(count, equals(1));
        expect(viewModel.isOfflineMode, isFalse);
        verify(() => mockTicketRepo.uploadServices([pendingService])).called(1);
      },
    );

    test(
      'sets isOfflineMode to true and rethrows when uploadServices fails',
      () async {
        final pendingService = ServiceModel(
          id: 3,
          ticketFk: 30,
          synchronized: 0,
          conclusion: 'Pending',
          description: 'Desc',
          date: '2026-02-20',
        );

        when(() => mockTicketRepo.getStoredServices())
            .thenAnswer((_) async => [pendingService]);

        when(() => mockTicketRepo.uploadServices([pendingService])).thenThrow(
          Exception('Falha na sincronização: sem conexão com a internet.'),
        );

        await expectLater(
          () => viewModel.syncServices(),
          throwsA(
            isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('sem conexão com a internet'),
            ),
          ),
        );

        expect(viewModel.isOfflineMode, isTrue);
      },
    );
  });
}
