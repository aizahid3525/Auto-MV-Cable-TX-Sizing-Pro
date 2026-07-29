import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data_repository.dart';
import '../widgets/common_widgets.dart';

class DashboardDatabaseFilter {
  const DashboardDatabaseFilter({
    required this.tabIndex,
    required this.group,
    required this.label,
  });

  final int tabIndex;
  final String group;
  final String label;
}

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({
    super.key,
    required this.onOpenPage,
    required this.onOpenDatabase,
  });

  final ValueChanged<int> onOpenPage;
  final ValueChanged<DashboardDatabaseFilter> onOpenDatabase;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool _workflowsExpanded = true;

  @override
  Widget build(BuildContext context) {
    final repo = EngineeringRepository.instance;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _ModernHeroCard(),
          const SizedBox(height: 18),
          _ExpandableWorkflowCard(
            expanded: _workflowsExpanded,
            onToggle: () => setState(() => _workflowsExpanded = !_workflowsExpanded),
            onOpenPage: widget.onOpenPage,
          ),
          const SizedBox(height: 18),
          _DatabaseReferenceCard(
            cableCount: repo.cables.length,
            transformerCount: repo.transformers.length,
            protectionCount: repo.protectionDevices.length,
            sourceCount: repo.standards.length,
            onOpenDatabase: () => widget.onOpenPage(5),
          ),
          const SizedBox(height: 18),
          _InteractiveCoverageCard(
            repo: repo,
            onOpenSelected: widget.onOpenDatabase,
          ),
          const SizedBox(height: 18),
          const _EngineeringTipsSection(),
          const SizedBox(height: 18),
          SectionCard(
            title: 'Professional-use safeguard',
            subtitle: 'Preliminary engineering design aid',
            icon: Icons.verified_user_outlined,
            trailing: const HelperButton(
              topicId: 'data_status',
              information: true,
            ),
            child: Text(
              'Final issue requires verification of exact manufacturer models and type-tested ratings, utility fault levels, CT performance, protection curves and grading, ACB discrimination, transformer inrush, cable screen bonding, applicable TNB/ST requirements and project-specific engineering studies.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModernHeroCard extends StatelessWidget {
  const _ModernHeroCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final divider = theme.colorScheme.outlineVariant;
    const features = <_HeroFeatureData>[
      _HeroFeatureData(Icons.cable_outlined, 'MV Cable', 'IEC sizing'),
      _HeroFeatureData(Icons.electrical_services_outlined, 'Transformer', 'Demand & loss'),
      _HeroFeatureData(Icons.security_outlined, 'Protection', 'VCB & ACB'),
      _HeroFeatureData(Icons.account_tree_outlined, 'Coordination', 'System workflow'),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: theme.colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.22)
                : const Color(0xFF0F172A).withValues(alpha: 0.07),
            blurRadius: 22,
            offset: const Offset(0, 9),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 74,
                height: 74,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF0B1220) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFBFE8F2)),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.cyan.withValues(alpha: 0.16),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(17),
                  child: Image.asset(
                    'assets/icons/app_icon_512.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto MV Cable & TX Sizing Pro',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w900,
                        height: 1.05,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text.rich(
                      TextSpan(
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                        children: const [
                          TextSpan(text: 'MV engineering app by '),
                          TextSpan(
                            text: 'AiZahid',
                            style: TextStyle(
                              color: AppTheme.blue,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(height: 1, color: divider),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final compact = constraints.maxWidth < 430;
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var index = 0; index < features.length; index++) ...[
                    Expanded(
                      child: _HeroFeature(
                        data: features[index],
                        compact: compact,
                      ),
                    ),
                    if (index != features.length - 1)
                      Container(
                        width: 1,
                        height: compact ? 70 : 64,
                        margin: EdgeInsets.symmetric(horizontal: compact ? 2 : 6),
                        color: divider,
                      ),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _HeroFeatureData {
  const _HeroFeatureData(this.icon, this.title, this.subtitle);

  final IconData icon;
  final String title;
  final String subtitle;
}

class _HeroFeature extends StatelessWidget {
  const _HeroFeature({required this.data, required this.compact});

  final _HeroFeatureData data;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(data.icon, color: AppTheme.blue, size: compact ? 23 : 26),
        const SizedBox(height: 6),
        Text(
          data.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            fontSize: compact ? 11.5 : 12.5,
            height: 1.05,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          data.subtitle,
          textAlign: TextAlign.center,
          maxLines: 2,
          style: TextStyle(
            fontSize: compact ? 10.5 : 11.5,
            height: 1.05,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _ExpandableWorkflowCard extends StatelessWidget {
  const _ExpandableWorkflowCard({
    required this.expanded,
    required this.onToggle,
    required this.onOpenPage,
  });

  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<int> onOpenPage;

  @override
  Widget build(BuildContext context) {
    final cards = <Widget>[
      _WorkflowCard(
        icon: Icons.cable_outlined,
        title: 'MV Cable Design',
        description: 'Ampacity, voltage drop, fault withstand, charging current and losses.',
        onTap: () => onOpenPage(1),
      ),
      _WorkflowCard(
        icon: Icons.electrical_services_outlined,
        title: 'Transformer Design',
        description: 'Demand, unit selection, loading, losses, regulation and preliminary fault duty.',
        onTap: () => onOpenPage(2),
      ),
      _WorkflowCard(
        icon: Icons.account_tree_outlined,
        title: 'Cable + TX Coordination',
        description: 'Size the transformer and MV feeder as one coordinated preliminary design.',
        onTap: () => onOpenPage(3),
      ),
      _WorkflowCard(
        icon: Icons.security_outlined,
        title: 'Protection & Switchgear',
        description: 'VCB, switch-fuse, ACB, CT, relay and transformer-protection screening.',
        onTap: () => onOpenPage(4),
      ),
      _WorkflowCard(
        icon: Icons.storage_outlined,
        title: 'Engineering Database',
        description: 'Filter MV cable, transformer and protection families with source status.',
        onTap: () => onOpenPage(5),
      ),
      _WorkflowCard(
        icon: Icons.menu_book_outlined,
        title: 'Standards & Sources',
        description: 'IEC, Malaysian Standards, ST, TNB and supplementary IEEE references.',
        onTap: () => onOpenPage(6),
      ),
    ];

    return SectionCard(
      title: 'Engineering workflows',
      subtitle: 'Six coordinated design and reference destinations',
      icon: Icons.handyman_outlined,
      trailing: IconButton.filledTonal(
        tooltip: expanded ? 'Hide workflows' : 'Show workflows',
        onPressed: onToggle,
        icon: AnimatedRotation(
          turns: expanded ? 0.5 : 0,
          duration: const Duration(milliseconds: 180),
          child: const Icon(Icons.expand_more_rounded),
        ),
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        child: expanded
            ? ResponsiveGrid(
                minItemWidth: 145,
                children: cards,
              )
            : Text(
                'Open the workflow list when needed. The dashboard remains compact by default.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
              ),
      ),
    );
  }
}

class _WorkflowCard extends StatelessWidget {
  const _WorkflowCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppTheme.cyan, AppTheme.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
              ),
              child: Icon(icon, color: Colors.white, size: 23),
            ),
            const SizedBox(height: 11),
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w900,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'Open',
                  style: TextStyle(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(width: 3),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: theme.colorScheme.primary,
                  size: 18,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DatabaseReferenceCard extends StatelessWidget {
  const _DatabaseReferenceCard({
    required this.cableCount,
    required this.transformerCount,
    required this.protectionCount,
    required this.sourceCount,
    required this.onOpenDatabase,
  });

  final int cableCount;
  final int transformerCount;
  final int protectionCount;
  final int sourceCount;
  final VoidCallback onOpenDatabase;

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Engineering Database & Reference',
      subtitle: 'Controlled MV cable, transformer, protection and standards coverage',
      icon: Icons.inventory_2_outlined,
      child: ResponsiveGrid(
        minItemWidth: 145,
        children: [
          _MetricCard(
            icon: Icons.cable_outlined,
            value: cableCount,
            label: 'MV cable records',
            color: const Color(0xFF2563EB),
            onTap: onOpenDatabase,
          ),
          _MetricCard(
            icon: Icons.electrical_services_outlined,
            value: transformerCount,
            label: 'Transformer records',
            color: const Color(0xFF059669),
            onTap: onOpenDatabase,
          ),
          _MetricCard(
            icon: Icons.security_outlined,
            value: protectionCount,
            label: 'Protection records',
            color: const Color(0xFF7C3AED),
            onTap: onOpenDatabase,
          ),
          _MetricCard(
            icon: Icons.menu_book_outlined,
            value: sourceCount,
            label: 'Standards entries',
            color: const Color(0xFFEA580C),
            onTap: onOpenDatabase,
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final int value;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.11),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 25),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value.toString(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      height: 1,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color),
          ],
        ),
      ),
    );
  }
}

class _CoverageEntry {
  const _CoverageEntry({
    required this.label,
    required this.value,
    required this.color,
    required this.group,
    required this.tabIndex,
  });

  final String label;
  final int value;
  final Color color;
  final String group;
  final int tabIndex;
}

class _InteractiveCoverageCard extends StatefulWidget {
  const _InteractiveCoverageCard({
    required this.repo,
    required this.onOpenSelected,
  });

  final EngineeringRepository repo;
  final ValueChanged<DashboardDatabaseFilter> onOpenSelected;

  @override
  State<_InteractiveCoverageCard> createState() => _InteractiveCoverageCardState();
}

class _InteractiveCoverageCardState extends State<_InteractiveCoverageCard> {
  int _selectedIndex = 0;
  bool _detailsExpanded = false;

  static const _outerColors = <Color>[
    Color(0xFF2563EB),
    Color(0xFF06B6D4),
    Color(0xFF7C3AED),
    Color(0xFF14B8A6),
    Color(0xFFF59E0B),
    Color(0xFFEC4899),
    Color(0xFF84CC16),
    Color(0xFFF97316),
    Color(0xFF6366F1),
    Color(0xFF0EA5E9),
  ];
  static const _innerColors = <Color>[
    Color(0xFF22C55E),
    Color(0xFFE879F9),
    Color(0xFFFB7185),
    Color(0xFF38BDF8),
  ];

  List<_CoverageEntry> get _entries {
    final cableCounts = <String, int>{};
    for (final cable in widget.repo.cables) {
      cableCounts.update(cable.family, (value) => value + 1, ifAbsent: () => 1);
    }
    final txCounts = <String, int>{};
    for (final transformer in widget.repo.transformers) {
      txCounts.update(transformer.type, (value) => value + 1, ifAbsent: () => 1);
    }
    final cableEntries = cableCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final txEntries = txCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return [
      for (var i = 0; i < cableEntries.length; i++)
        _CoverageEntry(
          label: cableEntries[i].key,
          value: cableEntries[i].value,
          color: _outerColors[i % _outerColors.length],
          group: 'MV cable family',
          tabIndex: 0,
        ),
      for (var i = 0; i < txEntries.length; i++)
        _CoverageEntry(
          label: txEntries[i].key,
          value: txEntries[i].value,
          color: _innerColors[i % _innerColors.length],
          group: 'Transformer family',
          tabIndex: 1,
        ),
    ];
  }

  void _select(int index, List<_CoverageEntry> entries) {
    if (entries.isEmpty) {
      return;
    }
    setState(() => _selectedIndex = index.clamp(0, entries.length - 1).toInt());
  }

  @override
  Widget build(BuildContext context) {
    final entries = _entries;
    final selectedIndex = entries.isEmpty
        ? 0
        : _selectedIndex.clamp(0, entries.length - 1).toInt();
    final selected = entries.isEmpty ? null : entries[selectedIndex];
    final groupTotal = selected == null
        ? 0
        : entries
            .where((entry) => entry.group == selected.group)
            .fold<int>(0, (sum, entry) => sum + entry.value);
    final percentage = selected == null || groupTotal == 0
        ? 0.0
        : selected.value / groupTotal * 100;

    return SectionCard(
      title: 'Interactive radial chart',
      subtitle: 'MV cable and transformer-family database coverage',
      icon: Icons.donut_large_rounded,
      trailing: _SelectedGroupPill(entry: selected),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Outer ring shows MV cable families and inner ring shows transformer families. Each ring is independently normalised to 100%. Tap a segment or coverage card to select it; tap the centre circle to cycle through all families.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  height: 1.42,
                ),
          ),
          const SizedBox(height: 12),
          _SelectionNote(
            selected: selected,
            groupTotal: groupTotal,
            percentage: percentage,
            cableRecords: widget.repo.cables.length,
            transformerRecords: widget.repo.transformers.length,
          ),
          const SizedBox(height: 12),
          const ResponsiveGrid(
            minItemWidth: 140,
            children: [
              _RingGuideChip(
                label: 'Outer ring: MV cable families',
                icon: Icons.circle_outlined,
              ),
              _RingGuideChip(
                label: 'Inner ring: Transformer families',
                icon: Icons.donut_large_rounded,
              ),
            ],
          ),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final size = constraints.maxWidth.clamp(285.0, 430.0).toDouble();
              return Center(
                child: SizedBox(
                  width: size,
                  child: _CoverageChart(
                    entries: entries,
                    selectedIndex: selectedIndex,
                    onSelected: (index) => _select(index, entries),
                    onNext: () => _select((selectedIndex + 1) % entries.length, entries),
                    onOpen: selected == null
                        ? null
                        : () => widget.onOpenSelected(
                              DashboardDatabaseFilter(
                                tabIndex: selected.tabIndex,
                                group: selected.group,
                                label: selected.label,
                              ),
                            ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cable & Transformer Families',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Detailed family breakdown',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                          ),
                    ),
                  ],
                ),
              ),
              IconButton.filledTonal(
                tooltip: _detailsExpanded ? 'Hide details' : 'Show details',
                onPressed: () => setState(() => _detailsExpanded = !_detailsExpanded),
                icon: AnimatedRotation(
                  turns: _detailsExpanded ? 0.5 : 0,
                  duration: const Duration(milliseconds: 180),
                  child: const Icon(Icons.expand_more_rounded),
                ),
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            child: _detailsExpanded
                ? Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: _CoverageLegend(
                      entries: entries,
                      selectedIndex: selectedIndex,
                      onSelected: (index) => _select(index, entries),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _SelectedGroupPill extends StatelessWidget {
  const _SelectedGroupPill({required this.entry});

  final _CoverageEntry? entry;

  @override
  Widget build(BuildContext context) {
    final color = entry?.color ?? AppTheme.blue;
    return Container(
      constraints: const BoxConstraints(maxWidth: 138),
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: color.withValues(alpha: 0.55)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 9,
            height: 9,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Flexible(
            child: Text(
              entry?.group ?? 'Family',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectionNote extends StatelessWidget {
  const _SelectionNote({
    required this.selected,
    required this.groupTotal,
    required this.percentage,
    required this.cableRecords,
    required this.transformerRecords,
  });

  final _CoverageEntry? selected;
  final int groupTotal;
  final double percentage;
  final int cableRecords;
  final int transformerRecords;

  @override
  Widget build(BuildContext context) {
    final text = selected == null
        ? 'No database family is available.'
        : '${selected!.group}: ${selected!.label} has ${selected!.value} records, equal to ${percentage.toStringAsFixed(1)}% of its ring. The database contains $cableRecords MV cable records and $transformerRecords transformer records.';
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFF2D76B)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.lightbulb_outline_rounded, color: Color(0xFFB86500)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color(0xFF8A430D),
                fontWeight: FontWeight.w700,
                height: 1.38,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingGuideChip extends StatelessWidget {
  const _RingGuideChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.cyanDark, size: 18),
          const SizedBox(width: 7),
          Expanded(
            child: Text(
              label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11.5,
                height: 1.12,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverageChart extends StatelessWidget {
  const _CoverageChart({
    required this.entries,
    required this.selectedIndex,
    required this.onSelected,
    required this.onNext,
    required this.onOpen,
  });

  final List<_CoverageEntry> entries;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final VoidCallback onNext;
  final VoidCallback? onOpen;

  @override
  Widget build(BuildContext context) {
    if (entries.isEmpty) {
      return const SizedBox.shrink();
    }
    final selected = entries[selectedIndex];
    final groupTotal = entries
        .where((entry) => entry.group == selected.group)
        .fold<int>(0, (sum, entry) => sum + entry.value);
    final ratio = groupTotal == 0 ? 0.0 : selected.value / groupTotal * 100;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final size = Size(constraints.maxWidth, constraints.maxHeight);
              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTapUp: (details) {
                  final index = _coverageIndexFromPosition(
                    details.localPosition,
                    size,
                    entries,
                  );
                  if (index != null) {
                    onSelected(index);
                  }
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: Size.infinite,
                      painter: _CoveragePainter(
                        entries: entries,
                        selectedIndex: selectedIndex,
                        isDark: isDark,
                      ),
                    ),
                    InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onNext,
                      child: Container(
                        width: constraints.maxWidth * 0.42,
                        height: constraints.maxWidth * 0.42,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surface,
                          shape: BoxShape.circle,
                          border: Border.all(color: selected.color, width: 2),
                          boxShadow: [
                            BoxShadow(
                              color: selected.color.withValues(alpha: 0.14),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              selected.group.toUpperCase(),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: selected.color,
                                fontSize: 10.5,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              selected.value.toString(),
                              style: const TextStyle(
                                fontSize: 28,
                                height: 1,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              selected.label,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 10.5,
                                height: 1.08,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${ratio.toStringAsFixed(1)}%',
                              style: TextStyle(
                                color: selected.color,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: onOpen,
          icon: const Icon(Icons.manage_search_rounded),
          label: Text('View ${selected.value} records'),
        ),
      ],
    );
  }
}

class _CoverageLegend extends StatelessWidget {
  const _CoverageLegend({
    required this.entries,
    required this.selectedIndex,
    required this.onSelected,
  });

  final List<_CoverageEntry> entries;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in const ['MV cable family', 'Transformer family']) ...[
          Row(
            children: [
              Icon(
                group == 'MV cable family'
                    ? Icons.cable_outlined
                    : Icons.electrical_services_outlined,
                color: AppTheme.cyanDark,
              ),
              const SizedBox(width: 8),
              Text(
                group,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const Spacer(),
              Text(
                entries.where((entry) => entry.group == group).length.toString(),
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ],
          ),
          const SizedBox(height: 9),
          ResponsiveGrid(
            minItemWidth: 140,
            children: [
              for (var index = 0; index < entries.length; index++)
                if (entries[index].group == group)
                  _LegendTile(
                    entry: entries[index],
                    selected: index == selectedIndex,
                    groupTotal: entries
                        .where((entry) => entry.group == group)
                        .fold<int>(0, (sum, entry) => sum + entry.value),
                    onTap: () => onSelected(index),
                  ),
            ],
          ),
          if (group != 'Transformer family') const Divider(height: 28),
        ],
      ],
    );
  }
}

class _LegendTile extends StatelessWidget {
  const _LegendTile({
    required this.entry,
    required this.selected,
    required this.groupTotal,
    required this.onTap,
  });

  final _CoverageEntry entry;
  final bool selected;
  final int groupTotal;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ratio = groupTotal == 0 ? 0.0 : entry.value / groupTotal;
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          color: selected
              ? entry.color.withValues(alpha: 0.09)
              : Theme.of(context).colorScheme.surfaceContainerLowest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? entry.color
                : Theme.of(context).colorScheme.outlineVariant,
            width: selected ? 1.8 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: entry.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    entry.label,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 12,
                      height: 1.08,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(width: 5),
                Text(
                  entry.value.toString(),
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
              ],
            ),
            const SizedBox(height: 7),
            ClipRRect(
              borderRadius: BorderRadius.circular(999),
              child: LinearProgressIndicator(
                value: ratio.clamp(0.0, 1.0).toDouble(),
                minHeight: 5,
                color: entry.color,
                backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${(ratio * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    fontSize: 11.5,
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded, size: 16, color: entry.color),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _CoveragePainter extends CustomPainter {
  const _CoveragePainter({
    required this.entries,
    required this.selectedIndex,
    required this.isDark,
  });

  final List<_CoverageEntry> entries;
  final int selectedIndex;
  final bool isDark;

  @override
  void paint(Canvas canvas, Size size) {
    final geometry = _RingGeometry.fromSize(size);
    final cableEntries = entries
        .where((entry) => entry.group == 'MV cable family')
        .toList();
    final transformerEntries = entries
        .where((entry) => entry.group == 'Transformer family')
        .toList();
    final cableCount = cableEntries.length;

    _paintRing(
      canvas: canvas,
      center: geometry.center,
      radius: geometry.outerRadius,
      strokeWidth: geometry.outerStroke,
      entries: cableEntries,
      selectedLocalIndex: selectedIndex < cableCount ? selectedIndex : -1,
    );
    _paintRing(
      canvas: canvas,
      center: geometry.center,
      radius: geometry.innerRadius,
      strokeWidth: geometry.innerStroke,
      entries: transformerEntries,
      selectedLocalIndex: selectedIndex >= cableCount ? selectedIndex - cableCount : -1,
    );
  }

  void _paintRing({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required double strokeWidth,
    required List<_CoverageEntry> entries,
    required int selectedLocalIndex,
  }) {
    if (entries.isEmpty) {
      return;
    }
    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = isDark ? const Color(0xFF1E293B) : const Color(0xFFE8EEF5),
    );
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.value);
    if (total <= 0) {
      return;
    }

    var angle = _startAngle;
    for (var index = 0; index < entries.length; index++) {
      final rawSweep = math.pi * 2 * entries[index].value / total;
      final gap = math.min(0.022, rawSweep * 0.20).toDouble();
      final sweep = math.max(0.001, rawSweep - gap).toDouble();
      final selected = index == selectedLocalIndex;
      if (selected) {
        canvas.drawArc(
          rect,
          angle + gap / 2,
          sweep,
          false,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = strokeWidth + 12
            ..color = entries[index].color.withValues(alpha: 0.18)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 9),
        );
      }
      canvas.drawArc(
        rect,
        angle + gap / 2,
        sweep,
        false,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = selected ? strokeWidth + 4 : strokeWidth
          ..strokeCap = StrokeCap.butt
          ..color = entries[index].color.withValues(alpha: selected ? 1 : 0.72),
      );
      angle += rawSweep;
    }
  }

  @override
  bool shouldRepaint(covariant _CoveragePainter oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.isDark != isDark ||
        oldDelegate.entries != entries;
  }
}

const double _startAngle = -math.pi / 2;

class _RingGeometry {
  const _RingGeometry({
    required this.center,
    required this.outerRadius,
    required this.innerRadius,
    required this.outerStroke,
    required this.innerStroke,
  });

  factory _RingGeometry.fromSize(Size size) {
    final shortest = math.min(size.width, size.height);
    final outerStroke = (shortest * 0.115).clamp(30.0, 44.0).toDouble();
    final innerStroke = (shortest * 0.090).clamp(27.0, 36.0).toDouble();
    final outerRadius = shortest / 2 - outerStroke / 2 - 9;
    final gap = (shortest * 0.035).clamp(10.0, 15.0).toDouble();
    final innerRadius = outerRadius - outerStroke / 2 - gap - innerStroke / 2;
    return _RingGeometry(
      center: Offset(size.width / 2, size.height / 2),
      outerRadius: outerRadius,
      innerRadius: innerRadius,
      outerStroke: outerStroke,
      innerStroke: innerStroke,
    );
  }

  final Offset center;
  final double outerRadius;
  final double innerRadius;
  final double outerStroke;
  final double innerStroke;
}

int? _coverageIndexFromPosition(
  Offset position,
  Size size,
  List<_CoverageEntry> entries,
) {
  final geometry = _RingGeometry.fromSize(size);
  final distance = (position - geometry.center).distance;
  final cables = entries
      .where((entry) => entry.group == 'MV cable family')
      .toList();
  final transformers = entries
      .where((entry) => entry.group == 'Transformer family')
      .toList();

  List<_CoverageEntry>? ring;
  var offset = 0;
  if ((distance - geometry.outerRadius).abs() <= geometry.outerStroke * 0.64) {
    ring = cables;
  } else if ((distance - geometry.innerRadius).abs() <= geometry.innerStroke * 0.64) {
    ring = transformers;
    offset = cables.length;
  }
  if (ring == null || ring.isEmpty) {
    return null;
  }

  var angle = math.atan2(
        position.dy - geometry.center.dy,
        position.dx - geometry.center.dx,
      ) -
      _startAngle;
  while (angle < 0) {
    angle += math.pi * 2;
  }
  while (angle >= math.pi * 2) {
    angle -= math.pi * 2;
  }

  final total = ring.fold<int>(0, (sum, entry) => sum + entry.value);
  var current = 0.0;
  for (var index = 0; index < ring.length; index++) {
    final rawSweep = math.pi * 2 * ring[index].value / total;
    final gap = math.min(0.022, rawSweep * 0.20).toDouble();
    if (angle >= current + gap / 2 && angle <= current + rawSweep - gap / 2) {
      return offset + index;
    }
    current += rawSweep;
  }
  return null;
}

class _EngineeringTipsSection extends StatelessWidget {
  const _EngineeringTipsSection();

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      title: 'Engineering tips',
      subtitle: 'Built into the app for site-friendly checking',
      icon: Icons.lightbulb_outline_rounded,
      child: const ResponsiveGrid(
        minItemWidth: 145,
        children: [
          _TipCard(
            icon: Icons.speed_rounded,
            title: 'Ampacity first',
            body: 'Verify design current against derated cable ampacity before checking voltage drop.',
          ),
          _TipCard(
            icon: Icons.show_chart_rounded,
            title: 'Use R + X for MV feeders',
            body: 'For long MV routes, resistance and reactance provide a more realistic voltage-drop result.',
          ),
          _TipCard(
            icon: Icons.security_outlined,
            title: 'Fault duty is location-specific',
            body: 'Use the prospective fault current at the actual switchgear or cable location.',
          ),
          _TipCard(
            icon: Icons.fact_check_outlined,
            title: 'Final issue check',
            body: 'Confirm route, bonding, earthing, protection grading and exact manufacturer data.',
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.cyan, Color(0xFF7C3AED)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: Colors.white, size: 25),
          ),
          const SizedBox(height: 13),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w900,
                  height: 1.18,
                ),
          ),
          const SizedBox(height: 7),
          Text(
            body,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                  height: 1.40,
                ),
          ),
        ],
      ),
    );
  }
}
