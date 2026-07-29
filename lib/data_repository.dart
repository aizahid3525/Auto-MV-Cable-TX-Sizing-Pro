import 'dart:convert';

import 'package:flutter/services.dart';

import 'models.dart';
import 'protection_models.dart';

class EngineeringRepository {
  EngineeringRepository._();

  static final EngineeringRepository instance = EngineeringRepository._();

  List<MvCableRecord> cables = const [];
  List<TransformerRecord> transformers = const [];
  List<HelpTopic> helpTopics = const [];
  List<StandardRecord> standards = const [];
  List<ProtectionDeviceRecord> protectionDevices = const [];
  List<ProtectionProfileRecord> protectionProfiles = const [];
  List<RelayFunctionRecord> relayFunctions = const [];
  List<InternalProtectionRecord> internalProtection = const [];
  List<double> ctRatios = const [];
  List<double> standardAcbFrames = const [];
  List<double> standardAcbBreakingRatings = const [];
  List<double> standardVcbVoltages = const [];
  List<double> standardVcbCurrents = const [];
  List<double> standardVcbBreakingRatings = const [];
  List<double> standardFuseRatings = const [];
  String protectionSafeguard = '';

  bool get isLoaded =>
      cables.isNotEmpty &&
      transformers.isNotEmpty &&
      protectionDevices.isNotEmpty &&
      protectionProfiles.isNotEmpty;

  Future<void> load() async {
    if (isLoaded) {
      return;
    }
    final results = await Future.wait<String>([
      rootBundle.loadString('assets/data/mv_cable_database.json'),
      rootBundle.loadString('assets/data/transformer_database.json'),
      rootBundle.loadString('assets/data/help_content.json'),
      rootBundle.loadString('assets/data/standards_register.json'),
      rootBundle.loadString('assets/data/protection_database.json'),
    ]);
    final cableJson = jsonDecode(results[0]) as Map<String, dynamic>;
    final transformerJson = jsonDecode(results[1]) as Map<String, dynamic>;
    final helpJson = jsonDecode(results[2]) as Map<String, dynamic>;
    final standardsJson = jsonDecode(results[3]) as Map<String, dynamic>;
    final protectionJson = jsonDecode(results[4]) as Map<String, dynamic>;

    cables = (cableJson['records'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(MvCableRecord.fromJson)
        .toList(growable: false);
    transformers = (transformerJson['records'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(TransformerRecord.fromJson)
        .toList(growable: false);
    helpTopics = (helpJson['records'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(HelpTopic.fromJson)
        .toList(growable: false);
    standards = (standardsJson['records'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(StandardRecord.fromJson)
        .toList(growable: false);
    protectionDevices = (protectionJson['records'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(ProtectionDeviceRecord.fromJson)
        .toList(growable: false);
    protectionProfiles = (protectionJson['profiles'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(ProtectionProfileRecord.fromJson)
        .toList(growable: false);
    relayFunctions = (protectionJson['relayFunctions'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(RelayFunctionRecord.fromJson)
        .toList(growable: false);
    internalProtection = (protectionJson['internalProtection'] as List<dynamic>)
        .whereType<Map<String, dynamic>>()
        .map(InternalProtectionRecord.fromJson)
        .toList(growable: false);
    ctRatios = _numberList(protectionJson['ctRatiosA']);
    standardAcbFrames = _numberList(protectionJson['standardAcbFramesA']);
    standardAcbBreakingRatings =
        _numberList(protectionJson['standardAcbBreakingKa']);
    standardVcbVoltages = _numberList(protectionJson['standardVcbVoltageKv']);
    standardVcbCurrents = _numberList(protectionJson['standardVcbCurrentA']);
    standardVcbBreakingRatings =
        _numberList(protectionJson['standardVcbBreakingKa']);
    standardFuseRatings = _numberList(protectionJson['standardFuseCurrentA']);
    protectionSafeguard = protectionJson['globalSafeguard']?.toString() ?? '';
  }

  HelpTopic? help(String id) {
    for (final topic in helpTopics) {
      if (topic.id == id) {
        return topic;
      }
    }
    return null;
  }

  List<String> get cableBrands => _sorted(cables.map((e) => e.brand));
  List<String> get cableFamilies => _sorted(cables.map((e) => e.family));
  List<String> get cableCores => _sorted(cables.map((e) => e.cores));
  List<String> get conductorMaterials => _sorted(cables.map((e) => e.conductor));
  List<String> get transformerBrands => _sorted(transformers.map((e) => e.brand));
  List<String> get transformerTypes => _sorted(transformers.map((e) => e.type));
  List<String> get protectionBrands =>
      _sorted(protectionDevices.map((e) => e.brand));
  List<String> get protectionCategories =>
      _sorted(protectionDevices.map((e) => e.category));

  ProtectionProfileRecord protectionProfile(String id) {
    for (final profile in protectionProfiles) {
      if (profile.id == id) {
        return profile;
      }
    }
    return protectionProfiles.first;
  }

  List<ProtectionDeviceRecord> get productFamilies => protectionDevices
      .where((record) => record.category.endsWith('family'))
      .toList(growable: false);

  List<double> _numberList(dynamic source) {
    if (source is! List<dynamic>) {
      return const [];
    }
    return source.whereType<num>().map((value) => value.toDouble()).toList();
  }

  List<String> _sorted(Iterable<String> source) {
    final values = source.where((e) => e.trim().isNotEmpty).toSet().toList()..sort();
    return values;
  }
}
