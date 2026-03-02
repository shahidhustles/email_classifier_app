import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../config/app_theme.dart';
import '../../models/auth_user.dart';
import '../../models/email_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/email_provider.dart';
import '../../widgets/email_list_item.dart';

class HomeTabScreen extends StatefulWidget {
  const HomeTabScreen({super.key});

  @override
  State<HomeTabScreen> createState() => _HomeTabScreenState();
}

class _HomeTabScreenState extends State<HomeTabScreen> {
  bool _autoLoadTriggered = false;

  void _maybeAutoLoad(AuthProvider authProvider, EmailProvider emailProvider) {
    if (_autoLoadTriggered) {
      return;
    }

    if (!authProvider.hasGmailAccess || emailProvider.isLoading) {
      return;
    }

    if (emailProvider.emails.isNotEmpty) {
      _autoLoadTriggered = true;
      return;
    }

    _autoLoadTriggered = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      emailProvider.loadLatestEmails(limit: 10);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<AuthProvider, EmailProvider>(
      builder: (context, authProvider, emailProvider, _) {
        _maybeAutoLoad(authProvider, emailProvider);

        final AuthUser? user = authProvider.currentUser;
        final List<EmailModel> topEmails = emailProvider.emails.length > 10
            ? emailProvider.emails.take(10).toList(growable: false)
            : emailProvider.emails;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back',
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      user?.displayName ?? user?.email ?? 'Inbox user',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _StatusPill(
                          label: authProvider.hasGmailAccess
                              ? 'Gmail Access Granted'
                              : 'Gmail Access Missing',
                          color: authProvider.hasGmailAccess
                              ? AppColors.success
                              : AppColors.warning,
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: emailProvider.isLoading
                              ? null
                              : emailProvider.refreshLatestEmails,
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                    if (!authProvider.hasGmailAccess)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: FilledButton(
                          onPressed: authProvider.authorizeScopes,
                          child: const Text('Authorize Gmail Access'),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Recent 10 emails',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 10),
              Expanded(
                child: _buildEmailSection(context, emailProvider, topEmails),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmailSection(
    BuildContext context,
    EmailProvider emailProvider,
    List<EmailModel> topEmails,
  ) {
    if (emailProvider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (emailProvider.errorMessage != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            emailProvider.errorMessage!,
            style: const TextStyle(color: AppColors.danger),
          ),
          const SizedBox(height: 10),
          FilledButton(
            onPressed: emailProvider.refreshLatestEmails,
            child: const Text('Retry'),
          ),
        ],
      );
    }

    if (topEmails.isEmpty) {
      return const _EmptyState(
        title: 'No recent emails yet',
        subtitle: 'Use refresh to fetch your latest inbox activity.',
      );
    }

    return ListView.separated(
      itemCount: topEmails.length,
      separatorBuilder: (_, __) => const SizedBox(height: 10),
      itemBuilder: (context, index) {
        final EmailModel email = topEmails[index];
        return EmailListItem(
          key: ValueKey<String>('home-email-${email.id}'),
          email: email,
        );
      },
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.45)),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(color: color),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
