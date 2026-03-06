import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:uv_dosimeter/features/onboarding/presentation/widgets/spf_slider_widget.dart';
import 'package:uv_dosimeter/l10n/app_localizations.dart';

// Helper to wrap widget in a localised MaterialApp.
Widget _buildApp(Widget child) {
  return MaterialApp(
    localizationsDelegates: const [
      AppLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: const [Locale('en')],
    home: Scaffold(body: child),
  );
}

void main() {
  group('SpfSliderWidget', () {
    testWidgets('renders with SPF 30 selected by default', (tester) async {
      int? changedValue;
      await tester.pumpWidget(
        _buildApp(
          SpfSliderWidget(
            selectedSpf: 30,
            onChanged: (v) => changedValue = v,
          ),
        ),
      );

      // SPF badge should show the selected value
      expect(find.textContaining('30'), findsWidgets);
      // Label key from ARB
      expect(find.textContaining('SPF'), findsWidgets);
    });

    testWidgets('renders None label when SPF is 1', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          SpfSliderWidget(
            selectedSpf: 1,
            onChanged: (_) {},
          ),
        ),
      );
      // 'None' label should appear
      expect(find.textContaining('None'), findsWidgets);
    });

    testWidgets('Slider is present', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          SpfSliderWidget(
            selectedSpf: 15,
            onChanged: (_) {},
          ),
        ),
      );
      expect(find.byType(Slider), findsOneWidget);
    });
  });
}
