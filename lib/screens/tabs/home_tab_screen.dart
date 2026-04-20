import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../models/email_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/email_provider.dart';
import '../../widgets/email_category_filter_bar.dart';
import '../../widgets/email_list_item.dart';

class HomeTabScreen extends StatelessWidget {
  const HomeTabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, EmailProvider>(
      builder: (context, authProvider, emailProvider, _) {
        final List<EmailModel> previewEmails = emailProvider.visibleEmails
            .take(6)
            .toList(growable: false);

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Toolbar(
                canRefresh: authProvider.hasGmailAccess && !emailProvider.isLoading,
                onRefresh: emailProvider.refreshLatestEmails,
              ),
              const SizedBox(height: 16),
              _AccessSection(
                hasGmailAccess: authProvider.hasGmailAccess,
                isBusy: authProvider.isLoading,
                onAuthorize: authProvider.authorizeScopes,
                lastSyncedAt: emailProvider.lastRefreshedAt,
              ),
              const SizedBox(height: 16),
              _SummarySection(emailProvider: emailProvider),
              const SizedBox(height: 16),
              EmailCategoryFilterBar(
                selectedFilter: emailProvider.selectedFilter,
                onFilterSelected: emailProvider.setSelectedFilter,
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _PreviewSection(
                  authProvider: authProvider,
                  emailProvider: emailProvider,
                  previewEmails: previewEmails,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar({required this.canRefresh, required this.onRefresh});

  final bool canRefresh;
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Organizer', style: Theme.of(context).textTheme.titleLarge),
        const Spacer(),
        FilledButton(
          onPressed: canRefresh ? onRefresh : null,
          child: const Text('Refresh'),
        ),
      ],
    );
  }
}

class _AccessSection extends StatelessWidget {
  const _AccessSection({
    required this.hasGmailAccess,
    required this.isBusy,
    required this.onAuthorize,
    required this.lastSyncedAt,
  });

  final bool hasGmailAccess;
  final bool isBusy;
  final VoidCallback onAuthorize;
  final DateTime? lastSyncedAt;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hasGmailAccess ? 'Gmail access granted' : 'Gmail access required',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 6),
          Text(
            lastSyncedAt == null
                ? 'No synced data yet.'
                : 'Last synced ${_formatDate(lastSyncedAt!)}',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (!hasGmailAccess) ...[
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: isBusy ? null : onAuthorize,
              child: const Text('Authorize Gmail access'),
            ),
          ],
        ],
      ),
    );
  }

  String _formatDate(DateTime value) {
    final DateTime local = value.toLocal();
    final String month = local.month.toString().padLeft(2, '0');
    final String day = local.day.toString().padLeft(2, '0');
    final String hour = local.hour.toString().padLeft(2, '0');
    final String minute = local.minute.toString().padLeft(2, '0');
    return '${local.year}-$month-$day $hour:$minute';
  }
}

class _SummarySection extends StatelessWidget {
  const _SummarySection({required this.emailProvider});

  final EmailProvider emailProvider;

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
        children: [
          _CountRow(label: 'All', count: emailProvider.allCount),
          const Divider(height: 20, color: AppColors.border),
          _CountRow(label: 'Orders', count: emailProvider.orderCount),
          const Divider(height: 20, color: AppColors.border),
          _CountRow(label: 'Shipping', count: emailProvider.shippingCount),
          const Divider(height: 20, color: AppColors.border),
          _CountRow(label: 'Promotions', count: emailProvider.promotionCount),
          const Divider(height: 20, color: AppColors.border),
          _CountRow(label: 'Other', count: emailProvider.otherCount),
        ],
      ),
    );
  }
}

class _CountRow extends StatelessWidget {
  const _CountRow({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        const Spacer(),
        Text(
          '$count',
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _PreviewSection extends StatelessWidget {
  const _PreviewSection({
    required this.authProvider,
    required this.emailProvider,
    required this.previewEmails,
  });

  final AuthProvider authProvider;
  final EmailProvider emailProvider;
  final List<EmailModel> previewEmails;

  @override
  Widget build(BuildContext context) {
    if (emailProvider.isBootstrappingCache ||
        (emailProvider.isLoading && emailProvider.emails.isEmpty)) {
      return const Center(child: CircularProgressIndicator());
    }

    if (emailProvider.errorMessage != null) {
      return _MessageBlock(
        message: emailProvider.errorMessage!,
        actionLabel: 'Retry',
        onAction: authProvider.hasGmailAccess
            ? emailProvider.refreshLatestEmails
            : authProvider.authorizeScopes,
      );
    }

    if (!authProvider.hasGmailAccess && previewEmails.isEmpty) {
      return const _MessageBlock(message: 'Authorize Gmail access to start syncing.');
    }

    if (previewEmails.isEmpty) {
      final String filterLabel = emailProvider.selectedFilter.label.toLowerCase();
      return _MessageBlock(
        message: 'No $filterLabel emails in the current sync.',
      );
    }

    return ListView.separated(
      itemCount: previewEmails.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final EmailModel email = previewEmails[index];
        return EmailListItem(
          key: ValueKey<String>('home-email-${email.id}'),
          email: email,
        );
      },
    );
  }
}

class _MessageBlock extends StatelessWidget {
  const _MessageBlock({
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
