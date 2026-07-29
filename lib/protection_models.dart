import 'models.dart';

class ProtectionDeviceRecord {
  const ProtectionDeviceRecord({
    required this.id,
    required this.category,
    required this.brand,
    required this.family,
    required this.ratedVoltageKv,
    required this.ratedCurrentA,
    required this.breakingCurrentKa,
    required this.shortTimeCurrentKa,
    required this.shortTimeDurationS,
    required this.poles,
    required this.tripFunctions,
    required this.construction,
    required this.dataStatus,
    required this.sourceUrl,
    required this.sourceBasis,
    required this.notes,
  });

  final String id;
  final String category;
  final String brand;
  final String family;
  final double ratedVoltageKv;
  final double ratedCurrentA;
  final double breakingCurrentKa;
  final double shortTimeCurrentKa;
  final double shortTimeDurationS;
  final String poles;
  final String tripFunctions;
  final String construction;
  final String dataStatus;
  final String sourceUrl;
  final String sourceBasis;
  final String notes;

  factory ProtectionDeviceRecord.fromJson(Map<String, dynamic> json) {
    double number(String key) => (json[key] as num?)?.toDouble() ?? 0;
    String text(String key) => json[key]?.toString() ?? '';
    return ProtectionDeviceRecord(
      id: text('ID'),
      category: text('Device category'),
      brand: text('Brand'),
      family: text('Family'),
      ratedVoltageKv: number('Rated voltage kV'),
      ratedCurrentA: number('Rated current A'),
      breakingCurrentKa: number('Breaking current kA'),
      shortTimeCurrentKa: number('Short-time current kA'),
      shortTimeDurationS: number('Short-time duration s'),
      poles: text('Poles'),
      tripFunctions: text('Trip functions'),
      construction: text('Construction'),
      dataStatus: text('Data status'),
      sourceUrl: text('Source URL'),
      sourceBasis: text('Source basis'),
      notes: text('Notes'),
    );
  }

  String get shortLabel => '$brand • $family';
}

class ProtectionProfileRecord {
  const ProtectionProfileRecord({
    required this.id,
    required this.name,
    required this.fusePreferenceMaximumKva,
    required this.enhancedProtectionThresholdKva,
    required this.preferredCtNormalLoadingPercent,
    required this.vcbMinimumRatedCurrentA,
    required this.mvFaultMarginFactor,
    required this.lvBreakingMarginFactor,
    required this.status,
    required this.notes,
  });

  final String id;
  final String name;
  final double fusePreferenceMaximumKva;
  final double enhancedProtectionThresholdKva;
  final double preferredCtNormalLoadingPercent;
  final double vcbMinimumRatedCurrentA;
  final double mvFaultMarginFactor;
  final double lvBreakingMarginFactor;
  final String status;
  final String notes;

  factory ProtectionProfileRecord.fromJson(Map<String, dynamic> json) {
    double number(String key) => (json[key] as num?)?.toDouble() ?? 0;
    String text(String key) => json[key]?.toString() ?? '';
    return ProtectionProfileRecord(
      id: text('ID'),
      name: text('Name'),
      fusePreferenceMaximumKva: number('Fuse preference maximum kVA'),
      enhancedProtectionThresholdKva:
          number('Enhanced protection threshold kVA'),
      preferredCtNormalLoadingPercent:
          number('Preferred CT normal loading %'),
      vcbMinimumRatedCurrentA: number('VCB minimum rated current A'),
      mvFaultMarginFactor: number('MV fault margin factor'),
      lvBreakingMarginFactor: number('LV breaking margin factor'),
      status: text('Status'),
      notes: text('Notes'),
    );
  }
}

class RelayFunctionRecord {
  const RelayFunctionRecord({
    required this.code,
    required this.name,
    required this.applicability,
    required this.status,
  });

  final String code;
  final String name;
  final String applicability;
  final String status;

  factory RelayFunctionRecord.fromJson(Map<String, dynamic> json) =>
      RelayFunctionRecord(
        code: json['Code']?.toString() ?? '',
        name: json['Name']?.toString() ?? '',
        applicability: json['Default applicability']?.toString() ?? '',
        status: json['Status']?.toString() ?? '',
      );
}

class InternalProtectionRecord {
  const InternalProtectionRecord({
    required this.transformerType,
    required this.item,
    required this.applicability,
    required this.tripAction,
  });

  final String transformerType;
  final String item;
  final String applicability;
  final String tripAction;

  factory InternalProtectionRecord.fromJson(Map<String, dynamic> json) =>
      InternalProtectionRecord(
        transformerType: json['Transformer type']?.toString() ?? '',
        item: json['Item']?.toString() ?? '',
        applicability: json['Applicability']?.toString() ?? '',
        tripAction: json['Trip action']?.toString() ?? '',
      );
}

