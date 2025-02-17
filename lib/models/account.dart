import 'dart:convert';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

import 'package:uuid/uuid.dart';

sealed class BaseAccount {
  String get id;

  String get title;

  String get groupID;

  int get createdAt;

  int get updatedAt;

  Map<String, dynamic> toJson();

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}

class PlainAccount extends BaseAccount {
  PlainAccount({
    String? id,
    this.title = '',
    this.groupID = '',
    int? createdAt,
    this.updatedAt = 0,
    this.username = '',
    this.password = '',
    this.url = '',
    this.extendField = const {},
  })  : id = id ?? Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  @override
  final String id;
  @override
  final String title;
  @override
  final String groupID;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  final String username;
  final String password;

  final String url;
  final Map<String, String> extendField;

  PlainAccount.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        groupID = json['group_id'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        username = json['username'],
        password = json['password'],
        url = json['url'],
        extendField = {} {
    json['extend_field'].forEach((key, value) {
      if (value is String) {
        extendField[key] = value;
      }
    });
  }

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'group_id': groupID,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'username': username,
        'password': password,
        'url': url,
        'extend_field': extendField,
      };

  PlainAccount copyWith({
    String? title,
    String? groupID,
    String? username,
    String? password,
    String? url,
    Map<String, String>? extendField,
  }) {
    return PlainAccount(
      id: id,
      title: title ?? this.title,
      groupID: groupID ?? this.groupID,
      username: username ?? this.username,
      password: password ?? this.password,
      url: url ?? this.url,
      extendField: extendField ?? this.extendField,
      createdAt: createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  EncryptAccount encrypt(String password) {
    var iv = IV.fromLength(16);
    final encrypter = Encrypter(AES(_keyFromPassword(password), mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(
      jsonEncode(<String, dynamic>{
        'username': username,
        'password': password,
        'url': url,
        'extend_field': extendField,
      }),
      iv: iv,
    );
    return EncryptAccount(
      id: id,
      title: title,
      groupID: groupID,
      createdAt: createdAt,
      iv: iv.base64,
      mKey: md5.convert(utf8.encode(password)).toString(),
      data: encrypted.base64,
      updatedAt: updatedAt,
    );
  }
}

class EncryptAccount extends BaseAccount {
  @override
  final String id;
  @override
  final String title;
  @override
  final String groupID;
  @override
  final int createdAt;
  @override
  final int updatedAt;

  final String cipher;
  final AESMode mode;
  final String iv;
  final String mKey;
  final int encryptedAt;

  final String data;

  EncryptAccount({
    String? id,
    required this.title,
    this.groupID = '',
    int? createdAt,
    this.updatedAt = 0,
    this.cipher = 'AES',
    this.mode = AESMode.cbc,
    required this.iv,
    required this.mKey,
    this.data = '',
  })  : id = id ?? Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        encryptedAt = DateTime.now().millisecondsSinceEpoch;

  EncryptAccount.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        groupID = json['group_id'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'],
        cipher = json['cipher'],
        mode = AESMode.values.firstWhere((e) => e.name == json['mode'], orElse: () => AESMode.cbc),
        iv = json['iv'],
        mKey = json['m_key'],
        encryptedAt = json['encrypted_at'],
        data = json['data'];

  @override
  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'title': title,
        'group_id': groupID,
        'created_at': createdAt,
        'updated_at': updatedAt,
        'cipher': cipher,
        'mode': mode.name,
        'iv': iv,
        'encrypted_at': encryptedAt,
        'm_key': mKey,
        'data': data
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  PlainAccount decrypt(String pwd) {
    var key = _keyFromPassword(pwd);

    var encrypter = Encrypter(AES(key, mode: mode));
    var decrypted = encrypter.decrypt64(
      data,
      iv: IV.fromBase64(iv),
    );
    var json = <String, dynamic>{
      'id': id,
      'title': title,
      'group_id': groupID,
      'created_at': createdAt,
      'updated_at': updatedAt,
      ...jsonDecode(decrypted)
    };
    return PlainAccount.fromJson(json);
  }
}

Key _keyFromPassword(String password) {
  var pwdB = utf8.encode(password);
  var pwdSha = md5.convert(pwdB);
  pwdSha = md5.convert(pwdSha.bytes + pwdB);
  return Key(Uint8List.fromList(pwdSha.bytes));
}
