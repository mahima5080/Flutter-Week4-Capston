import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:week_4/main.dart';

void main() {
  testWidgets('App renders Login Screen correctly', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => OrderProvider()),
        ],
        child: const CapstoneEcommerceApp(),
      ),
    );

    // Verify Login Screen Elements
    expect(find.text('ShopSmart Store'), findsOneWidget);
    expect(find.text('Login to Store'), findsOneWidget);
  });
}