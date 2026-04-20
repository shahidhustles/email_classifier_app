import 'dart:convert';

import 'package:googleapis/gmail/v1.dart';

import '../models/email_model.dart';

class EmailParserService {
  EmailModel parseMessage(Message message) {
    final MessagePart? payload = message.payload;
    final String from = _headerValue(payload, 'From') ?? 'Unknown sender';
    final String subject = _headerValue(payload, 'Subject') ?? '(No subject)';
    final String? dateHeader = _headerValue(payload, 'Date');

    return EmailModel(
      id: message.id ?? '',
      threadId: message.threadId ?? '',
      internalDate: _parseInternalDate(message.internalDate),
      from: from,
      subject: subject,
      snippet: (message.snippet ?? '').trim(),
      dateHeader: dateHeader,
      plainTextBody: _extractPlainTextBody(payload),
      labelIds: List<String>.unmodifiable(message.labelIds ?? const <String>[]),
      category: EmailCategory.nonEcommerce,
    );
  }

  String? _headerValue(MessagePart? payload, String headerName) {
    final List<MessagePartHeader>? headers = payload?.headers;
    if (headers == null || headers.isEmpty) {
      return null;
    }

    for (final MessagePartHeader header in headers) {
      final String? name = header.name;
      if (name != null && name.toLowerCase() == headerName.toLowerCase()) {
        final String? value = header.value?.trim();
        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    }

    return null;
  }

  DateTime? _parseInternalDate(String? epochMs) {
    if (epochMs == null || epochMs.isEmpty) {
      return null;
    }

    final int? timestamp = int.tryParse(epochMs);
    if (timestamp == null) {
      return null;
    }

    return DateTime.fromMillisecondsSinceEpoch(timestamp);
  }

  String? _extractPlainTextBody(MessagePart? payload) {
    if (payload == null) {
      return null;
    }

    final MessagePart? plainTextPart = _findPartByMimeType(
      payload,
      mimeTypePrefix: 'text/plain',
    );

    final String? plainText = _decodeBodyData(plainTextPart?.body?.data);
    if (plainText != null && plainText.trim().isNotEmpty) {
      return plainText.trim();
    }

    final String? fallback = _decodeBodyData(payload.body?.data);
    if (fallback != null && fallback.trim().isNotEmpty) {
      return fallback.trim();
    }

    return null;
  }

  MessagePart? _findPartByMimeType(
    MessagePart part, {
    required String mimeTypePrefix,
  }) {
    final String? mimeType = part.mimeType?.toLowerCase();
    if (mimeType != null &&
        mimeType.startsWith(mimeTypePrefix) &&
        part.body?.data != null) {
      return part;
    }

    final List<MessagePart>? childParts = part.parts;
    if (childParts == null || childParts.isEmpty) {
      return null;
    }

    for (final MessagePart child in childParts) {
      final MessagePart? result = _findPartByMimeType(
        child,
        mimeTypePrefix: mimeTypePrefix,
      );
      if (result != null) {
        return result;
      }
    }

    return null;
  }

  String? _decodeBodyData(String? encoded) {
    if (encoded == null || encoded.isEmpty) {
      return null;
    }

    try {
      final String normalized = base64Url.normalize(encoded);
      final List<int> bytes = base64Url.decode(normalized);
      return utf8.decode(bytes, allowMalformed: true);
    } catch (_) {
      return null;
    }
  }
}
