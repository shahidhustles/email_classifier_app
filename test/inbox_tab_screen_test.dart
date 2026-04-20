import 'package:email_classifier_app/config/app_theme.dart';
import 'package:email_classifier_app/models/auth_user.dart';
import 'package:email_classifier_app/models/email_model.dart';
import 'package:email_classifier_app/models/latest_email_batch.dart';
import 'package:email_classifier_app/providers/auth_provider.dart';
import 'package:email_classifier_app/providers/email_provider.dart';
import 'package:email_classifier_app/screens/tabs/inbox_tab_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'test_helpers.dart';

void main() {
  testWidgets('shows filtered list and loads more emails', (
    WidgetTester tester,
  ) async {
    final FakeGmailService gmailService = FakeGmailService(
      responses: <LatestEmailBatch>[
        LatestEmailBatch(
          emails: [
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
          hasMore: true,
        ),
        LatestEmailBatch(
          emails: [
            buildEmail(
              id: '2',
              subject: 'Package is on the way',
              category: EmailCategory.shipping,
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
    final EmailProvider emailProvider = EmailProvider(
      gmailService: gmailService,
      cacheService: FakeCacheService(),
    );
    await emailProvider.bootstrap();
    final AuthProvider authProvider = FakeAuthProvider(
      fakeCurrentUser: const AuthUser(
        id: 'user-1',
        email: 'user@example.com',
        displayName: 'User',
      ),
    );
    emailProvider.bindAuthProvider(authProvider);
    await emailProvider.loadLatestEmails();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
          ChangeNotifierProvider<EmailProvider>.value(value: emailProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.darkTheme,
          home: const Scaffold(body: InboxTabScreen()),
        ),
      ),
    );

    expect(find.text('Order confirmed'), findsOneWidget);
    expect(find.text('Load more'), findsOneWidget);

    await tester.tap(find.text('Load more'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Package is on the way'), findsOneWidget);
  });
}
