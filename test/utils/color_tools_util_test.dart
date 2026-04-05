import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ods/utils/color_tools_util.dart';

void main() {
  group('ColorTools', () {
    group('createMaterialColor()', () {
      test('returns MaterialColor with 10 swatch entries', () {
        final swatch = ColorTools.createMaterialColor(Colors.red);

        expect(swatch[50], isNotNull);
        expect(swatch[100], isNotNull);
        expect(swatch[200], isNotNull);
        expect(swatch[300], isNotNull);
        expect(swatch[400], isNotNull);
        expect(swatch[500], isNotNull);
        expect(swatch[600], isNotNull);
        expect(swatch[700], isNotNull);
        expect(swatch[800], isNotNull);
        expect(swatch[900], isNotNull);
      });

      test('works with primary red color', () {
        const primaryRed = Color.fromRGBO(172, 25, 20, 1);
        final swatch = ColorTools.createMaterialColor(primaryRed);

        expect(swatch, isA<MaterialColor>());
        expect(swatch[50], isNotNull);
        expect(swatch[900], isNotNull);
      });

      test('works with black', () {
        final swatch = ColorTools.createMaterialColor(Colors.black);

        expect(swatch, isA<MaterialColor>());
        for (final key in [50, 100, 200, 300, 400, 500, 600, 700, 800, 900]) {
          expect(swatch[key], isNotNull);
        }
      });

      test('works with white', () {
        final swatch = ColorTools.createMaterialColor(Colors.white);

        expect(swatch, isA<MaterialColor>());
        for (final key in [50, 100, 200, 300, 400, 500, 600, 700, 800, 900]) {
          expect(swatch[key], isNotNull);
        }
      });

      test('lighter shades are lighter than darker shades', () {
        final swatch = ColorTools.createMaterialColor(
          const Color.fromRGBO(172, 25, 20, 1),
        );

        final light = swatch[50]!;
        final dark = swatch[900]!;

        // Lighter shade should have higher luminance
        final lightLuminance = light.computeLuminance();
        final darkLuminance = dark.computeLuminance();
        expect(lightLuminance, greaterThan(darkLuminance));
      });

      test('all swatch colors have valid RGB values', () {
        final swatch = ColorTools.createMaterialColor(
          const Color.fromRGBO(100, 150, 200, 1),
        );

        for (final key in [50, 100, 200, 300, 400, 500, 600, 700, 800, 900]) {
          final color = swatch[key]!;
          expect(color.red, greaterThanOrEqualTo(0));
          expect(color.red, lessThanOrEqualTo(255));
          expect(color.green, greaterThanOrEqualTo(0));
          expect(color.green, lessThanOrEqualTo(255));
          expect(color.blue, greaterThanOrEqualTo(0));
          expect(color.blue, lessThanOrEqualTo(255));
        }
      });
    });
  });
}
