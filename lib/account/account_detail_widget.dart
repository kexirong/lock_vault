import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../l10n/l10n.dart';

import '../models/account.dart';

class AccountDetailWidget extends StatelessWidget {
  final PlainAccount account;

  const AccountDetailWidget({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = context.l10n;
    var fieldMap = <String, String>{
      l10n.username: account.username,
      l10n.password: account.password,
      l10n.url: account.url
    }..addAll(account.extendField);

    var extend = <Widget>[];
    fieldMap.forEach((key, value) {
      extend.add(
        Row(
          children: <Widget>[
            Expanded(flex: 7, child: Text('$key: $value', overflow: TextOverflow.ellipsis)),
            Expanded(
              flex: 1,
              child: IconButton(
                padding: const EdgeInsets.all(0),
                icon: Icon(
                  Icons.content_copy,
                  size: 20,
                  color: colorScheme.tertiary,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: value));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(l10n.copyToClipboard),
                  ));
                },
              ),
            )
          ],
        ),
      );
    });

    return AlertDialog.adaptive(
      contentPadding: const EdgeInsets.all(16.0),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                account.title,
                style: const TextStyle(fontSize: 22),
              ),
            ],
          ),
          ...extend,
        ],
      ),
    );
  }
}
