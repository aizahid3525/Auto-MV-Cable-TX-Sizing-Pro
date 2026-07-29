import 'package:flutter/material.dart';

import '../data_repository.dart';
import '../models.dart';
import '../protection_calculations.dart';
import '../protection_models.dart';
import '../widgets/common_widgets.dart';

class ProtectionDesignScreen extends StatefulWidget {
  const ProtectionDesignScreen({
    super.key,
    this.initialTransformer,
  });

  final TransformerRecord? initialTransformer;

  @override
  State<ProtectionDesignScreen> createState() =>
      _ProtectionDesignScreenState();
}

class _ProtectionDesignScreenState extends State<ProtectionDesignScreen> {
  final _repo = EngineeringRepository.instance;

  late final TextEditingController _transformerKva;
  late final TextEditingController _primaryKv;
  late final TextEditingController _secondaryKv;
  late final TextEditingController _impedance;
  final _units = TextEditingController(text: '1');
  final _mvFaultKa = TextEditingController(text: '20');
  final _mvFaultDuration = TextEditingController(text: '3');
  final _lvFaultOverride = TextEditingController();
  final _lvBusRating = TextEditingController();

  final _manualVcbVoltage = TextEditingController();
  final _manualVcbCurrent = TextEditingController();
  final _manualVcbBreaking = TextEditingController();
  final _manualFuseCurrent = TextEditingController();
  final _manualAcbFrame = TextEditingController();
  final _manualAcbBreaking = TextEditingController();
  final _manualCtPrimary = TextEditingController();
  final _manualLongTime = TextEditingController();
  final _manualShortTime = TextEditingController();
  final _manualShortDelay = TextEditingController();
  final _manualInstantaneous = TextEditingController();
  final _manualGroundPickup = TextEditingController();
  final _manualGroundDelay = TextEditingController();

  String _mode = 'Automatic preliminary';
  String _profileId = 'MYS-IEC-PRELIMINARY';
  String _mvStrategy = 'Auto';
  String _transformerType = 'Oil Immersed';
  bool _criticalLoad = false;
  bool _enhancedProtection = false;
  bool _groundFaultEnabled = true;

  List<TextEditingController> get _controllers => [
        _transformerKva,
        _primaryKv,
        _secondaryKv,
        _impedance,
        _units,
        _mvFaultKa,
        _mvFaultDuration,
        _lvFaultOverride,
        _lvBusRating,
        _manualVcbVoltage,
        _manualVcbCurrent,
        _manualVcbBreaking,
        _manualFuseCurrent,
        _manualAcbFrame,
        _manualAcbBreaking,
        _manualCtPrimary,
        _manualLongTime,
        _manualShortTime,
        _manualShortDelay,
        _manualInstantaneous,
        _manualGroundPickup,
        _manualGroundDelay,
      ];

