import 'package:email_classifier_app/config/app_theme.dart';
import 'package:email_classifier_app/models/auth_user.dart';
import 'package:email_classifier_app/models/email_cache_snapshot.dart';
import 'package:email_classifier_app/models/email_model.dart';
import 'package:email_classifier_app/providers/auth_provider.dart';
import 'package:email_classifier_app/providers/email_provider.dart';
import 'package:email_classifier_app/screens/tabs/home_tab_screen.dart';
import 'package:email_classifier_app/widgets/email_category_filter_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('shows summary counts and updates preview when filter changes', (
    WidgetTester tester,
  ) async {
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
            subject: '50% off today only',
            category: EmailCategory.promotion,
          ),
        ],
        nextPageTokensByLabel: const <String, String?>{},
        lastSyncedAt: DateTime(2026, 4, 20, 9),
        schemaVersion: 1,
      );
    final EmailProvider emailProvider = EmailProvider(
      gmailService: FakeGmailService(responses: const []),
      cacheService: cacheService,
    );
    await emailProvider.bootstrap();
    final AuthProvider authProvider = FakeAuthProvider(
      fakeCurrentUser: const AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        displayName: 'User',
      ),
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<EmailProvider>.value(value: emailProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: HomeTabScreen()),
        ),
      ),
    );

    expect(find.text('Organizer'), findsOneWidget);
    expect(find.text('Order confirmed'), findsOneWidget);
    expect(find.text('Package is on the way'), findsOneWidget);

    final Finder shippingFilter = find.descendant(
      of: find.byType(EmailCategoryFilterBar),
      matching: find.text('Shipping'),
    );
    final Finder otherFilter = find.descendant(
      of: find.byType(EmailCategoryFilterBar),
      matching: find.text('Other'),
    );

    await tester.ensureVisible(shippingFilter);
    await tester.tap(shippingFilter, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('Package is on the way'), findsOneWidget);
    expect(find.text('Order confirmed'), findsNothing);

    await tester.ensureVisible(otherFilter);
    await tester.tap(otherFilter, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.text('No other emails in the current sync.'), findsOneWidget);
  });
}
