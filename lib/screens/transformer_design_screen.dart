import 'package:flutter/material.dart';

import '../calculations.dart';
import '../data_repository.dart';
import '../models.dart';
import '../protection_calculations.dart';
import '../protection_models.dart';
import '../widgets/common_widgets.dart';

class TransformerDesignScreen extends StatefulWidget {
  const TransformerDesignScreen({super.key});

  @override
  State<TransformerDesignScreen> createState() => _TransformerDesignScreenState();
}

class _TransformerDesignScreenState extends State<TransformerDesignScreen> {
  final _repo = EngineeringRepository.instance;

  final _connectedKw = TextEditingController(text: '650');
  final _powerFactor = TextEditingController(text: '0.90');
  final _efficiency = TextEditingController(text: '0.98');
  final _demandFactor = TextEditingController(text: '0.90');
  final _growth = TextEditingController(text: '15');
  final _harmonic = TextEditingController(text: '1.00');
  final _motor = TextEditingController(text: '1.00');
  final _units = TextEditingController(text: '1');

  String _brand = 'All brands';
  String _type = 'All types';
  double _primaryKv = 11;
  TransformerRecord? _selected;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _connectedKw,
      _powerFactor,
      _efficiency,
      _demandFactor,
      _growth,
      _harmonic,
      _motor,
      _units,
    ]) {
      controller.addListener(_refresh);
    }
    _selected = _matching().firstOrNull;
  }

  @override
  void dispose() {
    for (final controller in [
      _connectedKw,
      _powerFactor,
      _efficiency,
      _demandFactor,
      _growth,
      _harmonic,
      _motor,
      _units,
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

  TransformerDesignInput get _input => TransformerDesignInput(
        connectedLoadKw: _number(_connectedKw),
        powerFactor: _number(_powerFactor),
        efficiency: _number(_efficiency),
        demandFactor: _number(_demandFactor),
        futureGrowthPercent: _number(_growth),
        harmonicFactor: _number(_harmonic),
        motorStartingFactor: _number(_motor),
        numberOfUnits: _integer(_units),
      );

  List<TransformerRecord> _matching() {
    final records = _repo.transformers.where((record) {
      final voltageMatch = (record.primaryKv - _primaryKv).abs() < 0.25;
      final brandMatch = _brand == 'All brands' || record.brand == _brand;
      final typeMatch = _type == 'All types' || record.type == _type;
      return voltageMatch && brandMatch && typeMatch;
    }).toList();
    records.sort((a, b) => a.ratedKva.compareTo(b.ratedKva));
    return records;
  }

  void _normaliseSelection() {
    final records = _matching();
    if (_selected == null || !records.any((e) => e.id == _selected!.id)) {
      _selected = records.firstOrNull;
    }
  }

  void _autoSelect() {
    final records = _matching();
    for (final record in records) {
      final result = EngineeringCalculations.evaluateTransformer(_input, record);
      if (result.status != AssessmentStatus.fail &&
          result.status != AssessmentStatus.notAssessed &&
          result.normalLoadingPercent <= 90) {
        setState(() => _selected = record);
        return;
      }
    }
    setState(() => _selected = records.lastOrNull);
  }

  @override
  Widget build(BuildContext context) {
    _normaliseSelection();
    final records = _matching();
    final selected = _selected;
    final result = selected == null
        ? null
        : EngineeringCalculations.evaluateTransformer(_input, selected);

    return EngineeringHelpScope(
      values: _helpValues(result),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
        children: [
          const PageHeader(
            title: 'Transformer Design',
            subtitle: 'Demand, capacity, loading, losses, regulation and preliminary fault current.',
            icon: Icons.electrical_services,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 940;
              final inputCard = SectionCard(
                title: 'Load and design assumptions',
                subtitle: 'Transparent real-time demand calculation',
                child: _fieldGrid([
                  LabeledField(
                    label: 'Connected load',
                    topicId: 'load_kva',
                    child: _numberField(_connectedKw, 'kW'),
                  ),
                  LabeledField(
                    label: 'Power factor',
                    topicId: 'power_factor',
                    child: _numberField(_powerFactor, 'p.u.'),
                  ),
                  LabeledField(
                    label: 'Efficiency',
                    topicId: 'transformer_loading',
                    child: _numberField(_efficiency, 'p.u.'),
                  ),
                  LabeledField(
                    label: 'Demand factor',
                    topicId: 'demand_factor',
                    child: _numberField(_demandFactor, 'p.u.'),
                  ),
                  LabeledField(
                    label: 'Future growth',
                    topicId: 'future_growth',
                    child: _numberField(_growth, '%'),
                  ),
                  LabeledField(
                    label: 'Harmonic allowance',
                    topicId: 'harmonic_factor',
                    child: _numberField(_harmonic, 'factor'),
                  ),
                  LabeledField(
                    label: 'Motor-starting allowance',
                    topicId: 'transformer_loading',
                    child: _numberField(_motor, 'factor'),
                  ),
                  LabeledField(
                    label: 'Number of units',
                    topicId: 'redundancy',
                    child: _numberField(_units, 'units'),
                  ),
                ]),
              );

              final selectionCard = SectionCard(
                title: 'Transformer filters and selection',
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
                        values: ['All brands', ..._repo.transformerBrands],
                        onChanged: (value) => setState(() => _brand = value),
                      ),
                      _dropdown(
                        label: 'Transformer type',
                        topicId: 'transformer_type',
                        value: _type,
                        values: ['All types', ..._repo.transformerTypes],
                        onChanged: (value) => setState(() => _type = value),
                      ),
                      LabeledField(
                        label: 'Primary voltage',
                        topicId: 'system_voltage',
                        child: DropdownButtonFormField<double>(
                          initialValue: _primaryKv,
                          items: const [
                            DropdownMenuItem(value: 6.6, child: Text('6.6 kV')),
                            DropdownMenuItem(value: 11, child: Text('11 kV')),
                            DropdownMenuItem(value: 22, child: Text('22 kV')),
                            DropdownMenuItem(value: 33, child: Text('33 kV')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _primaryKv = value);
                            }
                          },
                        ),
                      ),
                      const SizedBox.shrink(),
                    ]),
                    const SizedBox(height: 12),
                    LabeledField(
                      label: 'Selected transformer',
                      topicId: 'data_status',
                      child: DropdownButtonFormField<String>(
                        key: ValueKey(selected?.id),
                        initialValue: records.any((e) => e.id == selected?.id) ? selected?.id : null,
                        isExpanded: true,
                        hint: const Text('No matching transformer'),
                        items: records.map((record) {
                          return DropdownMenuItem(
                            value: record.id,
                            child: Text(
                              '${record.shortLabel} • ${record.primaryKv.toStringAsFixed(1)}/${record.secondaryKv.toStringAsFixed(3)} kV',
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
                  ],
                ),
              );

              if (!wide) {
                return Column(children: [inputCard, const SizedBox(height: 16), selectionCard]);
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
          if (result != null) ...[
            const SizedBox(height: 16),
            _protectionPreview(result),
          ],
          ],
        ),
      ),
    );
  }

  Map<String, Object?> _helpValues(TransformerDesignResult? result) {
    final selected = _selected;
    return <String, Object?>{
      'screen': 'transformer',
      'connectedLoadKw': _number(_connectedKw),
      'powerFactor': _number(_powerFactor),
      'efficiency': _number(_efficiency),
      'demandFactor': _number(_demandFactor),
      'futureGrowthPercent': _number(_growth),
      'harmonicFactor': _number(_harmonic),
      'motorStartingFactor': _number(_motor),
      'numberOfUnits': _integer(_units).toDouble(),
      'primaryKv': selected?.primaryKv ?? _primaryKv,
      'secondaryKv': selected?.secondaryKv,
      'transformerRatingKva': selected?.ratedKva,
      'selectedTransformerKva': selected?.ratedKva,
      'transformerType': _type == 'All types' ? selected?.type : _type,
      'transformerBrand': selected?.brand,
      'brandFilter': _brand,
      'selectedTransformer': selected?.shortLabel,
      'selectedRecord': selected?.shortLabel,
      'impedancePercent': selected?.impedancePercent,
      'vectorGroup': selected?.vectorGroup,
      'coolingClass': selected?.cooling,
      'noLoadLossKw': selected?.noLoadLossKw,
      'loadLossKw': selected?.loadLossKw,
      'dataStatus': selected?.dataStatus,
      'designDemandKva': result?.designDemandKva,
      'normalLoadingPercent': result?.normalLoadingPercent,
      'outageLoadingPercent': result?.outageLoadingPercent,
      'primaryCurrentA': result?.primaryCurrentA,
      'secondaryCurrentA': result?.secondaryCurrentA,
      'approxFaultCurrentKa': result?.approxFaultCurrentKa,
      'calculatedLvFaultKa': result?.approxFaultCurrentKa,
      'totalLossKw': result?.totalLossKw,
      'efficiencyPercent': result?.efficiencyPercent,
      'approxRegulationPercent': result?.approxRegulationPercent,
      'overallStatus': result?.status.label,
    };
  }

  Widget _resultSection(TransformerDesignResult? result) {
    if (result == null) {
      return const SectionCard(
        title: 'Results',
        child: Text('No compatible transformer record is available for the current filters.'),
      );
    }
    return SectionCard(
      title: 'Live transformer assessment',
      subtitle: result.transformer.shortLabel,
      trailing: Chip(label: Text(result.status.label)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveGrid(
            children: [
              ResultTile(label: 'Design demand', value: _format(result.designDemandKva, 'kVA')),
              ResultTile(label: 'Normal loading', value: _format(result.normalLoadingPercent, '%')),
              ResultTile(label: 'Outage loading', value: _format(result.outageLoadingPercent, '%')),
              ResultTile(label: 'MV current / unit', value: _format(result.primaryCurrentA, 'A')),
              ResultTile(label: 'LV current / unit', value: _format(result.secondaryCurrentA, 'A')),
              ResultTile(label: 'Approx. LV terminal fault', value: _format(result.approxFaultCurrentKa, 'kA')),
              ResultTile(label: 'Total loss at design', value: _format(result.totalLossKw, 'kW')),
              ResultTile(label: 'Approx. efficiency', value: _format(result.efficiencyPercent, '%')),
              ResultTile(label: 'Approx. regulation', value: _format(result.approxRegulationPercent, '%')),
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
          Text('Vector group: ${result.transformer.vectorGroup}'),
          Text('Cooling: ${result.transformer.cooling}'),
          Text('Source: ${result.transformer.sourceUrl}'),
          const SizedBox(height: 4),
          Text(result.transformer.notes),
        ],
      ),
    );
  }


  Widget _protectionPreview(TransformerDesignResult transformerResult) {
    final transformer = transformerResult.transformer;
    final protection = ProtectionCalculations.evaluate(
      input: ProtectionDesignInput(
        mode: 'Automatic preliminary',
        profileId: 'MYS-IEC-PRELIMINARY',
        mvDeviceStrategy: 'Auto',
        transformerKva: transformer.ratedKva,
        primaryKv: transformer.primaryKv,
        secondaryKv: transformer.secondaryKv,
        impedancePercent: transformer.impedancePercent,
        transformerType: transformer.type,
        numberOfUnits: _integer(_units),
        criticalLoad: false,
        enhancedProtection: false,
        mvFaultCurrentKa: 20,
        mvFaultDurationS: 3,
        lvFaultOverrideKa: 0,
        lvBusOrCableRatingA: 0,
        groundFaultEnabled: true,
      ),
      profile: _repo.protectionProfile('MYS-IEC-PRELIMINARY'),
      ctRatios: _repo.ctRatios,
      acbFrames: _repo.standardAcbFrames,
      acbBreakingRatings: _repo.standardAcbBreakingRatings,
      vcbVoltages: _repo.standardVcbVoltages,
      vcbCurrents: _repo.standardVcbCurrents,
      vcbBreakingRatings: _repo.standardVcbBreakingRatings,
      fuseRatings: _repo.standardFuseRatings,
      productFamilies: _repo.productFamilies,
      internalProtectionDatabase: _repo.internalProtection,
    );
    return EngineeringHelpScope(
      values: <String, Object?>{
        ..._helpValues(transformerResult),
        'mvFaultCurrentKa': 20.0,
        'mvFaultDurationS': 3.0,
        'preferredMvDevice': protection.preferredMvDevice,
        'vcbRatedVoltageKv': protection.vcbRatedVoltageKv,
        'vcbRatedCurrentA': protection.vcbRatedCurrentA,
        'vcbBreakingCurrentKa': protection.vcbBreakingCurrentKa,
        'fuseCurrentA': protection.fuseCurrentA,
        'acbFrameA': protection.acbFrameA,
        'acbSensorA': protection.acbSensorA,
        'acbBreakingCurrentKa': protection.acbBreakingCurrentKa,
        'ctRatio': protection.ctRatio,
        'acbPoles': protection.acbPoles,
        'acbShortTimeWithstandKa': protection.acbShortTimeWithstandKa,
        'longTimePickupA': protection.longTimePickupA,
        'shortTimePickupA': protection.shortTimePickupA,
        'shortTimeDelayS': protection.shortTimeDelayS,
        'instantaneousPickupA': protection.instantaneousPickupA,
        'groundFaultPickupA': protection.groundFaultPickupA,
        'groundFaultDelayS': protection.groundFaultDelayS,
        'protectionStatus': protection.status.label,
      },
      child: SectionCard(
        title: 'Integrated protection preview',
      subtitle: 'Default 20 kA / 3 s MV duty — use the Protection page for project inputs',
      trailing: const HelperButton(
        topicId: 'protection_status',
        information: true,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveGrid(
            children: [
              ResultTile(
                label: 'Preferred MV device',
                value: protection.preferredMvDevice,
                status: protection.status,
              ),
              ResultTile(
                label: 'VCB requirement',
                value:
                    '${protection.vcbRatedVoltageKv.toStringAsFixed(1)} kV • '
                    '${protection.vcbRatedCurrentA.toStringAsFixed(0)} A • '
                    '${protection.vcbBreakingCurrentKa.toStringAsFixed(1)} kA',
              ),
              ResultTile(
                label: 'ACB frame / duty',
                value:
                    '${protection.acbFrameA.toStringAsFixed(0)} A • '
                    '${protection.acbBreakingCurrentKa.toStringAsFixed(1)} kA',
              ),
              ResultTile(label: 'Protection CT', value: protection.ctRatio),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'This preview deliberately remains VERIFY. Confirm actual TNB/utility fault data, exact product ratings, CT performance, transformer inrush, relay curves and ACB discrimination in the dedicated workflow.',
          ),
          ],
        ),
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
    return ResponsiveGrid(
      minItemWidth: 145,
      children: children,
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
  T? get lastOrNull => isEmpty ? null : last;
}
