import 'package:isar_community/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:test_app/models/note_db.dart';

class Database {
  Database._();

  static final Database instance = Database._();

  late Isar _db;

  Isar get db => _db;

  Future<void> init() async {
    final dir = await getApplicationDocumentsDirectory();

    _db = await Isar.open([NoteDataSchema], directory: dir.path);
  }
}

Isar get db => Database.instance.db;
