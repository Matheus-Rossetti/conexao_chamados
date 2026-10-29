import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class LocalDbService {
  Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDb();
    return _database!;
  }

  Future<Database> _initDb() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'sctec_tickets.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await createTable(db);
      },
    );
  }

  Future<void> createTable([Database? dbConnection]) async {
    final db = dbConnection ?? await database;
    await db.execute('''
      CREATE TABLE IF NOT EXISTS tickets (
        id INTEGER PRIMARY KEY,
        codigo_cliente TEXT,
        nome_cliente TEXT,
        categoria_informada TEXT,
        descricao_problema TEXT,
        endereco_cliente TEXT,
        bairro TEXT,
        cidade TEXT,
        latitude REAL,
        longitude REAL,
        status TEXT,
        criado_em TEXT
      )
    ''');
  }
}
