import 'package:flutter/material.dart';

import '../app_theme.dart';
import '../data_repository.dart';
import '../widgets/common_widgets.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    required this.onOpenPage,
  });

  final ValueChanged<int> onOpenPage;

  @override
  Widget build(BuildContext context) {
    final repo = EngineeringRepository.instance;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.fuchsiaDark, AppTheme.fuchsiaBright],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(26),
            ),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final compact = constraints.maxWidth < 720;
                final artwork = ClipRRect(
                  borderRadius: BorderRadius.circular(22),
                  child: Image.asset(
                    'assets/icons/app_icon_512.png',
                    width: compact ? 132 : 180,
                    height: compact ? 132 : 180,
                    fit: BoxFit.contain,
                  ),
                );
                final text = Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Auto MV Cable & TX Sizing Pro',
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Medium-voltage cable, transformer and coordinated feeder design for Android and Windows.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Colors.white.withValues(alpha: 0.90),
                            ),
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _HeroPill(text: '${repo.cables.length} MV cable records'),
                          _HeroPill(text: '${repo.transformers.length} transformer records'),
                          _HeroPill(text: '${repo.helpTopics.length} helper topics'),
                          _HeroPill(text: '${repo.protectionDevices.length} protection records'),
                          const _HeroPill(text: 'MVTX-PROTECTION-V1'),
                        ],
                      ),
                    ],
                  ),
                );
                if (compact) {
                  return Column(
                    children: [artwork, const SizedBox(height: 18), Row(children: [text])],
                  );
                }
                return Row(
                  children: [artwork, const SizedBox(width: 24), text],
                );
              },
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Engineering workflows',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                ),
          ),
          const SizedBox(height: 12),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 1000
                  ? 3
                  : constraints.maxWidth >= 620
                      ? 2
                      : 1;
              final cards = [
                _WorkflowCard(
                  icon: Icons.cable,
                  title: 'MV Cable Design',
                  description: 'Ampacity, voltage drop, short-circuit withstand, charging current and losses.',
                  onTap: () => onOpenPage(1),
                ),
                _WorkflowCard(
                  icon: Icons.electrical_services,
                  title: 'Transformer Design',
                  description: 'Demand, unit selection, loading, losses, regulation and preliminary fault duty.',
                  onTap: () => onOpenPage(2),
                ),
                _WorkflowCard(
                  icon: Icons.account_tree,
                  title: 'Cable + TX Coordination',
                  description: 'Size the transformer and MV feeder as one coordinated preliminary design.',
                  onTap: () => onOpenPage(3),
                ),
                _WorkflowCard(
                  icon: Icons.security,
                  title: 'Protection & Switchgear',
                  description: 'Automatic VCB, switch-fuse, ACB, CT, relay and transformer internal-protection screening.',
                  onTap: () => onOpenPage(4),
                ),
                _WorkflowCard(
                  icon: Icons.storage,
                  title: 'Engineering Database',
                  description: 'Filter cable, transformer and protection device families with source status.',
                  onTap: () => onOpenPage(5),
                ),
                _WorkflowCard(
                  icon: Icons.menu_book,
                  title: 'Standards & Sources',
                  description: 'IEC, Malaysian Standards, ST, TNB and supplementary IEEE references.',
                  onTap: () => onOpenPage(6),
                ),
              ];
              return GridView.count(
                crossAxisCount: columns,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: columns == 1 ? 2.7 : 1.65,
                children: cards,
              );
            },
          ),
          const SizedBox(height: 18),
          SectionCard(
            title: 'Professional-use safeguard',
            subtitle: 'Preliminary engineering design aid',
            child: Text(
              'Final issue requires verification of exact manufacturer models and type-tested ratings, utility fault levels, CT performance, protection curves and grading, ACB discrimination, transformer inrush, cable screen bonding, applicable TNB/ST requirements and project-specific engineering studies.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroPill extends StatelessWidget {
  const _HeroPill({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
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
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colors.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.fuchsia.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: AppTheme.fuchsia),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                  ),
            ),
            const SizedBox(height: 6),
            Expanded(child: Text(description)),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('Open', style: TextStyle(color: colors.primary, fontWeight: FontWeight.w700)),
                const SizedBox(width: 4),
                Icon(Icons.arrow_forward, size: 18, color: colors.primary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
