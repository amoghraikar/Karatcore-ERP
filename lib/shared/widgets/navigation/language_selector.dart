import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeLocale = ref.watch(localeProvider);

    return PopupMenuButton<String>(
      icon: const Icon(Icons.language_rounded, size: 20),
      tooltip: AppLocalizations.of(context).translate('select_language'),
      onSelected: (String langCode) {
        ref.read(localeProvider.notifier).setLanguageCode(langCode);
      },
      itemBuilder: (BuildContext context) {
        return AppLocalizations.supportedLocales.map((Locale locale) {
          final isSelected = activeLocale.languageCode == locale.languageCode;
          final name = AppLocalizations.languageNames[locale.languageCode] ?? locale.languageCode;
          return PopupMenuItem<String>(
            value: locale.languageCode,
            child: Row(
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                  size: 18,
                  color: isSelected ? const Color(0xFF059669) : Colors.grey,
                ),
                const SizedBox(width: 10),
                Text(
                  name,
                  style: TextStyle(
                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w500,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
    );
  }
}
