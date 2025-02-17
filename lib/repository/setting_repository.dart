import 'dart:convert';

import 'package:sembast/sembast.dart';
import 'package:uuid/uuid.dart';

import '../models/webdav_config.dart';
import '../models/secret_config.dart';

class SettingRepository {
  SettingRepository(Database db) : _db = db;

  final Database _db;
  final StoreRef<String, String> _store = StoreRef<String, String>('__nest_setting__');
  final _webdavField = 'webdav';
  final _deviceIDField = 'device_id';
  final _secretsField = 'secrets';
  final _syncMethodField = 'sync_method';

  Future<String> getDeviceID() async {
    var record = _store.record(_deviceIDField);
    var devID = await record.get(_db);
    if (devID == null) {
      devID = Uuid().v4();
      await record.add(_db, devID);
    }
    return devID;
  }

  Future<WebdavConfig?> getWebdavConfig() async {
    var record = _store.record(_webdavField);
    var webdavStr = await record.get(_db);

    if (webdavStr == null) return null;
    var jsonMap = jsonDecode(webdavStr);
    return WebdavConfig.fromJson(jsonMap);
  }

  Future<String> setWebdavConfig(WebdavConfig config) async {
    var configStr = jsonEncode(config);
    return await _store.record(_webdavField).put(_db, configStr);
  }

  Future<String?> getSyncMethod() async {
    return await _store.record(_syncMethodField).get(_db);
  }

  Future<String> setSyncMethod(String method) async {
    return await _store.record(_syncMethodField).put(_db, method);
  }

  //isMaster即主密钥
  //用于所有账号数据加密/重新加密
  //非master为attSecrets
  //仅用于数据解密
  Future<List<SecretConfig>> getSecrets() async {
    var secretConfigs = <SecretConfig>[];
    var secrets = await _store.record(_secretsField).get(_db);

    if (secrets != null) {
      var jsonList = jsonDecode(secrets);
      for (var i in jsonList) {
        secretConfigs.add(SecretConfig.fromJson(i));
      }
    }
    return secretConfigs;
  }

  Future<String> setSecrets(List<SecretConfig> secrets) async {
    return await _store.record(_secretsField).put(_db, jsonEncode(secrets));
  }
}
