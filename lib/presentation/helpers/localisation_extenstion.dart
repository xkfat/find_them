import 'package:flutter/material.dart';
import 'package:find_them/l10n/app_localizations.dart';

extension LocalizationHelper on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this)!;
}
