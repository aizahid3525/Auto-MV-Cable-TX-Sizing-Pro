import 'package:flutter/material.dart';

import '../calculations.dart';
import '../data_repository.dart';
import '../models.dart';
import '../widgets/common_widgets.dart';

class CableDesignScreen extends StatefulWidget {
  const CableDesignScreen({super.key});

  @override
  State<CableDesignScreen> createState() => _CableDesignScreenState();
}

class _CableDesignScreenState extends State<CableDesignScreen> {
  final _repo = EngineeringRepository.instance;

  final _systemKv = TextEditingController(text: '11');
  final _loadKva = TextEditingController(text: '1000');
  final _powerFactor = TextEditingController(text: '0.90');
  final _lengthM = TextEditingController(text: '300');
  final _parallelRuns = TextEditingController(text: '1');
  final _derating = TextEditingController(text: '0.85');
  final _vdLimit = TextEditingController(text: '3.0');
  final _faultKa = TextEditingController(text: '20');
  final _faultTime = TextEditingController(text: '1');

  String _installationMethod = 'Direct buried';
  String _screenBonding = 'Not selected';
  String _brand = 'All brands';
  String _family = 'All families';
  String _cores = 'All cores';
  String _conductor = 'All materials';
  MvCableRecord? _selected;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _systemKv,
      _loadKva,
      _powerFactor,
      _lengthM,
      _parallelRuns,
      _derating,
      _vdLimit,
      _faultKa,
      _faultTime,
    ]) {
      controller.addListener(_refresh);
    }
    _selected = _matchingCables().firstOrNull;
  }

  @override
  void dispose() {
    for (final controller in [
      _systemKv,
      _loadKva,
      _powerFactor,
      _lengthM,
      _parallelRuns,
      _derating,
      _vdLimit,
      _faultKa,
      _faultTime,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  void _refresh() {
    if (mounted) {
      setState(() {});
    }
  }

  double _number(TextEditingController controller) =>
      double.tryParse(controller.text.trim()) ?? double.nan;

  int _integer(TextEditingController controller) =>
      int.tryParse(controller.text.trim()) ?? 0;

  CableDesignInput get _input => CableDesignInput(
        systemKv: _number(_systemKv),
        loadKva: _number(_loadKva),
        powerFactor: _number(_powerFactor),
        lengthM: _number(_lengthM),
        parallelRuns: _integer(_parallelRuns),
        deratingFactor: _number(_derating),
        voltageDropLimitPercent: _number(_vdLimit),
        faultCurrentKa: _number(_faultKa),
        faultTimeS: _number(_faultTime),
        installationMethod: _installationMethod,
        screenBonding: _screenBonding,
      );

  List<MvCableRecord> _matchingCables() {
    final kv = _number(_systemKv);
    final records = _repo.cables.where((record) {
      final voltageMatch = !kv.isFinite || (record.systemKv - kv).abs() < 0.25;
      final brandMatch = _brand == 'All brands' || record.brand == _brand;
      final familyMatch = _family == 'All families' || record.family == _family;
      final coresMatch = _cores == 'All cores' || record.cores == _cores;
      final conductorMatch =
          _conductor == 'All materials' || record.conductor == _conductor;
      return voltageMatch &&
          brandMatch &&
          familyMatch &&
          coresMatch &&
          conductorMatch;
    }).toList();
    records.sort((a, b) => a.sizeMm2.compareTo(b.sizeMm2));
    return records;
  }

  void _normaliseSelection() {
    final records = _matchingCables();
    if (_selected == null || !records.any((e) => e.id == _selected!.id)) {
      _selected = records.firstOrNull;
    }
  }

  void _autoSelect() {
    final records = _matchingCables();
    MvCableRecord? fallback;
    for (final record in records) {
      fallback ??= record;
      final result = EngineeringCalculations.evaluateCable(_input, record);
      if (result.status != AssessmentStatus.fail &&
          result.status != AssessmentStatus.notAssessed) {
        setState(() => _selected = record);
        return;
      }
    }
    setState(() => _selected = fallback);
  }

  @override
  Widget build(BuildContext context) {
    _normaliseSelection();
    final records = _matchingCables();
    final selected = _selected;
    final result = selected == null
        ? null
        : EngineeringCalculations.evaluateCable(_input, selected);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const PageHeader(
            title: 'MV Cable Design',
            subtitle: 'Ampacity, voltage drop, short-circuit withstand, charging current and losses.',
            icon: Icons.cable,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 940;
              final inputCard = SectionCard(
                title: 'Design inputs',
                subtitle: 'Live preliminary calculation',
                child: Column(
                  children: [
                    _fieldGrid([
                      LabeledField(
                        label: 'System voltage',
                        topicId: 'system_voltage',
                        liveValues: {'Entered voltage': '${_systemKv.text} kV'},
                        child: _numberField(_systemKv, 'kV'),
                      ),
                      LabeledField(
                        label: 'Load / transformer capacity',
                        topicId: 'load_kva',
                        liveValues: {'Entered load': '${_loadKva.text} kVA'},
                        child: _numberField(_loadKva, 'kVA'),
                      ),
                      LabeledField(
                        label: 'Power factor',
                        topicId: 'power_factor',
                        child: _numberField(_powerFactor, 'p.u.'),
                      ),
                      LabeledField(
                        label: 'Route length',
                        topicId: 'voltage_drop',
                        child: _numberField(_lengthM, 'm'),
                      ),
                      LabeledField(
                        label: 'Parallel runs per phase',
                        topicId: 'parallel_runs',
                        child: _numberField(_parallelRuns, 'runs'),
                      ),
                      LabeledField(
                        label: 'Total derating factor',
                        topicId: 'ambient_temperature',
                        child: _numberField(_derating, 'p.u.'),
                      ),
                      LabeledField(
                        label: 'Voltage-drop limit',
                        topicId: 'voltage_drop',
                        child: _numberField(_vdLimit, '%'),
                      ),
                      LabeledField(
                        label: 'Prospective fault current',
                        topicId: 'fault_current',
                        child: _numberField(_faultKa, 'kA'),
                      ),
                      LabeledField(
                        label: 'Fault clearing time',
                        topicId: 'fault_time',
                        child: _numberField(_faultTime, 's'),
                      ),
                      LabeledField(
                        label: 'Installation method',
                        topicId: 'installation_method',
                        child: DropdownButtonFormField<String>(
                          initialValue: _installationMethod,
                          items: const [
                            DropdownMenuItem(value: 'In air', child: Text('In air / trefoil')),
                            DropdownMenuItem(value: 'Direct buried', child: Text('Direct buried')),
                            DropdownMenuItem(value: 'In duct', child: Text('In duct')),
                          ],
                          onChanged: (value) => setState(() => _installationMethod = value!),
                        ),
                      ),
                      LabeledField(
                        label: 'Screen bonding',
                        topicId: 'screen_bonding',
                        child: DropdownButtonFormField<String>(
                          initialValue: _screenBonding,
                          items: const [
                            DropdownMenuItem(value: 'Not selected', child: Text('Not selected')),
                            DropdownMenuItem(value: 'Single-point bonded', child: Text('Single-point bonded')),
                            DropdownMenuItem(value: 'Both-end bonded', child: Text('Both-end bonded')),
                            DropdownMenuItem(value: 'Cross-bonded', child: Text('Cross-bonded')),
                          ],
                          onChanged: (value) => setState(() => _screenBonding = value!),
                        ),
                      ),
                    ]),
                  ],
                ),
              );

              final selectionCard = SectionCard(
                title: 'Cable filters and selection',
                subtitle: '${records.length} matching controlled records',
                trailing: FilledButton.icon(
                  onPressed: records.isEmpty ? null : _autoSelect,
                  icon: const Icon(Icons.auto_awesome),
                  label: const Text('Auto select'),
                ),
                child: Column(
                  children: [
                    _fieldGrid([
                      _dropdown(
                        label: 'Brand',
                        topicId: 'brand_filter',
                        value: _brand,
                        values: ['All brands', ..._repo.cableBrands],
                        onChanged: (value) => setState(() => _brand = value),
                      ),
                      _dropdown(
                        label: 'Family',
                        topicId: 'cable_family',
                        value: _family,
                        values: ['All families', ..._repo.cableFamilies],
                        onChanged: (value) => setState(() => _family = value),
                      ),
                      _dropdown(
                        label: 'Number of cores',
                        topicId: 'number_of_cores',
                        value: _cores,
                        values: ['All cores', ..._repo.cableCores],
                        onChanged: (value) => setState(() => _cores = value),
                      ),
                      _dropdown(
                        label: 'Conductor material',
                        topicId: 'conductor_material',
                        value: _conductor,
                        values: ['All materials', ..._repo.conductorMaterials],
                        onChanged: (value) => setState(() => _conductor = value),
                      ),
                    ]),
                    const SizedBox(height: 12),
                    LabeledField(
                      label: 'Selected cable',
                      topicId: 'data_status',
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(selected?.id),
                        initialValue: records.any((e) => e.id == selected?.id) ? selected?.id : null,
                        isExpanded: true,
                        hint: const Text('No matching cable'),
                        items: records.take(250).map((record) {
                          return DropdownMenuItem(
                            value: record.id,
                            child: Text(
                              '${record.shortLabel} • ${record.voltageDesignation}',
                              overflow: TextOverflow.ellipsis,
                            ),
                          );
                        }).toList(),
                        onChanged: (id) {
                          setState(() {
                            _selected = records.where((e) => e.id == id).firstOrNull;
                          });
                        },
                      ),
                    ),
                    if (records.length > 250)
                      const Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Text('The selector shows the first 250 matches. Narrow the filters for a shorter list.'),
                      ),
                  ],
                ),
              );

              if (!wide) {
                return Column(
                  children: [inputCard, const SizedBox(height: 16), selectionCard],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: inputCard),
                  const SizedBox(width: 16),
                  Expanded(child: selectionCard),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
          _resultSection(result),
        ],
      ),
    );
  }

  Widget _resultSection(CableDesignResult? result) {
    if (result == null) {
      return const SectionCard(
        title: 'Results',
        child: Text('No compatible cable record is available for the current filters.'),
      );
    }
    return SectionCard(
      title: 'Live cable assessment',
      subtitle: result.cable.shortLabel,
      trailing: Chip(label: Text(result.status.label)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveGrid(
            children: [
              ResultTile(label: 'Design current', value: _format(result.designCurrentA, 'A')),
              ResultTile(label: 'Derated ampacity', value: _format(result.deratedAmpacityA, 'A')),
              ResultTile(label: 'Cable loading', value: _format(result.loadingPercent, '%')),
              ResultTile(label: 'Voltage drop', value: _format(result.voltageDropPercent, '%')),
              ResultTile(label: 'Conductor withstand', value: _format(result.shortCircuitWithstandKa, 'kA')),
              ResultTile(label: 'Charging current', value: _format(result.chargingCurrentA, 'A')),
              ResultTile(label: 'Conductor loss', value: _format(result.lossKw, 'kW')),
              ResultTile(label: 'Overall status', value: result.status.label, status: result.status),
            ],
          ),
          const SizedBox(height: 14),
          for (final message in result.messages)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.info_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(message)),
                ],
              ),
            ),
          const Divider(height: 28),
          Text('Source: ${result.cable.sourceUrl}'),
          const SizedBox(height: 4),
          Text(result.cable.notes),
        ],
      ),
    );
  }

  Widget _numberField(TextEditingController controller, String suffix) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(suffixText: suffix),
    );
  }

  Widget _fieldGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 640 ? 2 : 1;
        return GridView.count(
          crossAxisCount: count,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: count == 1 ? 3.1 : 2.5,
          children: children,
        );
      },
    );
  }

  Widget _dropdown({
    required String label,
    required String topicId,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
  }) {
    return LabeledField(
      label: label,
      topicId: topicId,
      child: DropdownButtonFormField<String>(
        key: ValueKey('$label|${values.contains(value) ? value : values.first}'),
        initialValue: values.contains(value) ? value : values.first,
        isExpanded: true,
        items: values
            .map((item) => DropdownMenuItem(
                  value: item,
                  child: Text(item, overflow: TextOverflow.ellipsis),
                ))
            .toList(),
        onChanged: (newValue) {
          if (newValue != null) {
            onChanged(newValue);
          }
        },
      ),
    );
  }

  String _format(double value, String unit) {
    if (!value.isFinite) {
      return 'Not assessed';
    }
    return '${value.toStringAsFixed(2)} $unit';
  }
}

extension _FirstOrNull<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
