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

        return RefreshIndicator(
          onRefresh: emailProvider.refreshLatestEmails,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            children: [
              const _Toolbar(),
              const SizedBox(height: 16),
              _SummarySection(emailProvider: emailProvider),
              const SizedBox(height: 16),
              EmailCategoryFilterBar(
                selectedFilter: emailProvider.selectedFilter,
                onFilterSelected: emailProvider.setSelectedFilter,
              ),
              const SizedBox(height: 16),
              _PreviewSection(
                authProvider: authProvider,
                emailProvider: emailProvider,
                previewEmails: previewEmails,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Toolbar extends StatelessWidget {
  const _Toolbar();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text('Organizer', style: Theme.of(context).textTheme.titleLarge),
      ],
    );
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
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 48),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (emailProvider.errorMessage != null) {
      return _MessageBlock(
        message: emailProvider.errorMessage!,
        actionLabel: 'Retry',
        onAction: emailProvider.refreshLatestEmails,
      );
    }

    if (previewEmails.isEmpty) {
      final String filterLabel = emailProvider.selectedFilter.label.toLowerCase();
      return _MessageBlock(
        message: 'No $filterLabel emails in the current sync.',
      );
    }

    return Column(
      children: [
        for (int index = 0; index < previewEmails.length; index++) ...[
          EmailListItem(
            key: ValueKey<String>('home-email-${previewEmails[index].id}'),
            email: previewEmails[index],
          ),
          if (index < previewEmails.length - 1) const SizedBox(height: 10),
        ],
      ],
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
