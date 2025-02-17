part of 'setting_sync_cubit.dart';

final class SettingSyncState extends Equatable {
  const SettingSyncState({
    this.webdavUrl = '',
    this.webdavUser = '',
    this.webdavPassword = '',
    this.webdavPath = '',
  });

  final String webdavUrl;
  final String webdavUser;
  final String webdavPassword;
  final String webdavPath;

  SettingSyncState copyWith({
    String? webdavUrl,
    String? webdavUser,
    String? webdavPassword,
    String? webdavPath,
  }) {
    return SettingSyncState(
      webdavUrl: webdavUrl ?? this.webdavUrl,
      webdavUser: webdavUser ?? this.webdavUser,
      webdavPassword: webdavPassword ?? this.webdavPassword,
      webdavPath: webdavPath ?? this.webdavPath,
    );
  }

  @override
  List<Object?> get props => [webdavUrl, webdavUser, webdavPassword, webdavPath];
}
