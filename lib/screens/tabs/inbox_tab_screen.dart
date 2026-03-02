import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/email_model.dart';
import '../../providers/email_provider.dart';
import '../../widgets/email_list_item.dart';

class InboxTabScreen extends StatelessWidget {
  const InboxTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmailProvider>(
      builder: (context, emailProvider, _) {
        if (emailProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (emailProvider.errorMessage != null) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  emailProvider.errorMessage!,
                  style: const TextStyle(color: Color(0xFFEF4444)),
                ),
                const SizedBox(height: 10),
                FilledButton(
                  onPressed: emailProvider.refreshLatestEmails,
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        final List<EmailModel> emails = emailProvider.emails;
        if (emails.isEmpty) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Inbox is empty for now. Visit Home to trigger sync.'),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(16),
          child: ListView.separated(
            itemCount: emails.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final EmailModel email = emails[index];
              return EmailListItem(
                key: ValueKey<String>('inbox-email-${email.id}'),
                email: email,
                compact: true,
              );
            },
          ),
        );
      },
    );
  }
}
