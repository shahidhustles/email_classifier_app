import '../models/email_model.dart';

class EmailClassifierService {
  EmailCategory classify(EmailModel email) {
    final String from = email.from.toLowerCase();
    final String searchableText = _normalize(
      <String>[
        email.from,
        email.subject,
        email.snippet,
        email.plainTextBody ?? '',
      ].join(' '),
    );

    final bool retailerMatch =
        _matchesAny(from, _retailerSignals) ||
        _matchesAny(searchableText, _retailerSignals);

    if (_matchesAny(searchableText, _shippingKeywords)) {
      return EmailCategory.shipping;
    }

    if (_matchesAny(searchableText, _orderKeywords)) {
      return EmailCategory.order;
    }

    if (_matchesAny(searchableText, _promotionKeywords)) {
      return EmailCategory.promotion;
    }

    if (retailerMatch) {
      return EmailCategory.other;
    }

    return EmailCategory.nonEcommerce;
  }

  String _normalize(String rawValue) {
    return rawValue.toLowerCase().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  bool _matchesAny(String source, List<String> patterns) {
    for (final String pattern in patterns) {
      if (source.contains(pattern)) {
        return true;
      }
    }

    return false;
  }

  static const List<String> _retailerSignals = <String>[
    'amazon',
    'flipkart',
    'myntra',
    'meesho',
    'ajio',
    'nykaa',
    'swiggy instamart',
    'blinkit',
    'bigbasket',
    'jiomart',
    'shopify',
    'etsy',
    'ebay',
    'walmart',
    'target',
    'best buy',
    'ikea',
    'zara',
    'hm.com',
    'h&m',
    'nike',
    'adidas',
    'sephora',
    'ulta',
    'delivery update',
    'order update',
    'no-reply@amazon',
    'noreply@',
  ];

  static const List<String> _shippingKeywords = <String>[
    'has shipped',
    'order shipped',
    'shipment',
    'tracking number',
    'track your package',
    'track package',
    'out for delivery',
    'arriving today',
    'arriving tomorrow',
    'delivery update',
    'delivered',
    'carrier',
    'courier',
    'package is on the way',
    'package on the way',
  ];

  static const List<String> _orderKeywords = <String>[
    'order confirmed',
    'order confirmation',
    'thanks for your order',
    'thank you for your order',
    'purchase confirmation',
    'receipt for your order',
    'invoice',
    'payment received',
    'your order',
    'buy again',
    'return request',
    'refund initiated',
    'refund processed',
  ];

  static const List<String> _promotionKeywords = <String>[
    'sale',
    'flash sale',
    'discount',
    'limited time offer',
    'offer ends',
    'coupon',
    'promo code',
    'deal',
    'shop now',
    'new arrivals',
    'free shipping',
    'off today',
    '% off',
    'save big',
    'exclusive offer',
  ];
}
