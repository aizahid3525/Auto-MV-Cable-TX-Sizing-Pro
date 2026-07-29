import 'dart:math' as math;

import 'calculations.dart';
import 'models.dart';
import 'protection_models.dart';

class ProtectionCalculations {
  const ProtectionCalculations._();

  static ProtectionDesignResult evaluate({
    required ProtectionDesignInput input,
    required ProtectionProfileRecord profile,
    required List<double> ctRatios,
    required List<double> acbFrames,
    required List<double> acbBreakingRatings,
    required List<double> vcbVoltages,
    required List<double> vcbCurrents,
    required List<double> vcbBreakingRatings,
    required List<double> fuseRatings,
    required List<ProtectionDeviceRecord> productFamilies,
    required List<InternalProtectionRecord> internalProtectionDatabase,
  }) {
    final messages = <String>[];
    if (input.transformerKva <= 0 ||
        input.primaryKv <= 0 ||
        input.secondaryKv <= 0 ||
        input.impedancePercent <= 0 ||
        input.mvFaultCurrentKa <= 0 ||
        input.mvFaultDurationS <= 0 ||
        input.numberOfUnits < 1 ||
        profile.preferredCtNormalLoadingPercent <= 0) {
      return _notAssessed(messages: const [
        'Correct invalid or incomplete transformer, voltage, impedance and fault-duty inputs.',
      ]);
    }

    final primaryCurrentA = EngineeringCalculations.designCurrentA(
      kva: input.transformerKva,
      kv: input.primaryKv,
    );
    final secondaryCurrentA = EngineeringCalculations.designCurrentA(
      kva: input.transformerKva,
      kv: input.secondaryKv,
    );
    final calculatedLvFaultKa = input.lvFaultOverrideKa > 0
        ? input.lvFaultOverrideKa
        : secondaryCurrentA / (input.impedancePercent / 100) / 1000;

    final enhancedRequired = input.enhancedProtection ||
        input.criticalLoad ||
        input.numberOfUnits > 1 ||
        input.transformerKva >= profile.enhancedProtectionThresholdKva;
    final autoPrefersVcb = enhancedRequired ||
        profile.fusePreferenceMaximumKva <= 0 ||
        input.transformerKva > profile.fusePreferenceMaximumKva;

    String preferredMvDevice;
    switch (input.mvDeviceStrategy) {
      case 'VCB':
        preferredMvDevice = 'VCB + numerical relay';
        break;
      case 'Switch-fuse':
        preferredMvDevice = 'MV switch-fuse combination';
        break;
      default:
        preferredMvDevice = autoPrefersVcb
            ? 'VCB + numerical relay'
            : 'MV switch-fuse combination';
    }

    if (input.mvDeviceStrategy == 'Switch-fuse' && enhancedRequired) {
      messages.add(
        'Manual switch-fuse preference conflicts with the selected critical, parallel or enhanced-protection conditions. VCB assessment is strongly recommended.',
      );
    }

    final manual = input.mode == 'Professional manual';
    final requiredVcbVoltage = _next(
      vcbVoltages,
      input.primaryKv <= 6.6
          ? 7.2
          : input.primaryKv <= 11
              ? 12
              : input.primaryKv <= 22
                  ? 24
                  : 36,
    );
    final requiredVcbCurrent = _next(
      vcbCurrents,
      math.max(primaryCurrentA * 1.25, profile.vcbMinimumRatedCurrentA),
    );
    final requiredVcbBreaking = _next(
      vcbBreakingRatings,
      input.mvFaultCurrentKa * math.max(1.0, profile.mvFaultMarginFactor),
    );

    final vcbRatedVoltageKv = manual && _positive(input.manualVcbVoltageKv)
        ? input.manualVcbVoltageKv!
        : requiredVcbVoltage;
    final vcbRatedCurrentA = manual && _positive(input.manualVcbCurrentA)
        ? input.manualVcbCurrentA!
        : requiredVcbCurrent;
    final vcbBreakingCurrentKa =
        manual && _positive(input.manualVcbBreakingKa)
            ? input.manualVcbBreakingKa!
            : requiredVcbBreaking;

    final requiredFuse = _next(fuseRatings, primaryCurrentA * 1.5);
    final fuseCurrentA = manual && _positive(input.manualFuseCurrentA)
        ? input.manualFuseCurrentA!
        : requiredFuse;

    final requiredAcbFrame = _next(acbFrames, secondaryCurrentA * 1.05);
    final requiredAcbBreaking = _next(
      acbBreakingRatings,
      calculatedLvFaultKa * math.max(1.0, profile.lvBreakingMarginFactor),
    );
    final acbFrameA = manual && _positive(input.manualAcbFrameA)
        ? input.manualAcbFrameA!
        : requiredAcbFrame;
    final acbBreakingCurrentKa =
        manual && _positive(input.manualAcbBreakingKa)
            ? input.manualAcbBreakingKa!
            : requiredAcbBreaking;
    final acbSensorA = acbFrameA;
    final acbShortTimeWithstandKa = math.min(acbBreakingCurrentKa, 100.0);
    final acbPoles = input.secondaryKv <= 0.5 ? '4P preferred for 3P4W system' : '3P/4P — verify system';

    final targetCtLoading = profile.preferredCtNormalLoadingPercent / 100;
    final requiredCtPrimary = _next(ctRatios, primaryCurrentA / targetCtLoading);
    final ctPrimaryA = manual && _positive(input.manualCtPrimaryA)
        ? input.manualCtPrimaryA!
        : requiredCtPrimary;
    final ctRatio = '${ctPrimaryA.toStringAsFixed(ctPrimaryA % 1 == 0 ? 0 : 1)}/1 A';
    final ctClassGuidance = enhancedRequired
        ? 'Separate protection cores; 5P/10P for OC/EF and PX/PS or relay-specific class for 87T/REF'
        : 'Protection core starting point: 5P20, burden and ALF to be calculated';

    final autoLongTime = secondaryCurrentA;
    final longTimePickupA = manual && _positive(input.manualLongTimePickupA)
        ? input.manualLongTimePickupA!
        : autoLongTime;
    final availableFaultA = calculatedLvFaultKa * 1000;
    final autoShortTime = math.min(longTimePickupA * 6, availableFaultA * 0.8);
    final shortTimePickupA = manual && _positive(input.manualShortTimePickupA)
        ? input.manualShortTimePickupA!
        : math.max(longTimePickupA * 2, autoShortTime);
    final shortTimeDelayS = manual && _positive(input.manualShortTimeDelayS)
        ? input.manualShortTimeDelayS!
        : 0.3;
    final faultMultiple = availableFaultA / longTimePickupA;
    final autoInstantaneous = faultMultiple >= 14 ? longTimePickupA * 12 : null;
    final instantaneousPickupA = manual
        ? (_positive(input.manualInstantaneousPickupA)
            ? input.manualInstantaneousPickupA
            : null)
        : autoInstantaneous;
    final groundFaultPickupA = input.groundFaultEnabled
        ? (manual && _positive(input.manualGroundFaultPickupA)
            ? input.manualGroundFaultPickupA!
            : acbFrameA * 0.2)
        : null;
    final groundFaultDelayS = input.groundFaultEnabled
        ? (manual && _positive(input.manualGroundFaultDelayS)
            ? input.manualGroundFaultDelayS!
            : 0.2)
        : null;

    final phaseOvercurrentPickupA = primaryCurrentA * 1.2;
    final earthFaultPickupA = math.max(primaryCurrentA * 0.2, 5.0);
    final highSetPickupA = input.mvFaultCurrentKa * 1000 / primaryCurrentA >= 12
        ? math.min(primaryCurrentA * 10, input.mvFaultCurrentKa * 1000 * 0.8)
        : null;

    final relayFunctions = <String>[
      '51 — time-delayed phase overcurrent',
      '50N/51N — earth-fault overcurrent',
      '49 — transformer thermal protection',
      '74TCS — trip-circuit supervision for VCB scheme',
    ];
    if (highSetPickupA != null) {
      relayFunctions.insert(0, '50 — instantaneous/high-set phase overcurrent');
    }
    if (input.criticalLoad) {
      relayFunctions.add('46 — negative-sequence / unbalance');
    }
    if (enhancedRequired) {
      relayFunctions.addAll([
        '87T — transformer differential, subject to CT and stability study',
        '64REF — restricted earth fault where winding/neutral arrangement permits',
        '50BF — breaker-failure logic for critical trip scheme',
      ]);
    }

    final internalProtection = internalProtectionDatabase
        .where((record) =>
            record.transformerType == 'All' ||
            input.transformerType.toLowerCase().contains(
                  record.transformerType.toLowerCase().split(' ').first,
                ))
        .map((record) => '${record.item} — ${record.applicability}')
        .toList(growable: false);

    final vcbCandidateFamilies = productFamilies
        .where((record) =>
            record.category == 'VCB family' &&
            record.ratedVoltageKv >= vcbRatedVoltageKv)
        .map((record) => record.shortLabel)
        .toSet()
        .toList()
      ..sort();
    final acbCandidateFamilies = productFamilies
        .where((record) =>
            record.category == 'ACB family' &&
            record.ratedCurrentA >= acbFrameA)
        .map((record) => record.shortLabel)
        .toSet()
        .toList()
      ..sort();

    var failed = false;
    if (!requiredVcbVoltage.isFinite ||
        !requiredVcbCurrent.isFinite ||
        !requiredVcbBreaking.isFinite) {
      failed = true;
      messages.add('No controlled VCB rating envelope covers the entered voltage/current/fault duty.');
    }
    if (!requiredAcbFrame.isFinite || !requiredAcbBreaking.isFinite) {
      failed = true;
      messages.add('No controlled ACB rating envelope covers the entered LV current/fault duty.');
    }
    if (preferredMvDevice.startsWith('MV switch-fuse') &&
        !requiredFuse.isFinite) {
      failed = true;
      messages.add('No controlled fuse-current screening rating covers the transformer primary current.');
    }
    if (vcbRatedVoltageKv < requiredVcbVoltage ||
        vcbRatedCurrentA < primaryCurrentA ||
        vcbBreakingCurrentKa < input.mvFaultCurrentKa) {
      failed = true;
      messages.add('Selected/manual VCB rating is below the calculated minimum requirement.');
    }
    if (acbFrameA < secondaryCurrentA ||
        acbBreakingCurrentKa < calculatedLvFaultKa) {
      failed = true;
      messages.add('Selected/manual ACB frame or breaking capacity is below the calculated minimum requirement.');
    }
    if (input.lvBusOrCableRatingA > 0 &&
        longTimePickupA > input.lvBusOrCableRatingA) {
      failed = true;
      messages.add('ACB long-time pickup exceeds the entered LV busduct/cable current rating.');
    }
    if (longTimePickupA > acbSensorA || shortTimePickupA <= longTimePickupA) {
      failed = true;
      messages.add('ACB trip-unit settings are outside a coherent L/S relationship or exceed the sensor rating.');
    }
    if (instantaneousPickupA != null && instantaneousPickupA <= shortTimePickupA) {
      failed = true;
      messages.add('Instantaneous pickup must exceed the short-time pickup or be disabled.');
    }
    if (ctPrimaryA < primaryCurrentA) {
      failed = true;
      messages.add('Selected/manual CT primary ratio is below transformer full-load current.');
    }

    if (instantaneousPickupA == null) {
      messages.add(
        'ACB instantaneous is shown as OFF/not recommended because available fault-current separation from transformer inrush is insufficient for a generic setting.',
      );
    }
    messages.add(
      'VCB, ACB and fuse outputs are rating requirements only. Select an exact manufacturer model after verifying type-tested panel data, Icu/Ics/Icw, operating voltage and accessories.',
    );
    messages.add(
      'Relay pickups and LSIG values are coordination starting points, not final settings. Perform minimum/maximum fault, inrush, CT saturation, grading and manufacturer selectivity studies.',
    );
    messages.add(
      'The calculated LV fault level excludes upstream source impedance, MV/LV cable impedance, motor contribution and transformer impedance tolerance unless included through a project-specific override.',
    );

    return ProtectionDesignResult(
      status: failed ? AssessmentStatus.fail : AssessmentStatus.verify,
      preferredMvDevice: preferredMvDevice,
      primaryCurrentA: primaryCurrentA,
      secondaryCurrentA: secondaryCurrentA,
      calculatedLvFaultKa: calculatedLvFaultKa,
      vcbRatedVoltageKv: vcbRatedVoltageKv,
      vcbRatedCurrentA: vcbRatedCurrentA,
      vcbBreakingCurrentKa: vcbBreakingCurrentKa,
      vcbShortTimeDurationS: input.mvFaultDurationS,
      fuseCurrentA: fuseCurrentA,
      acbFrameA: acbFrameA,
      acbSensorA: acbSensorA,
      acbBreakingCurrentKa: acbBreakingCurrentKa,
      acbShortTimeWithstandKa: acbShortTimeWithstandKa,
      acbPoles: acbPoles,
      ctRatio: ctRatio,
      ctClassGuidance: ctClassGuidance,
      longTimePickupA: longTimePickupA,
      shortTimePickupA: shortTimePickupA,
      shortTimeDelayS: shortTimeDelayS,
      instantaneousPickupA: instantaneousPickupA,
      groundFaultPickupA: groundFaultPickupA,
      groundFaultDelayS: groundFaultDelayS,
      phaseOvercurrentPickupA: phaseOvercurrentPickupA,
      earthFaultPickupA: earthFaultPickupA,
      highSetPickupA: highSetPickupA,
      relayFunctions: relayFunctions,
      internalProtection: internalProtection,
      vcbCandidateFamilies: vcbCandidateFamilies,
      acbCandidateFamilies: acbCandidateFamilies,
      messages: messages,
    );
  }

