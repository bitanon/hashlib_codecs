import 'dart:typed_data';

import 'package:convertlib/convertlib.dart';
import 'package:test/test.dart';

void main() {
  group('constantTimeEquals', () {
    test('identical instance is equal', () {
      final a = [1, 2, 3];
      expect(constantTimeEquals(a, a), isTrue);
    });

    test('equal content in distinct lists', () {
      expect(constantTimeEquals([1, 2, 3], [1, 2, 3]), isTrue);
      expect(constantTimeEquals(<int>[], <int>[]), isTrue);
      expect(
        constantTimeEquals(Uint8List.fromList([9, 8, 7]), [9, 8, 7]),
        isTrue,
      );
    });

    test('different length is not equal', () {
      expect(constantTimeEquals([1, 2, 3], [1, 2]), isFalse);
      expect(constantTimeEquals([1, 2], [1, 2, 3]), isFalse);
    });

    test('same length but differing content is not equal', () {
      expect(constantTimeEquals([1, 2, 3], [1, 2, 4]), isFalse);
      // Difference in the first element (would fail an early-exit compare too).
      expect(constantTimeEquals([9, 2, 3], [1, 2, 3]), isFalse);
    });
  });
}
