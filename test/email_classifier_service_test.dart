import 'package:email_classifier_app/models/email_model.dart';
import 'package:email_classifier_app/services/email_classifier_service.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_helpers.dart';

void main() {
  group('EmailClassifierService', () {
    final EmailClassifierService service = EmailClassifierService();

    test('classifies shipping phrases as shipping', () {
      final EmailCategory category = service.classify(
        buildEmail(
          id: '1',
          subject: 'Your order has shipped',
          category: EmailCategory.nonEcommerce,
          snippet: 'Track your package with this tracking number.',
        ),
      );

      expect(category, EmailCategory.shipping);
    });

    test('classifies order confirmation phrases as order', () {
      final EmailCategory category = service.classify(
        buildEmail(
          id: '2',
          subject: 'Order confirmed',
          category: EmailCategory.nonEcommerce,
          snippet: 'Thank you for your order.',
        ),
      );

      expect(category, EmailCategory.order);
    });

    test('classifies promotion phrases as promotion', () {
      final EmailCategory category = service.classify(
        buildEmail(
          id: '3',
          subject: '50% off today only',
          category: EmailCategory.nonEcommerce,
          snippet: 'Use this promo code before the offer ends.',
        ),
      );

      expect(category, EmailCategory.promotion);
    });

    test('falls back to other for retailer senders with weak content', () {
      final EmailCategory category = service.classify(
        buildEmail(
          id: '4',
          subject: 'Account update',
          category: EmailCategory.nonEcommerce,
          from: 'Myntra <support@myntra.com>',
          snippet: 'We updated your account settings.',
        ),
      );

      expect(category, EmailCategory.other);
    });

    test('keeps normal non-shopping mail as nonEcommerce', () {
      final EmailCategory category = service.classify(
        buildEmail(
          id: '5',
          subject: 'Team meeting at 4pm',
          category: EmailCategory.nonEcommerce,
          from: 'Alex <alex@example.com>',
          snippet: 'Please review the notes before the call.',
        ),
      );

      expect(category, EmailCategory.nonEcommerce);
    });

    test('applies precedence with shipping above order and promotion', () {
      final EmailCategory category = service.classify(
        buildEmail(
          id: '6',
          subject: 'Order confirmed and shipped',
          category: EmailCategory.nonEcommerce,
          snippet: 'Your order has shipped. Track your package.',
        ),
      );

      expect(category, EmailCategory.shipping);
    });
  });
}
