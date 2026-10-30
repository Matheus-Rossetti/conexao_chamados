class ServiceModel {
  final int? id;
  final int ticketFk;
  final int synchronized;
  final String conclusion;
  final String description;
  final String date;
  final String? imagePath;

  ServiceModel({
    this.id,
    required this.ticketFk,
    this.synchronized = 0,
    required this.conclusion,
    required this.description,
    required this.date,
    this.imagePath,
  });

  factory ServiceModel.fromMap(Map<String, dynamic> map) {
    return ServiceModel(
      id: map['id'] is int
          ? map['id']
          : (map['id'] != null ? int.parse(map['id'].toString()) : null),
      ticketFk: map['ticket_fk'] is int
          ? map['ticket_fk']
          : int.parse(map['ticket_fk'].toString()),
      synchronized: map['sincronizado'] is int
          ? map['sincronizado']
          : (map['sincronizado'] == true ? 1 : 0),
      conclusion: map['conclusao'] ?? '',
      description: map['descricao'] ?? '',
      date: map['data'] ?? '',
      imagePath: map['imagem'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'ticket_fk': ticketFk,
      'sincronizado': synchronized,
      'conclusao': conclusion,
      'descricao': description,
      'data': date,
      'imagem': imagePath,
    };
  }
}