  static double _next(List<double> values, double required) {
    final sorted = values.where((value) => value > 0).toSet().toList()..sort();
    for (final value in sorted) {
      if (value + 1e-9 >= required) {
        return value;
      }
    }
    return double.nan;
  }

  static bool _positive(double? value) =>
      value != null && value.isFinite && value > 0;

  static ProtectionDesignResult _notAssessed({required List<String> messages}) {
    return ProtectionDesignResult(
      status: AssessmentStatus.notAssessed,
      preferredMvDevice: 'Not assessed',
      primaryCurrentA: double.nan,
      secondaryCurrentA: double.nan,
      calculatedLvFaultKa: double.nan,
      vcbRatedVoltageKv: double.nan,
      vcbRatedCurrentA: double.nan,
      vcbBreakingCurrentKa: double.nan,
      vcbShortTimeDurationS: double.nan,
      fuseCurrentA: double.nan,
      acbFrameA: double.nan,
      acbSensorA: double.nan,
      acbBreakingCurrentKa: double.nan,
      acbShortTimeWithstandKa: double.nan,
      acbPoles: 'Not assessed',
      ctRatio: 'Not assessed',
      ctClassGuidance: 'Not assessed',
      longTimePickupA: double.nan,
      shortTimePickupA: double.nan,
      shortTimeDelayS: double.nan,
      instantaneousPickupA: null,
      groundFaultPickupA: null,
      groundFaultDelayS: null,
      phaseOvercurrentPickupA: double.nan,
      earthFaultPickupA: double.nan,
      highSetPickupA: null,
      relayFunctions: const [],
      internalProtection: const [],
      vcbCandidateFamilies: const [],
      acbCandidateFamilies: const [],
      messages: messages,
    );
  }
}
