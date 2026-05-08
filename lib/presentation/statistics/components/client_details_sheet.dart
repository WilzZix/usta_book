import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:usta_book/core/localization/i18n/strings.g.dart';
import 'package:usta_book/core/ui_kit/app_theme_extension.dart';
import 'package:usta_book/core/ui_kit/colors.dart';
import 'package:usta_book/core/ui_kit/components/app_icons.dart';
import 'package:usta_book/core/ui_kit/typography.dart';
import 'package:usta_book/data/models/stats_summary.dart';
import 'package:usta_book/presentation/add_new_record/add_new_record_page.dart';

class ClientDetailsSheet {
  static Future<void> show(BuildContext context, TopClient client) {
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    return showModalBottomSheet(
      context: context,
      backgroundColor: custom.body,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetCtx) => _ClientDetailsBody(client: client),
    );
  }
}

class _ClientDetailsBody extends StatelessWidget {
  const _ClientDetailsBody({required this.client});

  final TopClient client;

  @override
  Widget build(BuildContext context) {
    final tr = Translations.of(context);
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    final dateFmt = DateFormat('dd.MM.yyyy');
    final moneyFmt = NumberFormat('#,##0');

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    tr.statistics.client_details,
                    style: Typographies.regularH3,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: AppIcons.icClose,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: custom.secondary,
                  ),
                  child: AppIcons.icPerson,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        client.name.isEmpty ? '—' : client.name,
                        style: Typographies.regularBody,
                      ),
                      const SizedBox(height: 2),
                      if (client.phone.isNotEmpty)
                        Text(
                          client.phone,
                          style: Typographies.regularOverlineLower,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _DetailRow(
              label: tr.statistics.visits_count,
              value: '${client.visits} ${tr.statistics.visits_suffix}',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: tr.statistics.last_visit,
              value: client.lastVisit != null
                  ? dateFmt.format(client.lastVisit!)
                  : '—',
            ),
            const SizedBox(height: 8),
            _DetailRow(
              label: tr.statistics.total_spent,
              value: '${moneyFmt.format(client.totalSpent)} ${tr.statistics.currency_suffix}',
              valueColor: custom.primary,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: custom.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pushNamed(AddNewRecordPage.tag);
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add, size: 18),
                    const SizedBox(width: 6),
                    Text(tr.statistics.schedule),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _SecondaryButton(
                    icon: Icons.call_outlined,
                    label: tr.statistics.contact,
                    onTap: () => _launchTel(client.phone),
                    enabled: client.phone.isNotEmpty,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SecondaryButton(
                    icon: Icons.history,
                    label: tr.statistics.history,
                    onTap: () => _showSoon(context),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _SecondaryButton(
                    icon: Icons.edit_outlined,
                    label: tr.statistics.edit,
                    onTap: () => _showSoon(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () => _confirmDelete(context),
                style: TextButton.styleFrom(
                  backgroundColor: StateColor.error.withValues(alpha: 0.1),
                  foregroundColor: StateColor.error,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.delete_outline),
                label: Text(tr.statistics.delete_client),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _launchTel(String phone) async {
    final clean = phone.replaceAll(RegExp(r'[^\d+]'), '');
    if (clean.isEmpty) return;
    final uri = Uri(scheme: 'tel', path: clean);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  void _showSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }

  Future<void> _confirmDelete(BuildContext context) async {
    final tr = Translations.of(context);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(tr.statistics.delete_client),
        content: Text(client.name.isEmpty ? client.phone : client.name),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('OK'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon')),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.valueColor,
  });

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: Typographies.regularBody2),
        Text(
          value,
          style: valueColor != null
              ? Typographies.regularBody2.copyWith(color: valueColor)
              : Typographies.regularBody2,
        ),
      ],
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  const _SecondaryButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final custom = Theme.of(context).extension<AppThemeExtension>()!;
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: custom.secondary,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: enabled ? custom.primary : Colors.grey),
            const SizedBox(height: 4),
            Text(
              label,
              style: Typographies.regularOverlineLower.copyWith(
                color: enabled ? custom.primary : Colors.grey,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
