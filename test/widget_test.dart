import 'package:auto_mv_cable_tx_sizing_pro/data_repository.dart';
import 'package:auto_mv_cable_tx_sizing_pro/main.dart';
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
  });
}
