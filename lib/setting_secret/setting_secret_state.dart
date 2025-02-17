part of 'setting_secret_cubit.dart';

final class SettingSecretState extends Equatable {
  const SettingSecretState({
    this.newMainSecret = '',
    this.confirmNewMainSecret = '',
  });

  final String newMainSecret;
  final String confirmNewMainSecret;

  SettingSecretState copyWith({
    List<SecretConfig>? secrets,
    String? newMainSecret,
    String? confirmNewMainSecret,
  }) {
    return SettingSecretState(
      newMainSecret: newMainSecret ?? this.newMainSecret,
      confirmNewMainSecret: confirmNewMainSecret ?? this.confirmNewMainSecret,
    );
  }

  @override
  List<Object?> get props => [newMainSecret, confirmNewMainSecret];
}
