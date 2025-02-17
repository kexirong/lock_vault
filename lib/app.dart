import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sembast/sembast.dart';

import 'account/account_cubit.dart';
import 'home/home_view.dart';
import 'repository/account_repository.dart';
import 'repository/change_record_repository.dart';
import 'repository/setting_repository.dart';
import 'setting/setting_cubit.dart';
import 'l10n/l10n.dart';
import 'sync_webdav/sync_webdav_cubit.dart';

class App extends StatelessWidget {
  const App({required this.db, super.key});

  final Database db;

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AccountRepository>(create: (context) => AccountRepository(db)),
        RepositoryProvider<ChangeRecordRepository>(create: (context) => ChangeRecordRepository(db)),
        RepositoryProvider<SettingRepository>(create: (context) => SettingRepository(db)),
      ],
      child: AppView(),
    );
  }
}

class AppView extends StatelessWidget {
  const AppView({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<SettingCubit>(
          create: (context) => SettingCubit(settingRepository: context.read<SettingRepository>()),
        ),
        BlocProvider<AccountCubit>(
          create: (context) => AccountCubit(accountRepository: context.read<AccountRepository>()),
        ),
        BlocProvider<SyncWebdavCubit>(
          create: (context) => SyncWebdavCubit(
            accountRepository: context.read<AccountRepository>(),
            settingRepository: context.read<SettingRepository>(),
            changeRecordRepository: context.read<ChangeRecordRepository>(),
          ),
        ),
      ],
      child: BlocListener<AccountCubit, AccountState>(
        listenWhen: (previous, current) =>
            previous.status != AccountStatus.loading && current.status == AccountStatus.success,
        listener: (context, state) => context.read<SyncWebdavCubit>().sync(),
        child: MaterialApp(
          theme: ThemeData(colorSchemeSeed: Color.fromRGBO(76, 92, 146, 1)),
          // theme: FlutterTodosTheme.light,
          // darkTheme: FlutterTodosTheme.dark,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const HomePage(),
        ),
      ),
    );
  }
}

class AppBlocObserver extends BlocObserver {
  const AppBlocObserver();

  @override
  void onChange(BlocBase<dynamic> bloc, Change<dynamic> change) {
    super.onChange(bloc, change);
    log('onChange(${bloc.runtimeType}, $change)');
  }

  @override
  void onError(BlocBase<dynamic> bloc, Object error, StackTrace stackTrace) {
    log('onError(${bloc.runtimeType}, $error, $stackTrace)');
    super.onError(bloc, error, stackTrace);
  }
}
