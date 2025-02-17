import 'dart:convert';

import 'package:uuid/uuid.dart';

class AccountGroup {
  AccountGroup({
    String? id,
      this.name='',
    this.description = '',
    int? createdAt,
    this.updatedAt = 0,
  })  : id = id ?? Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch;

  final String id;
  final String name;
  final String description;
  final int createdAt;
  final int updatedAt;

  AccountGroup copyWith({
    String? name,
    String? description,
  }) {
    return AccountGroup(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt,
      updatedAt: DateTime.now().millisecondsSinceEpoch,
    );
  }

  AccountGroup.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'],
        createdAt = json['created_at'],
        updatedAt = json['updated_at'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'name': name,
        'description': description,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }
}
