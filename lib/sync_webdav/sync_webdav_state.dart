part of 'sync_webdav_cubit.dart';

enum SyncStatus { initial, syncing, success, failure }

final class SyncWebdavState extends Equatable {
  const SyncWebdavState({
    this.status = SyncStatus.initial,
    this.duration = const Duration(seconds: 20),
    this.needSync = false,
  });

  final SyncStatus status;

  final Duration duration;

  final bool needSync;

  SyncWebdavState copyWith({
    SyncStatus? status,
    Duration? duration,
    bool? needSync,
  }) {
    return SyncWebdavState(
      status: status ?? this.status,
      duration: duration ?? this.duration,
      needSync: needSync ?? this.needSync,
    );
  }

  @override
  List<Object?> get props => [status, duration, needSync];
}
