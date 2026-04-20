import 'package:email_classifier_app/models/email_cache_snapshot.dart';
import 'package:email_classifier_app/models/email_model.dart';
import 'package:email_classifier_app/services/cache_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'test_helpers.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('EmailModel serialization', () {
    test('round-trips through json', () {
      final EmailModel original = buildEmail(
        id: '1',
        subject: 'Order confirmed',
        category: EmailCategory.order,
      );

      final EmailModel restored = EmailModel.fromJson(original.toJson());

      expect(restored.id, original.id);
      expect(restored.subject, original.subject);
      expect(restored.category, EmailCategory.order);
      expect(restored.labelIds, original.labelIds);
    });
  });

  group('CacheService', () {
    test('saves and loads a snapshot', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final CacheService cacheService = CacheService();
      final EmailCacheSnapshot snapshot = EmailCacheSnapshot(
        emails: <EmailModel>[
          buildEmail(
            id: '1',
            subject: 'Order confirmed',
            category: EmailCategory.order,
          ),
        ],
        nextPageTokensByLabel: const <String, String?>{
          'INBOX': 'page-2',
          'CATEGORY_PROMOTIONS': null,
          'SPAM': null,
        },
        lastSyncedAt: DateTime(2026, 4, 20, 10),
        schemaVersion: CacheService.schemaVersion,
      );

      await cacheService.saveSnapshot(snapshot);
      final EmailCacheSnapshot? restored = await cacheService.loadSnapshot();

      expect(restored, isNotNull);
      expect(restored!.emails.single.subject, 'Order confirmed');
      expect(restored.nextPageTokensByLabel['INBOX'], 'page-2');
    });

    test('clears a snapshot', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{});
      final CacheService cacheService = CacheService();
      final EmailCacheSnapshot snapshot = EmailCacheSnapshot(
        emails: <EmailModel>[
          buildEmail(
            id: '1',
            subject: 'Order confirmed',
            category: EmailCategory.order,
          ),
        ],
        nextPageTokensByLabel: const <String, String?>{},
        lastSyncedAt: DateTime(2026, 4, 20, 10),
        schemaVersion: CacheService.schemaVersion,
      );

      await cacheService.saveSnapshot(snapshot);
      await cacheService.clear();

      expect(await cacheService.loadSnapshot(), isNull);
    });
  });
}
