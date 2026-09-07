import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:karatcore_erp/core/localization/app_localizations.dart';
import 'package:karatcore_erp/core/localization/locale_provider.dart';

void main() {
  group('AppLocalizations & Multilingual Support Tests', () {
    test('All 7 supported locales and names are configured', () {
      expect(AppLocalizations.supportedLocales.length, 7);
      final codes = AppLocalizations.supportedLocales.map((l) => l.languageCode).toSet();
      expect(codes, containsAll(['en', 'hi', 'ta', 'te', 'kn', 'gu', 'mr']));

      for (final code in codes) {
        expect(AppLocalizations.languageNames.containsKey(code), isTrue);
      }
    });

    test('AppLocalizationsDelegate supports all 7 languages', () {
      const delegate = AppLocalizationsDelegate();
      for (final code in ['en', 'hi', 'ta', 'te', 'kn', 'gu', 'mr']) {
        expect(delegate.isSupported(Locale(code)), isTrue);
      }
      expect(delegate.isSupported(const Locale('fr')), isFalse);
    });

    test('Telugu translations contain genuine Telugu script (not Kannada)', () {
      final teLoc = AppLocalizations(const Locale('te'));
      expect(teLoc.translate('resend_otp'), equals('మళ్లీ OTP పంపండి'));
      expect(teLoc.translate('gross_weight'), equals('మొత్తం బరువు'));
      expect(teLoc.translate('purity'), equals('బంగారు స్వచ్ఛత'));
      expect(teLoc.translate('valuation'), equals('మార్కెట్ విలువ'));
      expect(teLoc.translate('view_certificate'), equals('సర్టిఫికేట్ చూడండి'));
      expect(teLoc.translate('status'), equals('స్థితి'));
      expect(teLoc.translate('closed'), equals('ముగిసింది'));
      expect(teLoc.translate('vault_secure'), equals('వాల్ట్ సురక్షితం'));
    });

    test('Kannada translations contain genuine Kannada script', () {
      final knLoc = AppLocalizations(const Locale('kn'));
      expect(knLoc.translate('resend_otp'), equals('OTP ಮರುಕಳುಹಿಸಿ'));
      expect(knLoc.translate('gross_weight'), equals('ಒಟ್ಟು ತೂಕ'));
      expect(knLoc.translate('purity'), equals('ಚಿನ್ನದ ಶುದ್ಧತೆ'));
    });

    test('Hindi, Tamil, Gujarati, and Marathi translations resolve correctly', () {
      final hiLoc = AppLocalizations(const Locale('hi'));
      expect(hiLoc.translate('app_name'), equals('कैरेटकोर ईआरपी'));
      expect(hiLoc.translate('dashboard'), equals('डैशबोर्ड'));

      final taLoc = AppLocalizations(const Locale('ta'));
      expect(taLoc.translate('app_name'), equals('கேரட்கோர் ERP'));
      expect(taLoc.translate('dashboard'), equals('டாஷ்போர்டு'));

      final guLoc = AppLocalizations(const Locale('gu'));
      expect(guLoc.translate('app_name'), equals('કેરેટકોર ERP'));
      expect(guLoc.translate('dashboard'), equals('ડેશબોર્ડ'));

      final mrLoc = AppLocalizations(const Locale('mr'));
      expect(mrLoc.translate('app_name'), equals('कॅरेटकोर ERP'));
      expect(mrLoc.translate('dashboard'), equals('डॅशबोर्ड'));
    });

    test('Sidebar navigation headers & items resolve in all 7 languages', () {
      final testKeys = [
        'core_operations',
        'jewellery_and_assets',
        'finance_and_analytics',
        'security_and_audit',
        'store_administration',
        'accounting_ledger',
        'reports_and_analytics',
        'audit_log',
        'security_activity',
        'notifications',
        'owner_profile',
        'store_settings',
        'help_and_docs',
        'kyc_verification',
        'inventory_and_stock',
        'pledges_and_loans',
        'welcome_back',
        'search_placeholder',
        'vault_secure',
      ];

      for (final code in ['en', 'hi', 'ta', 'te', 'kn', 'gu', 'mr']) {
        final loc = AppLocalizations(Locale(code));
        for (final key in testKeys) {
          final translated = loc.translate(key);
          expect(translated, isNotEmpty, reason: 'Key "$key" should have translation in "$code"');
          if (code != 'en') {
            // Should not fall back to English key name
            expect(translated != key, isTrue, reason: 'Key "$key" was not translated for "$code"');
          }
        }
      }
    });

    test('LocaleNotifier switches active locale reactively', () {
      final container = ProviderContainer();
      addTearDown(container.dispose);

      expect(container.read(localeProvider), equals(const Locale('en')));

      container.read(localeProvider.notifier).setLanguageCode('hi');
      expect(container.read(localeProvider), equals(const Locale('hi')));

      container.read(localeProvider.notifier).setLanguageCode('ta');
      expect(container.read(localeProvider), equals(const Locale('ta')));

      container.read(localeProvider.notifier).setLanguageCode('te');
      expect(container.read(localeProvider), equals(const Locale('te')));

      container.read(localeProvider.notifier).setLanguageCode('kn');
      expect(container.read(localeProvider), equals(const Locale('kn')));

      container.read(localeProvider.notifier).setLanguageCode('gu');
      expect(container.read(localeProvider), equals(const Locale('gu')));

      container.read(localeProvider.notifier).setLanguageCode('mr');
      expect(container.read(localeProvider), equals(const Locale('mr')));
    });
  });
}
