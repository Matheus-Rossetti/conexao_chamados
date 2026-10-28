class MockTicket {
  final String clientCode;
  final String clientName;
  final String category;
  final String description;
  final String address;
  final String neighborhood;
  final String city;
  final String createdAt;
  final bool isSynced;
  final String distance;

  MockTicket({
    required this.clientCode,
    required this.clientName,
    required this.category,
    required this.description,
    required this.address,
    required this.neighborhood,
    required this.city,
    required this.createdAt,
    required this.isSynced,
    required this.distance,
  });
}

class HomeViewmodel {
  HomeViewmodel();

  final String technicianName = "Joao Ilson Thum Garcia";

  final List<MockTicket> activeTickets = [
    MockTicket(
      clientCode: "CLI-84920",
      clientName: "Mariana Silveira Ramos",
      category: "Lentidão na navegação",
      description: "Vídeos em alta resolução não carregam e teste bate 10% do plano contratado.",
      address: "Rua Fernando Machado, 450, Apto 204",
      neighborhood: "Centro",
      city: "Chapecó",
      createdAt: "2026-09-28 14:20:00",
      isSynced: true,
      distance: "1.4 km",
    ),
    MockTicket(
      clientCode: "CLI-91234",
      clientName: "Carlos Eduardo Souza",
      category: "Sem conexão com a internet",
      description: "LED PON piscando vermelho no modem ONT após tempestade.",
      address: "Av. Getúlio Vargas, 1200",
      neighborhood: "Dona Emma",
      city: "Chapecó",
      createdAt: "2026-09-28 15:45:00",
      isSynced: false,
      distance: "3.8 km",
    ),
    MockTicket(
      clientCode: "CLI-55412",
      clientName: "Ana Paula de Oliveira",
      category: "Quedas frequentes de sinal",
      description: "Conexão cai toda vez que chove forte na região.",
      address: "Rua Sete de Setembro, 890",
      neighborhood: "Paraíso",
      city: "Chapecó",
      createdAt: "2026-09-29 09:10:00",
      isSynced: true,
      distance: "5.2 km",
    ),
  ];
}
