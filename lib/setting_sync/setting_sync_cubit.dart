import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/webdav_config.dart';

part 'setting_sync_state.dart';

class SettingSyncCubit extends Cubit<SettingSyncState> {
  SettingSyncCubit(WebdavConfig? webdavConfig)
      : super(SettingSyncState(
          webdavUrl: webdavConfig?.url ?? '',
          webdavUser: webdavConfig?.user ?? '',
          webdavPassword: webdavConfig?.password ?? '',
          webdavPath: webdavConfig?.path ?? '',
        ));

  void webdavUrlChanged(String value) {
    emit(state.copyWith(webdavUrl: value));
  }

  void webdavUserChanged(String value) {
    emit(state.copyWith(webdavUser: value));
  }

  void webdavPasswordChanged(String value) {
    emit(state.copyWith(webdavPassword: value));
  }

  void webdavPathChanged(String value) {
    emit(state.copyWith(webdavPath: value));
  }
}
