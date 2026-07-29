import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data_repository.dart';
import '../models.dart';

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
          colors: [AppTheme.fuchsiaDark, AppTheme.fuchsiaBright],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.88),
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
  });

  final String title;
  final String? subtitle;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: colors.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 3),
                      Text(
                        subtitle!,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
              if (trailing != null) trailing!,
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }
}

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
    return IconButton(
      tooltip: information ? 'Technical information' : 'Field guidance',
      visualDensity: VisualDensity.compact,
      onPressed: () => showHelperDialog(
        context,
        topicId: topicId,
        information: information,
        liveValues: liveValues,
      ),
      icon: Icon(
        information ? Icons.info_outline : Icons.help_outline,
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
        content: Text('No controlled helper topic is linked to this field.'),
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
                    information ? Icons.info_outline : Icons.help_outline,
                    color: AppTheme.fuchsia,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      topic.title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800,
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
                      if (liveValues.isNotEmpty)
                        _LiveValues(values: liveValues),
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

class _HelperSection extends StatelessWidget {
  const _HelperSection({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    if (body.trim().isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
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
        color: AppTheme.fuchsia.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Current project values', style: TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          for (final entry in values.entries)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Expanded(child: Text(entry.key)),
                  Text(entry.value, style: const TextStyle(fontWeight: FontWeight.w700)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

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
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            if (topicId != null) ...[
              HelperButton(topicId: topicId!, liveValues: liveValues),
              HelperButton(
                topicId: topicId!,
                information: true,
                liveValues: liveValues,
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }
}

class ResultTile extends StatelessWidget {
  const ResultTile({
    super.key,
    required this.label,
    required this.value,
    this.status,
  });

  final String label;
  final String value;
  final AssessmentStatus? status;

  Color _statusColor(BuildContext context) {
    switch (status) {
      case AssessmentStatus.pass:
        return const Color(0xFF18864B);
      case AssessmentStatus.verify:
        return const Color(0xFFB56900);
      case AssessmentStatus.fail:
        return const Color(0xFFB42318);
      case AssessmentStatus.notAssessed:
      case null:
        return Theme.of(context).colorScheme.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _statusColor(context);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
          ),
        ],
      ),
    );
  }
}

class ResponsiveGrid extends StatelessWidget {
  const ResponsiveGrid({
    super.key,
    required this.children,
    this.minItemWidth = 260,
    this.spacing = 12,
  });

  final List<Widget> children;
  final double minItemWidth;
  final double spacing;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = (constraints.maxWidth / minItemWidth).floor().clamp(1, 4);
        return GridView.count(
          crossAxisCount: count,
          crossAxisSpacing: spacing,
          mainAxisSpacing: spacing,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 2.4,
          children: children,
        );
      },
    );
  }
}
