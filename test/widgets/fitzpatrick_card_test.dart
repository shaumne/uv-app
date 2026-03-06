import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:uv_dosimeter/features/onboarding/presentation/widgets/fitzpatrick_card.dart';

Widget _buildApp(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('FitzpatrickCard', () {
    testWidgets('renders label and description', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          FitzpatrickCard(
            type: 1,
            label: 'Type I — Very Fair',
            description: 'Always burns, never tans',
            swatchColor: const Color(0xFFFDE8D8),
            isSelected: false,
            onTap: () {},
          ),
        ),
      );
      expect(find.text('Type I — Very Fair'), findsOneWidget);
      expect(find.text('Always burns, never tans'), findsOneWidget);
    });

    testWidgets('shows check icon when selected', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          FitzpatrickCard(
            type: 2,
            label: 'Type II — Fair',
            description: 'Usually burns',
            swatchColor: const Color(0xFFF5D5C0),
            isSelected: true,
            onTap: () {},
          ),
        ),
      );
      // PhosphorIcon check should be visible when selected
      expect(find.byType(PhosphorIcon), findsOneWidget);
    });

    testWidgets('does not show check icon when unselected', (tester) async {
      await tester.pumpWidget(
        _buildApp(
          FitzpatrickCard(
            type: 3,
            label: 'Type III — Medium',
            description: 'Sometimes burns',
            swatchColor: const Color(0xFFD4A57A),
            isSelected: false,
            onTap: () {},
          ),
        ),
      );
      expect(find.byType(PhosphorIcon), findsNothing);
    });

    testWidgets('calls onTap when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        _buildApp(
          FitzpatrickCard(
            type: 4,
            label: 'Type IV — Olive',
            description: 'Rarely burns',
            swatchColor: const Color(0xFFB5722F),
            isSelected: false,
            onTap: () => tapped = true,
          ),
        ),
      );
      await tester.tap(find.byType(GestureDetector).first);
      expect(tapped, isTrue);
    });
  });
}
