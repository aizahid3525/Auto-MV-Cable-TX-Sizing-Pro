import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data_repository.dart';
import '../models.dart';

/// Modern page hero used by the engineering workflows.
class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.navy, AppTheme.blue, AppTheme.cyan],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppTheme.blue.withValues(alpha: 0.18),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            ),
            child: Icon(icon, color: Colors.white, size: 31),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
                        fontWeight: FontWeight.w600,
                        height: 1.28,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.trailing,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    return Material(
      color: colors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
        side: BorderSide(color: colors.outlineVariant),
      ),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.16)
                  : const Color(0xFF0F172A).withValues(alpha: 0.055),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.cyan.withValues(alpha: isDark ? 0.16 : 0.10),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(icon, color: AppTheme.cyanDark, size: 24),
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w900,
                          height: 1.12,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colors.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            height: 1.25,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  trailing!,
                ],
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

/// Controlled helper control.
///
/// Input fields use [information] = false and therefore show a question mark.
/// Result/output information uses [information] = true and therefore shows an
/// information mark. This mirrors the latest Auto Cable Sizing Pro convention.
class HelperButton extends StatelessWidget {
  const HelperButton({
    super.key,
    required this.topicId,
    this.information = false,
    this.liveValues = const {},
  });

  final String topicId;
  final bool information;
  final Map<String, String> liveValues;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = information ? AppTheme.teal : AppTheme.cyanDark;
    return IconButton(
      tooltip: information ? 'Result information' : 'Input guidance',
      visualDensity: VisualDensity.compact,
      constraints: const BoxConstraints.tightFor(width: 36, height: 36),
      padding: EdgeInsets.zero,
      style: IconButton.styleFrom(
        foregroundColor: color,
        backgroundColor: theme.colorScheme.surface,
        side: BorderSide(color: color.withValues(alpha: 0.70)),
        shape: const CircleBorder(),
      ),
      onPressed: () => showHelperDialog(
        context,
        topicId: topicId,
        information: information,
        liveValues: liveValues,
      ),
      icon: Icon(
        information ? Icons.info_outline_rounded : Icons.help_outline_rounded,
        size: 20,
      ),
    );
  }
}

Future<void> showHelperDialog(
  BuildContext context, {
  required String topicId,
  required bool information,
  Map<String, String> liveValues = const {},
}) async {
  final topic = EngineeringRepository.instance.help(topicId);
  if (topic == null) {
    await showDialog<void>(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Guidance unavailable'),
        content: Text('No controlled helper topic is linked to this item.'),
      ),
    );
    return;
  }
  await showDialog<void>(
    context: context,
    builder: (context) => Dialog(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720, maxHeight: 760),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    information
                        ? Icons.info_outline_rounded
                        : Icons.help_outline_rounded,
                    color: information ? AppTheme.teal : AppTheme.cyanDark,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      topic.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const Divider(),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HelperSection(title: 'Explanation', body: topic.explanation),
                      _HelperSection(title: 'How the app uses it', body: topic.usage),
                      _HelperSection(title: 'Worked example', body: topic.example),
                      if (liveValues.isNotEmpty) _LiveValues(values: liveValues),
                      if (topic.referenceTable.trim().isNotEmpty)
                        _HelperSection(
                          title: 'Reference table / list',
                          body: topic.referenceTable.replaceAll(' | ', '\n• '),
                        ),
                      _HelperSection(title: 'Important warning', body: topic.warning),
                      _HelperSection(title: 'Source / basis', body: topic.source),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<void> showResultInformationDialog(
  BuildContext context, {
  required String label,
  required String value,
}) {
  return showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      icon: const Icon(Icons.info_outline_rounded, color: AppTheme.teal),
      title: Text(label),
      content: Text(
        '$value\n\nThis is a calculated or database-derived output. Review the associated input assumptions, data status and engineering warnings before final issue.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Close'),
        ),
      ],
    ),
  );
}

class _HelperSection extends StatelessWidget {
  const _HelperSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    if (body.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 5),
          Text(body),
        ],
      ),
    );
  }
}

