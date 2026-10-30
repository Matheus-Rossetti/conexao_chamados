import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:mocktail/mocktail.dart';
import 'package:avaliacao_final_sctec/core/routes.dart';
import 'package:avaliacao_final_sctec/data/repositories/auth_repository.dart';
import 'package:avaliacao_final_sctec/data/repositories/location_repository.dart';
import 'package:avaliacao_final_sctec/data/repositories/ticket_repository.dart';
import 'package:avaliacao_final_sctec/views/auth/auth_view.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

class MockTicketRepository extends Mock implements TicketRepository {}

class MockLocationRepository extends Mock implements LocationRepository {}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

void main() {
  late MockAuthRepository mockAuthRepo;
  late MockTicketRepository mockTicketRepo;
  late MockLocationRepository mockLocationRepo;
  late MockFlutterSecureStorage mockSecureStorage;

  setUp(() {
    GetIt.I.reset();

    mockAuthRepo = MockAuthRepository();
    mockTicketRepo = MockTicketRepository();
    mockLocationRepo = MockLocationRepository();
    mockSecureStorage = MockFlutterSecureStorage();

    GetIt.I.registerSingleton<AuthRepository>(mockAuthRepo);
    GetIt.I.registerSingleton<TicketRepository>(mockTicketRepo);
    GetIt.I.registerSingleton<LocationRepository>(mockLocationRepo);
    GetIt.I.registerSingleton<FlutterSecureStorage>(mockSecureStorage);

    when(() => mockSecureStorage.read(key: 'technician_name'))
        .thenAnswer((_) async => 'Técnico');
    when(() => mockLocationRepo.getCurrentPosition())
        .thenAnswer((_) async => null);
    when(() => mockTicketRepo.fetchAndSaveTickets())
        .thenAnswer((_) async => []);
    when(() => mockTicketRepo.getStoredTickets()).thenAnswer((_) async => []);
    when(() => mockTicketRepo.getStoredServices()).thenAnswer((_) async => []);
  });

  tearDown(() {
    GetIt.I.reset();
  });

  Widget createAuthWidget() {
    return MaterialApp(
      key: UniqueKey(),
      routes: {
        AppRoutes.auth: (context) => const AuthView(),
        AppRoutes.home: (context) => const Scaffold(body: Text('Home Screen')),
      },
      initialRoute: AppRoutes.auth,
    );
  }

  group('AuthView Widget Tests', () {
    testWidgets('renders all initial login UI components correctly', (
      tester,
    ) async {
      await tester.pumpWidget(createAuthWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Bem-vindo de volta!'), findsOneWidget);
      expect(find.text('Entre na sua conta para continuar'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Senha'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Entrar'), findsOneWidget);
    });

    testWidgets('shows validation snackbar when email is invalid', (
      tester,
    ) async {
      await tester.pumpWidget(createAuthWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(TextField).at(0), 'invalid-email');
      await tester.enterText(find.byType(TextField).at(1), '123456');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Por favor, insira um e-mail válido'), findsOneWidget);
      verifyNever(
        () => mockAuthRepo.login(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    testWidgets('toggles password visibility on icon tap', (tester) async {
      await tester.pumpWidget(createAuthWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

      await tester.tap(find.byIcon(Icons.visibility_outlined));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);
    });

    testWidgets(
      'navigates to Home on successful login with valid credentials',
      (tester) async {
        when(
          () => mockAuthRepo.login(
            email: 'user@test.com',
            password: 'password123',
          ),
        ).thenAnswer((_) async {});

        await tester.pumpWidget(createAuthWidget());
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        await tester.enterText(find.byType(TextField).at(0), 'user@test.com');
        await tester.enterText(find.byType(TextField).at(1), 'password123');

        await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        verify(
          () => mockAuthRepo.login(
            email: 'user@test.com',
            password: 'password123',
          ),
        ).called(1);

        expect(find.text('Home Screen'), findsOneWidget);
      },
    );

    testWidgets('displays error snackbar when login fails', (tester) async {
      when(
        () => mockAuthRepo.login(
          email: 'user@test.com',
          password: 'wrongpassword',
        ),
      ).thenThrow(Exception('Credenciais inválidas'));

      await tester.pumpWidget(createAuthWidget());
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      await tester.enterText(find.byType(TextField).at(0), 'user@test.com');
      await tester.enterText(find.byType(TextField).at(1), 'wrongpassword');

      await tester.tap(find.widgetWithText(ElevatedButton, 'Entrar'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.text('Credenciais inválidas'), findsOneWidget);
    });
  });
}
