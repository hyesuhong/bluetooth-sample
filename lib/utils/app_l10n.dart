import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

abstract class AppL10n {
  AppL10n._();

  static AppLocalizations getL10n(BuildContext context) {
    return AppLocalizations.of(context)!;
  }
}
