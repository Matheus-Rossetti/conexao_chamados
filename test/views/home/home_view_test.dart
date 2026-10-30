import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:avaliacao_final_sctec/core/routes.dart';
import 'package:avaliacao_final_sctec/data/models/service_model.dart';
import 'package:avaliacao_final_sctec/data/models/ticket_model.dart';
import 'package:avaliacao_final_sctec/data/repositories/location_repository.dart';
import 'package:avaliacao_final_sctec/data/repositories/ticket_repository.dart';
import 'package:avaliacao_final_sctec/views/home/home_view.dart';

class MockTicketRepository extends Mock implements TicketRepository {}

class MockLocationRepository extends Mock implements LocationRepository {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockTicketRepository mockTicketRepo;
  late MockLocationRepository mockLocationRepo;
  late MockFlutterSecureStorage mockSecureStorage;

  final sampleTickets = [
    TicketModel(
      id: 1,
      clientCode: 'CLI01',
      clientName: 'Cliente Silva',
      category: 'Fibra Óptica',
      description: 'Lentidão na rede',
      address: 'Rua das Flores, 123',
      neighborhood: 'Centro',
      city: 'Florianópolis',
      latitude: -27.5969,
      longitude: -48.5457,
      status: 'ativo',
      createdAt: '2026-02-01',
    ),
    TicketModel(
      id: 2,
      clientCode: 'CLI02',
      clientName: 'Cliente Santos',
      category: 'Roteador',
      description: 'Sem acesso',
      address: 'Av. Beira Mar, 456',
      neighborhood: 'Agronômica',
      city: 'Florianópolis',
      latitude: -27.5800,
      longitude: -48.5200,
      status: 'ativo',
      createdAt: '2026-02-02',
    ),
  ];

  final sampleServices = [
    ServiceModel(
      id: 10,
      ticketFk: 1,
      synchronized: 1,
      conclusion: 'Concluído',
      description: 'Troca de conector RJ45',
      date: '2026-02-10',
      clientName: 'Cliente Souza',
      clientCode: 'CLI03',
      category: 'Manutenção',
    ),
  ];

  setUp(() {
    GetIt.I.reset();

    mockTicketRepo = MockTicketRepository();
    mockLocationRepo = MockLocationRepository();
    mockSecureStorage = MockFlutterSecureStorage();

    GetIt.I.registerSingleton<TicketRepository>(mockTicketRepo);
    GetIt.I.registerSingleton<LocationRepository>(mockLocationRepo);
    GetIt.I.registerSingleton<FlutterSecureStorage>(mockSecureStorage);

    when(() => mockSecureStorage.read(key: 'technician_name'))
        .thenAnswer((_) async => 'Carlos Técnico');

    when(() => mockLocationRepo.getCurrentPosition())
        .thenAnswer((_) async => null);

    when(() => mockTicketRepo.fetchAndSaveTickets())
        .thenAnswer((_) async => sampleTickets);

    when(() => mockTicketRepo.getStoredTickets())
        .thenAnswer((_) async => sampleTickets);

    when(() => mockTicketRepo.getStoredServices())
        .thenAnswer((_) async => sampleServices);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  Widget createHomeWidget() {
    return MaterialApp(
      key: UniqueKey(),
      routes: {AppRoutes.home: (context) => const HomeView()},
      initialRoute: AppRoutes.home,
    );
  }

  group('HomeView Widget Tests', () {
    testWidgets(
      'renders technician name, active tickets count, and ticket list',
      (tester) async {
        await tester.pumpWidget(createHomeWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Carlos Técnico'), findsOneWidget);
        expect(find.text('2 Ativos'), findsOneWidget);
        expect(find.text('Chamados'), findsOneWidget);
        expect(find.text('Atendimentos'), findsOneWidget);

        expect(find.text('Cliente Silva'), findsOneWidget);
        expect(find.text('Cliente Santos'), findsOneWidget);
      },
    );

    testWidgets('displays empty state when no active tickets are returned', (
      tester,
    ) async {
      when(() => mockTicketRepo.fetchAndSaveTickets())
          .thenAnswer((_) async => []);

      await tester.pumpWidget(createHomeWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Nenhum chamado ativo no momento.'), findsOneWidget);
    });

    testWidgets(
      'switches to Atendimentos tab and displays search bar and service list',
      (tester) async {
        await tester.pumpWidget(createHomeWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        await tester.tap(find.text('Atendimentos'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Buscar atendimentos...'), findsOneWidget);
        expect(find.text('Cliente Souza'), findsOneWidget);
        expect(find.text('Troca de conector RJ45'), findsOneWidget);

        await tester.tap(find.text('Chamados'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Cliente Silva'), findsOneWidget);
      },
    );

    testWidgets('filters services list when typing in search bar', (
      tester,
    ) async {
      await tester.pumpWidget(createHomeWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.tap(find.text('Atendimentos'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(TextField), 'NonExistentClient');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Nenhum atendimento realizado.'), findsOneWidget);

      await tester.enterText(find.byType(TextField), 'Souza');
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Cliente Souza'), findsOneWidget);
    });

    testWidgets(
      'triggers refresh on Chamados tab and displays success snackbar',
      (tester) async {
        await tester.pumpWidget(createHomeWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        await tester.fling(
          find.byType(CustomScrollView),
          const Offset(0, 300),
          1000,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.text('Chamados atualizados com sucesso!'), findsOneWidget);
      },
    );

    testWidgets(
      'triggers sync on Atendimentos tab and displays synced status snackbar',
      (tester) async {
        await tester.pumpWidget(createHomeWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        await tester.tap(find.text('Atendimentos'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        await tester.fling(
          find.byType(CustomScrollView),
          const Offset(0, 300),
          1000,
        );
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        expect(
          find.text('Todos os atendimentos já estão sincronizados.'),
          findsOneWidget,
        );
      },
    );
  });
}
