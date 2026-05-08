import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/app_theme_extension.dart';
import 'package:usta_book/core/ui_kit/components/button.dart';
import 'package:usta_book/core/ui_kit/typography.dart';

class PaywallPage extends StatefulWidget {
  const PaywallPage({super.key});

  static const String tag = '/paywall';

  @override
  State<PaywallPage> createState() => _PaywallPageState();
}

enum _Plan { monthly, yearly }

class _PaywallPageState extends State<PaywallPage> {
  _Plan _selected = _Plan.yearly;

  static const monthlyPrice = 49000;
  static const yearlyPrice = 490000;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    final canPop = Navigator.of(context).canPop();
    return Scaffold(
      backgroundColor: custom.body,
      appBar: canPop
          ? AppBar(backgroundColor: custom.body, elevation: 0)
          : null,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Image.asset(
                  'assets/branding/logo.png',
                  width: 88,
                  height: 88,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                tr.subscription.title,
                style: Typographies.boldH1,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                tr.subscription.subtitle_expired,
                style: Typographies.regularBody2,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _BenefitsList(custom: custom, tr: tr),
              const SizedBox(height: 24),
              _TariffCard(
                plan: _Plan.yearly,
                selected: _selected == _Plan.yearly,
                title: tr.subscription.tariff_yearly_label,
                price: yearlyPrice,
                priceSuffix: tr.subscription.tariff_per_year,
                badge: tr.subscription.save_badge,
                custom: custom,
                onTap: () => setState(() => _selected = _Plan.yearly),
              ),
              const SizedBox(height: 12),
              _TariffCard(
                plan: _Plan.monthly,
                selected: _selected == _Plan.monthly,
                title: tr.subscription.tariff_monthly_label,
                price: monthlyPrice,
                priceSuffix: tr.subscription.tariff_per_month,
                custom: custom,
                onTap: () => setState(() => _selected = _Plan.monthly),
              ),
              const SizedBox(height: 24),
              Text(
                tr.subscription.select_payment_method,
                style: Typographies.regularH3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _PaymentMethodButton(
                      label: 'Click',
                      icon: Icons.flash_on,
                      onTap: () => _showSoon(context, tr),
                      custom: custom,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PaymentMethodButton(
                      label: 'Payme',
                      icon: Icons.qr_code_2,
                      onTap: () => _showSoon(context, tr),
                      custom: custom,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _PaymentMethodButton(
                      label: 'Uzum',
                      icon: Icons.shopping_bag_outlined,
                      onTap: () => _showSoon(context, tr),
                      custom: custom,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              MainButton.primary(
                title: tr.subscription.upgrade_button,
                onTap: () => _showSoon(context, tr),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showSoon(BuildContext context, Translations tr) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(tr.subscription.soon)),
    );
  }
}

class _BenefitsList extends StatelessWidget {
  const _BenefitsList({required this.custom, required this.tr});

  final AppThemeExtension custom;
  final Translations tr;

  @override
  Widget build(BuildContext context) {
    final items = [
      tr.subscription.feature_unlimited_records,
      tr.subscription.feature_stats,
      tr.subscription.feature_reminders,
      tr.subscription.feature_support,
    ];
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: custom.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: items
            .map(
              (text) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: custom.primary, size: 20),
                    const SizedBox(width: 12),
                    Expanded(child: Text(text, style: Typographies.regularBody2)),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }
}

class _TariffCard extends StatelessWidget {
  const _TariffCard({
    required this.plan,
    required this.selected,
    required this.title,
    required this.price,
    required this.priceSuffix,
    this.badge,
    required this.custom,
    required this.onTap,
  });

  final _Plan plan;
  final bool selected;
  final String title;
  final int price;
  final String priceSuffix;
  final String? badge;
  final AppThemeExtension custom;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final f = NumberFormat('#,##0');
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: custom.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? custom.primary : custom.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? custom.primary : custom.border,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(title, style: Typographies.regularBody),
                      if (badge != null) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: custom.primary.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            badge!,
                            style: Typographies.regularOverlineLower.copyWith(
                              color: custom.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${f.format(price)} $priceSuffix',
                    style: Typographies.regularOverlineLower,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodButton extends StatelessWidget {
  const _PaymentMethodButton({
    required this.label,
    required this.icon,
    required this.onTap,
    required this.custom,
  });

  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final AppThemeExtension custom;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: custom.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: custom.border),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: custom.primary),
            const SizedBox(height: 6),
            Text(label, style: Typographies.regularBody2),
          ],
        ),
      ),
    );
  }
}
