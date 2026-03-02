import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/auth_user.dart';
import '../models/email_model.dart';
import '../providers/auth_provider.dart';
import '../providers/email_provider.dart';
import '../widgets/email_list_item.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, EmailProvider>(
      builder: (context, authProvider, emailProvider, _) {
        final AuthUser? user = authProvider.currentUser;
        final bool hasGmailAccess = authProvider.hasGmailAccess;

        return Scaffold(
          appBar: AppBar(
            title: const Text('The Inbox Store'),
            actions: [
              TextButton(
                onPressed: authProvider.isLoading ? null : authProvider.signOut,
                child: const Text('Sign out'),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.displayName ?? 'Google user',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 4),
                Text(user?.email ?? ''),
                const SizedBox(height: 20),
                Text('Gmail scope status: ${hasGmailAccess ? 'Granted' : 'Missing'}'),
                const SizedBox(height: 12),
                if (!hasGmailAccess)
                  ElevatedButton(
                    onPressed: authProvider.isLoading
                        ? null
                        : authProvider.authorizeScopes,
                    child: const Text('Authorize Gmail Access'),
                  ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: authProvider.isLoading
                      ? null
                      : authProvider.testGmailConnection,
                  child: const Text('Test Gmail Connection'),
                ),
                if (authProvider.gmailAddress != null) ...[
                  const SizedBox(height: 12),
                  Text('Connected Gmail: ${authProvider.gmailAddress}'),
                ],
                if (authProvider.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    authProvider.errorMessage!,
                    style: TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ],
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Latest Emails (Top 10)',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Row(
                      children: [
                        TextButton(
                          onPressed: emailProvider.isLoading
                              ? null
                              : () => emailProvider.loadLatestEmails(limit: 10),
                          child: const Text('Load'),
                        ),
                        TextButton(
                          onPressed: emailProvider.isLoading
                              ? null
                              : emailProvider.refreshLatestEmails,
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: _buildEmailSection(context, emailProvider),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmailSection(BuildContext context, EmailProvider emailProvider) {
    if (emailProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (emailProvider.errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emailProvider.errorMessage!,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: emailProvider.refreshLatestEmails,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    final List<EmailModel> emails = emailProvider.emails;
    if (emails.isEmpty) {
      return const Text('No inbox emails found. Tap Load to fetch your latest emails.');
    }

    return ListView.separated(
      itemCount: emails.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final EmailModel email = emails[index];
        return EmailListItem(
          key: ValueKey<String>('email-${email.id}'),
          email: email,
        );
      },
    );
  }
}
