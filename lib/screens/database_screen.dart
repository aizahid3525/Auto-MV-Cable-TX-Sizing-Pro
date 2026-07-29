import 'package:flutter/material.dart';

import '../data_repository.dart';
import '../models.dart';
import '../protection_models.dart';
import '../widgets/common_widgets.dart';

class DatabaseScreen extends StatefulWidget {
  const DatabaseScreen({super.key});

  @override
  State<DatabaseScreen> createState() => _DatabaseScreenState();
}

class _DatabaseScreenState extends State<DatabaseScreen>
    with SingleTickerProviderStateMixin {
  final _repo = EngineeringRepository.instance;
  late final TabController _tabController;
  final _search = TextEditingController();
  String _cableBrand = 'All brands';
  String _cableCore = 'All cores';
  String _cableMaterial = 'All materials';
  String _txBrand = 'All brands';
  String _txType = 'All types';
  String _protectionBrand = 'All brands';
  String _protectionCategory = 'All categories';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
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
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
          child: const PageHeader(
            title: 'Engineering Database',
            subtitle: 'Malaysia-focused MV cable, transformer and protection records with controlled source status.',
            icon: Icons.storage,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(18),
          child: TextField(
            controller: _search,
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search brand, family, type, rating or record ID',
            ),
          ),
        ),
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'MV cables', icon: Icon(Icons.cable)),
            Tab(text: 'Transformers', icon: Icon(Icons.electrical_services)),
            Tab(text: 'Protection', icon: Icon(Icons.security)),
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
    );
  }

  Widget _cableTab() {
    final query = _search.text.trim().toLowerCase();
    final records = _repo.cables.where((record) {
      final brand = _cableBrand == 'All brands' || record.brand == _cableBrand;
      final cores = _cableCore == 'All cores' || record.cores == _cableCore;
      final material = _cableMaterial == 'All materials' || record.conductor == _cableMaterial;
      final haystack = '${record.id} ${record.brand} ${record.family} ${record.cores} ${record.conductor} ${record.sizeMm2} ${record.voltageDesignation}'.toLowerCase();
      return brand && cores && material && (query.isEmpty || haystack.contains(query));
    }).toList();

    return Column(
      children: [
        _filters([
          _filter(
            value: _cableBrand,
            values: ['All brands', ..._repo.cableBrands],
            onChanged: (value) => setState(() => _cableBrand = value),
          ),
          _filter(
            value: _cableCore,
            values: ['All cores', ..._repo.cableCores],
            onChanged: (value) => setState(() => _cableCore = value),
          ),
          _filter(
            value: _cableMaterial,
            values: ['All materials', ..._repo.conductorMaterials],
            onChanged: (value) => setState(() => _cableMaterial = value),
          ),
          Text('${records.length} records', style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                child: ListTile(
                  title: Text(record.shortLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${record.voltageDesignation} • ${record.family}\nAir ${record.ampacityAirA.toStringAsFixed(0)} A • Buried ${record.ampacityBuriedA.toStringAsFixed(0)} A • Duct ${record.ampacityDuctA.toStringAsFixed(0)} A'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showCable(record),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _transformerTab() {
    final query = _search.text.trim().toLowerCase();
    final records = _repo.transformers.where((record) {
      final brand = _txBrand == 'All brands' || record.brand == _txBrand;
      final type = _txType == 'All types' || record.type == _txType;
      final haystack = '${record.id} ${record.brand} ${record.manufacturer} ${record.type} ${record.ratedKva} ${record.primaryKv} ${record.vectorGroup}'.toLowerCase();
      return brand && type && (query.isEmpty || haystack.contains(query));
    }).toList();

    return Column(
      children: [
        _filters([
          _filter(
            value: _txBrand,
            values: ['All brands', ..._repo.transformerBrands],
            onChanged: (value) => setState(() => _txBrand = value),
          ),
          _filter(
            value: _txType,
            values: ['All types', ..._repo.transformerTypes],
            onChanged: (value) => setState(() => _txType = value),
          ),
          Text('${records.length} records', style: const TextStyle(fontWeight: FontWeight.w700)),
        ]),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = records[index];
              return Card(
                child: ListTile(
                  title: Text(record.shortLabel, style: const TextStyle(fontWeight: FontWeight.w800)),
                  subtitle: Text('${record.primaryKv.toStringAsFixed(1)}/${record.secondaryKv.toStringAsFixed(3)} kV • ${record.vectorGroup} • ${record.cooling}\nImpedance ${record.impedancePercent.toStringAsFixed(2)}% • P0 ${record.noLoadLossKw.toStringAsFixed(2)} kW • Pk ${record.loadLossKw.toStringAsFixed(2)} kW'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showTransformer(record),
                ),
              );
            },
          ),
        ),
      ],
    );
  }


  Widget _protectionTab() {
    final query = _search.text.trim().toLowerCase();
    final records = _repo.protectionDevices.where((record) {
      final brand = _protectionBrand == 'All brands' ||
          record.brand == _protectionBrand;
      final category = _protectionCategory == 'All categories' ||
          record.category == _protectionCategory;
      final haystack = '${record.id} ${record.category} ${record.brand} '
              '${record.family} ${record.ratedVoltageKv} '
              '${record.ratedCurrentA} ${record.breakingCurrentKa}'
          .toLowerCase();
      return brand && category && (query.isEmpty || haystack.contains(query));
    }).toList();

    return Column(
      children: [
        _filters([
          _filter(
            value: _protectionBrand,
            values: ['All brands', ..._repo.protectionBrands],
            onChanged: (value) =>
                setState(() => _protectionBrand = value),
          ),
          _filter(
            value: _protectionCategory,
            values: ['All categories', ..._repo.protectionCategories],
            onChanged: (value) =>
                setState(() => _protectionCategory = value),
          ),
          Text(
            '${records.length} records',
            style: const TextStyle(fontWeight: FontWeight.w700),
          ),
        ]),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            itemCount: records.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final record = records[index];
              final rating = record.ratedCurrentA > 0
                  ? '${record.ratedVoltageKv.toStringAsFixed(1)} kV • '
                      '${record.ratedCurrentA.toStringAsFixed(0)} A • '
                      '${record.breakingCurrentKa.toStringAsFixed(1)} kA'
                  : record.construction;
              return Card(
                child: ListTile(
                  leading: const Icon(Icons.security_outlined),
                  title: Text(
                    record.shortLabel,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text('${record.category}\n$rating'),
                  isThreeLine: true,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => _showProtection(record),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _filters(List<Widget> children) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: children,
      ),
    );
  }

  Widget _filter({
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return SizedBox(
      width: 210,
      child: DropdownButtonFormField<String>(
        value: values.contains(value) ? value : values.first,
        isExpanded: true,
        items: values
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: (newValue) {
          if (newValue != null) onChanged(newValue);
        },
      ),
    );
  }

  Future<void> _showCable(MvCableRecord record) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
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
              ['Resistance at 90°C', '${record.resistanceOhmPerKm.toStringAsFixed(5)} Ω/km'],
              ['Trefoil reactance', '${record.reactanceTrefoilOhmPerKm.toStringAsFixed(4)} Ω/km'],
              ['Capacitance', '${record.capacitanceUfPerKm.toStringAsFixed(3)} µF/km'],
              ['Data status', record.dataStatus],
              ['Source', record.sourceUrl],
              ['Notes', record.notes],
            ]),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }

  Future<void> _showTransformer(TransformerRecord record) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
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
              ['No-load loss reference', '${record.noLoadLossKw.toStringAsFixed(3)} kW'],
              ['Load loss reference', '${record.loadLossKw.toStringAsFixed(3)} kW'],
              ['Data status', record.dataStatus],
              ['Source', record.sourceUrl],
              ['Notes', record.notes],
            ]),
          ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
      ),
    );
  }


  Future<void> _showProtection(ProtectionDeviceRecord record) {
    return showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
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
              ['Short-time withstand',
                '${record.shortTimeCurrentKa} kA / ${record.shortTimeDurationS} s'],
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
      children: rows
          .map((row) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(width: 180, child: Text(row[0], style: const TextStyle(fontWeight: FontWeight.w700))),
                    Expanded(child: Text(row[1])),
                  ],
                ),
              ))
          .toList(),
    );
  }
}