class ProtectionDesignInput {
  const ProtectionDesignInput({
    required this.mode,
    required this.profileId,
    required this.mvDeviceStrategy,
    required this.transformerKva,
    required this.primaryKv,
    required this.secondaryKv,
    required this.impedancePercent,
    required this.transformerType,
    required this.numberOfUnits,
    required this.criticalLoad,
    required this.enhancedProtection,
    required this.mvFaultCurrentKa,
    required this.mvFaultDurationS,
    required this.lvFaultOverrideKa,
    required this.lvBusOrCableRatingA,
    required this.groundFaultEnabled,
    this.manualVcbVoltageKv,
    this.manualVcbCurrentA,
    this.manualVcbBreakingKa,
    this.manualFuseCurrentA,
    this.manualAcbFrameA,
    this.manualAcbBreakingKa,
    this.manualCtPrimaryA,
    this.manualLongTimePickupA,
    this.manualShortTimePickupA,
    this.manualShortTimeDelayS,
    this.manualInstantaneousPickupA,
    this.manualGroundFaultPickupA,
    this.manualGroundFaultDelayS,
  });

  final String mode;
  final String profileId;
  final String mvDeviceStrategy;
  final double transformerKva;
  final double primaryKv;
  final double secondaryKv;
  final double impedancePercent;
  final String transformerType;
  final int numberOfUnits;
  final bool criticalLoad;
  final bool enhancedProtection;
  final double mvFaultCurrentKa;
  final double mvFaultDurationS;
  final double lvFaultOverrideKa;
  final double lvBusOrCableRatingA;
  final bool groundFaultEnabled;
  final double? manualVcbVoltageKv;
  final double? manualVcbCurrentA;
  final double? manualVcbBreakingKa;
  final double? manualFuseCurrentA;
  final double? manualAcbFrameA;
  final double? manualAcbBreakingKa;
  final double? manualCtPrimaryA;
  final double? manualLongTimePickupA;
  final double? manualShortTimePickupA;
  final double? manualShortTimeDelayS;
  final double? manualInstantaneousPickupA;
  final double? manualGroundFaultPickupA;
  final double? manualGroundFaultDelayS;
}

class ProtectionDesignResult {
  const ProtectionDesignResult({
    required this.status,
    required this.preferredMvDevice,
    required this.primaryCurrentA,
    required this.secondaryCurrentA,
    required this.calculatedLvFaultKa,
    required this.vcbRatedVoltageKv,
    required this.vcbRatedCurrentA,
    required this.vcbBreakingCurrentKa,
    required this.vcbShortTimeDurationS,
    required this.fuseCurrentA,
    required this.acbFrameA,
    required this.acbSensorA,
    required this.acbBreakingCurrentKa,
    required this.acbShortTimeWithstandKa,
    required this.acbPoles,
    required this.ctRatio,
    required this.ctClassGuidance,
    required this.longTimePickupA,
    required this.shortTimePickupA,
    required this.shortTimeDelayS,
    required this.instantaneousPickupA,
    required this.groundFaultPickupA,
    required this.groundFaultDelayS,
    required this.phaseOvercurrentPickupA,
    required this.earthFaultPickupA,
    required this.highSetPickupA,
    required this.relayFunctions,
    required this.internalProtection,
    required this.vcbCandidateFamilies,
    required this.acbCandidateFamilies,
    required this.messages,
  });

  final AssessmentStatus status;
  final String preferredMvDevice;
  final double primaryCurrentA;
  final double secondaryCurrentA;
  final double calculatedLvFaultKa;
  final double vcbRatedVoltageKv;
  final double vcbRatedCurrentA;
  final double vcbBreakingCurrentKa;
  final double vcbShortTimeDurationS;
  final double fuseCurrentA;
  final double acbFrameA;
  final double acbSensorA;
  final double acbBreakingCurrentKa;
  final double acbShortTimeWithstandKa;
  final String acbPoles;
  final String ctRatio;
  final String ctClassGuidance;
  final double longTimePickupA;
  final double shortTimePickupA;
  final double shortTimeDelayS;
  final double? instantaneousPickupA;
  final double? groundFaultPickupA;
  final double? groundFaultDelayS;
  final double phaseOvercurrentPickupA;
  final double earthFaultPickupA;
  final double? highSetPickupA;
  final List<String> relayFunctions;
  final List<String> internalProtection;
  final List<String> vcbCandidateFamilies;
  final List<String> acbCandidateFamilies;
  final List<String> messages;
}
