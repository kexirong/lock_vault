import 'dart:convert';

import 'package:equatable/equatable.dart';

enum SyncMethod { off, webdav }

class WebdavConfig extends Equatable {
  final String url;
  final String user;
  final String password;
  final String path;

  const WebdavConfig({
    required this.url,
    required this.user,
    required this.password,
    this.path = '',
  });

  WebdavConfig.fromJson(Map<String, dynamic> json)
      : url = json['url'],
        user = json['user'],
        password = json['password'],
        path = json['path'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'url': url,
        'user': user,
        'password': password,
        'path': path,
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  @override
  List<Object?> get props => [url, user, password, path];
}
