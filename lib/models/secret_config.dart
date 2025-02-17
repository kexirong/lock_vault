import 'dart:convert';

class SecretConfig {
  final bool isMain;
  final String secret;
  final int createdAt;

  SecretConfig({required this.secret, this.isMain = false})
      : createdAt = DateTime.now().millisecondsSinceEpoch;

  SecretConfig.fromJson(Map<String, dynamic> json)
      : secret = json['secret'],
        isMain = json['is_main'],
        createdAt = json['created_at'];

  Map<String, dynamic> toJson() => <String, dynamic>{
        'secret': secret,
        'is_main': isMain,
        'created_at': createdAt,
      };

  @override
  String toString() {
    return jsonEncode(toJson());
  }

  SecretConfig copyWith({
    String? secret,
    bool? isMain,
  }) {
    return SecretConfig(
      secret: secret ?? this.secret,
      isMain: isMain ?? this.isMain,
    );
  }
}
