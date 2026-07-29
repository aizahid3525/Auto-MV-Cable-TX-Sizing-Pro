import 'package:auto_mv_cable_tx_sizing_pro/main.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('app loads controlled dashboard', (tester) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(const AutoMvCableTxApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));
    expect(find.text('Auto MV Cable & TX Sizing Pro'), findsWidgets);
    expect(find.text('MV Cable Design'), findsOneWidget);
    expect(find.text('Transformer Design'), findsOneWidget);
    expect(find.text('Protection & Switchgear'), findsOneWidget);
  });
}
