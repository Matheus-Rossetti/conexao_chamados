class TicketModel {
  final int id;
  final String clientCode;
  final String clientName;
  final String category;
  final String description;
  final String address;
  final String neighborhood;
  final String city;
  final double latitude;
  final double longitude;
  final String status;
  final String createdAt;

  double? distanceMeters;
  String distanceFormatted;

  TicketModel({
    required this.id,
    required this.clientCode,
    required this.clientName,
    required this.category,
    required this.description,
    required this.address,
    required this.neighborhood,
    required this.city,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.createdAt,
    this.distanceMeters,
    this.distanceFormatted = '1.5 km',
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) {
    return TicketModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      clientCode: json['codigo_cliente'] ?? '',
      clientName: json['nome_cliente'] ?? '',
      category: json['categoria_informada'] ?? '',
      description: json['descricao_problema'] ?? '',
      address: json['endereco_cliente'] ?? '',
      neighborhood: json['bairro'] ?? '',
      city: json['cidade'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      status: json['status'] ?? '',
      createdAt: json['criado_em'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo_cliente': clientCode,
      'nome_cliente': clientName,
      'categoria_informada': category,
      'descricao_problema': description,
      'endereco_cliente': address,
      'bairro': neighborhood,
      'cidade': city,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'criado_em': createdAt,
    };
  }

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel(
      id: map['id'] is int ? map['id'] : int.parse(map['id'].toString()),
      clientCode: map['codigo_cliente'] ?? '',
      clientName: map['nome_cliente'] ?? '',
      category: map['categoria_informada'] ?? '',
      description: map['descricao_problema'] ?? '',
      address: map['endereco_cliente'] ?? '',
      neighborhood: map['bairro'] ?? '',
      city: map['cidade'] ?? '',
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? '',
      createdAt: map['criado_em'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'codigo_cliente': clientCode,
      'nome_cliente': clientName,
      'categoria_informada': category,
      'descricao_problema': description,
      'endereco_cliente': address,
      'bairro': neighborhood,
      'cidade': city,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'criado_em': createdAt,
    };
  }
}
