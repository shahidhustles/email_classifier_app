import 'email_model.dart';

class LatestEmailBatch {
  const LatestEmailBatch({
    required this.emails,
    required this.nextPageTokensByLabel,
    required this.hasMore,
  });

  final List<EmailModel> emails;
  final Map<String, String?> nextPageTokensByLabel;
  final bool hasMore;
}
