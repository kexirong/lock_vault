import 'dart:convert';

import 'package:sembast/sembast.dart';

import '../models/account.dart';
import '../models/account_group.dart';
import '../models/change_record.dart';
import 'change_record_repository.dart';

class AccountRepository {
  AccountRepository(Database db) : _db = db;

  final Database _db;
  final StoreRef<String, String> _accountStore = StoreRef<String, String>('__nest_account__');
  final StoreRef<String, String> _groupStore = StoreRef<String, String>('__nest_account_group__');

  Future<List<BaseAccount>> getAccounts() async {
    var bas = <BaseAccount>[];
    var records = await _accountStore.find(_db);
    for (var rec in records) {
      var jsonMap = jsonDecode(rec.value) as Map<String, dynamic>;

      if (jsonMap.containsKey('cipher')) {
        bas.add(EncryptAccount.fromJson(jsonMap));
      } else {
        bas.add(PlainAccount.fromJson(jsonMap));
      }
    }
    return bas;
  }

  Future<BaseAccount?> getAccount(String key) async {
    var rec = await _accountStore.record(key).get(_db);
    if (rec == null) return null;
    var jsonMap = jsonDecode(rec) as Map<String, dynamic>;
    if (jsonMap.containsKey('cipher')) {
      return EncryptAccount.fromJson(jsonMap);
    }
    return PlainAccount.fromJson(jsonMap);
  }

  Future<void> addAccount(BaseAccount account) async {
    var cr = ChangeRecord(account.id, ItemType.account, RecordType.create, account.createdAt);
    await _db.transaction((txn) async {
      await _accountStore.record(account.id).add(txn, jsonEncode(account));
      await ChangeRecordRepository.store.add(txn, jsonEncode(cr));
    });
  }

  Future<void> updateAccount(BaseAccount account) async {
    var cr = ChangeRecord(account.id, ItemType.account, RecordType.update, account.updatedAt);

    await _db.transaction((txn) async {
      await _accountStore.record(account.id).put(txn, jsonEncode(account));
      await ChangeRecordRepository.store.add(txn, jsonEncode(cr));
    });
  }

  Future<void> deleteAccount(BaseAccount account) async {
    var cr = ChangeRecord(
      account.id,
      ItemType.account,
      RecordType.delete,
      DateTime.now().millisecondsSinceEpoch,
    );
    await _db.transaction((txn) async {
      await _accountStore.record(account.id).delete(txn);
      await ChangeRecordRepository.store.add(txn, jsonEncode(cr));
    });
  }

  Future<List<AccountGroup>> getGroups() async {
    var ngs = <AccountGroup>[];
    var records = await _groupStore.find(_db);
    for (var rec in records) {
      var jsonMap = jsonDecode(rec.value);
      ngs.add(AccountGroup.fromJson(jsonMap));
    }
    return ngs;
  }

  Future<AccountGroup?> getGroup(String key) async {
    var rec = await _groupStore.record(key).get(_db);
    if (rec == null) return null;
    var jsonMap = jsonDecode(rec);
    return AccountGroup.fromJson(jsonMap);
  }

  Future<void> addGroup(AccountGroup group) async {
    var cr = ChangeRecord(group.id, ItemType.group, RecordType.create, group.createdAt);
    await _db.transaction((txn) async {
      await _groupStore.record(group.id).add(txn, jsonEncode(group));
      await ChangeRecordRepository.store.add(txn, jsonEncode(cr));
    });
  }

  Future<void> updateGroup(AccountGroup group) async {
    var cr = ChangeRecord(group.id, ItemType.group, RecordType.update, group.updatedAt);
    await _db.transaction((txn) async {
      await _groupStore.record(group.id).put(txn, jsonEncode(group));
      await ChangeRecordRepository.store.add(txn, jsonEncode(cr));
    });
  }

  Future<void> deleteGroup(AccountGroup group) async {
    var cr = ChangeRecord(
      group.id,
      ItemType.group,
      RecordType.delete,
      DateTime.now().millisecondsSinceEpoch,
    );
    await _db.transaction((txn) async {
      await _groupStore.record(group.id).delete(txn);
      await ChangeRecordRepository.store.add(txn, jsonEncode(cr));
    });
  }
}
