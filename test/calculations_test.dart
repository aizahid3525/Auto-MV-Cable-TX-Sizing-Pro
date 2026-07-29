import 'package:auto_mv_cable_tx_sizing_pro/calculations.dart';
import 'package:auto_mv_cable_tx_sizing_pro/models.dart';
import 'package:auto_mv_cable_tx_sizing_pro/protection_calculations.dart';
import 'package:auto_mv_cable_tx_sizing_pro/protection_models.dart';
import 'package:flutter_test/flutter_test.dart';

void calculationRegressionTests() {
  test('three-phase current regression', () {
    final current = EngineeringCalculations.designCurrentA(kva: 1000, kv: 11);
    expect(current, closeTo(52.4863881081, 1e-6));
  });

  test('cable evaluation checks ampacity, voltage drop and fault withstand', () {
    const cable = MvCableRecord(
      id: 'TEST',
      brand: 'Test',
      manufacturer: 'Test',
      family: 'XLPE',
      voltageDesignation: '6.35/11 kV',
      systemKv: 11,
      cores: '1 Core',
      conductor: 'Copper',
      sizeMm2: 240,
      insulation: 'XLPE',
      screenMm2: 25,
      armour: 'AWA',
      ampacityAirA: 400,
      ampacityBuriedA: 350,
      ampacityDuctA: 300,
      resistanceOhmPerKm: 0.125,
      reactanceTrefoilOhmPerKm: 0.1,
      capacitanceUfPerKm: 0.25,
      dataStatus: 'REFERENCE',
      sourceUrl: 'https://example.com',
      notes: 'Test record',
    );
    const input = CableDesignInput(
      systemKv: 11,
      loadKva: 1000,
      powerFactor: 0.9,
      lengthM: 300,
      parallelRuns: 1,
      deratingFactor: 0.85,
      voltageDropLimitPercent: 3,
      faultCurrentKa: 20,
      faultTimeS: 1,
      installationMethod: 'Direct buried',
      screenBonding: 'Both-end bonded',
    );
    final result = EngineeringCalculations.evaluateCable(input, cable);
    expect(result.designCurrentA, closeTo(52.4863881081, 1e-6));
    expect(result.deratedAmpacityA, closeTo(297.5, 1e-9));
    expect(result.shortCircuitWithstandKa, closeTo(34.32, 1e-9));
    expect(result.status, AssessmentStatus.verify);
  });

  test('transformer terminal fault current regression', () {
    const transformer = TransformerRecord(
      id: 'TEST',
      brand: 'Test',
      manufacturer: 'Test',
      type: 'Oil Immersed',
      ratedKva: 1000,
      primaryKv: 11,
      secondaryKv: 0.415,
      vectorGroup: 'Dyn11',
      impedancePercent: 6,
      tapRangePercent: 5,
      cooling: 'ONAN',
      noLoadLossKw: 1.8,
      loadLossKw: 9,
      dataStatus: 'REFERENCE',
      sourceUrl: 'https://example.com',
      notes: 'Test record',
    );
    const input = TransformerDesignInput(
      connectedLoadKw: 650,
      powerFactor: 0.9,
      efficiency: 0.98,
      demandFactor: 0.9,
      futureGrowthPercent: 15,
      harmonicFactor: 1,
      motorStartingFactor: 1,
      numberOfUnits: 1,
    );
    final result = EngineeringCalculations.evaluateTransformer(input, transformer);
    expect(result.approxFaultCurrentKa, closeTo(23.1867577988, 1e-6));
    expect(result.status, AssessmentStatus.verify);
  });
}

