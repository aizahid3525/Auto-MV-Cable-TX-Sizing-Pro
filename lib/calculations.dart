import 'dart:math' as math;

import 'models.dart';

class CableDesignInput {
  const CableDesignInput({
    required this.systemKv,
    required this.loadKva,
    required this.powerFactor,
    required this.lengthM,
    required this.parallelRuns,
    required this.deratingFactor,
    required this.voltageDropLimitPercent,
    required this.faultCurrentKa,
    required this.faultTimeS,
    required this.installationMethod,
    required this.screenBonding,
  });

  final double systemKv;
  final double loadKva;
  final double powerFactor;
  final double lengthM;
  final int parallelRuns;
  final double deratingFactor;
  final double voltageDropLimitPercent;
  final double faultCurrentKa;
  final double faultTimeS;
  final String installationMethod;
  final String screenBonding;
}

class CableDesignResult {
  const CableDesignResult({
    required this.cable,
    required this.designCurrentA,
    required this.deratedAmpacityA,
    required this.loadingPercent,
    required this.voltageDropV,
    required this.voltageDropPercent,
    required this.shortCircuitWithstandKa,
    required this.chargingCurrentA,
    required this.lossKw,
    required this.status,
    required this.messages,
  });

  final MvCableRecord cable;
  final double designCurrentA;
  final double deratedAmpacityA;
  final double loadingPercent;
  final double voltageDropV;
  final double voltageDropPercent;
  final double shortCircuitWithstandKa;
  final double chargingCurrentA;
  final double lossKw;
  final AssessmentStatus status;
  final List<String> messages;
}

class TransformerDesignInput {
  const TransformerDesignInput({
    required this.connectedLoadKw,
    required this.powerFactor,
    required this.efficiency,
    required this.demandFactor,
    required this.futureGrowthPercent,
    required this.harmonicFactor,
    required this.motorStartingFactor,
    required this.numberOfUnits,
  });

  final double connectedLoadKw;
  final double powerFactor;
  final double efficiency;
  final double demandFactor;
  final double futureGrowthPercent;
  final double harmonicFactor;
  final double motorStartingFactor;
  final int numberOfUnits;
}

class TransformerDesignResult {
  const TransformerDesignResult({
    required this.transformer,
    required this.designDemandKva,
    required this.normalLoadingPercent,
    required this.outageLoadingPercent,
    required this.primaryCurrentA,
    required this.secondaryCurrentA,
    required this.approxFaultCurrentKa,
    required this.totalLossKw,
    required this.efficiencyPercent,
    required this.approxRegulationPercent,
    required this.status,
    required this.messages,
  });

  final TransformerRecord transformer;
  final double designDemandKva;
  final double normalLoadingPercent;
  final double outageLoadingPercent;
  final double primaryCurrentA;
  final double secondaryCurrentA;
  final double approxFaultCurrentKa;
  final double totalLossKw;
  final double efficiencyPercent;
  final double approxRegulationPercent;
  final AssessmentStatus status;
  final List<String> messages;
}

class EngineeringCalculations {
  const EngineeringCalculations._();

  static double designCurrentA({required double kva, required double kv}) {
    if (kva <= 0 || kv <= 0) {
      return double.nan;
    }
    return kva / (math.sqrt(3) * kv);
  }

  static CableDesignResult evaluateCable(
    CableDesignInput input,
    MvCableRecord cable,
  ) {
    final messages = <String>[];
    if (input.systemKv <= 0 ||
        input.loadKva <= 0 ||
        input.powerFactor <= 0 ||
        input.powerFactor > 1 ||
        input.lengthM < 0 ||
        input.parallelRuns < 1 ||
        input.deratingFactor <= 0 ||
        input.deratingFactor > 1 ||
        input.faultTimeS <= 0) {
      return CableDesignResult(
        cable: cable,
        designCurrentA: double.nan,
        deratedAmpacityA: double.nan,
        loadingPercent: double.nan,
        voltageDropV: double.nan,
        voltageDropPercent: double.nan,
        shortCircuitWithstandKa: double.nan,
        chargingCurrentA: double.nan,
        lossKw: double.nan,
        status: AssessmentStatus.notAssessed,
        messages: const ['Correct invalid or incomplete inputs before assessment.'],
      );
    }

    final current = designCurrentA(kva: input.loadKva, kv: input.systemKv);
    final ampacity = cable.ampacityFor(input.installationMethod) *
        input.deratingFactor *
        input.parallelRuns;
    final currentPerRun = current / input.parallelRuns;
    final loadingPercent = current / ampacity * 100;
    final sinPhi = math.sqrt(math.max(0, 1 - input.powerFactor * input.powerFactor));
    final lengthKm = input.lengthM / 1000;
    final voltageDropV = math.sqrt(3) *
        currentPerRun *
        lengthKm *
        (cable.resistanceOhmPerKm * input.powerFactor +
            cable.reactanceTrefoilOhmPerKm * sinPhi);
    final voltageDropPercent = voltageDropV / (input.systemKv * 1000) * 100;
    final k = cable.conductor.toLowerCase().contains('aluminium') ? 94.0 : 143.0;
    final withstandKa = k * cable.sizeMm2 * input.parallelRuns /
        math.sqrt(input.faultTimeS) /
        1000;
    final phaseVoltage = input.systemKv * 1000 / math.sqrt(3);
    final chargingCurrent = 2 *
        math.pi *
        50 *
        cable.capacitanceUfPerKm *
        1e-6 *
        lengthKm *
        phaseVoltage *
        input.parallelRuns;
    final lossKw = 3 *
        currentPerRun *
        currentPerRun *
        cable.resistanceOhmPerKm *
        lengthKm *
        input.parallelRuns /
        1000;

    final ampacityPass = current <= ampacity;
    final vdPass = voltageDropPercent <= input.voltageDropLimitPercent;
    final faultPass = input.faultCurrentKa <= withstandKa;

    if (!ampacityPass) {
      messages.add('Derated ampacity is below the design current.');
    }
    if (!vdPass) {
      messages.add('Voltage drop exceeds the selected project limit.');
    }
    if (!faultPass) {
      messages.add('Conductor short-circuit withstand is insufficient.');
    }
    if (input.screenBonding == 'Not selected') {
      messages.add('Select and verify the MV screen-bonding arrangement.');
    }
    messages.add(
      'Manufacturer family is traceable; electrical ratings remain controlled engineering references until the exact catalogue is verified.',
    );

    final status = (!ampacityPass || !vdPass || !faultPass)
        ? AssessmentStatus.fail
        : AssessmentStatus.verify;

    return CableDesignResult(
      cable: cable,
      designCurrentA: current,
      deratedAmpacityA: ampacity,
      loadingPercent: loadingPercent,
      voltageDropV: voltageDropV,
      voltageDropPercent: voltageDropPercent,
      shortCircuitWithstandKa: withstandKa,
      chargingCurrentA: chargingCurrent,
      lossKw: lossKw,
      status: status,
      messages: messages,
    );
  }

