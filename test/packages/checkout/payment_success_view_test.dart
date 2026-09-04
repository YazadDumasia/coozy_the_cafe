import 'package:coozy_the_cafe/packages/checkout/presentation/pages/checkout/widget/payment_success_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('PaymentSuccessView renders without infinite height assertion error in SingleChildScrollView',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: PaymentSuccessView(
              grandTotal: 150.0,
              receiptId: 'EN-1001',
              itemCount: 3,
            ),
          ),
        ),
      ),
    );

    // Pump frames (avoid pumpAndSettle due to continuous floating particle animations)
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byType(PaymentSuccessView), findsOneWidget);
    expect(find.textContaining('150.00'), findsOneWidget);
  });
}