// Protection and switchgear regression tests are separated from final
// manufacturer selection. They verify the controlled rating-envelope logic.
void protectionRegressionTests() {
  test('automatic protection selects VCB/ACB/CT rating envelopes', () {
    const profile = ProtectionProfileRecord(
      id: 'MYS-IEC-PRELIMINARY',
      name: 'Malaysia / IEC preliminary screening',
      fusePreferenceMaximumKva: 1000,
      enhancedProtectionThresholdKva: 2500,
      preferredCtNormalLoadingPercent: 80,
      vcbMinimumRatedCurrentA: 630,
      mvFaultMarginFactor: 1,
      lvBreakingMarginFactor: 1.1,
      status: 'ENGINEERING PRESET',
      notes: 'Test profile',
    );
    const input = ProtectionDesignInput(
      mode: 'Automatic preliminary',
      profileId: 'MYS-IEC-PRELIMINARY',
      mvDeviceStrategy: 'Auto',
      transformerKva: 1000,
      primaryKv: 11,
      secondaryKv: 0.415,
      impedancePercent: 6,
      transformerType: 'Oil Immersed',
      numberOfUnits: 1,
      criticalLoad: false,
      enhancedProtection: false,
      mvFaultCurrentKa: 20,
      mvFaultDurationS: 3,
      lvFaultOverrideKa: 0,
      lvBusOrCableRatingA: 0,
      groundFaultEnabled: true,
    );
    final result = ProtectionCalculations.evaluate(
      input: input,
      profile: profile,
      ctRatios: const [50, 75, 100, 150, 200],
      acbFrames: const [630, 800, 1000, 1250, 1600, 2000],
      acbBreakingRatings: const [42, 50, 65, 85, 100],
      vcbVoltages: const [7.2, 12, 24, 36],
      vcbCurrents: const [630, 800, 1250],
      vcbBreakingRatings: const [20, 25, 31.5, 40],
      fuseRatings: const [40, 50, 63, 80, 100, 125],
      productFamilies: const [],
      internalProtectionDatabase: const [],
    );
    expect(result.status, AssessmentStatus.verify);
    expect(result.preferredMvDevice, 'MV switch-fuse combination');
    expect(result.vcbRatedVoltageKv, 12);
    expect(result.vcbRatedCurrentA, 630);
    expect(result.vcbBreakingCurrentKa, 20);
    expect(result.fuseCurrentA, 80);
    expect(result.acbFrameA, 1600);
    expect(result.acbBreakingCurrentKa, 42);
    expect(result.ctRatio, '75/1 A');
  });

  test('manual undersized protection selection fails closed', () {
    const profile = ProtectionProfileRecord(
      id: 'MYS-IEC-PRELIMINARY',
      name: 'Malaysia / IEC preliminary screening',
      fusePreferenceMaximumKva: 1000,
      enhancedProtectionThresholdKva: 2500,
      preferredCtNormalLoadingPercent: 80,
      vcbMinimumRatedCurrentA: 630,
      mvFaultMarginFactor: 1,
      lvBreakingMarginFactor: 1.1,
      status: 'ENGINEERING PRESET',
      notes: 'Test profile',
    );
    const input = ProtectionDesignInput(
      mode: 'Professional manual',
      profileId: 'MYS-IEC-PRELIMINARY',
      mvDeviceStrategy: 'VCB',
      transformerKva: 1000,
      primaryKv: 11,
      secondaryKv: 0.415,
      impedancePercent: 6,
      transformerType: 'Oil Immersed',
      numberOfUnits: 1,
      criticalLoad: false,
      enhancedProtection: false,
      mvFaultCurrentKa: 20,
      mvFaultDurationS: 3,
      lvFaultOverrideKa: 0,
      lvBusOrCableRatingA: 1500,
      groundFaultEnabled: true,
      manualVcbVoltageKv: 7.2,
      manualVcbCurrentA: 50,
      manualVcbBreakingKa: 16,
      manualAcbFrameA: 1250,
      manualAcbBreakingKa: 20,
      manualCtPrimaryA: 50,
    );
    final result = ProtectionCalculations.evaluate(
      input: input,
      profile: profile,
      ctRatios: const [50, 75, 100, 150, 200],
      acbFrames: const [630, 800, 1000, 1250, 1600, 2000],
      acbBreakingRatings: const [42, 50, 65, 85, 100],
      vcbVoltages: const [7.2, 12, 24, 36],
      vcbCurrents: const [630, 800, 1250],
      vcbBreakingRatings: const [20, 25, 31.5, 40],
      fuseRatings: const [40, 50, 63, 80, 100, 125],
      productFamilies: const [],
      internalProtectionDatabase: const [],
    );
    expect(result.status, AssessmentStatus.fail);
  });
}

void main() {
  calculationRegressionTests();
  protectionRegressionTests();
}
