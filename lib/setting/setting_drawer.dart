import 'package:flutter/material.dart';

import '../l10n/l10n.dart';
import '../setting_secret/setting_secret_page.dart';
import '../setting_sync/setting_sync_page.dart';

class SettingDrawer extends StatelessWidget {
  const SettingDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            padding: EdgeInsets.fromLTRB(16.0, 48.0, 16.0, 8.0),
            decoration: BoxDecoration(),
            child: Text(l10n.drawerHeader),
          ),
          ListTile(
            leading: const Icon(Icons.enhanced_encryption_outlined),
            title: Text(l10n.drawerEncryption),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, SettingSecretPage.route());
            },
          ),
          const Divider(height: 0),
          //
          ListTile(
            leading: const Icon(Icons.sync),
            title: Text(l10n.drawerSync),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, SettingSyncPage.route());
            },
          ),
          const Divider(height: 0),
          ListTile(
            leading: const Icon(Icons.info),
            title: Text(l10n.drawerAbout),
            onTap: () {},
          ),
        ],
      ),
    );
  }
}
