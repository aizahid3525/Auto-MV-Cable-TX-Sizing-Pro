import 'dart:math' as math;

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
                      color: AppTheme.cyan.withValues(
                        alpha: isDark ? 0.16 : 0.16,
                      ),
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

/// Current screen values supplied to all helper buttons below this widget.
///
/// This avoids stale hard-coded examples. Every input `?` and result `i` can
/// resolve a live substitution from the active screen state without creating a
/// second engineering calculation engine.
class EngineeringHelpScope extends InheritedWidget {
  const EngineeringHelpScope({
    super.key,
    required this.values,
    required super.child,
  });

  final Map<String, Object?> values;

  static Map<String, Object?> maybeValuesOf(BuildContext context) {
    return context
            .dependOnInheritedWidgetOfExactType<EngineeringHelpScope>()
            ?.values ??
        const <String, Object?>{};
  }

  @override
  bool updateShouldNotify(EngineeringHelpScope oldWidget) {
    return oldWidget.values != values;
  }
}

class HelpLiveMetric {
  const HelpLiveMetric({required this.label, required this.value});

  final String label;
  final String value;
}

class HelpLiveData {
  const HelpLiveData({
    required this.summary,
    required this.substitution,
    this.metrics = const <HelpLiveMetric>[],
    this.notes = const <String>[],
    this.status,
  });

  final String summary;
  final String substitution;
  final List<HelpLiveMetric> metrics;
  final List<String> notes;
  final String? status;
}

/// Controlled helper control.
///
/// Input fields use [information] = false and therefore show a question mark.
/// Result/output information uses [information] = true and therefore shows an
/// information mark.
class HelperButton extends StatelessWidget {
  const HelperButton({
    super.key,
    required this.topicId,
    this.information = false,
    this.liveValues = const <String, Object?>{},
  });

  final String topicId;
  final bool information;
  final Map<String, Object?> liveValues;

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
      onPressed: () {
        final values = <String, Object?>{
          ...EngineeringHelpScope.maybeValuesOf(context),
          ...liveValues,
        };
        showHelperDialog(
          context,
          topicId: topicId,
          information: information,
          liveValues: values,
        );
      },
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
  Map<String, Object?> liveValues = const <String, Object?>{},
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

  final parentScrollable = Scrollable.maybeOf(context);
  final parentPosition = parentScrollable?.position;
  final savedOffset = parentPosition?.hasPixels == true
      ? parentPosition!.pixels
      : null;

  void restoreParentScroll() {
    if (parentPosition == null ||
        savedOffset == null ||
        !parentPosition.hasPixels) {
      return;
    }
    final target = savedOffset
        .clamp(parentPosition.minScrollExtent, parentPosition.maxScrollExtent)
        .toDouble();
    if ((parentPosition.pixels - target).abs() > 0.5) {
      parentPosition.jumpTo(target);
    }
  }

  FocusManager.instance.primaryFocus?.unfocus();
  final liveData = buildEngineeringHelpLiveData(topicId, liveValues);

