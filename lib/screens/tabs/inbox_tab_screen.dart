import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../models/email_model.dart';
import '../../providers/email_provider.dart';
import '../../widgets/email_category_filter_bar.dart';
import '../../widgets/email_list_item.dart';

class InboxTabScreen extends StatelessWidget {
  const InboxTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<EmailProvider>(
      builder: (context, emailProvider, _) {
        final List<EmailModel> emails = emailProvider.visibleEmails;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EmailCategoryFilterBar(
                selectedFilter: emailProvider.selectedFilter,
                onFilterSelected: emailProvider.setSelectedFilter,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _InboxBody(
                  emailProvider: emailProvider,
                  emails: emails,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InboxBody extends StatelessWidget {
  const _InboxBody({required this.emailProvider, required this.emails});

  final EmailProvider emailProvider;
  final List<EmailModel> emails;

  @override
  Widget build(BuildContext context) {
    if (emailProvider.isBootstrappingCache ||
        (emailProvider.isLoading && emailProvider.emails.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (emailProvider.errorMessage != null && emails.isEmpty) {
      return _InboxMessage(
        message: emailProvider.errorMessage!,
        actionLabel: 'Retry',
        onAction: emailProvider.refreshLatestEmails,
      );
    }

    if (emails.isEmpty) {
      return _InboxMessage(
        message:
            'No ${emailProvider.selectedFilter.label.toLowerCase()} emails in the current sync.',
      );
    }

    return Column(
      children: [
        Expanded(
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
        ),
        if (emailProvider.errorMessage != null) ...[
          const SizedBox(height: 12),
          Text(
            emailProvider.errorMessage!,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: AppColors.danger),
          ),
        ],
        if (emailProvider.hasMore) ...[
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: emailProvider.isLoadingMore
                  ? null
                  : emailProvider.loadMoreEmails,
              child: Text(
                emailProvider.isLoadingMore ? 'Loading…' : 'Load more',
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _InboxMessage extends StatelessWidget {
  const _InboxMessage({
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(message, style: Theme.of(context).textTheme.bodyMedium),
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 12),
            OutlinedButton(onPressed: onAction, child: Text(actionLabel!)),
          ],
        ],
      ),
    );
  }
}
