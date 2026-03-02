class EmailModel {
  const EmailModel({
    required this.id,
    required this.threadId,
    required this.from,
    required this.subject,
    required this.snippet,
    required this.labelIds,
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
}
