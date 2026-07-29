import 'package:auto_mv_cable_tx_sizing_pro/data_repository.dart';
import 'package:auto_mv_cable_tx_sizing_pro/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app loads controlled dashboard', (tester) async {
    SharedPreferences.setMockInitialValues({});

    // Load the controlled asset database outside the frame scheduler. This
    // keeps the dashboard smoke test deterministic and avoids waiting for
    // continuously animated progress indicators with pumpAndSettle().
    await tester.runAsync(() async {
      await EngineeringRepository.instance.load();
    });

    await tester.pumpWidget(const AutoMvCableTxApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.text('Auto MV Cable & TX Sizing Pro'), findsWidgets);
    expect(find.text('MV Cable Design'), findsOneWidget);
    expect(find.text('Transformer Design'), findsOneWidget);
    expect(find.text('Protection & Switchgear'), findsOneWidget);
    expect(find.text('Interactive radial chart'), findsOneWidget);
    expect(find.text('Engineering Database & Reference'), findsOneWidget);
    expect(find.byTooltip('Open navigation menu'), findsOneWidget);
  });

  testWidgets('database filters and records share a scrollable surface',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.runAsync(() async {
      await EngineeringRepository.instance.load();
    });

    await tester.pumpWidget(const AutoMvCableTxApp());
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.tap(find.text('Database').last);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    const key = PageStorageKey<String>('mv-cable-database');
    expect(find.byKey(key), findsOneWidget);
    expect(find.text('Database filters'), findsOneWidget);
    expect(find.textContaining('MV cable records matched'), findsWidgets);

    await tester.drag(find.byKey(key), const Offset(0, -500));
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.byKey(key), findsOneWidget);
  });
}
