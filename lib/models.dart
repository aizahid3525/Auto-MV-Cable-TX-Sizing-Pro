class MvCableRecord {
  const MvCableRecord({
    required this.id,
    required this.brand,
    required this.manufacturer,
    required this.family,
    required this.voltageDesignation,
    required this.systemKv,
    required this.cores,
    required this.conductor,
    required this.sizeMm2,
    required this.insulation,
    required this.screenMm2,
    required this.armour,
    required this.ampacityAirA,
    required this.ampacityBuriedA,
    required this.ampacityDuctA,
    required this.resistanceOhmPerKm,
    required this.reactanceTrefoilOhmPerKm,
    required this.capacitanceUfPerKm,
    required this.dataStatus,
    required this.sourceUrl,
    required this.notes,
  });

  final String id;
  final String brand;
  final String manufacturer;
  final String family;
  final String voltageDesignation;
  final double systemKv;
  final String cores;
  final String conductor;
  final double sizeMm2;
  final String insulation;
  final double screenMm2;
  final String armour;
  final double ampacityAirA;
  final double ampacityBuriedA;
  final double ampacityDuctA;
  final double resistanceOhmPerKm;
  final double reactanceTrefoilOhmPerKm;
  final double capacitanceUfPerKm;
  final String dataStatus;
  final String sourceUrl;
  final String notes;

  factory MvCableRecord.fromJson(Map<String, dynamic> json) {
    double number(String key) => (json[key] as num?)?.toDouble() ?? 0;
    String text(String key) => json[key]?.toString() ?? '';
    return MvCableRecord(
      id: text('ID'),
      brand: text('Brand'),
      manufacturer: text('Manufacturer'),
      family: text('Family'),
      voltageDesignation: text('Voltage designation'),
      systemKv: number('System kV'),
      cores: text('Cores'),
      conductor: text('Conductor'),
      sizeMm2: number('Size mm²'),
      insulation: text('Insulation'),
      screenMm2: number('Screen mm²'),
      armour: text('Armour'),
      ampacityAirA: number('Ampacity air A'),
      ampacityBuriedA: number('Ampacity buried A'),
      ampacityDuctA: number('Ampacity duct A'),
      resistanceOhmPerKm: number('R90 Ω/km'),
      reactanceTrefoilOhmPerKm: number('X trefoil Ω/km'),
      capacitanceUfPerKm: number('Capacitance µF/km'),
      dataStatus: text('Data status'),
      sourceUrl: text('Source URL'),
      notes: text('Notes'),
    );
  }

  double ampacityFor(String method) {
    switch (method) {
      case 'Direct buried':
        return ampacityBuriedA;
      case 'In duct':
        return ampacityDuctA;
      default:
        return ampacityAirA;
    }
  }

  String get shortLabel => '$brand • $cores • $conductor ${sizeMm2.toStringAsFixed(0)} mm²';
}

class TransformerRecord {
  const TransformerRecord({
    required this.id,
    required this.brand,
    required this.manufacturer,
    required this.type,
    required this.ratedKva,
    required this.primaryKv,
    required this.secondaryKv,
    required this.vectorGroup,
    required this.impedancePercent,
    required this.tapRangePercent,
    required this.cooling,
    required this.noLoadLossKw,
    required this.loadLossKw,
    required this.dataStatus,
    required this.sourceUrl,
    required this.notes,
  });

  final String id;
  final String brand;
  final String manufacturer;
  final String type;
  final double ratedKva;
  final double primaryKv;
  final double secondaryKv;
  final String vectorGroup;
  final double impedancePercent;
  final double tapRangePercent;
  final String cooling;
  final double noLoadLossKw;
  final double loadLossKw;
  final String dataStatus;
  final String sourceUrl;
  final String notes;

  factory TransformerRecord.fromJson(Map<String, dynamic> json) {
    double number(String key) => (json[key] as num?)?.toDouble() ?? 0;
    String text(String key) => json[key]?.toString() ?? '';
    return TransformerRecord(
      id: text('ID'),
      brand: text('Brand'),
      manufacturer: text('Manufacturer'),
      type: text('Transformer type'),
      ratedKva: number('Rated kVA'),
      primaryKv: number('Primary kV'),
      secondaryKv: number('Secondary kV'),
      vectorGroup: text('Vector group'),
      impedancePercent: number('Impedance %'),
      tapRangePercent: number('Tap range ±%'),
      cooling: text('Cooling'),
      noLoadLossKw: number('No-load loss kW ref.'),
      loadLossKw: number('Load loss kW ref.'),
      dataStatus: text('Data status'),
      sourceUrl: text('Source URL'),
      notes: text('Notes'),
    );
  }

  String get shortLabel => '$brand • ${ratedKva.toStringAsFixed(0)} kVA • $type';
}

class HelpTopic {
  const HelpTopic({
    required this.id,
    required this.title,
    required this.explanation,
    required this.usage,
    required this.equation,
    required this.example,
    required this.warning,
    required this.source,
    required this.referenceTable,
  });

  final String id;
  final String title;
  final String explanation;
  final String usage;
  final String equation;
  final String example;
  final String warning;
  final String source;
  final String referenceTable;

  factory HelpTopic.fromJson(Map<String, dynamic> json) => HelpTopic(
        id: json['ID']?.toString() ?? '',
        title: json['Title']?.toString() ?? '',
        explanation: json['Explanation']?.toString() ?? '',
        usage: json['How app uses it']?.toString() ?? '',
        equation: json['Formula / equation']?.toString() ?? '',
        example: json['Worked example']?.toString() ?? '',
        warning: json['Warning']?.toString() ?? '',
        source: json['Source / basis']?.toString() ?? '',
        referenceTable: json['Reference table']?.toString() ?? '',
      );
}

class StandardRecord {
  const StandardRecord({
    required this.id,
    required this.title,
    required this.scope,
    required this.status,
    required this.url,
  });

  final String id;
  final String title;
  final String scope;
  final String status;
  final String url;

  factory StandardRecord.fromJson(Map<String, dynamic> json) => StandardRecord(
        id: json['ID']?.toString() ?? '',
        title: json['Title']?.toString() ?? '',
        scope: json['Scope']?.toString() ?? '',
        status: json['Status']?.toString() ?? '',
        url: json['Official URL']?.toString() ?? '',
      );
}

enum AssessmentStatus { pass, verify, fail, notAssessed }

extension AssessmentStatusLabel on AssessmentStatus {
  String get label {
    switch (this) {
      case AssessmentStatus.pass:
        return 'PASS';
      case AssessmentStatus.verify:
        return 'VERIFY';
      case AssessmentStatus.fail:
        return 'FAIL';
      case AssessmentStatus.notAssessed:
        return 'NOT ASSESSED';
    }
  }
}
