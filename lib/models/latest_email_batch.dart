import 'email_model.dart';

class LatestEmailBatch {
  const LatestEmailBatch({required this.emails, this.nextPageToken});

  final List<EmailModel> emails;
  final String? nextPageToken;
}
