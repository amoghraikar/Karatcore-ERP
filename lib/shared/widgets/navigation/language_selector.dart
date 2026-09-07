import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/localization/locale_provider.dart';

class LanguageSelector extends ConsumerWidget {
  const LanguageSelector({super.key});

  static Future<void> showLanguageDialog(BuildContext context, WidgetRef ref) async {
    final activeLocale = ref.read(localeProvider);
    final scheme = Theme.of(context).colorScheme;

    await showDialog<void>(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD97706).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.language_rounded, color: Color(0xFFD97706), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context).translate('select_language'),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      AppLocalizations.of(context).translate('select_app_language_desc'),
                      style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: AppLocalizations.supportedLocales.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final locale = AppLocalizations.supportedLocales[index];
                final isSelected = activeLocale.languageCode == locale.languageCode;
                final name = AppLocalizations.languageNames[locale.languageCode] ?? locale.languageCode;

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  leading: Icon(
                    isSelected ? Icons.radio_button_checked_rounded : Icons.radio_button_off_rounded,
                    color: isSelected ? const Color(0xFF059669) : Colors.grey,
                  ),
                  title: Text(
                    name,
                    style: TextStyle(
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                      color: isSelected ? const Color(0xFF059669) : scheme.onSurface,
                    ),
                  ),
                  trailing: isSelected
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF059669).withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'ACTIVE',
                            style: TextStyle(
                              color: Color(0xFF059669),
                              fontWeight: FontWeight.w800,
                              fontSize: 10,
                            ),
                          ),
                        )
                      : null,
                  onTap: () {
                    ref.read(localeProvider.notifier).setLanguageCode(locale.languageCode);
                    Navigator.of(ctx).pop();
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

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