  @override
  void initState() {
    super.initState();
    final transformer = widget.initialTransformer;
    _transformerKva = TextEditingController(
      text: (transformer?.ratedKva ?? 1000).toStringAsFixed(0),
    );
    _primaryKv = TextEditingController(
      text: (transformer?.primaryKv ?? 11).toStringAsFixed(1),
    );
    _secondaryKv = TextEditingController(
      text: (transformer?.secondaryKv ?? 0.415).toStringAsFixed(3),
    );
    _impedance = TextEditingController(
      text: (transformer?.impedancePercent ?? 6).toStringAsFixed(2),
    );
    _transformerType = transformer?.type ?? 'Oil Immersed';
    for (final controller in _controllers) {
      controller.addListener(_refresh);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
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

  double? _optional(TextEditingController controller) {
    if (controller.text.trim().isEmpty) {
      return null;
    }
    return double.tryParse(controller.text.trim());
  }

  int _integer(TextEditingController controller) =>
      int.tryParse(controller.text.trim()) ?? 0;

  ProtectionDesignInput get _input => ProtectionDesignInput(
        mode: _mode,
        profileId: _profileId,
        mvDeviceStrategy: _mvStrategy,
        transformerKva: _number(_transformerKva),
        primaryKv: _number(_primaryKv),
        secondaryKv: _number(_secondaryKv),
        impedancePercent: _number(_impedance),
        transformerType: _transformerType,
        numberOfUnits: _integer(_units),
        criticalLoad: _criticalLoad,
        enhancedProtection: _enhancedProtection,
        mvFaultCurrentKa: _number(_mvFaultKa),
        mvFaultDurationS: _number(_mvFaultDuration),
        lvFaultOverrideKa: _lvFaultOverride.text.trim().isEmpty
            ? 0
            : _number(_lvFaultOverride),
        lvBusOrCableRatingA: _lvBusRating.text.trim().isEmpty
            ? 0
            : _number(_lvBusRating),
        groundFaultEnabled: _groundFaultEnabled,
        manualVcbVoltageKv: _optional(_manualVcbVoltage),
        manualVcbCurrentA: _optional(_manualVcbCurrent),
        manualVcbBreakingKa: _optional(_manualVcbBreaking),
        manualFuseCurrentA: _optional(_manualFuseCurrent),
        manualAcbFrameA: _optional(_manualAcbFrame),
        manualAcbBreakingKa: _optional(_manualAcbBreaking),
        manualCtPrimaryA: _optional(_manualCtPrimary),
        manualLongTimePickupA: _optional(_manualLongTime),
        manualShortTimePickupA: _optional(_manualShortTime),
        manualShortTimeDelayS: _optional(_manualShortDelay),
        manualInstantaneousPickupA: _optional(_manualInstantaneous),
        manualGroundFaultPickupA: _optional(_manualGroundPickup),
        manualGroundFaultDelayS: _optional(_manualGroundDelay),
      );

  ProtectionDesignResult _evaluate() {
    final profile = _repo.protectionProfile(_profileId);
    return ProtectionCalculations.evaluate(
      input: _input,
      profile: profile,
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
  }

  @override
  Widget build(BuildContext context) {
    final result = _evaluate();
    final profile = _repo.protectionProfile(_profileId);
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          const PageHeader(
            title: 'Protection & Switchgear',
            subtitle:
                'Automatic preliminary VCB, switch-fuse, ACB, CT, relay and transformer internal-protection selection.',
            icon: Icons.security,
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Assessment mode and protection profile',
            subtitle: profile.status,
            child: _fieldGrid([
              _dropdown(
                label: 'Assessment mode',
                topicId: 'protection_status',
                value: _mode,
                values: const [
                  'Automatic preliminary',
                  'Professional manual',
                ],
                onChanged: (value) => setState(() => _mode = value),
              ),
              _dropdown(
                label: 'Protection profile',
                topicId: 'protection_profile',
                value: _profileId,
                values: _repo.protectionProfiles.map((e) => e.id).toList(),
                display: (id) => _repo.protectionProfile(id).name,
                onChanged: (value) => setState(() => _profileId = value),
              ),
              _dropdown(
                label: 'MV device strategy',
                topicId: 'mv_device_strategy',
                value: _mvStrategy,
                values: const ['Auto', 'VCB', 'Switch-fuse'],
                onChanged: (value) => setState(() => _mvStrategy = value),
              ),
              _dropdown(
                label: 'Transformer construction',
                topicId: 'internal_tx_protection',
                value: _transformerType,
                values: const ['Oil Immersed', 'Dry Type'],
                onChanged: (value) => setState(() => _transformerType = value),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 940;
              final transformerCard = SectionCard(
                title: 'Transformer and network inputs',
                child: _fieldGrid([
                  LabeledField(
                    label: 'Transformer rating',
                    topicId: 'load_kva',
                    child: _numberField(_transformerKva, 'kVA'),
                  ),
                  LabeledField(
                    label: 'Primary voltage',
                    topicId: 'system_voltage',
                    child: _numberField(_primaryKv, 'kV'),
                  ),
                  LabeledField(
                    label: 'Secondary voltage',
                    topicId: 'system_voltage',
                    child: _numberField(_secondaryKv, 'kV'),
                  ),
                  LabeledField(
                    label: 'Transformer impedance',
                    topicId: 'transformer_impedance',
                    child: _numberField(_impedance, '%'),
                  ),
                  LabeledField(
                    label: 'Number of transformer units',
                    topicId: 'redundancy',
                    child: _numberField(_units, 'units'),
                  ),
                  LabeledField(
                    label: 'MV maximum fault current',
                    topicId: 'mv_fault_duty',
                    liveValues: {
                      'Current value': '${_number(_mvFaultKa).toStringAsFixed(2)} kA',
                      'Duration': '${_number(_mvFaultDuration).toStringAsFixed(2)} s',
                    },
                    child: _numberField(_mvFaultKa, 'kA'),
                  ),
                  LabeledField(
                    label: 'MV short-time duration',
                    topicId: 'mv_fault_duty',
                    child: _numberField(_mvFaultDuration, 's'),
                  ),
                  LabeledField(
                    label: 'LV fault override',
                    topicId: 'fault_current',
                    child: _numberField(
                      _lvFaultOverride,
                      'kA (blank = transformer estimate)',
                    ),
                  ),
                  LabeledField(
                    label: 'LV busduct/cable rating',
                    topicId: 'acb_selection',
                    child: _numberField(
                      _lvBusRating,
                      'A (blank = not checked)',
                    ),
                  ),
                ]),
              );
              final philosophyCard = SectionCard(
                title: 'Protection philosophy',
                child: Column(
                  children: [
                    SwitchListTile.adaptive(
                      title: const Text('Critical / high-continuity load'),
                      subtitle: const Text(
                        'Prefers VCB, enhanced relay functions and conservative device margins.',
                      ),
                      value: _criticalLoad,
                      onChanged: (value) =>
                          setState(() => _criticalLoad = value),
                    ),
                    SwitchListTile.adaptive(
                      title: const Text('Enhanced transformer protection'),
                      subtitle: const Text(
                        'Adds differential, REF and breaker-failure applicability screening.',
                      ),
                      value: _enhancedProtection,
                      onChanged: (value) =>
                          setState(() => _enhancedProtection = value),
                    ),
                    SwitchListTile.adaptive(
                      title: const Text('ACB ground-fault function'),
                      subtitle: const Text(
                        'Provides preliminary G pickup and delay starting values.',
                      ),
                      value: _groundFaultEnabled,
                      onChanged: (value) =>
                          setState(() => _groundFaultEnabled = value),
                    ),
                    const Divider(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        profile.notes,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ),
                  ],
                ),
              );
              if (!wide) {
                return Column(
                  children: [
                    transformerCard,
                    const SizedBox(height: 16),
                    philosophyCard,
                  ],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: transformerCard),
                  const SizedBox(width: 16),
                  Expanded(flex: 2, child: philosophyCard),
                ],
              );
            },
          ),
          if (_mode == 'Professional manual') ...[
            const SizedBox(height: 16),
            _manualOverrideCard(result),
          ],
          const SizedBox(height: 16),
          _resultCard(result),
        ],
      ),
    );
  }

  Widget _manualOverrideCard(ProtectionDesignResult result) {
    return SectionCard(
      title: 'Professional manual selection and setting overrides',
      subtitle:
          'Blank values retain the automatic calculation. Entered values are checked against minimum requirements.',
      child: Column(
        children: [
          _fieldGrid([
            LabeledField(
              label: 'VCB rated voltage',
              topicId: 'vcb_selection',
              child: _numberField(_manualVcbVoltage, 'kV'),
            ),
            LabeledField(
              label: 'VCB rated current',
              topicId: 'vcb_selection',
              child: _numberField(_manualVcbCurrent, 'A'),
            ),
            LabeledField(
              label: 'VCB breaking current',
              topicId: 'vcb_selection',
              child: _numberField(_manualVcbBreaking, 'kA'),
            ),
            LabeledField(
              label: 'MV fuse current',
              topicId: 'mv_fuse_selection',
              child: _numberField(_manualFuseCurrent, 'A'),
            ),
            LabeledField(
              label: 'ACB frame / sensor',
              topicId: 'acb_selection',
              child: _numberField(_manualAcbFrame, 'A'),
            ),
            LabeledField(
              label: 'ACB breaking current',
              topicId: 'acb_selection',
              child: _numberField(_manualAcbBreaking, 'kA'),
            ),
            LabeledField(
              label: 'CT primary ratio',
              topicId: 'ct_selection',
              child: _numberField(_manualCtPrimary, 'A / 1 A'),
            ),
            LabeledField(
              label: 'Long-time pickup Ir',
              topicId: 'acb_lsig',
              child: _numberField(_manualLongTime, 'A'),
            ),
            LabeledField(
              label: 'Short-time pickup Isd',
              topicId: 'acb_lsig',
              child: _numberField(_manualShortTime, 'A'),
            ),
            LabeledField(
              label: 'Short-time delay tsd',
              topicId: 'acb_lsig',
              child: _numberField(_manualShortDelay, 's'),
            ),
            LabeledField(
              label: 'Instantaneous pickup Ii',
              topicId: 'acb_lsig',
              child: _numberField(
                _manualInstantaneous,
                'A (blank = OFF/auto)',
              ),
            ),
            LabeledField(
              label: 'Ground-fault pickup Ig',
              topicId: 'acb_lsig',
              child: _numberField(_manualGroundPickup, 'A'),
            ),
            LabeledField(
              label: 'Ground-fault delay tg',
              topicId: 'acb_lsig',
              child: _numberField(_manualGroundDelay, 's'),
            ),
          ]),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Current assessment: ${result.status.label}. Manual values do not become manufacturer-approved settings merely because the numerical checks pass.',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _resultCard(ProtectionDesignResult result) {
    return Column(
      children: [
        SectionCard(
          title: 'Automatic protection and switchgear result',
          subtitle: 'MVTX-PROTECTION-V1 • ${result.status.label}',
          trailing: Chip(label: Text(result.status.label)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResponsiveGrid(
                children: [
                  ResultTile(
                    label: 'Preferred MV protection',
                    value: result.preferredMvDevice,
                    status: result.status,
                  ),
                  ResultTile(
                    label: 'Transformer MV current',
                    value: _format(result.primaryCurrentA, 'A'),
                  ),
                  ResultTile(
                    label: 'Transformer LV current',
                    value: _format(result.secondaryCurrentA, 'A'),
                  ),
                  ResultTile(
                    label: 'Calculated / entered LV fault',
                    value: _format(result.calculatedLvFaultKa, 'kA'),
                  ),
                  ResultTile(
                    label: 'VCB requirement',
                    value:
                        '${_plain(result.vcbRatedVoltageKv)} kV • ${_plain(result.vcbRatedCurrentA)} A • ${_plain(result.vcbBreakingCurrentKa)} kA / ${_plain(result.vcbShortTimeDurationS)} s',
                  ),
                  ResultTile(
                    label: 'Switch-fuse starting point',
                    value: _format(result.fuseCurrentA, 'A'),
                  ),
                  ResultTile(
                    label: 'ACB frame / sensor',
                    value:
                        '${_plain(result.acbFrameA)} A / ${_plain(result.acbSensorA)} A',
                  ),
                  ResultTile(
                    label: 'ACB duty',
                    value:
                        'Icu ≥ ${_plain(result.acbBreakingCurrentKa)} kA • Icw ≥ ${_plain(result.acbShortTimeWithstandKa)} kA',
                  ),
                  ResultTile(label: 'ACB poles', value: result.acbPoles),
                  ResultTile(label: 'Protection CT', value: result.ctRatio),
                  ResultTile(
                    label: 'ACB Ir / Isd',
                    value:
                        '${_plain(result.longTimePickupA)} A / ${_plain(result.shortTimePickupA)} A',
                  ),
                  ResultTile(
                    label: 'ACB Ii',
                    value: result.instantaneousPickupA == null
                        ? 'OFF / manufacturer review'
                        : _format(result.instantaneousPickupA!, 'A'),
                  ),
                  ResultTile(
                    label: 'ACB ground fault',
                    value: result.groundFaultPickupA == null
                        ? 'Not selected'
                        : '${_plain(result.groundFaultPickupA!)} A / ${_plain(result.groundFaultDelayS!)} s',
                  ),
                  ResultTile(
                    label: 'Relay 51 pickup start',
                    value: _format(result.phaseOvercurrentPickupA, 'A'),
                  ),
                  ResultTile(
                    label: 'Relay earth-fault pickup start',
                    value: _format(result.earthFaultPickupA, 'A'),
                  ),
                  ResultTile(
                    label: 'Relay high-set start',
                    value: result.highSetPickupA == null
                        ? 'Not recommended generically'
                        : _format(result.highSetPickupA!, 'A'),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                'CT class guidance',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
              const SizedBox(height: 4),
              Text(result.ctClassGuidance),
            ],
          ),
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 940;
            final relay = _listCard(
              title: 'Recommended relay functions',
              subtitle: 'Applicability screening — settings remain VERIFY',
              items: result.relayFunctions,
              topicId: 'relay_functions',
            );
            final internal = _listCard(
              title: 'Transformer internal protection',
              subtitle: _transformerType,
              items: result.internalProtection,
              topicId: 'internal_tx_protection',
            );
            if (!wide) {
              return Column(
                children: [relay, const SizedBox(height: 16), internal],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: relay),
                const SizedBox(width: 16),
                Expanded(child: internal),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 940;
            final vcb = _listCard(
              title: 'Matching VCB product families',
              subtitle: 'Family-level candidates only',
              items: result.vcbCandidateFamilies.isEmpty
                  ? const ['No controlled family covers the selected voltage class.']
                  : result.vcbCandidateFamilies,
              topicId: 'vcb_selection',
            );
            final acb = _listCard(
              title: 'Matching ACB product families',
              subtitle: 'Family-level candidates only',
              items: result.acbCandidateFamilies.isEmpty
                  ? const ['No controlled family covers the selected frame rating.']
                  : result.acbCandidateFamilies,
              topicId: 'acb_selection',
            );
            if (!wide) {
              return Column(
                children: [vcb, const SizedBox(height: 16), acb],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: vcb),
                const SizedBox(width: 16),
                Expanded(child: acb),
              ],
            );
          },
        ),
        const SizedBox(height: 16),
        SectionCard(
          title: 'Safeguards and required verification',
          subtitle: 'The app intentionally does not claim final coordination',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final message in result.messages)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.shield_outlined, size: 18),
                      const SizedBox(width: 8),
                      Expanded(child: Text(message)),
                    ],
                  ),
                ),
              const Divider(),
              Text(
                _repo.protectionSafeguard,
                style: const TextStyle(fontWeight: FontWeight.w800),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _listCard({
    required String title,
    required String subtitle,
    required List<String> items,
    required String topicId,
  }) {
    return SectionCard(
      title: title,
      subtitle: subtitle,
      trailing: HelperButton(topicId: topicId, information: true),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.check_circle_outline, size: 18),
                  const SizedBox(width: 8),
                  Expanded(child: Text(item)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _fieldGrid(List<Widget> children) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final count = constraints.maxWidth >= 1040
            ? 3
            : constraints.maxWidth >= 620
                ? 2
                : 1;
        return GridView.count(
          crossAxisCount: count,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: count == 1 ? 3.0 : 2.25,
          children: children,
        );
      },
    );
  }

  Widget _numberField(TextEditingController controller, String suffix) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      decoration: InputDecoration(suffixText: suffix),
    );
  }

  Widget _dropdown({
    required String label,
    required String topicId,
    required String value,
    required List<String> values,
    required ValueChanged<String> onChanged,
    String Function(String value)? display,
  }) {
    return LabeledField(
      label: label,
      topicId: topicId,
      child: DropdownButtonFormField<String>(
        key: ValueKey('$label|${values.contains(value) ? value : values.first}'),
        initialValue: values.contains(value) ? value : values.first,
        isExpanded: true,
        items: values
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  display?.call(item) ?? item,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
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
    return '${_plain(value)} $unit';
  }

  String _plain(double value) {
    if (!value.isFinite) {
      return 'Not assessed';
    }
    final decimals = value.abs() >= 100 ? 0 : value.abs() >= 10 ? 1 : 2;
    return value.toStringAsFixed(decimals);
  }
}
