import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

import '../models/account.dart';
import '../models/account_group.dart';
import '../models/change_record.dart';
import '../repository/change_record_repository.dart';
import '../sync_webdav/webdav_client.dart';

import '../models/webdav_config.dart';
import '../repository/account_repository.dart';
import '../repository/setting_repository.dart';

part 'sync_webdav_state.dart';

const lockFile = '.lock';

class SyncWebdavCubit extends Cubit<SyncWebdavState> {
  SyncWebdavCubit({
    required AccountRepository accountRepository,
    required SettingRepository settingRepository,
    required ChangeRecordRepository changeRecordRepository,
  })  : _accountRepository = accountRepository,
        _settingRepository = settingRepository,
        _changeRecordRepository = changeRecordRepository,
        super(const SyncWebdavState());

  final AccountRepository _accountRepository;
  final SettingRepository _settingRepository;
  final ChangeRecordRepository _changeRecordRepository;

  Future<WebdavClient?> get webdavClient async {
    var conf = await _settingRepository.getWebdavConfig();
    if (conf == null) return null;
    return WebdavClient(conf.url, conf.user, conf.password, path: conf.path);
  }

  Future<void> sync() async {
    if (state.status == SyncStatus.syncing) {
      return emit(state.copyWith(needSync: true));
    }
    var method = await _settingRepository.getSyncMethod();
    if (method != SyncMethod.webdav.name) return;
    var client = await webdavClient;
    if (client == null) return;
    try {
      await doSync(client);
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      emit(state.copyWith(status: SyncStatus.failure, needSync: true));
      return;
    } finally {
      try {
        await _unlock(client);
      } finally {
        if (state.needSync) {
          Future.delayed(Duration(seconds: 1), () {
            emit(state.copyWith(needSync: false));
            sync();
          });
        }
      }
    }
  }

  Future<void> doSync(WebdavClient client) async {
    emit(state.copyWith(status: SyncStatus.syncing));

    if (await _hasLock(client)) {
      return emit(state.copyWith(status: SyncStatus.failure, needSync: true));
    }

    await _lock(client);

    var records = await _changeRecordRepository.getChangeRecords();
    var lzRecords = zipRecords(records);

    var ret = await client.read('change_records_mate');
    Map<String, ChangeRecord> cRecords = ret == null ? {} : _toRecords(json.decode(ret));

    final syncEvents = diffRecords(lzRecords, cRecords);

    for (var event in syncEvents) {
      switch (event.action) {
        case SyncAction.upload:
          String dataStr;
          switch (event.itemType) {
            case ItemType.group:
              dataStr = (await _accountRepository.getAccount(event.itemID)).toString();

            case ItemType.account:
              dataStr = (await _accountRepository.getAccount(event.itemID)).toString();
          }
          await client.write("${event.itemType.name}_${event.itemID}", dataStr);
        case SyncAction.add:
        case SyncAction.update:
          var itemStr = await client.read("${event.itemType.name}_${event.itemID}");
          if (itemStr == null) {
            continue;
          }
          var item = jsonDecode(itemStr);
          switch (event.itemType) {
            case ItemType.group:
              var ag = AccountGroup.fromJson(item);
              await (event.action == SyncAction.add
                  ? _accountRepository.addGroup(ag)
                  : _accountRepository.updateGroup(ag));
            case ItemType.account:
              BaseAccount acct;
              if (item.containsKey('cipher')) {
                acct = EncryptAccount.fromJson(item);
              } else {
                acct = PlainAccount.fromJson(item);
              }
              await (event.action == SyncAction.add
                  ? _accountRepository.addAccount(acct)
                  : _accountRepository.updateAccount(acct));
          }
        case SyncAction.delete:
          switch (event.itemType) {
            case ItemType.group:
              var group = await _accountRepository.getGroup(event.itemID);
              if (group != null) {
                await _accountRepository.deleteGroup(group);
              }
            case ItemType.account:
              var acct = await _accountRepository.getAccount(event.itemID);
              if (acct != null) {
                await _accountRepository.deleteAccount(acct);
              }
          }
        case SyncAction.remoteDelete:
          await client.delete("${event.itemType.name}_${event.itemID}");
      }
    }
    var lRecords = await _changeRecordRepository.getChangeRecords();

    await client.write("change_records_mate", jsonEncode(zipRecords(lRecords).values.toList()));
    return emit(state.copyWith(status: SyncStatus.success));
  }

