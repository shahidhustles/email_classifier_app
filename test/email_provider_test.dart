import 'package:email_classifier_app/models/auth_user.dart';
import 'package:email_classifier_app/models/email_cache_snapshot.dart';
import 'package:email_classifier_app/models/email_model.dart';
import 'package:email_classifier_app/models/latest_email_batch.dart';
import 'package:email_classifier_app/providers/email_provider.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  group('EmailProvider', () {
    test('boots from cache without syncing', () async {
      final FakeCacheService cacheService = FakeCacheService()
        ..storedSnapshot = EmailCacheSnapshot(
          emails: <EmailModel>[
            buildEmail(
              id: 'cached-1',
              subject: 'Cached order',
              category: EmailCategory.order,
            ),
          ],
          nextPageTokensByLabel: const <String, String?>{'INBOX': 'page-2'},
          lastSyncedAt: DateTime(2026, 4, 20, 9),
          schemaVersion: 1,
        );
      final FakeGmailService gmailService = FakeGmailService(
        responses: const <LatestEmailBatch>[],
      );
      final EmailProvider provider = EmailProvider(
        gmailService: gmailService,
        cacheService: cacheService,
      );

      await provider.bootstrap();

      expect(provider.emails.single.subject, 'Cached order');
      expect(gmailService.callCount, 0);
    });

    test('auto-syncs when cache is absent and auth is ready', () async {
      final FakeCacheService cacheService = FakeCacheService();
      final FakeGmailService gmailService = FakeGmailService(
        responses: <LatestEmailBatch>[
          LatestEmailBatch(
            emails: <EmailModel>[
              buildEmail(
                id: 'sync-1',
                subject: 'Order confirmed',
                category: EmailCategory.order,
              ),
            ],
            nextPageTokensByLabel: const <String, String?>{
              'INBOX': 'page-2',
              'CATEGORY_PROMOTIONS': null,
              'SPAM': null,
            },
            hasMore: true,
          ),
        ],
      );
      final EmailProvider provider = EmailProvider(
        gmailService: gmailService,
        cacheService: cacheService,
      );

      await provider.bootstrap();
      provider.bindAuthProvider(
        FakeAuthProvider(
          fakeCurrentUser: const AuthUser(
            id: 'user-1',
            email: 'user@example.com',
            displayName: 'User',
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);

      expect(gmailService.callCount, 1);
      expect(provider.allCount, 1);
      expect(cacheService.storedSnapshot, isNotNull);
    });

    test('manual refresh replaces cached content', () async {
      final FakeCacheService cacheService = FakeCacheService()
        ..storedSnapshot = EmailCacheSnapshot(
          emails: <EmailModel>[
            buildEmail(
              id: 'cached-1',
              subject: 'Cached order',
              category: EmailCategory.order,
            ),
          ],
          nextPageTokensByLabel: const <String, String?>{},
          lastSyncedAt: DateTime(2026, 4, 20, 9),
          schemaVersion: 1,
        );
      final FakeGmailService gmailService = FakeGmailService(
        responses: <LatestEmailBatch>[
          LatestEmailBatch(
            emails: <EmailModel>[
              buildEmail(
                id: 'fresh-1',
                subject: 'Fresh shipment',
                category: EmailCategory.shipping,
              ),
            ],
            nextPageTokensByLabel: const <String, String?>{},
            hasMore: false,
          ),
        ],
      );
      final EmailProvider provider = EmailProvider(
        gmailService: gmailService,
        cacheService: cacheService,
      );

      await provider.bootstrap();
      provider.bindAuthProvider(
        FakeAuthProvider(
          fakeCurrentUser: const AuthUser(
            id: 'user-1',
            email: 'user@example.com',
            displayName: 'User',
          ),
        ),
      );

      await provider.refreshLatestEmails();

      expect(provider.emails.single.subject, 'Fresh shipment');
      expect(cacheService.storedSnapshot!.emails.single.subject, 'Fresh shipment');
    });

    test('changes visible emails when selected filter changes', () async {
      final FakeCacheService cacheService = FakeCacheService()
        ..storedSnapshot = EmailCacheSnapshot(
          emails: <EmailModel>[
            buildEmail(
              id: '1',
              subject: 'Order confirmed',
              category: EmailCategory.order,
            ),
            buildEmail(
              id: '2',
              subject: 'Package is on the way',
              category: EmailCategory.shipping,
            ),
            buildEmail(
              id: '3',
              subject: 'Team meeting',
              category: EmailCategory.nonEcommerce,
              from: 'Alex <alex@example.com>',
            ),
          ],
          nextPageTokensByLabel: const <String, String?>{},
          lastSyncedAt: DateTime(2026, 4, 20, 9),
          schemaVersion: 1,
        );
      final EmailProvider provider = EmailProvider(
        gmailService: FakeGmailService(responses: const <LatestEmailBatch>[]),
        cacheService: cacheService,
      );

      await provider.bootstrap();

      expect(provider.visibleEmails.length, 2);
      provider.setSelectedFilter(EmailFilter.shipping);
      expect(provider.visibleEmails.single.subject, 'Package is on the way');
    });

    test('load more appends deduped sorted emails and hides non-ecommerce', () async {
      final FakeCacheService cacheService = FakeCacheService();
      final FakeGmailService gmailService = FakeGmailService(
        responses: <LatestEmailBatch>[
          LatestEmailBatch(
            emails: <EmailModel>[
              buildEmail(
                id: '1',
                subject: 'Order confirmed',
                category: EmailCategory.order,
                internalDate: DateTime(2026, 4, 20, 8),
              ),
              buildEmail(
                id: '2',
                subject: 'Team meeting',
                category: EmailCategory.nonEcommerce,
                from: 'Alex <alex@example.com>',
                internalDate: DateTime(2026, 4, 20, 7),
              ),
            ],
            nextPageTokensByLabel: const <String, String?>{
              'INBOX': 'page-2',
              'CATEGORY_PROMOTIONS': null,
              'SPAM': null,
            },
            hasMore: true,
          ),
          LatestEmailBatch(
            emails: <EmailModel>[
              buildEmail(
                id: '1',
                subject: 'Order confirmed',
                category: EmailCategory.order,
                internalDate: DateTime(2026, 4, 20, 8),
              ),
              buildEmail(
                id: '3',
                subject: 'Package is on the way',
                category: EmailCategory.shipping,
                internalDate: DateTime(2026, 4, 20, 9),
              ),
            ],
            nextPageTokensByLabel: const <String, String?>{
              'INBOX': null,
              'CATEGORY_PROMOTIONS': null,
              'SPAM': null,
            },
            hasMore: false,
          ),
        ],
      );
      final EmailProvider provider = EmailProvider(
        gmailService: gmailService,
        cacheService: cacheService,
      );

      await provider.bootstrap();
      provider.bindAuthProvider(
        FakeAuthProvider(
          fakeCurrentUser: const AuthUser(
            id: 'user-1',
            email: 'user@example.com',
            displayName: 'User',
          ),
        ),
      );
      await Future<void>.delayed(Duration.zero);
      await Future<void>.delayed(Duration.zero);
      await provider.loadMoreEmails();

      expect(provider.emails.map((EmailModel email) => email.id), <String>[
        '3',
        '1',
        '2',
      ]);
      expect(provider.visibleEmails.map((EmailModel email) => email.id), <String>[
        '3',
        '1',
      ]);
      expect(gmailService.lastPageTokens!['INBOX'], 'page-2');
    });
  });
}