class _LiveValues extends StatelessWidget {
  const _LiveValues({required this.values});

  final Map<String, String> values;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cyan.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current project values',
            style: TextStyle(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          for (final entry in values.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(child: Text(entry.key)),
                  Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w800)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

/// Input-field wrapper. Exactly one question-mark helper is shown when a
/// controlled [topicId] is supplied. Information icons are reserved for
/// result/output cards.
class LabeledField extends StatelessWidget {
  const LabeledField({
    super.key,
    required this.label,
    required this.child,
    this.topicId,
    this.liveValues = const {},
  });

  final String label;
  final Widget child;
  final String? topicId;
  final Map<String, String> liveValues;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
            if (topicId != null) ...[
              const SizedBox(width: 4),
              HelperButton(topicId: topicId!, liveValues: liveValues),
            ],
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

/// Result/output card. An information icon is always displayed, either opening
/// a controlled helper topic or a generic output explanation.
class ResultTile extends StatelessWidget {
  const ResultTile({
    super.key,
    required this.label,
    required this.value,
    this.status,
    this.topicId,
    this.icon,
  });

  final String label;
  final String value;
  final AssessmentStatus? status;
  final String? topicId;
  final IconData? icon;

  Color _statusColor(BuildContext context) {
    switch (status) {
      case AssessmentStatus.pass:
        return const Color(0xFF18864B);
      case AssessmentStatus.verify:
        return const Color(0xFFB56900);
      case AssessmentStatus.fail:
        return const Color(0xFFB42318);
      case AssessmentStatus.notAssessed:
        return const Color(0xFF64748B);
      case null:
        return AppTheme.cyanDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark
            ? color.withValues(alpha: 0.10)
            : Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        color: color,
                        height: 1.15,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          if (topicId != null)
            HelperButton(topicId: topicId!, information: true)
          else
            IconButton(
              tooltip: 'Result information',
              visualDensity: VisualDensity.compact,
              constraints: const BoxConstraints.tightFor(width: 34, height: 34),
              padding: EdgeInsets.zero,
              style: IconButton.styleFrom(
                foregroundColor: AppTheme.teal,
                backgroundColor: Theme.of(context).colorScheme.surface,
                side: BorderSide(color: AppTheme.teal.withValues(alpha: 0.70)),
                shape: const CircleBorder(),
              ),
              onPressed: () => showResultInformationDialog(
                context,
                label: label,
                value: value,
              ),
              icon: const Icon(Icons.info_outline_rounded, size: 19),
            ),
        ],
      ),
    );
  }
}

/// Two-column card layout used throughout the app.
///
/// On normal phones and tablets it uses exactly two columns. Cards in each row
/// are height-matched. If the number of children is odd, the final card spans
/// the full two-column width. Extremely narrow accessibility layouts fall back
/// to one column to prevent clipped text.
class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 150,
    this.spacing = 12,
  });

  final List<Widget> children;
  final double minItemWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final requestedWidth = minItemWidth * 2 + spacing;
        final breakpoint = requestedWidth.clamp(220.0, 252.0).toDouble();
        final useTwoColumns = constraints.maxWidth >= breakpoint;
        if (!useTwoColumns) {
          return Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                SizedBox(width: double.infinity, child: children[i]),
                if (i != children.length - 1) SizedBox(height: spacing),
              ],
            ],
          );
        }

        final rows = <Widget>[];
        for (var index = 0; index < children.length; index += 2) {
          final hasPair = index + 1 < children.length;
          if (!hasPair) {
            rows.add(SizedBox(width: double.infinity, child: children[index]));
            continue;
          }
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: children[index]),
                  SizedBox(width: spacing),
                  Expanded(child: children[index + 1]),
                ],
              ),
            ),
          );
        }
        return Column(
          children: [
            for (var i = 0; i < rows.length; i++) ...[
              rows[i],
              if (i != rows.length - 1) SizedBox(height: spacing),
            ],
          ],
        );
      },
    );
  }
}