  Future<bool> _hasLock(WebdavClient client) async {
    var ret = await client.read(lockFile);
    if (ret == null) return false;
    var jRet = json.decode(ret);
    int expired = jRet['expired'];
    if (DateTime.now().millisecondsSinceEpoch > expired) {
      return false;
    }

    return true;
  }

  Future<void> _lock(WebdavClient client) async {
    var deviceID = await _settingRepository.getDeviceID();

    var lockData = <String, dynamic>{
      'device_id': deviceID,
      'expired': DateTime.now().add(state.duration).millisecondsSinceEpoch,
    };
    await client.write(lockFile, jsonEncode(lockData));
  }

  Future<void> _unlock(WebdavClient client) async {
    await client.delete(lockFile);
  }
}

enum SyncAction { add, update, delete, upload, remoteDelete }

class SyncEvent {
  String itemID;
  ItemType itemType;
  SyncAction action;

  SyncEvent(this.itemID, this.itemType, this.action);

  @override
  String toString() {
    return "{'item_id':$itemID,'item_type':$itemType,'action':${action.name}";
  }
}

Map<ID, ChangeRecord> zipRecords(List<ChangeRecord> records) {
  Map<ID, ChangeRecord> recs = {};
  for (var item in records) {
    var value = recs[item.id];
    if (value == null) {
      recs[item.id] = item;
      continue;
    }
    if (value.recordType.index >= item.recordType.index && value.timestamp >= item.timestamp) {
      continue;
    }
    recs[item.id] = item;
  }
  return recs;
}

Map<String, ChangeRecord> _toRecords(List<dynamic> jsonInstance) {
  List<ChangeRecord> records = [];
  for (var i in jsonInstance) {
    var rm = ChangeRecord.fromJson(i);
    records.add(rm);
  }
  return zipRecords(records);
}

List<SyncEvent> diffRecords(
    Map<ID, ChangeRecord> localRecords, Map<ID, ChangeRecord> remoteRecords) {
  List<SyncEvent> ses = [];

  remoteRecords.forEach((key, rItem) {
    var lItem = localRecords[key];
    if (lItem == null) {
      if (rItem.recordType != RecordType.delete) {
        ses.add(SyncEvent(key, rItem.itemType, SyncAction.add));
      }
      return;
    }
    if (rItem.recordType.index > lItem.recordType.index || rItem.timestamp > lItem.timestamp) {
      SyncAction action;
      switch (lItem.recordType) {
        case RecordType.delete:
          action = SyncAction.delete;
        case RecordType.create:
          action = SyncAction.add;
        case RecordType.update:
          action = SyncAction.update;
      }
      ses.add(SyncEvent(
          key, rItem.itemType, lItem.recordType == RecordType.delete ? SyncAction.delete : action));
    }
  });
  localRecords.forEach((key, lItem) {
    var rItem = remoteRecords[key];
    if (rItem == null) {
      if (lItem.recordType != RecordType.delete) {
        ses.add(SyncEvent(key, lItem.itemType, SyncAction.upload));
      }
      return;
    }
    if (lItem.recordType.index > rItem.recordType.index || lItem.timestamp > rItem.timestamp) {
      ses.add(SyncEvent(key, lItem.itemType,
          rItem.recordType == RecordType.delete ? SyncAction.remoteDelete : SyncAction.upload));
    }
  });

  return ses;
}
