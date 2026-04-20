enum EmailCategory { nonEcommerce, order, shipping, promotion, other }

extension EmailCategoryX on EmailCategory {
  String get storageValue => name;

  String get label {
    switch (this) {
      case EmailCategory.nonEcommerce:
        return 'Non-ecommerce';
      case EmailCategory.order:
        return 'Orders';
      case EmailCategory.shipping:
        return 'Shipping';
      case EmailCategory.promotion:
        return 'Promotions';
      case EmailCategory.other:
        return 'Other';
    }
  }

  bool get isEcommerce => this != EmailCategory.nonEcommerce;

  static EmailCategory fromStorageValue(String? value) {
    for (final EmailCategory category in EmailCategory.values) {
      if (category.storageValue == value) {
        return category;
      }
    }

    return EmailCategory.nonEcommerce;
  }
}

class EmailModel {
  const EmailModel({
    required this.id,
    required this.threadId,
    required this.from,
    required this.subject,
    required this.snippet,
    required this.labelIds,
    required this.category,
    this.internalDate,
    this.dateHeader,
    this.plainTextBody,
  });

  final String id;
  final String threadId;
  final DateTime? internalDate;
  final String from;
  final String subject;
  final String snippet;
  final String? dateHeader;
  final String? plainTextBody;
  final List<String> labelIds;
  final EmailCategory category;

  bool get isEcommerce => category.isEcommerce;

  EmailModel copyWith({
    String? id,
    String? threadId,
    DateTime? internalDate,
    String? from,
    String? subject,
    String? snippet,
    String? dateHeader,
    String? plainTextBody,
    List<String>? labelIds,
    EmailCategory? category,
  }) {
    return EmailModel(
      id: id ?? this.id,
      threadId: threadId ?? this.threadId,
      internalDate: internalDate ?? this.internalDate,
      from: from ?? this.from,
      subject: subject ?? this.subject,
      snippet: snippet ?? this.snippet,
      dateHeader: dateHeader ?? this.dateHeader,
      plainTextBody: plainTextBody ?? this.plainTextBody,
      labelIds: List<String>.unmodifiable(labelIds ?? this.labelIds),
      category: category ?? this.category,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'threadId': threadId,
      'internalDate': internalDate?.millisecondsSinceEpoch,
      'from': from,
      'subject': subject,
      'snippet': snippet,
      'dateHeader': dateHeader,
      'plainTextBody': plainTextBody,
      'labelIds': labelIds,
      'category': category.storageValue,
    };
  }

  factory EmailModel.fromJson(Map<String, dynamic> json) {
    final List<dynamic> labelIdsJson =
        (json['labelIds'] as List<dynamic>?) ?? const <dynamic>[];

    return EmailModel(
      id: json['id'] as String? ?? '',
      threadId: json['threadId'] as String? ?? '',
      internalDate: _dateFromJson(json['internalDate']),
      from: json['from'] as String? ?? 'Unknown sender',
      subject: json['subject'] as String? ?? '(No subject)',
      snippet: json['snippet'] as String? ?? '',
      dateHeader: json['dateHeader'] as String?,
      plainTextBody: json['plainTextBody'] as String?,
      labelIds: List<String>.unmodifiable(
        labelIdsJson.map((dynamic value) => value.toString()),
      ),
      category: EmailCategoryX.fromStorageValue(json['category'] as String?),
    );
  }

  static DateTime? _dateFromJson(dynamic rawValue) {
    if (rawValue is int) {
      return DateTime.fromMillisecondsSinceEpoch(rawValue);
    }

    if (rawValue is String) {
      final int? milliseconds = int.tryParse(rawValue);
      if (milliseconds != null) {
        return DateTime.fromMillisecondsSinceEpoch(milliseconds);
      }
    }

    return null;
  }
}
