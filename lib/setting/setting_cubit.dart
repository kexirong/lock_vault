import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:crypto/crypto.dart';
import 'package:equatable/equatable.dart';
import 'package:lock_vault/repository/setting_repository.dart';

import '../models/secret_config.dart';
import '../models/webdav_config.dart';

part 'setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  SettingCubit({
    required SettingRepository settingRepository,
  })  : _settingRepository = settingRepository,
        super(const SettingState()) {
    _init();
  }

  final SettingRepository _settingRepository;

  void _init() {
    () async {
      emit(state.copyWith(status: SettingStatus.loading));
      final secrets = await _settingRepository.getSecrets();
      var syncMethodString = await _settingRepository.getSyncMethod();
      var syncMethod = SyncMethod.values
          .firstWhere((e) => e.name == syncMethodString, orElse: () => SyncMethod.off);

      var webdavConfig = await _settingRepository.getWebdavConfig();
      emit(state.copyWith(
        status: SettingStatus.success,
        secrets: secrets,
        syncMethod: syncMethod,
        webdavConfig: webdavConfig,
      ));
    }();
  }

  void setSyncMethod(SyncMethod method) {
    emit(state.copyWith(status: SettingStatus.loading));
    _settingRepository.setSyncMethod(method.name).then((value) {
      emit(state.copyWith(
        status: SettingStatus.success,
        syncMethod: method,
      ));
    });
  }

  void setWebdavConfig(WebdavConfig config) {
    emit(state.copyWith(status: SettingStatus.loading));
    _settingRepository.setWebdavConfig(config).then((value) {
      emit(state.copyWith(
        status: SettingStatus.success,
        webdavConfig: config,
      ));
    });
  }

  void setMainSecret(String secret) {
    emit(state.copyWith(status: SettingStatus.loading));
    final secrets = [...state.secrets];
    final index = secrets.indexWhere((element) => element.isMain);
    if (index >= 0) {
      final mSecret = secrets[index];
      secrets[index] = mSecret.copyWith(isMain: false);
    }

    secrets.add(SecretConfig(secret: secret, isMain: true));

    _settingRepository.setSecrets(secrets).then((value) {
      emit(state.copyWith(
        secrets: secrets,
        status: SettingStatus.success,
      ));
    });
  }

  void addSecret(String secret) {
    emit(state.copyWith(status: SettingStatus.loading));
    final secrets = [...state.secrets];
    secrets.add(SecretConfig(secret: secret));
    _settingRepository.setSecrets(secrets).then((value) {
      emit(state.copyWith(
        secrets: secrets,
        status: SettingStatus.success,
      ));
    });
  }

  void deleteSecret(String secret) {
    emit(state.copyWith(status: SettingStatus.loading));
    final secrets = [...state.secrets];
    final index = secrets.indexWhere((t) => t.secret == secret);
    if (index < 0) {
      return emit(state.copyWith(status: SettingStatus.failure));
    }
    secrets.removeAt(index);
    _settingRepository.setSecrets(secrets).then((value) {
      emit(state.copyWith(
        secrets: secrets,
        status: SettingStatus.success,
      ));
    });
  }
}
