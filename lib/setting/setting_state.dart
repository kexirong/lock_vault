part of 'setting_cubit.dart';

enum SettingStatus { initial, loading, success, failure }

final class SettingState extends Equatable {
  const SettingState({
    this.status = SettingStatus.initial,
    this.syncMethod = SyncMethod.off,
    this.secrets = const [],
    this.webdavConfig,
  });

  final SettingStatus status;

  final List<SecretConfig> secrets;

  final SyncMethod syncMethod;

  final WebdavConfig? webdavConfig;

  SettingState copyWith({
    SettingStatus? status,
    List<SecretConfig>? secrets,
    WebdavConfig? webdavConfig,
    SyncMethod? syncMethod,
  }) {
    return SettingState(
      status: status ?? this.status,
      secrets: secrets ?? this.secrets,
      webdavConfig: webdavConfig ?? this.webdavConfig,
      syncMethod: syncMethod ?? this.syncMethod,
    );
  }

  String? get mainSecret => _getMainSecret()?.secret;

  List<SecretConfig> get attSecrets => secrets.where((s) => !s.isMain).toList();

  bool isMainSecret(String mKey) {
    final mSecret = mainSecret;
    if (mSecret != null || md5.convert(utf8.encode(mSecret!)).toString() != mKey) {
      return false;
    }
    return true;
  }

  SecretConfig? _getMainSecret() {
    for (var s in secrets) {
      if (s.isMain) {
        return s;
      }
    }
    return null;
  }

  String? getSecret(String mKey) {
    for (var s in secrets) {
      if (md5.convert(utf8.encode(s.secret)).toString() == mKey) {
        return s.secret;
      }
    }
    return null;
  }

  @override
  List<Object?> get props => [status, secrets, syncMethod, webdavConfig];
}
