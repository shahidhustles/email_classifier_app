import 'package:flutter/foundation.dart';
import 'package:googleapis/gmail/v1.dart';

import '../models/email_model.dart';
import '../models/latest_email_batch.dart';
import 'email_classifier_service.dart';
import 'email_parser_service.dart';

class GmailService {
  GmailService({
    EmailParserService? emailParserService,
    EmailClassifierService? emailClassifierService,
  }) : _emailParserService = emailParserService ?? EmailParserService(),
       _emailClassifierService =
           emailClassifierService ?? EmailClassifierService();

  final EmailParserService _emailParserService;
  final EmailClassifierService _emailClassifierService;

  static const List<String> syncLabels = <String>[
    'INBOX',
    'CATEGORY_PROMOTIONS',
    'SPAM',
  ];

  Future<String> getMyEmailAddress(GmailApi gmailApi) async {
    final Profile profile = await gmailApi.users.getProfile('me');
    final String? emailAddress = profile.emailAddress;

    if (emailAddress == null || emailAddress.isEmpty) {
      throw StateError('Gmail profile did not include an email address.');
    }

    return emailAddress;
  }

  Future<ListMessagesResponse> listMessageIdsForLabel(
    GmailApi gmailApi, {
    required String labelId,
    int maxResults = 15,
    String? pageToken,
  }) {
    return gmailApi.users.messages.list(
      'me',
      labelIds: <String>[labelId],
      maxResults: maxResults,
      pageToken: pageToken,
    );
  }

  Future<Message> getFullMessage(GmailApi gmailApi, String messageId) {
    return gmailApi.users.messages.get('me', messageId, format: 'full');
  }

  Future<LatestEmailBatch> fetchLatestEmails(
    GmailApi gmailApi, {
    int limitPerLabel = 15,
    Map<String, String?>? pageTokensByLabel,
  }) async {
    final Map<String, String?> requestedTokens = pageTokensByLabel == null
        ? <String, String?>{}
        : Map<String, String?>.from(pageTokensByLabel);

    final List<String> labelsToFetch = requestedTokens.isEmpty
        ? syncLabels
        : syncLabels.where((String label) => requestedTokens[label] != null).toList();

    final Map<String, String?> nextPageTokensByLabel = <String, String?>{
      for (final String label in syncLabels)
        label: requestedTokens.isEmpty ? null : requestedTokens[label],
    };

    final Map<String, EmailModel> dedupedEmails = <String, EmailModel>{};

    for (final String label in labelsToFetch) {
      final ListMessagesResponse listResponse = await listMessageIdsForLabel(
        gmailApi,
        labelId: label,
        maxResults: limitPerLabel,
        pageToken: requestedTokens[label],
      );

      nextPageTokensByLabel[label] = listResponse.nextPageToken;

      final List<String> messageIds =
          (listResponse.messages ?? const <Message>[])
              .map((Message message) => message.id ?? '')
              .where((String id) => id.isNotEmpty)
              .toList(growable: false);

      final List<Future<Message>> fullMessageRequests = messageIds
          .map((String id) => getFullMessage(gmailApi, id))
          .toList(growable: false);

      final List<Message> fullMessages = await Future.wait(fullMessageRequests);

      for (final Message message in fullMessages) {
        try {
          final EmailModel parsedEmail = _emailParserService.parseMessage(message);
          final EmailCategory category = _emailClassifierService.classify(
            parsedEmail,
          );
          dedupedEmails[parsedEmail.id] = parsedEmail.copyWith(category: category);
        } catch (error) {
          debugPrint('Skipping message parse failure for ${message.id}: $error');
        }
      }
    }

    final List<EmailModel> parsedEmails = dedupedEmails.values.toList(
      growable: false,
    )..sort((EmailModel a, EmailModel b) {
        final int aMs = a.internalDate?.millisecondsSinceEpoch ?? 0;
        final int bMs = b.internalDate?.millisecondsSinceEpoch ?? 0;
        return bMs.compareTo(aMs);
      });

    final bool hasMore = nextPageTokensByLabel.values.any(
      (String? token) => token != null && token.isNotEmpty,
    );

    return LatestEmailBatch(
      emails: List<EmailModel>.unmodifiable(parsedEmails),
      nextPageTokensByLabel: Map<String, String?>.unmodifiable(
        nextPageTokensByLabel,
      ),
      hasMore: hasMore,
    );
  }
}
