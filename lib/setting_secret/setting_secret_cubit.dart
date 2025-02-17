import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import '../models/secret_config.dart';

part 'setting_secret_state.dart';

class SettingSecretCubit extends Cubit<SettingSecretState> {
  SettingSecretCubit() : super(const SettingSecretState());

  void newMainSecretChanged(String value) {
    emit(state.copyWith(newMainSecret: value));
  }

  void confirmNewMainSecretChanged(String value) {
    emit(state.copyWith(confirmNewMainSecret: value));
  }
}
