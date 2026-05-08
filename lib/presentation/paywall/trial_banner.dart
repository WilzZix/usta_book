import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:usta_book/bloc/master/master_bloc.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/app_theme_extension.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/data/models/master_profile.dart';
import 'package:usta_book/presentation/paywall/paywall_page.dart';

class TrialBanner extends StatelessWidget {
  const TrialBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MasterBloc, MasterState>(
      builder: (context, state) {
        if (state is! MasterProfileLoaded || state.profile == null) {
          return const SizedBox.shrink();
        }
        final profile = state.profile!;
        final status = profile.subscriptionStatus;
        if (status == SubscriptionStatus.paid ||
            status == SubscriptionStatus.notStarted) {
          return const SizedBox.shrink();
        }
        if (status == SubscriptionStatus.trial &&
            profile.trialDaysRemaining > 3) {
          return const SizedBox.shrink();
        }
        return _Banner(profile: profile);
      },
    );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({required this.profile});

  final MasterProfile profile;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    final isExpired = profile.subscriptionStatus == SubscriptionStatus.expired;
    final bg = isExpired ? StateColor.error.withValues(alpha: 0.12) : custom.primary.withValues(alpha: 0.12);
    final fg = isExpired ? StateColor.error : custom.primary;
    final text = isExpired
        ? tr.subscription.trial_expired_short
        : tr.subscription.trial_remaining
            .replaceAll('{days}', '${profile.trialDaysRemaining}');
    return Material(
      color: bg,
      child: InkWell(
        onTap: () => context.pushNamed(PaywallPage.tag),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Row(
            children: [
              Icon(
                isExpired ? Icons.lock_outline : Icons.access_time,
                size: 18,
                color: fg,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  text,
                  style: Typographies.regularBody2.copyWith(color: fg),
                ),
              ),
              Text(
                tr.subscription.upgrade_short,
                style: Typographies.regularBody2.copyWith(
                  color: fg,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.chevron_right, color: fg, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}
