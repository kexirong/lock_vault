import 'dart:convert';

import 'package:sembast/sembast.dart';
import '../models/change_record.dart';

class ChangeRecordRepository {
  ChangeRecordRepository(Database db) : _db = db;

  final Database _db;

  static final StoreRef<String, String> store = StoreRef<String, String>('__nest_record_change__');

  Future<List<ChangeRecord>> getChangeRecords() async {
    var crs = <ChangeRecord>[];
    var records = await store.find(_db);
    for (var rec in records) {
      var jsonMap = jsonDecode(rec.value);
      crs.add(ChangeRecord.fromJson(jsonMap));
    }
    return crs;
  }
}
