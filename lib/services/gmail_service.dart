import 'package:flutter/foundation.dart';
import 'package:googleapis/gmail/v1.dart';

import '../models/email_model.dart';
import '../models/latest_email_batch.dart';
import 'email_parser_service.dart';

class GmailService {
  GmailService({EmailParserService? emailParserService})
    : _emailParserService = emailParserService ?? EmailParserService();

  final EmailParserService _emailParserService;

  Future<String> getMyEmailAddress(GmailApi gmailApi) async {
    final Profile profile = await gmailApi.users.getProfile('me');
    final String? emailAddress = profile.emailAddress;

    if (emailAddress == null || emailAddress.isEmpty) {
      throw StateError('Gmail profile did not include an email address.');
    }

    return emailAddress;
  }

  Future<ListMessagesResponse> listInboxMessageIds(
    GmailApi gmailApi, {
    int maxResults = 10,
    String? pageToken,
  }) {
    return gmailApi.users.messages.list(
      'me',
      labelIds: const <String>['INBOX'],
      maxResults: maxResults,
      pageToken: pageToken,
    );
  }

  Future<Message> getFullMessage(GmailApi gmailApi, String messageId) {
    return gmailApi.users.messages.get('me', messageId, format: 'full');
  }

  Future<LatestEmailBatch> fetchLatestInboxEmails(
    GmailApi gmailApi, {
    int limit = 10,
    String? pageToken,
  }) async {
    final ListMessagesResponse listResponse = await listInboxMessageIds(
      gmailApi,
      maxResults: limit,
      pageToken: pageToken,
    );

    final List<String> messageIds = (listResponse.messages ?? const <Message>[])
        .map((Message message) => message.id ?? '')
        .where((String id) => id.isNotEmpty)
        .toList(growable: false);

    final List<Future<Message>> fullMessageRequests = messageIds
        .map((String id) => getFullMessage(gmailApi, id))
        .toList(growable: false);

    final List<Message> fullMessages = await Future.wait(fullMessageRequests);

    final List<EmailModel> parsedEmails = <EmailModel>[];
    for (final Message message in fullMessages) {
      try {
        parsedEmails.add(_emailParserService.parseMessage(message));
      } catch (error) {
        debugPrint('Skipping message parse failure for ${message.id}: $error');
      }
    }

    parsedEmails.sort((EmailModel a, EmailModel b) {
      final int aMs = a.internalDate?.millisecondsSinceEpoch ?? 0;
      final int bMs = b.internalDate?.millisecondsSinceEpoch ?? 0;
      return bMs.compareTo(aMs);
    });

    final List<EmailModel> topEmails = parsedEmails.length > limit
        ? parsedEmails.take(limit).toList(growable: false)
        : List<EmailModel>.unmodifiable(parsedEmails);

    return LatestEmailBatch(
      emails: topEmails,
      nextPageToken: listResponse.nextPageToken,
    );
  }
}
