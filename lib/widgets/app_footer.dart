import 'package:flutter/material.dart';
import 'package:chess_stats_pwa/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../services/changelog_service.dart';
import '../viewmodels/changelog_viewmodel.dart';

/// Pied de page : numéro de version et lien « Nouveautés » (avec une
/// pastille tant que celles de la version actuelle n'ont pas été lues),
/// qui ouvre le journal des versions.
class AppFooter extends StatelessWidget {
  const AppFooter({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final hasUnseen = context.watch<ChangelogViewModel>().hasUnseenChanges;
    final textStyle = theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Divider(height: 1),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 8,
            children: [
              Text(l10n.appVersion(ChangelogService.currentVersion), style: textStyle),
              Text('·', style: textStyle),
              TextButton(
                onPressed: () => _showChangelog(context),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.whatsNew),
                    if (hasUnseen) ...[
                      const SizedBox(width: 6),
                      const Badge(smallSize: 8),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showChangelog(BuildContext context) {
    context.read<ChangelogViewModel>().markSeen();
    showDialog<void>(
      context: context,
      builder: (context) => const _ChangelogDialog(),
    );
  }
}

class _ChangelogDialog extends StatelessWidget {
  const _ChangelogDialog();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMMd(Localizations.localeOf(context).toString());

    return AlertDialog(
      title: Text(l10n.whatsNew),
      content: SizedBox(
        width: 480,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final (index, entry) in ChangelogService.entries.indexed) ...[
                if (index > 0) const SizedBox(height: 20),
                Text(
                  l10n.changelogVersionTitle(entry.version, dateFormat.format(entry.date)),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                for (final change in entry.changes(l10n))
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('•  ', style: theme.textTheme.bodyMedium),
                        Expanded(child: Text(change, style: theme.textTheme.bodyMedium)),
                      ],
                    ),
                  ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.close),
        ),
      ],
    );
  }
}
