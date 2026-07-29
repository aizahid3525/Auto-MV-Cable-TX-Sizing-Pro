import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../data_repository.dart';
import '../widgets/common_widgets.dart';

class StandardsScreen extends StatelessWidget {
  const StandardsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = EngineeringRepository.instance;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const PageHeader(
            title: 'Standards & Sources',
            subtitle: 'Controlled IEC, Malaysia, ST, TNB and supplementary IEEE references.',
            icon: Icons.menu_book,
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Standards register',
            subtitle: '${repo.standards.length} controlled references',
            child: Column(
              children: repo.standards.map((standard) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    leading: const Icon(Icons.verified_outlined),
                    title: Text(standard.title, style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('${standard.scope}\nStatus: ${standard.status}'),
                    isThreeLine: true,
                    trailing: const Icon(Icons.open_in_new),
                    onTap: standard.url.isEmpty
                        ? null
                        : () async {
                            final uri = Uri.tryParse(standard.url);
                            if (uri != null) {
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),
          const SectionCard(
            title: 'Engineering governance',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('• IEC and Malaysian Standards provide the principal engineering framework.'),
                SizedBox(height: 6),
                Text('• Suruhanjaya Tenaga legislation and competent-person requirements remain mandatory in Malaysia.'),
                SizedBox(height: 6),
                Text('• TNB requirements govern utility interfaces, available voltages, equipment duties and supply applications.'),
                SizedBox(height: 6),
                Text('• IEEE references are supplementary and do not replace the governing IEC, Malaysian, ST, TNB or project requirements.'),
                SizedBox(height: 6),
                Text('• Proprietary standards tables are not reproduced without permission; the app uses controlled summaries and equations.'),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const SectionCard(
            title: 'About this Rev2 package',
            child: Text(
              'Auto MV Cable & TX Sizing Pro V1.1.0+2 • MVTX-CALC-V1 + MVTX-PROTECTION-V1 • Developed under the AiZahid engineering-app family. The Excel engineering master, JSON databases and Flutter source are revision controlled together.',
            ),
          ),
        ],
      ),
    );
  }
}
