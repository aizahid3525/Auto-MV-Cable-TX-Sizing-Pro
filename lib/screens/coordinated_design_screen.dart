import 'package:flutter/material.dart';

import '../calculations.dart';
import '../data_repository.dart';
import '../models.dart';
import '../protection_calculations.dart';
import '../protection_models.dart';
import '../services/report_service.dart';
import '../widgets/common_widgets.dart';

class CoordinatedDesignScreen extends StatefulWidget {
  const CoordinatedDesignScreen({super.key});

  @override
  State<CoordinatedDesignScreen> createState() => _CoordinatedDesignScreenState();
}

class _CoordinatedDesignScreenState extends State<CoordinatedDesignScreen> {
  final _repo = EngineeringRepository.instance;
  final _connectedKw = TextEditingController(text: '650');
  final _powerFactor = TextEditingController(text: '0.90');
  final _lengthM = TextEditingController(text: '300');
  final _faultKa = TextEditingController(text: '20');
  final _faultTime = TextEditingController(text: '1');
  final _growth = TextEditingController(text: '15');
  final _demand = TextEditingController(text: '0.90');
  final _derating = TextEditingController(text: '0.85');
  double _systemKv = 11;
  String _installationMethod = 'Direct buried';
  String _screenBonding = 'Both-end bonded';
  TransformerRecord? _transformer;
  MvCableRecord? _cable;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _connectedKw,
      _powerFactor,
      _lengthM,
      _faultKa,
      _faultTime,
      _growth,
      _demand,
      _derating,
    ]) {
      controller.addListener(_refresh);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoSelect());
  }

  @override
  void dispose() {
    for (final controller in [
      _connectedKw,
      _powerFactor,
      _lengthM,
      _faultKa,
      _faultTime,
      _growth,
      _demand,
      _derating,
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

  double _n(TextEditingController controller) =>
      double.tryParse(controller.text.trim()) ?? double.nan;

  TransformerDesignInput get _txInput => TransformerDesignInput(
        connectedLoadKw: _n(_connectedKw),
        powerFactor: _n(_powerFactor),
        efficiency: 0.98,
        demandFactor: _n(_demand),
        futureGrowthPercent: _n(_growth),
        harmonicFactor: 1,
        motorStartingFactor: 1,
        numberOfUnits: 1,
      );

  void _autoSelect() {
    final transformers = _repo.transformers
        .where((e) => (e.primaryKv - _systemKv).abs() < 0.25)
        .toList()
      ..sort((a, b) => a.ratedKva.compareTo(b.ratedKva));
    TransformerRecord? tx;
    TransformerDesignResult? txResult;
    for (final record in transformers) {
      final result = EngineeringCalculations.evaluateTransformer(_txInput, record);
      if (result.status != AssessmentStatus.fail && result.normalLoadingPercent <= 90) {
        tx = record;
        txResult = result;
        break;
      }
    }
    tx ??= transformers.lastOrNull;
    if (tx == null) {
      setState(() {
        _transformer = null;
        _cable = null;
      });
      return;
    }
    txResult ??= EngineeringCalculations.evaluateTransformer(_txInput, tx);
    final cableLoadKva = tx.ratedKva;
    final cableInput = CableDesignInput(
      systemKv: _systemKv,
      loadKva: cableLoadKva,
      powerFactor: _n(_powerFactor),
      lengthM: _n(_lengthM),
      parallelRuns: 1,
      deratingFactor: _n(_derating),
      voltageDropLimitPercent: 3,
      faultCurrentKa: _n(_faultKa),
      faultTimeS: _n(_faultTime),
      installationMethod: _installationMethod,
      screenBonding: _screenBonding,
    );
    final cables = _repo.cables
        .where((e) => (e.systemKv - _systemKv).abs() < 0.25)
        .toList()
      ..sort((a, b) => a.sizeMm2.compareTo(b.sizeMm2));
    MvCableRecord? cable;
    for (final record in cables) {
      final result = EngineeringCalculations.evaluateCable(cableInput, record);
      if (result.status != AssessmentStatus.fail &&
          result.status != AssessmentStatus.notAssessed) {
        cable = record;
        break;
      }
    }
    cable ??= cables.lastOrNull;
    setState(() {
      _transformer = tx;
      _cable = cable;
    });
  }

  @override
  Widget build(BuildContext context) {
    final tx = _transformer;
    final cable = _cable;
    final txResult = tx == null
        ? null
        : EngineeringCalculations.evaluateTransformer(_txInput, tx);
    final cableInput = tx == null
        ? null
        : CableDesignInput(
            systemKv: _systemKv,
            loadKva: tx.ratedKva,
            powerFactor: _n(_powerFactor),
            lengthM: _n(_lengthM),
            parallelRuns: 1,
            deratingFactor: _n(_derating),
            voltageDropLimitPercent: 3,
            faultCurrentKa: _n(_faultKa),
            faultTimeS: _n(_faultTime),
            installationMethod: _installationMethod,
            screenBonding: _screenBonding,
          );
    final cableResult = cable == null || cableInput == null
        ? null
        : EngineeringCalculations.evaluateCable(cableInput, cable);
    final protectionResult = tx == null
        ? null
        : ProtectionCalculations.evaluate(
            input: ProtectionDesignInput(
              mode: 'Automatic preliminary',
              profileId: 'MYS-IEC-PRELIMINARY',
              mvDeviceStrategy: 'Auto',
              transformerKva: tx.ratedKva,
              primaryKv: tx.primaryKv,
              secondaryKv: tx.secondaryKv,
              impedancePercent: tx.impedancePercent,
              transformerType: tx.type,
              numberOfUnits: 1,
              criticalLoad: false,
              enhancedProtection: false,
              mvFaultCurrentKa: _n(_faultKa),
              mvFaultDurationS: _n(_faultTime),
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
      values: _helpValues(
        txResult: txResult,
        cableResult: cableResult,
        protectionResult: protectionResult,
        transformer: tx,
        cable: cable,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
        children: [
          const PageHeader(
            title: 'Cable + TX Coordination',
            subtitle: 'Select the transformer and upstream MV feeder as one preliminary engineering workflow.',
            icon: Icons.account_tree,
          ),
          const SizedBox(height: 16),
          SectionCard(
            title: 'Project inputs',
            trailing: FilledButton.icon(
              onPressed: _autoSelect,
              icon: const Icon(Icons.auto_awesome),
              label: const Text('Recalculate'),
            ),
            child: ResponsiveGrid(
              minItemWidth: 145,
              children: [
                  LabeledField(
                    label: 'MV system voltage',
                    topicId: 'system_voltage',
                    child: DropdownButtonFormField<double>(
                      initialValue: _systemKv,
                      items: const [
                        DropdownMenuItem(value: 6.6, child: Text('6.6 kV')),
                        DropdownMenuItem(value: 11, child: Text('11 kV')),
                        DropdownMenuItem(value: 22, child: Text('22 kV')),
                        DropdownMenuItem(value: 33, child: Text('33 kV')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _systemKv = value;
                          _autoSelect();
                        }
                      },
                    ),
                  ),
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
                    label: 'Demand factor',
                    topicId: 'demand_factor',
                    child: _numberField(_demand, 'p.u.'),
                  ),
                  LabeledField(
                    label: 'Future growth',
                    topicId: 'future_growth',
                    child: _numberField(_growth, '%'),
                  ),
                  LabeledField(
                    label: 'MV route length',
                    topicId: 'voltage_drop',
                    child: _numberField(_lengthM, 'm'),
                  ),
                  LabeledField(
                    label: 'Derating factor',
                    topicId: 'ambient_temperature',
                    child: _numberField(_derating, 'p.u.'),
                  ),
                  LabeledField(
                    label: 'MV fault current',
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
                      onChanged: (value) {
                        if (value != null) {
                          _installationMethod = value;
                          _autoSelect();
                        }
                      },
                    ),
                  ),
                  LabeledField(
                    label: 'Screen bonding',
                    topicId: 'screen_bonding',
                    child: DropdownButtonFormField<String>(
                      initialValue: _screenBonding,
                      items: const [
                        DropdownMenuItem(value: 'Single-point bonded', child: Text('Single-point bonded')),
                        DropdownMenuItem(value: 'Both-end bonded', child: Text('Both-end bonded')),
                        DropdownMenuItem(value: 'Cross-bonded', child: Text('Cross-bonded')),
                      ],
                      onChanged: (value) {
                        if (value != null) {
                          _screenBonding = value;
                          _autoSelect();
                        }
                      },
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (txResult == null || cableResult == null || protectionResult == null)
            const SectionCard(
              title: 'Coordinated result',
              child: Text('No compatible controlled records are available for the selected voltage.'),
            )
          else
            SectionCard(
              title: 'Coordinated preliminary result',
              subtitle: 'Transformer demand sets the MV feeder current basis',
              trailing: OutlinedButton.icon(
                onPressed: () => ReportService.previewCoordinatedReport(
                  cable: cableResult,
                  transformer: txResult,
                  protection: protectionResult,
                ),
                icon: const Icon(Icons.picture_as_pdf),
                label: const Text('PDF report'),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveGrid(
                    children: [
                      ResultTile(label: 'Transformer', value: txResult.transformer.shortLabel),
                      ResultTile(label: 'Design demand', value: '${txResult.designDemandKva.toStringAsFixed(2)} kVA'),
                      ResultTile(label: 'Transformer loading', value: '${txResult.normalLoadingPercent.toStringAsFixed(2)} %'),
                      ResultTile(label: 'MV feeder current', value: '${txResult.primaryCurrentA.toStringAsFixed(2)} A'),
                      ResultTile(label: 'MV cable', value: cableResult.cable.shortLabel),
                      ResultTile(label: 'Cable loading', value: '${cableResult.loadingPercent.toStringAsFixed(2)} %'),
                      ResultTile(label: 'Voltage drop', value: '${cableResult.voltageDropPercent.toStringAsFixed(3)} %'),
                      ResultTile(label: 'Cable status', value: cableResult.status.label, status: cableResult.status),
                      ResultTile(label: 'Preferred MV protection', value: protectionResult.preferredMvDevice, status: protectionResult.status),
                      ResultTile(label: 'VCB requirement', value: '${protectionResult.vcbRatedVoltageKv.toStringAsFixed(1)} kV • ${protectionResult.vcbRatedCurrentA.toStringAsFixed(0)} A • ${protectionResult.vcbBreakingCurrentKa.toStringAsFixed(1)} kA'),
                      ResultTile(label: 'LV ACB', value: '${protectionResult.acbFrameA.toStringAsFixed(0)} A • Icu ≥ ${protectionResult.acbBreakingCurrentKa.toStringAsFixed(1)} kA'),
                      ResultTile(label: 'Protection CT', value: protectionResult.ctRatio),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'This coordinated workflow includes automatic preliminary protection selection. Exact VCB/fuse/ACB models, CT class and saturation, relay and LSIG settings, transformer inrush, switchgear type tests, discrimination and cable screen/sheath design require project-specific verification.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Map<String, Object?> _helpValues({
    required TransformerDesignResult? txResult,
    required CableDesignResult? cableResult,
    required ProtectionDesignResult? protectionResult,
    required TransformerRecord? transformer,
    required MvCableRecord? cable,
  }) {
    return <String, Object?>{
      'systemKv': _systemKv,
      'connectedLoadKw': _n(_connectedKw),
      'loadKva': transformer?.ratedKva,
      'powerFactor': _n(_powerFactor),
      'efficiency': 0.98,
      'demandFactor': _n(_demand),
      'futureGrowthPercent': _n(_growth),
      'harmonicFactor': 1.0,
      'motorStartingFactor': 1.0,
      'numberOfUnits': 1.0,
      'lengthM': _n(_lengthM),
      'parallelRuns': 1.0,
      'deratingFactor': _n(_derating),
      'voltageDropLimitPercent': 3.0,
      'faultCurrentKa': _n(_faultKa),
      'faultTimeS': _n(_faultTime),
      'installationMethod': _installationMethod,
      'screenBonding': _screenBonding,
      'transformerType': transformer?.type,
      'transformerRatingKva': transformer?.ratedKva,
      'transformerRatedKva': transformer?.ratedKva,
      'primaryKv': transformer?.primaryKv ?? _systemKv,
      'secondaryKv': transformer?.secondaryKv,
      'impedancePercent': transformer?.impedancePercent,
      'vectorGroup': transformer?.vectorGroup,
      'coolingClass': transformer?.cooling,
      'noLoadLossKw': transformer?.noLoadLossKw,
      'loadLossKw': transformer?.loadLossKw,
      'designDemandKva': txResult?.designDemandKva,
      'normalLoadingPercent': txResult?.normalLoadingPercent,
      'outageLoadingPercent': txResult?.outageLoadingPercent,
      'primaryCurrentA': txResult?.primaryCurrentA,
      'secondaryCurrentA': txResult?.secondaryCurrentA,
      'calculatedLvFaultKa': txResult?.approxFaultCurrentKa,
      'totalLossKw': txResult?.totalLossKw,
      'efficiencyPercent': txResult?.efficiencyPercent,
      'approxRegulationPercent': txResult?.approxRegulationPercent,
      'cableBrand': cable?.brand,
      'cableFamily': cable?.family,
      'numberOfCores': cable?.cores,
      'conductorMaterial': cable?.conductor,
      'cableSizeMm2': cable?.sizeMm2,
      'baseAmpacityA': cable == null ? null : cable.ampacityFor(_installationMethod),
      'resistanceOhmPerKm': cable?.resistanceOhmPerKm,
      'reactanceOhmPerKm': cable?.reactanceTrefoilOhmPerKm,
      'capacitanceUfPerKm': cable?.capacitanceUfPerKm,
      'designCurrentA': cableResult?.designCurrentA,
      'deratedAmpacityA': cableResult?.deratedAmpacityA,
      'cableLoadingPercent': cableResult?.loadingPercent,
      'loadingPercent': cableResult?.loadingPercent,
      'voltageDropV': cableResult?.voltageDropV,
      'voltageDropPercent': cableResult?.voltageDropPercent,
      'shortCircuitWithstandKa': cableResult?.shortCircuitWithstandKa,
      'chargingCurrentA': cableResult?.chargingCurrentA,
      'cableLossKw': cableResult?.lossKw,
      'lossKw': cableResult?.lossKw,
      'preferredMvDevice': protectionResult?.preferredMvDevice,
      'vcbRatedVoltageKv': protectionResult?.vcbRatedVoltageKv,
      'vcbRatedCurrentA': protectionResult?.vcbRatedCurrentA,
      'vcbBreakingCurrentKa': protectionResult?.vcbBreakingCurrentKa,
      'fuseCurrentA': protectionResult?.fuseCurrentA,
      'acbFrameA': protectionResult?.acbFrameA,
      'acbSensorA': protectionResult?.acbSensorA,
      'acbBreakingCurrentKa': protectionResult?.acbBreakingCurrentKa,
      'ctRatio': protectionResult?.ctRatio,
      'acbPoles': protectionResult?.acbPoles,
      'acbShortTimeWithstandKa': protectionResult?.acbShortTimeWithstandKa,
      'phaseOvercurrentPickupA': protectionResult?.phaseOvercurrentPickupA,
      'earthFaultPickupA': protectionResult?.earthFaultPickupA,
      'highSetPickupA': protectionResult?.highSetPickupA,
      'longTimePickupA': protectionResult?.longTimePickupA,
      'shortTimePickupA': protectionResult?.shortTimePickupA,
      'shortTimeDelayS': protectionResult?.shortTimeDelayS,
      'instantaneousPickupA': protectionResult?.instantaneousPickupA,
      'groundFaultPickupA': protectionResult?.groundFaultPickupA,
      'groundFaultDelayS': protectionResult?.groundFaultDelayS,
      'protectionStatus': protectionResult?.status.label,
      'cableStatus': cableResult?.status.label,
      'transformerStatus': txResult?.status.label,
    };
  }

  Widget _numberField(TextEditingController controller, String suffix) => TextField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        decoration: InputDecoration(suffixText: suffix),
      );
}

extension _LastOrNull<T> on Iterable<T> {
  T? get lastOrNull => isEmpty ? null : last;
}
