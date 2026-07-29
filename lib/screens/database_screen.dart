import 'package:flutter/material.dart';

import '../data_repository.dart';
import '../models.dart';
import '../protection_models.dart';
import '../widgets/common_widgets.dart';

class DatabaseFilterTransfer {
  const DatabaseFilterTransfer({
    required this.tabIndex,
    required this.group,
    required this.label,
  });

  final int tabIndex;
  final String group;
  final String label;
}

class DatabaseScreen extends StatefulWidget {
  const DatabaseScreen({super.key, this.initialTransfer});

  final DatabaseFilterTransfer? initialTransfer;

  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen>
    with SingleTickerProviderStateMixin {
  final _repo = EngineeringRepository.instance;
  late final TabController _tabController;
  final _search = TextEditingController();

  String _cableBrand = 'All brands';
  String _cableFamily = 'All families';
  String _cableCore = 'All cores';
  String _cableMaterial = 'All materials';
  String _txBrand = 'All brands';
  String _txType = 'All types';
  String _protectionBrand = 'All brands';
  String _protectionCategory = 'All categories';

  @override
  void initState() {
    super.initState();
    final initialTab = (widget.initialTransfer?.tabIndex ?? 0).clamp(0, 2).toInt();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: initialTab,
    );
    final transfer = widget.initialTransfer;
    if (transfer != null) {
      if (transfer.group == 'MV cable family' &&
          _repo.cableFamilies.contains(transfer.label)) {
        _cableFamily = transfer.label;
      }
      if (transfer.group == 'Transformer family' &&
          _repo.transformerTypes.contains(transfer.label)) {
        _txType = transfer.label;
      }
    }
    _search.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return EngineeringHelpScope(
      values: <String, Object?>{
        'searchQuery': _search.text.trim(),
        'cableRecordCount': _repo.cables.length,
        'transformerRecordCount': _repo.transformers.length,
        'protectionRecordCount': _repo.protectionDevices.length,
        'dataStatus': 'Controlled database loaded',
      },
      child: Column(
        children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(18, 18, 18, 0),
          child: PageHeader(
            title: 'Smart Engineering Database',
            subtitle:
                'Search controlled MV cable, transformer and protection records with source status.',
            icon: Icons.manage_search_rounded,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
          child: LabeledField(
            label: 'Search database',
            topicId: 'database_search',
            child: TextField(
              controller: _search,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search_rounded),
                hintText: 'Brand, family, type, rating or record ID',
              ),
            ),
          ),
        ),
        TabBar(
          controller: _tabController,
          isScrollable: MediaQuery.sizeOf(context).width < 430,
          tabs: const [
            Tab(text: 'MV cables', icon: Icon(Icons.cable_outlined)),
            Tab(
              text: 'Transformers',
              icon: Icon(Icons.electrical_services_outlined),
            ),
            Tab(text: 'Protection', icon: Icon(Icons.security_outlined)),
          ],
        ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _cableTab(),
                _transformerTab(),
                _protectionTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cableTab() {
    final query = _search.text.trim().toLowerCase();
    final records = _repo.cables.where((record) {
      final brand = _cableBrand == 'All brands' || record.brand == _cableBrand;
      final family =
          _cableFamily == 'All families' || record.family == _cableFamily;
      final cores = _cableCore == 'All cores' || record.cores == _cableCore;
      final material = _cableMaterial == 'All materials' ||
          record.conductor == _cableMaterial;
      final haystack =
          '${record.id} ${record.brand} ${record.family} ${record.cores} '
          '${record.conductor} ${record.sizeMm2} ${record.voltageDesignation}'
              .toLowerCase();
      return brand &&
          family &&
          cores &&
          material &&
          (query.isEmpty || haystack.contains(query));
    }).toList();

    return _databaseTab(
      scrollKey: 'mv-cable-database',
      helpValues: <String, Object?>{
        'selectedDatabase': 'MV cables',
        'searchQuery': _search.text.trim(),
        'selectedBrand': _cableBrand,
        'selectedFamily': _cableFamily,
        'selectedCores': _cableCore,
        'selectedMaterial': _cableMaterial,
        'matchedRecordCount': records.length,
        'dataStatus': '${records.length} MV cable records matched',
      },
      filters: [
        _filterField(
          label: 'Brand',
          topicId: 'brand_filter',
          value: _cableBrand,
          values: ['All brands', ..._repo.cableBrands],
          onChanged: (value) => setState(() => _cableBrand = value),
        ),
        _filterField(
          label: 'Cable family',
          topicId: 'cable_family',
          value: _cableFamily,
          values: ['All families', ..._repo.cableFamilies],
          onChanged: (value) => setState(() => _cableFamily = value),
        ),
        _filterField(
          label: 'Number of cores',
          topicId: 'number_of_cores',
          value: _cableCore,
          values: ['All cores', ..._repo.cableCores],
          onChanged: (value) => setState(() => _cableCore = value),
        ),
        _filterField(
          label: 'Conductor material',
          topicId: 'conductor_material',
          value: _cableMaterial,
          values: ['All materials', ..._repo.conductorMaterials],
          onChanged: (value) => setState(() => _cableMaterial = value),
        ),
        _RecordCountTile(
          count: records.length,
          label: 'MV cable records matched',
        ),
      ],
      records: records,
      itemBuilder: (record) => _RecordCard(
        icon: Icons.cable_outlined,
        title: record.shortLabel,
        subtitle:
            '${record.voltageDesignation} • ${record.family}\n'
            'Air ${record.ampacityAirA.toStringAsFixed(0)} A • '
            'Buried ${record.ampacityBuriedA.toStringAsFixed(0)} A • '
            'Duct ${record.ampacityDuctA.toStringAsFixed(0)} A',
        onOpen: () => _showCable(record),
      ),
    );
  }

  Widget _transformerTab() {
    final query = _search.text.trim().toLowerCase();
    final records = _repo.transformers.where((record) {
      final brand = _txBrand == 'All brands' || record.brand == _txBrand;
      final type = _txType == 'All types' || record.type == _txType;
      final haystack =
          '${record.id} ${record.brand} ${record.manufacturer} ${record.type} '
          '${record.ratedKva} ${record.primaryKv} ${record.vectorGroup}'
              .toLowerCase();
      return brand && type && (query.isEmpty || haystack.contains(query));
    }).toList();

    return _databaseTab(
      scrollKey: 'transformer-database',
      helpValues: <String, Object?>{
        'selectedDatabase': 'Transformers',
        'searchQuery': _search.text.trim(),
        'selectedBrand': _txBrand,
        'selectedTransformerType': _txType,
        'matchedRecordCount': records.length,
        'dataStatus': '${records.length} transformer records matched',
      },
      filters: [
        _filterField(
          label: 'Brand',
          topicId: 'brand_filter',
          value: _txBrand,
          values: ['All brands', ..._repo.transformerBrands],
          onChanged: (value) => setState(() => _txBrand = value),
        ),
        _filterField(
          label: 'Transformer family',
          topicId: 'transformer_type',
          value: _txType,
          values: ['All types', ..._repo.transformerTypes],
          onChanged: (value) => setState(() => _txType = value),
        ),
        _RecordCountTile(
          count: records.length,
          label: 'Transformer records matched',
        ),
      ],
      records: records,
      itemBuilder: (record) => _RecordCard(
        icon: Icons.electrical_services_outlined,
        title: record.shortLabel,
        subtitle:
            '${record.primaryKv.toStringAsFixed(1)}/'
            '${record.secondaryKv.toStringAsFixed(3)} kV • '
            '${record.vectorGroup} • ${record.cooling}\n'
            'Impedance ${record.impedancePercent.toStringAsFixed(2)}% • '
            'P0 ${record.noLoadLossKw.toStringAsFixed(2)} kW • '
            'Pk ${record.loadLossKw.toStringAsFixed(2)} kW',
        onOpen: () => _showTransformer(record),
      ),
    );
  }

  Widget _protectionTab() {
    final query = _search.text.trim().toLowerCase();
    final records = _repo.protectionDevices.where((record) {
      final brand = _protectionBrand == 'All brands' ||
          record.brand == _protectionBrand;
      final category = _protectionCategory == 'All categories' ||
          record.category == _protectionCategory;
      final haystack =
          '${record.id} ${record.category} ${record.brand} ${record.family} '
          '${record.ratedVoltageKv} ${record.ratedCurrentA} '
          '${record.breakingCurrentKa}'
              .toLowerCase();
      return brand && category && (query.isEmpty || haystack.contains(query));
    }).toList();

    return _databaseTab(
      scrollKey: 'protection-database',
      helpValues: <String, Object?>{
        'selectedDatabase': 'Protection',
        'searchQuery': _search.text.trim(),
        'selectedBrand': _protectionBrand,
        'selectedProtectionCategory': _protectionCategory,
        'matchedRecordCount': records.length,
        'dataStatus': '${records.length} protection records matched',
      },
      filters: [
        _filterField(
          label: 'Brand',
          topicId: 'brand_filter',
          value: _protectionBrand,
          values: ['All brands', ..._repo.protectionBrands],
          onChanged: (value) => setState(() => _protectionBrand = value),
        ),
        _filterField(
          label: 'Protection category',
          topicId: 'protection_category',
          value: _protectionCategory,
          values: ['All categories', ..._repo.protectionCategories],
          onChanged: (value) => setState(() => _protectionCategory = value),
        ),
        _RecordCountTile(
          count: records.length,
          label: 'Protection records matched',
        ),
      ],
      records: records,
      itemBuilder: (record) {
        final rating = record.ratedCurrentA > 0
            ? '${record.ratedVoltageKv.toStringAsFixed(1)} kV • '
                '${record.ratedCurrentA.toStringAsFixed(0)} A • '
                '${record.breakingCurrentKa.toStringAsFixed(1)} kA'
            : record.construction;
        return _RecordCard(
          icon: Icons.security_outlined,
          title: record.shortLabel,
          subtitle: '${record.category}\n$rating',
          onOpen: () => _showProtection(record),
        );
      },
    );
  }

  Widget _databaseTab<T>({
    required String scrollKey,
    required Map<String, Object?> helpValues,
    required List<Widget> filters,
    required List<T> records,
    required Widget Function(T record) itemBuilder,
  }) {
    return EngineeringHelpScope(
      values: helpValues,
      child: CustomScrollView(
        key: PageStorageKey<String>(scrollKey),
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 12),
            sliver: SliverToBoxAdapter(
              child: SectionCard(
                title: 'Database filters',
                subtitle:
                    'Scroll the complete page to reach every filter and matching record',
                icon: Icons.filter_alt_outlined,
                child: ResponsiveGrid(
                  minItemWidth: 145,
                  children: filters,
                ),
              ),
            ),
          ),
          if (records.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'No records match the current search and filters.',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    if (index.isOdd) {
                      return const SizedBox(height: 10);
                    }
                    return itemBuilder(records[index ~/ 2]);
                  },
                  childCount: records.length * 2 - 1,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _filterField({
    required String label,
    required String topicId,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    final safeValue = values.contains(value) ? value : values.first;
    return LabeledField(
      label: label,
      topicId: topicId,
      child: DropdownButtonFormField<String>(
        key: ValueKey('$label|$safeValue'),
        initialValue: safeValue,
        isExpanded: true,
        items: [
          for (final item in values)
            DropdownMenuItem(
              value: item,
              child: Text(item, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  Future<void> _showCable(MvCableRecord record) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.cable_outlined),
        title: Text(record.shortLabel),
        content: SizedBox(
          width: 650,
          child: SingleChildScrollView(
            child: _details([
              ['Record ID', record.id],
              ['Manufacturer', record.manufacturer],
              ['Family', record.family],
              ['Voltage designation', record.voltageDesignation],
              ['Insulation', record.insulation],
              ['Screen area', '${record.screenMm2.toStringAsFixed(0)} mm²'],
              ['Armour', record.armour],
              [
                'Resistance at 90°C',
                '${record.resistanceOhmPerKm.toStringAsFixed(5)} Ω/km',
              ],
              [
                'Trefoil reactance',
                '${record.reactanceTrefoilOhmPerKm.toStringAsFixed(4)} Ω/km',
              ],
              [
                'Capacitance',
                '${record.capacitanceUfPerKm.toStringAsFixed(3)} µF/km',
              ],
              ['Data status', record.dataStatus],
              ['Source', record.sourceUrl],
              ['Notes', record.notes],
            ]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showTransformer(TransformerRecord record) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.electrical_services_outlined),
        title: Text(record.shortLabel),
        content: SizedBox(
          width: 650,
          child: SingleChildScrollView(
            child: _details([
              ['Record ID', record.id],
              ['Manufacturer', record.manufacturer],
              ['Voltage', '${record.primaryKv}/${record.secondaryKv} kV'],
              ['Vector group', record.vectorGroup],
              ['Impedance', '${record.impedancePercent.toStringAsFixed(2)} %'],
              ['Tap range', '±${record.tapRangePercent.toStringAsFixed(1)} %'],
              ['Cooling', record.cooling],
              [
                'No-load loss reference',
                '${record.noLoadLossKw.toStringAsFixed(3)} kW',
              ],
              [
                'Load loss reference',
                '${record.loadLossKw.toStringAsFixed(3)} kW',
              ],
              ['Data status', record.dataStatus],
              ['Source', record.sourceUrl],
              ['Notes', record.notes],
            ]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _showProtection(ProtectionDeviceRecord record) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.security_outlined),
        title: Text(record.shortLabel),
        content: SizedBox(
          width: 680,
          child: SingleChildScrollView(
            child: _details([
              ['Record ID', record.id],
              ['Category', record.category],
              ['Rated voltage', '${record.ratedVoltageKv} kV'],
              ['Rated current', '${record.ratedCurrentA} A'],
              ['Breaking current', '${record.breakingCurrentKa} kA'],
              [
                'Short-time withstand',
                '${record.shortTimeCurrentKa} kA / '
                    '${record.shortTimeDurationS} s',
              ],
              ['Poles', record.poles],
              ['Trip functions', record.tripFunctions],
              ['Construction / scope', record.construction],
              ['Data status', record.dataStatus],
              ['Source basis', record.sourceBasis],
              ['Source', record.sourceUrl],
              ['Notes', record.notes],
            ]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _details(List<List<String>> rows) {
    return Column(
      children: [
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 180,
                  child: Text(
                    row[0],
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                ),
                Expanded(child: Text(row[1])),
              ],
            ),
          ),
      ],
    );
  }
}

class _RecordCountTile extends StatelessWidget {
  const _RecordCountTile({required this.count, required this.label});

  final int count;
  final String label;

  @override
  Widget build(BuildContext context) {
    return ResultTile(
      label: label,
      value: count.toString(),
      topicId: 'data_status',
      icon: Icons.dataset_outlined,
    );
  }
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onOpen,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(26),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFC026D3), Color(0xFF7E22CE)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(icon, color: Colors.white, size: 27),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w900,
                          ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w600,
                            height: 1.35,
                          ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 7),
              IconButton(
                tooltip: 'Record information',
                onPressed: onOpen,
                icon: const Icon(Icons.info_outline_rounded),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
