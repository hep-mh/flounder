import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flounder/layout.dart';

void main() {
  group('layout.dart', () {
    test('getHeaderSize', () {
      final size1 = getHeaderSize(const Size(800, 600));
      // maxWidth is 700, maxHeight is 700 / (14/3) = 150
      // 20% of 600 is 120. So height should be 120.
      // ratio is height / maxHeight = 120 / 150 = 0.8
      // width = ratio * maxWidth = 0.8 * 700 = 560
      expect(size1.height, closeTo(120, 0.01));
      expect(size1.width, closeTo(560, 0.01));

      final size2 = getHeaderSize(const Size(400, 1000));
      // contextWidth = 400. width = 400 - 60 = 340
      // widthRatio = 340 / 700 = 0.4857
      // 20% of 1000 is 200. maxHeight is 150. So height = 150
      // heightRatio = 1
      // widthRatio < heightRatio, so height = widthRatio * maxHeight = 0.4857 * 150 = 72.857
      expect(size2.width, closeTo(340, 0.01));
      expect(size2.height, closeTo(72.857, 0.01));
    });

    test('getActionBarHeight', () {
      // maxSize = 60, pct = 0.15
      final size = const Size(800, 600);
      final height = getActionBarHeight(size);
      // contextWidth > magicWidth (760), so no scaling
      // min(60, 0.15 * 600 = 90) = 60
      expect(height, closeTo(60, 0.01));

      final size2 = const Size(400, 600);
      final height2 = getActionBarHeight(size2);
      // contextWidth < 760, scaling = 400 / 760 = 0.526
      // a = 0.5, maxSizeByWidth = 60 * (0.5 + 0.5 * 0.526) = 60 * 0.763 = 45.78
      // min(45.78, 90) = 45.78
      expect(height2, closeTo(45.78, 0.01));
    });

    test('getActionButtonRadius', () {
      // maxSize = 40, pct = 0.1
      final size = const Size(800, 600);
      final radius = getActionButtonRadius(size);
      // min(40, 60) = 40
      expect(radius, closeTo(40, 0.01));
    });

    test('getClockSwitcherHeight', () {
      // maxSize = 75, pct = 0.1
      final size = const Size(800, 600);
      final height = getClockSwitcherHeight(size);
      // min(75, 60) = 60
      expect(height, closeTo(60, 0.01));
    });

    test('getDrawerWidth and getDrawerScale', () {
      // maxWidth = 304, pct = 0.9
      final size = const Size(400, 600);
      final width = getDrawerWidth(size);
      // min(304, 0.9 * 400 = 360) = 304
      expect(width, closeTo(304, 0.01));

      final scale = getDrawerScale(size);
      expect(scale, closeTo(1.0, 0.01));

      final size2 = const Size(200, 600);
      final width2 = getDrawerWidth(size2);
      // min(304, 180) = 180
      expect(width2, closeTo(180, 0.01));

      final scale2 = getDrawerScale(size2);
      expect(scale2, closeTo(180 / 304, 0.01));
    });
  });
}