  await showDialog<void>(
    context: context,
    requestFocus: false,
    builder: (dialogContext) {
      final size = MediaQuery.sizeOf(dialogContext);
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 760,
            maxHeight: math.max(420.0, size.height * 0.88),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            topic.title,
                            style: Theme.of(dialogContext)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            information
                                ? 'Calculated result information'
                                : 'Input guidance and reference',
                            style: Theme.of(dialogContext)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(dialogContext)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _HelperSection(
                          title: 'What this means',
                          body: topic.explanation,
                          icon: Icons.info_outline_rounded,
                        ),
                        _HelperSection(
                          title: 'How the app uses it',
                          body: topic.usage,
                          icon: Icons.calculate_outlined,
                        ),
                        if (topic.equation.trim().isNotEmpty)
                          _EquationSection(equation: topic.equation),
                        if (liveData != null)
                          _HelpLiveCalculationPanel(data: liveData),
                        _HelperSection(
                          title: liveData == null
                              ? 'Worked example'
                              : 'General example — reference only',
                          body: topic.example,
                          icon: Icons.lightbulb_outline_rounded,
                        ),
                        if (topic.referenceTable.trim().isNotEmpty)
                          _ReferenceTableSection(raw: topic.referenceTable),
                        _HelperSection(
                          title: 'Important warning',
                          body: topic.warning,
                          icon: Icons.warning_amber_rounded,
                          warning: true,
                        ),
                        _HelperSection(
                          title: 'Source / basis',
                          body: topic.source,
                          icon: Icons.menu_book_outlined,
                        ),
                        Text(
                          'Live substitutions use the current screen values. Repeat critical calculations independently and verify exact manufacturer, utility and project requirements before final issue.',
                          style: Theme.of(dialogContext)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                height: 1.35,
                                color: Theme.of(dialogContext)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );

  WidgetsBinding.instance.addPostFrameCallback((_) => restoreParentScroll());
  Future<void>.delayed(const Duration(milliseconds: 80), restoreParentScroll);
}

Future<void> showResultInformationDialog(
  BuildContext context, {
  required String label,
  required String value,
  Map<String, Object?> liveValues = const <String, Object?>{},
}) {
  final values = <String, Object?>{
    ...EngineeringHelpScope.maybeValuesOf(context),
    ...liveValues,
  };
  final liveData = buildResultHelpLiveData(label, values);
  final topicId = _topicIdForResultLabel(label);
  final topic = topicId == null
      ? null
      : EngineeringRepository.instance.help(topicId);
  FocusManager.instance.primaryFocus?.unfocus();
  return showDialog<void>(
    context: context,
    requestFocus: false,
    builder: (dialogContext) {
      final size = MediaQuery.sizeOf(dialogContext);
      return Dialog(
        insetPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 20),
        clipBehavior: Clip.antiAlias,
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 760,
            maxHeight: math.max(420.0, size.height * 0.88),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.info_outline_rounded,
                      color: AppTheme.teal,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: Theme.of(dialogContext)
                                .textTheme
                                .titleLarge
                                ?.copyWith(fontWeight: FontWeight.w900),
                          ),
                          Text(
                            'Calculated result, equation trace and verification basis',
                            style: Theme.of(dialogContext)
                                .textTheme
                                .bodySmall
                                ?.copyWith(
                                  color: Theme.of(dialogContext)
                                      .colorScheme
                                      .onSurfaceVariant,
                                  fontWeight: FontWeight.w700,
                                ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      tooltip: 'Close',
                      onPressed: () => Navigator.of(dialogContext).pop(),
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
                const Divider(),
                Flexible(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ResultValueBanner(value: value),
                        if (topic != null) ...[
                          const SizedBox(height: 12),
                          _HelperSection(
                            title: 'What this result means',
                            body: topic.explanation,
                            icon: Icons.info_outline_rounded,
                          ),
                          _HelperSection(
                            title: 'How the app calculates or selects it',
                            body: topic.usage,
                            icon: Icons.calculate_outlined,
                          ),
                          if (topic.equation.trim().isNotEmpty)
                            _EquationSection(equation: topic.equation),
                        ],
                        if (liveData != null)
                          _HelpLiveCalculationPanel(data: liveData),
                        if (topic != null &&
                            topic.referenceTable.trim().isNotEmpty)
                          _ReferenceTableSection(raw: topic.referenceTable),
                        if (topic != null) ...[
                          _HelperSection(
                            title: 'Important warning',
                            body: topic.warning,
                            icon: Icons.warning_amber_rounded,
                            warning: true,
                          ),
                          _HelperSection(
                            title: 'Source / basis',
                            body: topic.source,
                            icon: Icons.menu_book_outlined,
                          ),
                        ],
                        Text(
                          'This is a calculated or database-derived output. Repeat critical calculations independently and verify exact manufacturer, utility, protection-coordination and project requirements before final issue.',
                          style: Theme.of(dialogContext)
                              .textTheme
                              .bodySmall
                              ?.copyWith(
                                height: 1.4,
                                color: Theme.of(dialogContext)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

String? _topicIdForResultLabel(String label) {
  switch (label.trim().toLowerCase()) {
    case 'design current':
    case 'mv feeder current':
    case 'transformer mv current':
    case 'transformer lv current':
    case 'mv current / unit':
    case 'lv current / unit':
      return 'load_kva';
    case 'derated ampacity':
      return 'installation_method';
    case 'cable loading':
      return 'cable_loading';
    case 'voltage drop':
      return 'voltage_drop';
    case 'conductor withstand':
      return 'fault_current';
    case 'charging current':
      return 'charging_current';
    case 'conductor loss':
      return 'cable_loss';
    case 'design demand':
    case 'transformer loading':
    case 'normal loading':
    case 'outage loading':
      return 'transformer_loading';
    case 'approx. lv terminal fault':
    case 'calculated / entered lv fault':
      return 'transformer_impedance';
    case 'total loss at design':
      return 'transformer_losses';
    case 'approx. efficiency':
      return 'transformer_efficiency';
    case 'approx. regulation':
      return 'transformer_regulation';
    case 'preferred mv protection':
    case 'preferred mv device':
      return 'mv_device_strategy';
    case 'vcb requirement':
      return 'vcb_selection';
    case 'switch-fuse starting point':
      return 'mv_fuse_selection';
    case 'acb frame / sensor':
    case 'acb frame / duty':
    case 'acb duty':
    case 'lv acb':
    case 'acb poles':
      return 'acb_selection';
    case 'protection ct':
      return 'ct_selection';
    case 'acb ir / isd':
    case 'acb ii':
    case 'acb ground fault':
      return 'acb_lsig';
    case 'relay 51 pickup start':
    case 'relay earth-fault pickup start':
    case 'relay high-set start':
      return 'relay_functions';
    case 'overall status':
    case 'cable status':
    case 'transformer':
    case 'mv cable':
      return 'data_status';
    default:
      if (label.toLowerCase().contains('records matched')) {
        return 'data_status';
      }
      return null;
  }
}

class _ResultValueBanner extends StatelessWidget {
  const _ResultValueBanner({required this.value});

  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.cyan.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.cyanDark.withValues(alpha: 0.30)),
      ),
      child: Text(
        value,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.cyanDark,
              fontWeight: FontWeight.w900,
            ),
      ),
    );
  }
}

class _HelperSection extends StatelessWidget {
  const _HelperSection({
    required this.title,
    required this.body,
    required this.icon,
    this.warning = false,
  });

  final String title;
  final String body;
  final IconData icon;
  final bool warning;

  @override
  Widget build(BuildContext context) {
    if (body.trim().isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final tint = warning ? const Color(0xFFD97706) : theme.colorScheme.primary;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: tint.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.14 : 0.07,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tint.withValues(alpha: 0.27)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: tint),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(color: tint, fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          SelectableText(
            body,
            style: const TextStyle(height: 1.38, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _EquationSection extends StatelessWidget {
  const _EquationSection({required this.equation});

  final String equation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.functions_rounded,
                size: 19,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 7),
              const Text(
                'Formula / equation',
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SelectableText(
            equation,
            style: const TextStyle(
              fontFamily: 'monospace',
              height: 1.42,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _HelpLiveCalculationPanel extends StatelessWidget {
  const _HelpLiveCalculationPanel({required this.data});

  final HelpLiveData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tint = theme.colorScheme.primary;
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: tint.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.14 : 0.07,
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: tint.withValues(alpha: 0.32)),
      ),
      child: ExpansionTile(
        initiallyExpanded: true,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
        leading: Icon(Icons.calculate_rounded, color: tint),
        title: const Text(
          'Live calculation using current values',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        subtitle: Text(
          data.summary,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: data.status == null
            ? const Icon(Icons.expand_more_rounded)
            : Chip(
                visualDensity: VisualDensity.compact,
                label: Text(
                  data.status!,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.colorScheme.outlineVariant),
            ),
            child: SelectableText(
              data.substitution,
              style: const TextStyle(
                fontFamily: 'monospace',
                height: 1.46,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (data.metrics.isNotEmpty) ...[
            const SizedBox(height: 10),
            _LiveMetricsTable(metrics: data.metrics),
          ],
          for (final note in data.notes)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.verified_user_outlined, size: 17, color: tint),
                  const SizedBox(width: 7),
                  Expanded(
                    child: Text(
                      note,
                      style: const TextStyle(
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                      ),
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

class _LiveMetricsTable extends StatelessWidget {
  const _LiveMetricsTable({required this.metrics});

  final List<HelpLiveMetric> metrics;

  @override
  Widget build(BuildContext context) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(3),
        1: FlexColumnWidth(2),
      },
      border: TableBorder.all(
        color: Theme.of(context).colorScheme.outlineVariant,
      ),
      children: [
        for (final metric in metrics)
          TableRow(
            children: [
              Padding(
                padding: const EdgeInsets.all(9),
                child: Text(
                  metric.label,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(9),
                child: Text(
                  metric.value,
                  textAlign: TextAlign.right,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ReferenceTableSection extends StatelessWidget {
  const _ReferenceTableSection({required this.raw});

  final String raw;

  @override
  Widget build(BuildContext context) {
    final rows = _parseReferenceTable(raw);
    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.table_chart_outlined,
                size: 19,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 7),
              const Expanded(
                child: Text(
                  'Reference values / options',
                  style: TextStyle(fontWeight: FontWeight.w900),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = math.max(constraints.maxWidth, 480.0);
              return SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SizedBox(
                  width: width,
                  child: Table(
                    columnWidths: const {
                      0: FlexColumnWidth(3),
                      1: FlexColumnWidth(4),
                    },
                    border: TableBorder.all(
                      color: theme.colorScheme.outlineVariant,
                    ),
                    children: [
                      for (var index = 0; index < rows.length; index++)
                        TableRow(
                          decoration: index == 0
                              ? BoxDecoration(
                                  color: theme.colorScheme.primary
                                      .withValues(alpha: 0.10),
                                )
                              : null,
                          children: [
                            _ReferenceCell(
                              text: rows[index][0],
                              header: index == 0,
                            ),
                            _ReferenceCell(
                              text: rows[index][1],
                              header: index == 0,
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _ReferenceCell extends StatelessWidget {
  const _ReferenceCell({required this.text, required this.header});

  final String text;
  final bool header;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      child: Text(
        text,
        style: TextStyle(
          height: 1.28,
          fontWeight: header ? FontWeight.w900 : FontWeight.w600,
        ),
      ),
    );
  }
}

List<List<String>> _parseReferenceTable(String raw) {
  final parts = raw
      .split(' | ')
      .map((part) => part.trim())
      .where((part) => part.isNotEmpty)
      .toList(growable: false);
  if (parts.isEmpty) {
    return const <List<String>>[];
  }

  List<String> splitRow(String part, {required bool header}) {
    final separator = header ? part.indexOf(' / ') : part.lastIndexOf(' / ');
    if (separator < 0) {
      return <String>[part, ''];
    }
    return <String>[
      part.substring(0, separator).trim(),
      part.substring(separator + 3).trim(),
    ];
  }

  return <List<String>>[
    splitRow(parts.first, header: true),
    for (final part in parts.skip(1)) splitRow(part, header: false),
  ];
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
    this.liveValues = const <String, Object?>{},
  });

  final String label;
  final Widget child;
  final String? topicId;
  final Map<String, Object?> liveValues;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
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
/// a controlled helper topic or a live output explanation.
class ResultTile extends StatelessWidget {
  const ResultTile({
    super.key,
    required this.label,
    required this.value,
    this.status,
    this.topicId,
    this.icon,
    this.liveValues = const <String, Object?>{},
  });

  final String label;
  final String value;
  final AssessmentStatus? status;
  final String? topicId;
  final IconData? icon;
  final Map<String, Object?> liveValues;

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
            HelperButton(
              topicId: topicId!,
              information: true,
              liveValues: liveValues,
            )
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
                liveValues: liveValues,
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

HelpLiveData? buildEngineeringHelpLiveData(
  String topicId,
  Map<String, Object?> values,
) {
  switch (topicId) {
    case 'system_voltage':
      return _systemVoltageLive(values);
    case 'load_kva':
      return _loadLive(values);
    case 'power_factor':
      return _powerFactorLive(values);
    case 'installation_method':
      return _installationLive(values);
    case 'soil_resistivity':
      return _selectionLive(
        values,
        keys: const ['soilResistivity'],
        label: 'Soil thermal resistivity',
        summary: 'The current soil value must be tied to a documented thermal correction or IEC 60287 model.',
      );
    case 'fault_current':
    case 'fault_time':
      return _faultLive(values);
    case 'screen_bonding':
      return _selectionLive(
        values,
        keys: const ['screenBonding'],
        label: 'Screen bonding',
        summary: 'The selected bonding arrangement remains a cable-system verification item.',
      );
    case 'transformer_impedance':
      return _transformerFaultLive(values);
    case 'transformer_loading':
    case 'demand_factor':
    case 'future_growth':
    case 'harmonic_factor':
    case 'redundancy':
      return _transformerDemandLive(values);
    case 'vector_group':
      return _selectionLive(
        values,
        keys: const ['vectorGroup'],
        label: 'Vector group',
        summary: 'The current vector group is shown for compatibility and parallel-operation review.',
      );
    case 'voltage_drop':
      return _voltageDropLive(values);
    case 'charging_current':
      return _chargingCurrentLive(values);
    case 'database_search':
      return _databaseSearchLive(values);
    case 'brand_filter':
      return _selectionLive(
        values,
        keys: const ['selectedBrand', 'brandFilter', 'transformerBrand', 'cableBrand'],
        label: 'Brand filter',
        summary: 'The current brand selection limits the controlled records shown by the app.',
      );
    case 'data_status':
      return _dataStatusLive(values);
    case 'conductor_material':
      return _conductorLive(values);
    case 'number_of_cores':
      return _selectionLive(
        values,
        keys: const ['selectedCores', 'numberOfCores'],
        label: 'Core arrangement',
        summary: 'The selected core arrangement filters compatible records and formations.',
      );
    case 'cable_family':
      return _selectionLive(
        values,
        keys: const ['selectedFamily', 'cableFamily'],
        label: 'Cable family',
        summary: 'The current family selection prevents incompatible cable constructions from being mixed.',
      );
    case 'cable_formation':
      return _selectionLive(
        values,
        keys: const ['cableFormation', 'installationMethod'],
        label: 'Cable formation',
        summary: 'Formation affects reactance, screen/sheath behaviour and installation rating.',
      );
    case 'parallel_runs':
      return _parallelRunsLive(values);
    case 'ambient_temperature':
      return _deratingLive(values);
    case 'transformer_type':
      return _selectionLive(
        values,
        keys: const ['selectedTransformerType', 'transformerType'],
        label: 'Transformer type',
        summary: 'The selected construction filters the transformer database and internal protection guidance.',
      );
    case 'cooling_class':
      return _selectionLive(
        values,
        keys: const ['coolingClass'],
        label: 'Cooling class',
        summary: 'The current cooling class must match the exact transformer nameplate and thermal duty.',
      );
    case 'protection_profile':
      return _selectionLive(
        values,
        keys: const ['protectionProfile'],
        label: 'Protection profile',
        summary: 'The selected profile controls preliminary device margins and philosophy preferences.',
      );
    case 'mv_device_strategy':
      return _selectionLive(
        values,
        keys: const ['mvDeviceStrategy', 'preferredMvDevice'],
        label: 'MV device strategy',
        summary: 'The active strategy is checked against transformer rating, criticality and protection requirements.',
      );
    case 'mv_fault_duty':
    case 'vcb_selection':
      return _vcbLive(values);
    case 'mv_fuse_selection':
      return _fuseLive(values);
    case 'ct_selection':
      return _ctLive(values);
    case 'relay_functions':
      return _relayLive(values);
    case 'acb_selection':
      return _acbLive(values);
    case 'acb_lsig':
      return _acbLsigLive(values);
    case 'internal_tx_protection':
      return _selectionLive(
        values,
        keys: const ['transformerType', 'internalProtectionSummary'],
        label: 'Transformer protection basis',
        summary: 'Internal protection applicability follows the current transformer construction and scheme.',
      );
    case 'protection_category':
      return _selectionLive(
        values,
        keys: const ['selectedProtectionCategory'],
        label: 'Protection category',
        summary: 'The current category selection limits the protection and switchgear records displayed by the database.',
      );
    case 'protection_status':
      return _protectionStatusLive(values);
    default:
      return null;
  }
}

HelpLiveData? buildResultHelpLiveData(
  String label,
  Map<String, Object?> values,
) {
  final key = label.trim().toLowerCase();
  switch (key) {
    case 'design current':
    case 'mv feeder current':
    case 'transformer mv current':
    case 'transformer lv current':
    case 'mv current / unit':
    case 'lv current / unit':
      return _resultCurrentLive(label, values);
    case 'derated ampacity':
      return _installationLive(values);
    case 'cable loading':
    case 'transformer loading':
    case 'normal loading':
    case 'outage loading':
      return _resultLoadingLive(label, values);
    case 'voltage drop':
      return _voltageDropLive(values);
    case 'conductor withstand':
      return _faultLive(values);
    case 'charging current':
      return _chargingCurrentLive(values);
    case 'conductor loss':
      return _cableLossLive(values);
    case 'design demand':
      return _transformerDemandLive(values);
    case 'approx. lv terminal fault':
    case 'calculated / entered lv fault':
      return _transformerFaultLive(values);
    case 'total loss at design':
      return _transformerLossLive(values);
    case 'approx. efficiency':
      return _transformerEfficiencyLive(values);
    case 'approx. regulation':
      return _transformerRegulationLive(values);
    case 'preferred mv protection':
    case 'preferred mv device':
      return _protectionStatusLive(values);
    case 'vcb requirement':
      return _vcbLive(values);
    case 'switch-fuse starting point':
      return _fuseLive(values);
    case 'acb frame / sensor':
    case 'acb frame / duty':
    case 'acb duty':
    case 'lv acb':
      return _acbLive(values);
    case 'protection ct':
      return _ctLive(values);
    case 'acb poles':
      return _selectionLive(
        values,
        keys: const ['acbPoles'],
        label: 'ACB poles',
        summary: 'The pole configuration must match the earthing system, neutral arrangement and project protection philosophy.',
      );
    case 'acb ir / isd':
    case 'acb ii':
    case 'acb ground fault':
      return _acbLsigLive(values);
    case 'relay 51 pickup start':
    case 'relay earth-fault pickup start':
    case 'relay high-set start':
      return _relayLive(values);
    case 'overall status':
    case 'cable status':
      return _dataStatusLive(values);
    case 'transformer':
    case 'mv cable':
      return _dataStatusLive(values);
    default:
      final matchedCount = _firstNumber(
        values,
        const ['matchedRecordCount', 'matchedCount'],
      );
      if (key.contains('records matched') && matchedCount != null) {
        return HelpLiveData(
          summary: 'The record count is recalculated from the current search text and active filters.',
          substitution: 'Matched records = ${_fmt(matchedCount, digits: 0)}',
          metrics: [
            HelpLiveMetric(
              label: 'Matched records',
              value: _fmt(matchedCount, digits: 0),
            ),
          ],
          status: 'LIVE',
        );
      }
      return null;
  }
}

HelpLiveData? _systemVoltageLive(Map<String, Object?> values) {
  final voltageKv = _firstNumber(values, const ['systemKv', 'primaryKv']);
  final kva = _firstNumber(
    values,
    const ['loadKva', 'transformerRatingKva', 'designDemandKva'],
  );
  if (voltageKv == null) {
    return null;
  }
  if (kva == null || kva <= 0) {
    return HelpLiveData(
      summary: 'The current nominal line-to-line voltage is used for compatibility and insulation-class screening.',
      substitution: 'VLL = ${_fmt(voltageKv)} kV\nVph = VLL ÷ √3 = ${_fmt(voltageKv / math.sqrt(3))} kV',
      metrics: [
        HelpLiveMetric(label: 'VLL', value: '${_fmt(voltageKv)} kV'),
        HelpLiveMetric(
          label: 'Vph',
          value: '${_fmt(voltageKv / math.sqrt(3))} kV',
        ),
      ],
      status: voltageKv > 0 ? 'ENTERED' : 'CHECK INPUT',
    );
  }
  final current = kva / (math.sqrt(3) * voltageKv);
  return HelpLiveData(
    summary: 'The current three-phase current trace uses the active apparent power and line voltage.',
    substitution: 'I = S ÷ (√3 × VLL)\nI = ${_fmt(kva)} kVA ÷ (√3 × ${_fmt(voltageKv)} kV)\nI = ${_fmt(current)} A',
    metrics: [
      HelpLiveMetric(label: 'VLL', value: '${_fmt(voltageKv)} kV'),
      HelpLiveMetric(label: 'S', value: '${_fmt(kva)} kVA'),
      HelpLiveMetric(label: 'I', value: '${_fmt(current)} A'),
    ],
    status: voltageKv > 0 ? 'CALCULATED' : 'CHECK INPUT',
  );
}

HelpLiveData? _loadLive(Map<String, Object?> values) {
  final connectedKw = _number(values, 'connectedLoadKw');
  if (connectedKw != null) {
    return _transformerDemandLive(values);
  }
  final kva = _firstNumber(
    values,
    const ['loadKva', 'transformerRatingKva', 'designDemandKva'],
  );
  final kv = _firstNumber(values, const ['systemKv', 'primaryKv']);
  if (kva == null || kv == null || kva <= 0 || kv <= 0) {
    return null;
  }
  final current = kva / (math.sqrt(3) * kv);
  return HelpLiveData(
    summary: 'The active kVA value is converted to three-phase line current.',
    substitution: 'I = S ÷ (√3 × VLL)\nI = ${_fmt(kva)} kVA ÷ (√3 × ${_fmt(kv)} kV)\nI = ${_fmt(current)} A',
    metrics: [
      HelpLiveMetric(label: 'S', value: '${_fmt(kva)} kVA'),
      HelpLiveMetric(label: 'VLL', value: '${_fmt(kv)} kV'),
      HelpLiveMetric(label: 'I', value: '${_fmt(current)} A'),
    ],
    status: 'CALCULATED',
  );
}

HelpLiveData? _powerFactorLive(Map<String, Object?> values) {
  final pf = _number(values, 'powerFactor');
  if (pf == null) {
    return null;
  }
  final sinPhi = pf >= 0 && pf <= 1
      ? math.sqrt(math.max(0, 1 - pf * pf))
      : double.nan;
  final connectedKw = _number(values, 'connectedLoadKw');
  final efficiency = _number(values, 'efficiency') ?? 1;
  if (connectedKw != null && connectedKw > 0 && efficiency > 0) {
    final apparent = connectedKw / (pf * efficiency);
    return HelpLiveData(
      summary: 'Power factor and efficiency convert the active load to base apparent power.',
      substitution: 'S = P ÷ (PF × η)\nS = ${_fmt(connectedKw)} kW ÷ (${_fmt(pf)} × ${_fmt(efficiency)})\nS = ${_fmt(apparent)} kVA\nsinφ = √(1 − PF²) = ${_fmt(sinPhi)}',
      metrics: [
        HelpLiveMetric(label: 'PF', value: _fmt(pf)),
        HelpLiveMetric(label: 'sinφ', value: _fmt(sinPhi)),
        HelpLiveMetric(label: 'Base S', value: '${_fmt(apparent)} kVA'),
      ],
      status: pf > 0 && pf <= 1 ? 'APPLIED' : 'CHECK INPUT',
    );
  }
  return HelpLiveData(
    summary: 'The active power factor controls the resistive/reactive voltage-drop components.',
    substitution: 'sinφ = √(1 − PF²)\nsinφ = √(1 − ${_fmt(pf)}²)\nsinφ = ${_fmt(sinPhi)}',
    metrics: [
      HelpLiveMetric(label: 'PF', value: _fmt(pf)),
      HelpLiveMetric(label: 'sinφ', value: _fmt(sinPhi)),
    ],
    status: pf > 0 && pf <= 1 ? 'APPLIED' : 'CHECK INPUT',
  );
}

HelpLiveData? _installationLive(Map<String, Object?> values) {
  final method = _text(values, 'installationMethod');
  final base = _number(values, 'baseAmpacityA');
  final factor = _number(values, 'deratingFactor');
  final runs = _number(values, 'parallelRuns');
  final result = _number(values, 'deratedAmpacityA');
  if (method == null && base == null) {
    return null;
  }
  if (base == null || factor == null || runs == null) {
    return HelpLiveData(
      summary: 'The current installation selection determines which reference ampacity column is used.',
      substitution: 'Installation method = ${method ?? 'Not selected'}',
      metrics: [
        HelpLiveMetric(label: 'Method', value: method ?? 'Not selected'),
      ],
      status: method == null ? 'CHECK INPUT' : 'SELECTED',
    );
  }
  final calculated = base * factor * runs;
  return HelpLiveData(
    summary: 'Derated total ampacity uses the selected installation record, total correction factor and parallel runs.',
    substitution: 'Iz = Itab × Ctotal × n\nIz = ${_fmt(base)} A × ${_fmt(factor)} × ${_fmt(runs, digits: 0)}\nIz = ${_fmt(result ?? calculated)} A',
    metrics: [
      HelpLiveMetric(label: 'Method', value: method ?? 'Selected record'),
      HelpLiveMetric(label: 'Itab', value: '${_fmt(base)} A'),
      HelpLiveMetric(label: 'Ctotal', value: _fmt(factor)),
      HelpLiveMetric(label: 'Iz', value: '${_fmt(result ?? calculated)} A'),
    ],
    status: factor > 0 && runs >= 1 ? 'APPLIED' : 'CHECK INPUT',
  );
}

HelpLiveData? _faultLive(Map<String, Object?> values) {
  final faultKa = _firstNumber(
    values,
    const ['faultCurrentKa', 'mvFaultCurrentKa', 'calculatedLvFaultKa'],
  );
  final time = _firstNumber(
    values,
    const ['faultTimeS', 'mvFaultDurationS', 'vcbShortTimeDurationS'],
  );
  final size = _firstNumber(values, const ['conductorSizeMm2', 'cableSizeMm2']);
  final runs = _number(values, 'parallelRuns') ?? 1;
  final material = _text(values, 'conductorMaterialSelected');
  final actual = _number(values, 'shortCircuitWithstandKa');
  if (faultKa == null && size == null) {
    return null;
  }
  if (size != null && time != null && time > 0) {
    final k = material?.toLowerCase().contains('aluminium') == true ? 94.0 : 143.0;
    final withstand = k * size * runs / math.sqrt(time) / 1000;
    final pass = faultKa == null ? null : faultKa <= (actual ?? withstand);
    return HelpLiveData(
      summary: 'The active conductor thermal-withstand trace uses the selected material, area, parallel runs and clearing time.',
      substitution: 'Ith = k × S × n ÷ √t\nIth = ${_fmt(k, digits: 0)} × ${_fmt(size)} mm² × ${_fmt(runs, digits: 0)} ÷ √${_fmt(time)} s ÷ 1000\nIth = ${_fmt(actual ?? withstand)} kA${faultKa == null ? '' : '\nCheck: ${_fmt(faultKa)} kA ≤ ${_fmt(actual ?? withstand)} kA'}',
      metrics: [
        if (faultKa != null)
          HelpLiveMetric(label: 'Entered fault', value: '${_fmt(faultKa)} kA'),
        HelpLiveMetric(label: 't', value: '${_fmt(time)} s'),
        HelpLiveMetric(label: 'k', value: _fmt(k, digits: 0)),
        HelpLiveMetric(
          label: 'Withstand',
          value: '${_fmt(actual ?? withstand)} kA',
        ),
      ],
      status: pass == null ? 'CALCULATED' : (pass ? 'PASS' : 'FAIL'),
    );
  }
  if (faultKa != null && time != null) {
    return HelpLiveData(
      summary: 'The current fault duty is the maximum RMS symmetrical current and required duration.',
      substitution: 'Duty = ${_fmt(faultKa)} kA for ${_fmt(time)} s\nThermal duty indicator I²t = ${_fmt(faultKa * faultKa * time)} kA²·s',
      metrics: [
        HelpLiveMetric(label: 'Ik', value: '${_fmt(faultKa)} kA'),
        HelpLiveMetric(label: 't', value: '${_fmt(time)} s'),
      ],
      status: faultKa > 0 && time > 0 ? 'ENTERED' : 'CHECK INPUT',
    );
  }
  return null;
}

HelpLiveData? _transformerFaultLive(Map<String, Object?> values) {
  final rating = _firstNumber(
    values,
    const ['transformerRatingKva', 'selectedTransformerKva'],
  );
  final secondaryKv = _number(values, 'secondaryKv');
  final impedance = _number(values, 'impedancePercent');
  final current = _number(values, 'secondaryCurrentA');
  final fault = _firstNumber(
    values,
    const ['approxFaultCurrentKa', 'calculatedLvFaultKa'],
  );
  if (impedance == null || secondaryKv == null || rating == null) {
    return null;
  }
  final fullLoad = current ?? rating / (math.sqrt(3) * secondaryKv);
  final calculatedFault = fullLoad / (impedance / 100) / 1000;
  return HelpLiveData(
    summary: 'The current transformer-limited LV fault estimate neglects upstream and downstream impedance unless a project override is entered.',
    substitution: 'Irated = S ÷ (√3 × VLV)\nIrated = ${_fmt(rating)} kVA ÷ (√3 × ${_fmt(secondaryKv)} kV) = ${_fmt(fullLoad)} A\nIk ≈ Irated ÷ (Z% ÷ 100)\nIk ≈ ${_fmt(fullLoad)} A ÷ (${_fmt(impedance)} ÷ 100) ÷ 1000\nIk ≈ ${_fmt(fault ?? calculatedFault)} kA',
    metrics: [
      HelpLiveMetric(label: 'Z', value: '${_fmt(impedance)} %'),
      HelpLiveMetric(label: 'Irated', value: '${_fmt(fullLoad)} A'),
      HelpLiveMetric(
        label: 'Ik',
        value: '${_fmt(fault ?? calculatedFault)} kA',
      ),
    ],
    notes: const [
      'Add source, cable, busbar, motor contribution and impedance tolerance in the final fault study.',
    ],
    status: impedance > 0 ? 'PRELIMINARY' : 'CHECK INPUT',
  );
}

HelpLiveData? _transformerDemandLive(Map<String, Object?> values) {
  final connected = _number(values, 'connectedLoadKw');
  final pf = _number(values, 'powerFactor');
  final efficiency = _number(values, 'efficiency');
  final demand = _number(values, 'demandFactor');
  final growth = _number(values, 'futureGrowthPercent');
  final harmonic = _number(values, 'harmonicFactor');
  final motor = _number(values, 'motorStartingFactor');
  if ([connected, pf, efficiency, demand, growth, harmonic, motor]
      .any((value) => value == null)) {
    return null;
  }
  final base = connected! / (pf! * efficiency!) * demand!;
  final design = base * (1 + growth! / 100) * harmonic! * motor!;
  final actual = _number(values, 'designDemandKva') ?? design;
  final rating = _number(values, 'transformerRatingKva');
  final units = _number(values, 'numberOfUnits');
  final normalLoading = rating != null && units != null && units > 0
      ? actual / (rating * units) * 100
      : null;
  final actualNormal = _number(values, 'normalLoadingPercent') ?? normalLoading;
  return HelpLiveData(
    summary: 'The current transformer demand is recalculated from the entered load and every active multiplicative allowance.',
    substitution: 'Sbase = Pconnected × DF ÷ (PF × η)\nSbase = ${_fmt(connected)} kW × ${_fmt(demand)} ÷ (${_fmt(pf)} × ${_fmt(efficiency)})\nSbase = ${_fmt(base)} kVA\nSdesign = Sbase × (1 + g/100) × Kh × Km\nSdesign = ${_fmt(base)} × (1 + ${_fmt(growth)} / 100) × ${_fmt(harmonic)} × ${_fmt(motor)}\nSdesign = ${_fmt(actual)} kVA${actualNormal == null ? '' : '\nLoading = ${_fmt(actual)} ÷ (${_fmt(rating!)} × ${_fmt(units!, digits: 0)}) × 100 = ${_fmt(actualNormal)}%'}',
    metrics: [
      HelpLiveMetric(label: 'Base demand', value: '${_fmt(base)} kVA'),
      HelpLiveMetric(label: 'Design demand', value: '${_fmt(actual)} kVA'),
      if (actualNormal != null)
        HelpLiveMetric(label: 'Normal loading', value: '${_fmt(actualNormal)} %'),
    ],
    status: connected > 0 && pf > 0 && pf <= 1 && efficiency > 0
        ? 'CALCULATED'
        : 'CHECK INPUT',
  );
}

HelpLiveData? _voltageDropLive(Map<String, Object?> values) {
  final current = _number(values, 'designCurrentA');
  final runs = _number(values, 'parallelRuns');
  final length = _number(values, 'lengthM');
  final resistance = _number(values, 'resistanceOhmPerKm');
  final reactance = _number(values, 'reactanceOhmPerKm');
  final pf = _number(values, 'powerFactor');
  final systemKv = _number(values, 'systemKv');
  final actualV = _number(values, 'voltageDropV');
  final actualPercent = _number(values, 'voltageDropPercent');
  final limit = _number(values, 'voltageDropLimitPercent');
  if ([current, runs, length, resistance, reactance, pf, systemKv]
      .any((value) => value == null)) {
    return null;
  }
  if (runs! <= 0 || systemKv! <= 0) {
    return null;
  }
  final currentPerRun = current! / runs;
  final sinPhi = math.sqrt(math.max(0, 1 - pf! * pf));
  final calculatedV = math.sqrt(3) *
      currentPerRun *
      (length! / 1000) *
      (resistance! * pf + reactance! * sinPhi);
  final calculatedPercent = calculatedV / (systemKv * 1000) * 100;
  final vd = actualV ?? calculatedV;
  final percent = actualPercent ?? calculatedPercent;
  final pass = limit == null ? null : percent <= limit;
  return HelpLiveData(
    summary: 'Voltage drop uses the selected cable R/X data, active power factor, route length and current per parallel run.',
    substitution: 'Irun = I ÷ n = ${_fmt(current)} A ÷ ${_fmt(runs, digits: 0)} = ${_fmt(currentPerRun)} A\nsinφ = √(1 − ${_fmt(pf)}²) = ${_fmt(sinPhi)}\nΔV = √3 × Irun × Lkm × (R × PF + X × sinφ)\nΔV = √3 × ${_fmt(currentPerRun)} × ${_fmt(length / 1000)} × (${_fmt(resistance)} × ${_fmt(pf)} + ${_fmt(reactance)} × ${_fmt(sinPhi)})\nΔV = ${_fmt(vd)} V\nVD% = ${_fmt(vd)} ÷ ${_fmt(systemKv * 1000)} × 100 = ${_fmt(percent)}%',
    metrics: [
      HelpLiveMetric(label: 'ΔV', value: '${_fmt(vd)} V'),
      HelpLiveMetric(label: 'VD', value: '${_fmt(percent)} %'),
      if (limit != null)
        HelpLiveMetric(label: 'Limit', value: '${_fmt(limit)} %'),
    ],
    status: pass == null ? 'CALCULATED' : (pass ? 'PASS' : 'FAIL'),
  );
}

HelpLiveData? _chargingCurrentLive(Map<String, Object?> values) {
  final capacitance = _number(values, 'capacitanceUfPerKm');
  final length = _number(values, 'lengthM');
  final systemKv = _number(values, 'systemKv');
  final runs = _number(values, 'parallelRuns');
  final actual = _number(values, 'chargingCurrentA');
  if ([capacitance, length, systemKv, runs].any((value) => value == null)) {
    return null;
  }
  final vPhase = systemKv! * 1000 / math.sqrt(3);
  final calculated = 2 *
      math.pi *
      50 *
      capacitance! *
      1e-6 *
      (length! / 1000) *
      vPhase *
      runs!;
  return HelpLiveData(
    summary: 'Charging current is recalculated from the selected cable capacitance and active route length.',
    substitution: 'Ic = 2πf × C × L × Vph × n\nVph = ${_fmt(systemKv)} kV × 1000 ÷ √3 = ${_fmt(vPhase)} V\nIc = 2π × 50 × ${_fmt(capacitance)} µF/km × 10⁻⁶ × ${_fmt(length / 1000)} km × ${_fmt(vPhase)} V × ${_fmt(runs, digits: 0)}\nIc = ${_fmt(actual ?? calculated)} A',
    metrics: [
      HelpLiveMetric(label: 'C', value: '${_fmt(capacitance)} µF/km'),
      HelpLiveMetric(label: 'L', value: '${_fmt(length)} m'),
      HelpLiveMetric(label: 'Ic', value: '${_fmt(actual ?? calculated)} A'),
    ],
    status: 'CALCULATED',
  );
}

HelpLiveData? _databaseSearchLive(Map<String, Object?> values) {
  final query = _text(values, 'searchQuery') ?? '';
  final database = _text(values, 'selectedDatabase') ?? 'Engineering database';
  final matched = _firstNumber(
    values,
    const ['matchedRecordCount', 'matchedCount'],
  );
  final filters = <String>[];
  for (final entry in <String, String>{
    'Brand': 'selectedBrand',
    'Family': 'selectedFamily',
    'Cores': 'selectedCores',
    'Material': 'selectedMaterial',
    'Transformer type': 'selectedTransformerType',
    'Protection category': 'selectedProtectionCategory',
  }.entries) {
    final value = _text(values, entry.value);
    if (value != null && !value.toLowerCase().startsWith('all ')) {
      filters.add('${entry.key} = $value');
    }
  }
  return HelpLiveData(
    summary: 'The visible records are rebuilt from the current search query and every active exact-match filter.',
    substitution: 'Match = TextMatch(query) AND active filters\n'
        'Database = $database\n'
        'Query = ${query.isEmpty ? '(blank — all text)' : query}\n'
        'Filters = ${filters.isEmpty ? '(none)' : filters.join(', ')}'
        '${matched == null ? '' : '\nMatched records = ${_fmt(matched, digits: 0)}'}',
    metrics: [
      HelpLiveMetric(label: 'Database', value: database),
      HelpLiveMetric(label: 'Query', value: query.isEmpty ? 'All text' : query),
      if (matched != null)
        HelpLiveMetric(label: 'Matched', value: _fmt(matched, digits: 0)),
    ],
    notes: const [
      'Search and filters identify records only; they do not replace the engineering suitability checks shown in the design workflows.',
    ],
    status: 'LIVE',
  );
}

HelpLiveData? _selectionLive(
  Map<String, Object?> values, {
  required List<String> keys,
  required String label,
  required String summary,
}) {
  final value = _firstText(values, keys);
  if (value == null || value.trim().isEmpty) {
    return null;
  }
  return HelpLiveData(
    summary: summary,
    substitution: '$label = $value',
    metrics: [HelpLiveMetric(label: label, value: value)],
    status: 'SELECTED',
  );
}

HelpLiveData? _dataStatusLive(Map<String, Object?> values) {
  final record = _firstText(
    values,
    const ['selectedRecord', 'selectedTransformer', 'selectedCable'],
  );
  final status = _firstText(
    values,
    const ['dataStatus', 'overallStatus', 'protectionStatus'],
  );
  final matched = _firstNumber(
    values,
    const ['matchedRecordCount', 'matchedCount'],
  );
  if (record == null && status == null && matched == null) {
    return null;
  }
  final lines = <String>[
    if (record != null) 'Selected record = $record',
    if (status != null) 'Current status = $status',
    if (matched != null) 'Matched records = ${_fmt(matched, digits: 0)}',
  ];
  return HelpLiveData(
    summary: 'The current output remains traceable to the selected record, calculation status and database filter state.',
    substitution: lines.join('\n'),
    metrics: [
      if (record != null) HelpLiveMetric(label: 'Record', value: record),
      if (status != null) HelpLiveMetric(label: 'Status', value: status),
      if (matched != null)
        HelpLiveMetric(
          label: 'Matched',
          value: _fmt(matched, digits: 0),
        ),
    ],
    status: status ?? 'LIVE',
  );
}

HelpLiveData? _conductorLive(Map<String, Object?> values) {
  final material = _firstText(
    values,
    const ['selectedMaterial', 'conductorMaterialSelected', 'conductorMaterial'],
  );
  final size = _firstNumber(values, const ['conductorSizeMm2', 'cableSizeMm2']);
  final time = _number(values, 'faultTimeS');
  final runs = _number(values, 'parallelRuns') ?? 1;
  if (material == null) {
    return null;
  }
  if (size == null || time == null || time <= 0) {
    return HelpLiveData(
      summary: 'The current material selection controls resistance and the adiabatic k coefficient used by the preliminary cable engine.',
      substitution: 'Conductor material = $material',
      metrics: [HelpLiveMetric(label: 'Material', value: material)],
      status: 'SELECTED',
    );
  }
  final k = material.toLowerCase().contains('aluminium') ? 94.0 : 143.0;
  final withstand = k * size * runs / math.sqrt(time) / 1000;
  return HelpLiveData(
    summary: 'The selected conductor material determines the preliminary adiabatic coefficient.',
    substitution: 'k = ${_fmt(k, digits: 0)} for $material\nIth = k × S × n ÷ √t\nIth = ${_fmt(k, digits: 0)} × ${_fmt(size)} × ${_fmt(runs, digits: 0)} ÷ √${_fmt(time)} ÷ 1000\nIth = ${_fmt(withstand)} kA',
    metrics: [
      HelpLiveMetric(label: 'Material', value: material),
      HelpLiveMetric(label: 'k', value: _fmt(k, digits: 0)),
      HelpLiveMetric(label: 'Ith', value: '${_fmt(withstand)} kA'),
    ],
    status: 'CALCULATED',
  );
}

HelpLiveData? _parallelRunsLive(Map<String, Object?> values) {
  final current = _number(values, 'designCurrentA');
  final runs = _number(values, 'parallelRuns');
  final base = _number(values, 'baseAmpacityA');
  final factor = _number(values, 'deratingFactor');
  if (runs == null) {
    return null;
  }
  final currentPerRun = current != null && runs > 0 ? current / runs : null;
  final total = base != null && factor != null ? base * factor * runs : null;
  return HelpLiveData(
    summary: 'The current is shared equally only when parallel circuits are electrically and physically matched.',
    substitution: '${currentPerRun == null ? '' : 'Irun = Iphase ÷ n\nIrun = ${_fmt(current!)} A ÷ ${_fmt(runs, digits: 0)} = ${_fmt(currentPerRun)} A\n'}${total == null ? '' : 'Iz,total = Itab × Ctotal × n\nIz,total = ${_fmt(base!)} × ${_fmt(factor!)} × ${_fmt(runs, digits: 0)} = ${_fmt(total)} A'}',
    metrics: [
      HelpLiveMetric(label: 'Runs', value: _fmt(runs, digits: 0)),
      if (currentPerRun != null)
        HelpLiveMetric(label: 'Current / run', value: '${_fmt(currentPerRun)} A'),
      if (total != null)
        HelpLiveMetric(label: 'Total Iz', value: '${_fmt(total)} A'),
    ],
    notes: const [
      'Verify equal length, conductor size, route, termination, impedance, grouping and phase sequence for every parallel circuit.',
    ],
    status: runs >= 1 ? 'APPLIED' : 'CHECK INPUT',
  );
}

HelpLiveData? _deratingLive(Map<String, Object?> values) {
  final factor = _number(values, 'deratingFactor');
  final base = _number(values, 'baseAmpacityA');
  final runs = _number(values, 'parallelRuns') ?? 1;
  final actual = _number(values, 'deratedAmpacityA');
  if (factor == null) {
    return null;
  }
  final calculated = base == null ? null : base * factor * runs;
  return HelpLiveData(
    summary: 'The active total correction factor is applied transparently to the selected reference ampacity.',
    substitution: base == null
        ? 'Ctotal = ${_fmt(factor)}'
        : 'Iz = Itab × Ctotal × n\nIz = ${_fmt(base)} A × ${_fmt(factor)} × ${_fmt(runs, digits: 0)}\nIz = ${_fmt(actual ?? calculated!)} A',
    metrics: [
      HelpLiveMetric(label: 'Ctotal', value: _fmt(factor)),
      if (base != null) HelpLiveMetric(label: 'Itab', value: '${_fmt(base)} A'),
      if (calculated != null)
        HelpLiveMetric(label: 'Iz', value: '${_fmt(actual ?? calculated)} A'),
    ],
    status: factor > 0 && factor <= 1 ? 'APPLIED' : 'CHECK INPUT',
  );
}

HelpLiveData? _vcbLive(Map<String, Object?> values) {
  final fault = _number(values, 'mvFaultCurrentKa');
  final duration = _number(values, 'mvFaultDurationS');
  final voltage = _number(values, 'vcbRatedVoltageKv');
  final current = _number(values, 'vcbRatedCurrentA');
  final breaking = _number(values, 'vcbBreakingCurrentKa');
  final loadCurrent = _number(values, 'primaryCurrentA');
  if ([fault, duration, voltage, current, breaking, loadCurrent]
      .every((value) => value == null)) {
    return null;
  }
  final status = fault != null && breaking != null && breaking < fault
      ? 'FAIL'
      : 'VERIFY';
  return HelpLiveData(
    summary: 'The current VCB envelope is checked against voltage class, transformer current and MV fault duty.',
    substitution: 'Required: Ur ≥ Um, Ir ≥ Iload, Ibreak ≥ Ik,max\nUm / selected Ur = ${_displayNumber(values, 'primaryKv', 'kV')} / ${_displayNumber(values, 'vcbRatedVoltageKv', 'kV')}\nIload / selected Ir = ${_displayNumber(values, 'primaryCurrentA', 'A')} / ${_displayNumber(values, 'vcbRatedCurrentA', 'A')}\nIk,max / selected Ibreak = ${_displayNumber(values, 'mvFaultCurrentKa', 'kA')} / ${_displayNumber(values, 'vcbBreakingCurrentKa', 'kA')}\nDuration = ${_displayNumber(values, 'mvFaultDurationS', 's')}',
    metrics: [
      if (voltage != null)
        HelpLiveMetric(label: 'VCB voltage', value: '${_fmt(voltage)} kV'),
      if (current != null)
        HelpLiveMetric(label: 'VCB current', value: '${_fmt(current)} A'),
      if (breaking != null)
        HelpLiveMetric(label: 'VCB breaking', value: '${_fmt(breaking)} kA'),
    ],
    notes: const [
      'Verify the exact panel/VCB rated voltage, normal current, breaking current, making current and short-time withstand at the service voltage.',
    ],
    status: status,
  );
}

HelpLiveData? _fuseLive(Map<String, Object?> values) {
  final primaryCurrent = _number(values, 'primaryCurrentA');
  final fuse = _number(values, 'fuseCurrentA');
  if (primaryCurrent == null && fuse == null) {
    return null;
  }
  final multiple = primaryCurrent != null && primaryCurrent > 0 && fuse != null
      ? fuse / primaryCurrent
      : null;
  return HelpLiveData(
    summary: 'The displayed fuse rating is only a current-envelope starting point before curve coordination.',
    substitution: 'Iprimary = ${_displayNumber(values, 'primaryCurrentA', 'A')}\nSelected starting fuse = ${_displayNumber(values, 'fuseCurrentA', 'A')}${multiple == null ? '' : '\nRating multiple = ${_fmt(fuse!)} ÷ ${_fmt(primaryCurrent!)} = ${_fmt(multiple)} × Iprimary'}',
    metrics: [
      if (primaryCurrent != null)
        HelpLiveMetric(label: 'Iprimary', value: '${_fmt(primaryCurrent)} A'),
      if (fuse != null)
        HelpLiveMetric(label: 'Fuse start', value: '${_fmt(fuse)} A'),
    ],
    notes: const [
      'Final selection requires transformer inrush withstand, low-current interruption, fault clearing, striker compatibility and manufacturer coordination tables.',
    ],
    status: 'VERIFY',
  );
}

HelpLiveData? _ctLive(Map<String, Object?> values) {
  final current = _number(values, 'primaryCurrentA');
  final ctPrimary = _number(values, 'ctPrimaryA');
  final ratio = _text(values, 'ctRatio');
  final target = _number(values, 'ctTargetUtilisation') ?? 0.8;
  if (current == null && ctPrimary == null && ratio == null) {
    return null;
  }
  final required = current == null ? null : current / target;
  return HelpLiveData(
    summary: 'The protection CT primary ratio is selected so normal current remains below the profile utilisation target.',
    substitution: 'CT primary required ≥ Iload ÷ target utilisation\nRequired ≥ ${_displayNumber(values, 'primaryCurrentA', 'A')} ÷ ${_fmt(target)}${required == null ? '' : '\nRequired ≥ ${_fmt(required)} A'}\nSelected ratio = ${ratio ?? (ctPrimary == null ? 'Not assessed' : '${_fmt(ctPrimary)} / 1 A')}',
    metrics: [
      if (current != null)
        HelpLiveMetric(label: 'Iload', value: '${_fmt(current)} A'),
      if (required != null)
        HelpLiveMetric(label: 'Required primary', value: '${_fmt(required)} A'),
      if (ratio != null) HelpLiveMetric(label: 'Selected CT', value: ratio),
    ],
    notes: const [
      'Ratio alone is insufficient. Verify class, burden, ALF/knee point, lead resistance and saturation for each protection function.',
    ],
    status: 'VERIFY',
  );
}

HelpLiveData? _relayLive(Map<String, Object?> values) {
  final phase = _number(values, 'phaseOvercurrentPickupA');
  final earth = _number(values, 'earthFaultPickupA');
  final highSet = _number(values, 'highSetPickupA');
  final primary = _number(values, 'primaryCurrentA');
  if ([phase, earth, highSet, primary].every((value) => value == null)) {
    return null;
  }
  return HelpLiveData(
    summary: 'The displayed relay pickups are transparent starting points, not a final coordinated setting schedule.',
    substitution: '51 pickup start ≈ 1.20 × Iprimary\n51 = ${_displayNumber(values, 'phaseOvercurrentPickupA', 'A')}\nEarth-fault start = ${_displayNumber(values, 'earthFaultPickupA', 'A')}\nHigh-set start = ${_displayNumber(values, 'highSetPickupA', 'A', fallback: 'Not recommended')}',
    metrics: [
      if (phase != null) HelpLiveMetric(label: '51', value: '${_fmt(phase)} A'),
      if (earth != null)
        HelpLiveMetric(label: '50N/51N', value: '${_fmt(earth)} A'),
      if (highSet != null)
        HelpLiveMetric(label: '50 high-set', value: '${_fmt(highSet)} A'),
    ],
    notes: const [
      'Complete minimum/maximum fault, transformer inrush, CT saturation, grading margin, curve family and breaker operating-time studies.',
    ],
    status: 'VERIFY',
  );
}

HelpLiveData? _acbLive(Map<String, Object?> values) {
  final secondary = _number(values, 'secondaryCurrentA');
  final fault = _number(values, 'calculatedLvFaultKa');
  final frame = _number(values, 'acbFrameA');
  final sensor = _number(values, 'acbSensorA');
  final breaking = _number(values, 'acbBreakingCurrentKa');
  final shortTime = _number(values, 'acbShortTimeWithstandKa');
  if ([secondary, fault, frame, sensor, breaking, shortTime]
      .every((value) => value == null)) {
    return null;
  }
  final passCurrent = secondary == null || frame == null || frame >= secondary;
  final passFault = fault == null || breaking == null || breaking >= fault;
  return HelpLiveData(
    summary: 'The current ACB frame and fault-duty envelope is checked against transformer LV current and prospective fault current.',
    substitution: 'Required: In ≥ ILV and Icu ≥ Ik\nILV = ${_displayNumber(values, 'secondaryCurrentA', 'A')}\nFrame / sensor = ${_displayNumber(values, 'acbFrameA', 'A')} / ${_displayNumber(values, 'acbSensorA', 'A')}\nIk = ${_displayNumber(values, 'calculatedLvFaultKa', 'kA')}\nIcu = ${_displayNumber(values, 'acbBreakingCurrentKa', 'kA')}\nIcw = ${_displayNumber(values, 'acbShortTimeWithstandKa', 'kA')}',
    metrics: [
      if (frame != null) HelpLiveMetric(label: 'Frame', value: '${_fmt(frame)} A'),
      if (breaking != null)
        HelpLiveMetric(label: 'Icu', value: '${_fmt(breaking)} kA'),
      if (shortTime != null)
        HelpLiveMetric(label: 'Icw', value: '${_fmt(shortTime)} kA'),
    ],
    notes: const [
      'Verify service-voltage Icu/Ics, Icw duration, poles, neutral protection, selectivity and the exact electronic trip-unit range.',
    ],
    status: passCurrent && passFault ? 'VERIFY' : 'FAIL',
  );
}

HelpLiveData? _acbLsigLive(Map<String, Object?> values) {
  final longTime = _number(values, 'longTimePickupA');
  final shortTime = _number(values, 'shortTimePickupA');
  final shortDelay = _number(values, 'shortTimeDelayS');
  final instantaneous = _number(values, 'instantaneousPickupA');
  final ground = _number(values, 'groundFaultPickupA');
  final groundDelay = _number(values, 'groundFaultDelayS');
  if ([longTime, shortTime, shortDelay, instantaneous, ground, groundDelay]
      .every((value) => value == null)) {
    return null;
  }
  final coherent = longTime == null || shortTime == null || shortTime > longTime;
  return HelpLiveData(
    summary: 'The current LSIG values are coordination starting points checked for a coherent pickup sequence.',
    substitution: 'Required sequence: Ir < Isd < Ii, or Ii = OFF\nIr = ${_displayNumber(values, 'longTimePickupA', 'A')}\nIsd = ${_displayNumber(values, 'shortTimePickupA', 'A')} at ${_displayNumber(values, 'shortTimeDelayS', 's')}\nIi = ${_displayNumber(values, 'instantaneousPickupA', 'A', fallback: 'OFF')}\nIg = ${_displayNumber(values, 'groundFaultPickupA', 'A', fallback: 'Not selected')} at ${_displayNumber(values, 'groundFaultDelayS', 's', fallback: '—')}',
    metrics: [
      if (longTime != null) HelpLiveMetric(label: 'Ir', value: '${_fmt(longTime)} A'),
      if (shortTime != null)
        HelpLiveMetric(label: 'Isd', value: '${_fmt(shortTime)} A'),
      HelpLiveMetric(
        label: 'Ii',
        value: instantaneous == null ? 'OFF' : '${_fmt(instantaneous)} A',
      ),
      if (ground != null) HelpLiveMetric(label: 'Ig', value: '${_fmt(ground)} A'),
    ],
    notes: const [
      'Confirm transformer inrush, outgoing-device curves, minimum fault, arc-flash implications and manufacturer selectivity tables.',
    ],
    status: coherent ? 'VERIFY' : 'FAIL',
  );
}

HelpLiveData? _protectionStatusLive(Map<String, Object?> values) {
  final status = _firstText(
    values,
    const ['protectionStatus', 'overallStatus'],
  );
  final preferred = _text(values, 'preferredMvDevice');
  if (status == null && preferred == null) {
    return null;
  }
  return HelpLiveData(
    summary: 'The current status reports the numerical envelope while preserving all external verification boundaries.',
    substitution: '${preferred == null ? '' : 'Preferred MV device = $preferred\n'}Status = ${status ?? 'VERIFY'}',
    metrics: [
      if (preferred != null)
        HelpLiveMetric(label: 'MV device', value: preferred),
      if (status != null) HelpLiveMetric(label: 'Status', value: status),
    ],
    notes: const [
      'VERIFY is expected for preliminary protection outputs until exact product, utility fault data, CT performance and coordination studies are complete.',
    ],
    status: status ?? 'VERIFY',
  );
}

HelpLiveData? _resultCurrentLive(
  String label,
  Map<String, Object?> values,
) {
  final lower = label.toLowerCase();
  if (lower.contains('lv')) {
    final rating = _number(values, 'transformerRatingKva');
    final kv = _number(values, 'secondaryKv');
    final result = _number(values, 'secondaryCurrentA');
    if (rating != null && kv != null) {
      final calculated = rating / (math.sqrt(3) * kv);
      return HelpLiveData(
        summary: 'The current is calculated from the selected transformer rating and LV line voltage.',
        substitution: 'I = S ÷ (√3 × VLL)\nI = ${_fmt(rating)} kVA ÷ (√3 × ${_fmt(kv)} kV)\nI = ${_fmt(result ?? calculated)} A',
        metrics: [
          HelpLiveMetric(label: 'S', value: '${_fmt(rating)} kVA'),
          HelpLiveMetric(label: 'I', value: '${_fmt(result ?? calculated)} A'),
        ],
        status: 'CALCULATED',
      );
    }
  }
  final kva = _firstNumber(
    values,
    const ['loadKva', 'transformerRatingKva', 'designDemandKva'],
  );
  final kv = _firstNumber(values, const ['systemKv', 'primaryKv']);
  final result = _firstNumber(
    values,
    const ['designCurrentA', 'primaryCurrentA'],
  );
  if (kva == null || kv == null) {
    return null;
  }
  final calculated = kva / (math.sqrt(3) * kv);
  return HelpLiveData(
    summary: 'The active three-phase current trace uses apparent power and line-to-line voltage.',
    substitution: 'I = S ÷ (√3 × VLL)\nI = ${_fmt(kva)} kVA ÷ (√3 × ${_fmt(kv)} kV)\nI = ${_fmt(result ?? calculated)} A',
    metrics: [
      HelpLiveMetric(label: 'S', value: '${_fmt(kva)} kVA'),
      HelpLiveMetric(label: 'VLL', value: '${_fmt(kv)} kV'),
      HelpLiveMetric(label: 'I', value: '${_fmt(result ?? calculated)} A'),
    ],
    status: 'CALCULATED',
  );
}

HelpLiveData? _resultLoadingLive(
  String label,
  Map<String, Object?> values,
) {
  if (label.toLowerCase().contains('cable')) {
    final current = _number(values, 'designCurrentA');
    final ampacity = _number(values, 'deratedAmpacityA');
    final loading = _number(values, 'loadingPercent');
    if (current == null || ampacity == null || ampacity <= 0) {
      return null;
    }
    final calculated = current / ampacity * 100;
    return HelpLiveData(
      summary: 'Cable loading compares design current with total derated ampacity.',
      substitution: 'Loading% = Idesign ÷ Iz × 100\nLoading% = ${_fmt(current)} ÷ ${_fmt(ampacity)} × 100\nLoading% = ${_fmt(loading ?? calculated)}%',
      metrics: [
        HelpLiveMetric(label: 'Idesign', value: '${_fmt(current)} A'),
        HelpLiveMetric(label: 'Iz', value: '${_fmt(ampacity)} A'),
        HelpLiveMetric(label: 'Loading', value: '${_fmt(loading ?? calculated)} %'),
      ],
      status: (loading ?? calculated) <= 100 ? 'PASS' : 'FAIL',
    );
  }
  final demand = _number(values, 'designDemandKva');
  final rating = _number(values, 'transformerRatingKva');
  final units = _number(values, 'numberOfUnits');
  if (demand == null || rating == null || units == null || units <= 0) {
    return null;
  }
  final outage = label.toLowerCase().contains('outage');
  final activeUnits = outage ? math.max(units - 1, 1.0) : units;
  final calculated = demand / (rating * activeUnits) * 100;
  final actual = outage
      ? _number(values, 'outageLoadingPercent')
      : _number(values, 'normalLoadingPercent');
  return HelpLiveData(
    summary: outage
        ? 'Outage loading checks the design demand against the remaining transformer capacity.'
        : 'Normal loading checks the design demand against total installed transformer capacity.',
    substitution: 'Loading% = Sdesign ÷ (Srated × Nactive) × 100\nLoading% = ${_fmt(demand)} ÷ (${_fmt(rating)} × ${_fmt(activeUnits, digits: 0)}) × 100\nLoading% = ${_fmt(actual ?? calculated)}%',
    metrics: [
      HelpLiveMetric(label: 'Sdesign', value: '${_fmt(demand)} kVA'),
      HelpLiveMetric(label: 'Active units', value: _fmt(activeUnits, digits: 0)),
      HelpLiveMetric(label: 'Loading', value: '${_fmt(actual ?? calculated)} %'),
    ],
    status: (actual ?? calculated) <= 100 ? 'PASS' : 'FAIL',
  );
}

HelpLiveData? _cableLossLive(Map<String, Object?> values) {
  final current = _number(values, 'designCurrentA');
  final runs = _number(values, 'parallelRuns');
  final resistance = _number(values, 'resistanceOhmPerKm');
  final length = _number(values, 'lengthM');
  final actual = _number(values, 'lossKw');
  if ([current, runs, resistance, length].any((value) => value == null) ||
      runs! <= 0) {
    return null;
  }
  final currentPerRun = current! / runs;
  final calculated = 3 *
      currentPerRun *
      currentPerRun *
      resistance! *
      (length! / 1000) *
      runs /
      1000;
  return HelpLiveData(
    summary: 'The displayed conductor loss uses three-phase I²R loss at the selected cable resistance.',
    substitution: 'Ploss = 3 × Irun² × R × Lkm × n ÷ 1000\nPloss = 3 × ${_fmt(currentPerRun)}² × ${_fmt(resistance)} × ${_fmt(length / 1000)} × ${_fmt(runs, digits: 0)} ÷ 1000\nPloss = ${_fmt(actual ?? calculated)} kW',
    metrics: [
      HelpLiveMetric(label: 'Irun', value: '${_fmt(currentPerRun)} A'),
      HelpLiveMetric(label: 'R', value: '${_fmt(resistance)} Ω/km'),
      HelpLiveMetric(label: 'Loss', value: '${_fmt(actual ?? calculated)} kW'),
    ],
    status: 'CALCULATED',
  );
}

HelpLiveData? _transformerLossLive(Map<String, Object?> values) {
  final noLoad = _number(values, 'noLoadLossKw');
  final loadLoss = _number(values, 'loadLossKw');
  final demand = _number(values, 'designDemandKva');
  final rating = _number(values, 'transformerRatingKva');
  final units = _number(values, 'numberOfUnits');
  final actual = _number(values, 'totalLossKw');
  if ([noLoad, loadLoss, demand, rating, units].any((value) => value == null) ||
      rating! <= 0 ||
      units! <= 0) {
    return null;
  }
  final loadFraction = demand! / (rating * units);
  final calculated = noLoad! * units + loadLoss! * loadFraction * loadFraction * units;
  return HelpLiveData(
    summary: 'Total transformer loss combines no-load loss and load loss scaled by the square of load fraction.',
    substitution: 'Ptotal = P0 × N + Pk × x² × N\nx = Sdesign ÷ (Srated × N) = ${_fmt(loadFraction)}\nPtotal = ${_fmt(noLoad)} × ${_fmt(units, digits: 0)} + ${_fmt(loadLoss)} × ${_fmt(loadFraction)}² × ${_fmt(units, digits: 0)}\nPtotal = ${_fmt(actual ?? calculated)} kW',
    metrics: [
      HelpLiveMetric(label: 'P0 / unit', value: '${_fmt(noLoad)} kW'),
      HelpLiveMetric(label: 'Pk / unit', value: '${_fmt(loadLoss)} kW'),
      HelpLiveMetric(label: 'Total loss', value: '${_fmt(actual ?? calculated)} kW'),
    ],
    status: 'CALCULATED',
  );
}

HelpLiveData? _transformerEfficiencyLive(Map<String, Object?> values) {
  final demand = _number(values, 'designDemandKva');
  final pf = _number(values, 'powerFactor');
  final loss = _number(values, 'totalLossKw');
  final actual = _number(values, 'efficiencyPercent');
  if (demand == null || pf == null || loss == null) {
    return null;
  }
  final output = demand * pf;
  final calculated = output / (output + loss) * 100;
  return HelpLiveData(
    summary: 'Approximate operating efficiency compares active output power with output plus calculated losses.',
    substitution: 'η = Pout ÷ (Pout + Ploss) × 100\nPout = ${_fmt(demand)} kVA × ${_fmt(pf)} = ${_fmt(output)} kW\nη = ${_fmt(output)} ÷ (${_fmt(output)} + ${_fmt(loss)}) × 100\nη = ${_fmt(actual ?? calculated)}%',
    metrics: [
      HelpLiveMetric(label: 'Pout', value: '${_fmt(output)} kW'),
      HelpLiveMetric(label: 'Ploss', value: '${_fmt(loss)} kW'),
      HelpLiveMetric(label: 'η', value: '${_fmt(actual ?? calculated)} %'),
    ],
    status: 'PRELIMINARY',
  );
}

HelpLiveData? _transformerRegulationLive(Map<String, Object?> values) {
  final loadLoss = _number(values, 'loadLossKw');
  final rating = _number(values, 'transformerRatingKva');
  final impedance = _number(values, 'impedancePercent');
  final pf = _number(values, 'powerFactor');
  final actual = _number(values, 'approxRegulationPercent');
  if ([loadLoss, rating, impedance, pf].any((value) => value == null) ||
      rating! <= 0) {
    return null;
  }
  final resistancePercent = loadLoss! / rating * 100;
  final reactancePercent = math.sqrt(math.max(
    0,
    impedance! * impedance - resistancePercent * resistancePercent,
  ));
  final sinPhi = math.sqrt(math.max(0, 1 - pf! * pf));
  final calculated = resistancePercent * pf + reactancePercent * sinPhi;
  return HelpLiveData(
    summary: 'Approximate regulation resolves impedance into resistive and reactive components using the selected loss reference.',
    substitution: 'R% = Pk ÷ Srated × 100 = ${_fmt(resistancePercent)}%\nX% = √(Z%² − R%²) = ${_fmt(reactancePercent)}%\nReg% ≈ R% × PF + X% × sinφ\nReg% ≈ ${_fmt(resistancePercent)} × ${_fmt(pf)} + ${_fmt(reactancePercent)} × ${_fmt(sinPhi)}\nReg% ≈ ${_fmt(actual ?? calculated)}%',
    metrics: [
      HelpLiveMetric(label: 'R%', value: '${_fmt(resistancePercent)} %'),
      HelpLiveMetric(label: 'X%', value: '${_fmt(reactancePercent)} %'),
      HelpLiveMetric(label: 'Regulation', value: '${_fmt(actual ?? calculated)} %'),
    ],
    status: 'PRELIMINARY',
  );
}

double? _number(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value is num) {
    final result = value.toDouble();
    return result.isFinite ? result : null;
  }
  if (value is String) {
    final result = double.tryParse(value.trim());
    return result != null && result.isFinite ? result : null;
  }
  return null;
}

double? _firstNumber(Map<String, Object?> values, List<String> keys) {
  for (final key in keys) {
    final value = _number(values, key);
    if (value != null) {
      return value;
    }
  }
  return null;
}

String? _text(Map<String, Object?> values, String key) {
  final value = values[key];
  if (value == null) {
    return null;
  }
  final text = value.toString().trim();
  return text.isEmpty ? null : text;
}

String? _firstText(Map<String, Object?> values, List<String> keys) {
  for (final key in keys) {
    final value = _text(values, key);
    if (value != null) {
      return value;
    }
  }
  return null;
}

String _fmt(double value, {int? digits}) {
  if (!value.isFinite) {
    return 'Not assessed';
  }
  final resolvedDigits = digits ??
      (value.abs() >= 1000
          ? 0
          : value.abs() >= 100
              ? 1
              : value.abs() >= 10
                  ? 2
                  : 3);
  var text = value.toStringAsFixed(resolvedDigits);
  if (text.contains('.')) {
    text = text.replaceFirst(RegExp(r'0+$'), '').replaceFirst(RegExp(r'\.$'), '');
  }
  return text;
}

String _displayNumber(
  Map<String, Object?> values,
  String key,
  String unit, {
  String fallback = 'Not assessed',
}) {
  final value = _number(values, key);
  return value == null ? fallback : '${_fmt(value)} $unit';
}
