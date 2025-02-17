import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_zh.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('zh')
  ];

  /// 首页的标题
  ///
  /// In zh, this message translates to:
  /// **'账号列表'**
  String get accountsHomeTitle;

  /// No description provided for @editAccountTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑账号'**
  String get editAccountTitle;

  /// No description provided for @addAccountTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加账号'**
  String get addAccountTitle;

  /// No description provided for @editAccountGroupTitle.
  ///
  /// In zh, this message translates to:
  /// **'编辑分组'**
  String get editAccountGroupTitle;

  /// No description provided for @addAccountGroupTitle.
  ///
  /// In zh, this message translates to:
  /// **'添加分组'**
  String get addAccountGroupTitle;

  /// No description provided for @accountTitle.
  ///
  /// In zh, this message translates to:
  /// **'标题'**
  String get accountTitle;

  /// No description provided for @username.
  ///
  /// In zh, this message translates to:
  /// **'用户名'**
  String get username;

  /// No description provided for @password.
  ///
  /// In zh, this message translates to:
  /// **'密码'**
  String get password;

  /// No description provided for @url.
  ///
  /// In zh, this message translates to:
  /// **'URL'**
  String get url;

  /// No description provided for @accountGroup.
  ///
  /// In zh, this message translates to:
  /// **'分组'**
  String get accountGroup;

  /// No description provided for @accountExtend.
  ///
  /// In zh, this message translates to:
  /// **'扩展字段'**
  String get accountExtend;

  /// No description provided for @groupName.
  ///
  /// In zh, this message translates to:
  /// **'分组名'**
  String get groupName;

  /// No description provided for @groupDescription.
  ///
  /// In zh, this message translates to:
  /// **'分组描述'**
  String get groupDescription;

  /// No description provided for @copyToClipboard.
  ///
  /// In zh, this message translates to:
  /// **'已复制到剪贴板'**
  String get copyToClipboard;

  /// No description provided for @edit.
  ///
  /// In zh, this message translates to:
  /// **'编辑'**
  String get edit;

  /// No description provided for @delete.
  ///
  /// In zh, this message translates to:
  /// **'删除'**
  String get delete;

  /// No description provided for @unableDecrypted.
  ///
  /// In zh, this message translates to:
  /// **'未能解密，请设置密码'**
  String get unableDecrypted;

  /// No description provided for @filledField.
  ///
  /// In zh, this message translates to:
  /// **'请填写此字段'**
  String get filledField;

  /// No description provided for @randPasswordButton.
  ///
  /// In zh, this message translates to:
  /// **'随机密码'**
  String get randPasswordButton;

  /// No description provided for @addFieldButton.
  ///
  /// In zh, this message translates to:
  /// **'添加字段'**
  String get addFieldButton;

  /// No description provided for @defaultGroup.
  ///
  /// In zh, this message translates to:
  /// **'默认分组'**
  String get defaultGroup;

  /// No description provided for @search.
  ///
  /// In zh, this message translates to:
  /// **'搜索'**
  String get search;

  /// No description provided for @groupsTitle.
  ///
  /// In zh, this message translates to:
  /// **'分组列表'**
  String get groupsTitle;

  /// No description provided for @defaultGroupDescription.
  ///
  /// In zh, this message translates to:
  /// **'默认组不可删除编辑'**
  String get defaultGroupDescription;

  /// No description provided for @drawerHeader.
  ///
  /// In zh, this message translates to:
  /// **'设置'**
  String get drawerHeader;

  /// No description provided for @drawerEncryption.
  ///
  /// In zh, this message translates to:
  /// **'加密'**
  String get drawerEncryption;

  /// No description provided for @drawerSync.
  ///
  /// In zh, this message translates to:
  /// **'同步'**
  String get drawerSync;

  /// No description provided for @drawerAbout.
  ///
  /// In zh, this message translates to:
  /// **'关于'**
  String get drawerAbout;

  /// No description provided for @settingSecretTitle.
  ///
  /// In zh, this message translates to:
  /// **'加密设置'**
  String get settingSecretTitle;

  /// No description provided for @mainSecret.
  ///
  /// In zh, this message translates to:
  /// **'主密钥'**
  String get mainSecret;

  /// No description provided for @attSecrets.
  ///
  /// In zh, this message translates to:
  /// **'附加密钥'**
  String get attSecrets;

  /// No description provided for @setMainSecret.
  ///
  /// In zh, this message translates to:
  /// **'请先设置主密钥'**
  String get setMainSecret;

  /// No description provided for @reEncrypt.
  ///
  /// In zh, this message translates to:
  /// **'重新加密'**
  String get reEncrypt;

  /// No description provided for @reEncryptComplete.
  ///
  /// In zh, this message translates to:
  /// **'重新加密完成'**
  String get reEncryptComplete;

  /// No description provided for @oldSecret.
  ///
  /// In zh, this message translates to:
  /// **'原密钥'**
  String get oldSecret;

  /// No description provided for @inputOldSecret.
  ///
  /// In zh, this message translates to:
  /// **'请输入原密钥'**
  String get inputOldSecret;

  /// No description provided for @invalidOldSecret.
  ///
  /// In zh, this message translates to:
  /// **'原密钥错误'**
  String get invalidOldSecret;

  /// No description provided for @newSecret.
  ///
  /// In zh, this message translates to:
  /// **'新密钥'**
  String get newSecret;

  /// No description provided for @inputNewSecret.
  ///
  /// In zh, this message translates to:
  /// **'请输入新密钥'**
  String get inputNewSecret;

  /// No description provided for @newSecretConfirm.
  ///
  /// In zh, this message translates to:
  /// **'确认新密钥'**
  String get newSecretConfirm;

  /// No description provided for @notMatchNewSecret.
  ///
  /// In zh, this message translates to:
  /// **'新密钥不一致'**
  String get notMatchNewSecret;

  /// No description provided for @save.
  ///
  /// In zh, this message translates to:
  /// **'保存'**
  String get save;

  /// No description provided for @confirm.
  ///
  /// In zh, this message translates to:
  /// **'请确认'**
  String get confirm;

  /// No description provided for @confirmContent.
  ///
  /// In zh, this message translates to:
  /// **'确认删除此密钥?'**
  String get confirmContent;

  /// No description provided for @ok.
  ///
  /// In zh, this message translates to:
  /// **'确认'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In zh, this message translates to:
  /// **'取消'**
  String get cancel;

  /// No description provided for @add.
  ///
  /// In zh, this message translates to:
  /// **'添加'**
  String get add;

  /// No description provided for @addAttSecret.
  ///
  /// In zh, this message translates to:
  /// **'添加附加密密钥'**
  String get addAttSecret;

  /// No description provided for @secretNotSecret.
  ///
  /// In zh, this message translates to:
  /// **'密钥不能为空'**
  String get secretNotSecret;

  /// No description provided for @test.
  ///
  /// In zh, this message translates to:
  /// **'测试'**
  String get test;

  /// No description provided for @syncTitle.
  ///
  /// In zh, this message translates to:
  /// **'同步'**
  String get syncTitle;

  /// No description provided for @syncMethod.
  ///
  /// In zh, this message translates to:
  /// **'同步方式'**
  String get syncMethod;

  /// No description provided for @webdav.
  ///
  /// In zh, this message translates to:
  /// **'Webdav'**
  String get webdav;

  /// No description provided for @doSync.
  ///
  /// In zh, this message translates to:
  /// **'立即同步'**
  String get doSync;

  /// No description provided for @webdavPath.
  ///
  /// In zh, this message translates to:
  /// **'路径'**
  String get webdavPath;

  /// No description provided for @saveSuccess.
  ///
  /// In zh, this message translates to:
  /// **'保存成功'**
  String get saveSuccess;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['zh'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'zh': return AppLocalizationsZh();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