  static TransformerDesignResult evaluateTransformer(
    TransformerDesignInput input,
    TransformerRecord transformer,
  ) {
    final messages = <String>[];
    if (input.connectedLoadKw <= 0 ||
        input.powerFactor <= 0 ||
        input.powerFactor > 1 ||
        input.efficiency <= 0 ||
        input.efficiency > 1 ||
        input.demandFactor <= 0 ||
        input.demandFactor > 1 ||
        input.futureGrowthPercent < 0 ||
        input.harmonicFactor < 1 ||
        input.motorStartingFactor < 1 ||
        input.numberOfUnits < 1 ||
        transformer.impedancePercent <= 0) {
      return TransformerDesignResult(
        transformer: transformer,
        designDemandKva: double.nan,
        normalLoadingPercent: double.nan,
        outageLoadingPercent: double.nan,
        primaryCurrentA: double.nan,
        secondaryCurrentA: double.nan,
        approxFaultCurrentKa: double.nan,
        totalLossKw: double.nan,
        efficiencyPercent: double.nan,
        approxRegulationPercent: double.nan,
        status: AssessmentStatus.notAssessed,
        messages: const ['Correct invalid or incomplete inputs before assessment.'],
      );
    }

    final baseDemand = input.connectedLoadKw /
        (input.powerFactor * input.efficiency) *
        input.demandFactor;
    final designDemand = baseDemand *
        (1 + input.futureGrowthPercent / 100) *
        input.harmonicFactor *
        input.motorStartingFactor;
    final installedCapacity = transformer.ratedKva * input.numberOfUnits;
    final normalLoading = designDemand / installedCapacity * 100;
    final outageCapacity = input.numberOfUnits > 1
        ? transformer.ratedKva * (input.numberOfUnits - 1)
        : transformer.ratedKva;
    final outageLoading = designDemand / outageCapacity * 100;
    final primaryCurrent = designCurrentA(
      kva: transformer.ratedKva,
      kv: transformer.primaryKv,
    );
    final secondaryCurrent = designCurrentA(
      kva: transformer.ratedKva,
      kv: transformer.secondaryKv,
    );
    final faultKa = secondaryCurrent /
        (transformer.impedancePercent / 100) /
        1000;
    final loadFraction = designDemand / installedCapacity;
    final totalLoss = transformer.noLoadLossKw * input.numberOfUnits +
        transformer.loadLossKw * loadFraction * loadFraction * input.numberOfUnits;
    final outputKw = designDemand * input.powerFactor;
    final efficiency = outputKw / (outputKw + totalLoss) * 100;
    final resistancePercent = transformer.loadLossKw /
        transformer.ratedKva *
        100;
    final reactancePercent = math.sqrt(math.max(
      0,
      transformer.impedancePercent * transformer.impedancePercent -
          resistancePercent * resistancePercent,
    ));
    final sinPhi = math.sqrt(math.max(0, 1 - input.powerFactor * input.powerFactor));
    final regulation = resistancePercent * input.powerFactor + reactancePercent * sinPhi;

    if (normalLoading > 100) {
      messages.add('Selected installed capacity is below the design demand.');
    }
    if (normalLoading > 90 && normalLoading <= 100) {
      messages.add('Normal loading exceeds the preferred 90% preliminary threshold.');
    }
    if (input.numberOfUnits > 1 && outageLoading > 100) {
      messages.add('N-1 outage loading exceeds 100%.');
    }
    messages.add(
      'Fault current excludes upstream impedance, cable impedance, motor contribution and manufacturing tolerance.',
    );
    messages.add(
      'Loss and impedance values are preliminary references; enter guaranteed manufacturer values for final issue.',
    );

    final status = normalLoading > 100 ||
            (input.numberOfUnits > 1 && outageLoading > 120)
        ? AssessmentStatus.fail
        : AssessmentStatus.verify;

    return TransformerDesignResult(
      transformer: transformer,
      designDemandKva: designDemand,
      normalLoadingPercent: normalLoading,
      outageLoadingPercent: outageLoading,
      primaryCurrentA: primaryCurrent,
      secondaryCurrentA: secondaryCurrent,
      approxFaultCurrentKa: faultKa,
      totalLossKw: totalLoss,
      efficiencyPercent: efficiency,
      approxRegulationPercent: regulation,
      status: status,
      messages: messages,
    );
  }
}
