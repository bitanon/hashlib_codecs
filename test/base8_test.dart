// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:hashlib_codecs/hashlib_codecs.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Test base8', () {
    group('[] <=> empty string', () {
      final input = <int>[];
      final output = "";
      test('encoding', () {
        expect(toOctal(input), output);
      });
      test('decoding', () {
        expect(fromOctal(output), input);
      });
    });
    group('[1] <=> 001', () {
      final input = <int>[1];
      final output = "001";
      test('encoding', () {
        expect(toOctal(input), equals(output));
      });
      test('decoding', () {
        expect(fromOctal(output), equals(input));
      });
    });
    group('[0, 1] <=> 000001', () {
      final input = <int>[0, 1];
      final output = "000001";
      test('encoding', () {
        expect(toOctal(input), equals(output));
      });
      test('decoding', () {
        expect(fromOctal(output), equals(input));
      });
    });
    group('[1, 0] <=> 000400', () {
      final input = <int>[1, 0];
      final output = "000400";
      test('encoding', () {
        expect(toOctal(input), equals(output));
      });
      test('decoding', () {
        expect(fromOctal(output), equals(input));
      });
    });
    group('[7] <=> 007', () {
      final input = <int>[7];
      final output = "007";
      test('encoding', () {
        expect(toOctal(input), equals(output));
      });
      test('decoding', () {
        expect(fromOctal(output), equals(input));
      });
    });
    group('[10] <=> 012', () {
      final input = <int>[10];
      final output = "012";
      test('encoding', () {
        expect(toOctal(input), equals(output));
      });
      test('decoding', () {
        expect(fromOctal(output), equals(input));
      });
    });
    group('[0, 10] <=> 000012', () {
      final input = <int>[0, 10];
      final output = "000012";
      test('encoding', () {
        expect(toOctal(input), equals(output));
      });
      test('decoding', () {
        expect(fromOctal(output), equals(input));
      });
    });
    group('[1, 2, 3, 4, 5, 6, 7, 8] => 0004020060200501403410', () {
      var input = [1, 2, 3, 4, 5, 6, 7, 8];
      final output = "0004020060200501403410";
      test('encoding', () {
        expect(toOctal(input), equals(output));
      });
      test('decoding', () {
        expect(fromOctal(output), equals(input));
      });
    });

    test('encoding <-> decoding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = toOctal(b);
        expect(fromOctal(r), equals(b), reason: 'length $i');
      }
    });

    group('decoding edge cases', () {
      test('partial message', () {
        expect(fromOctal("12"), equals([10]));
      });
      test('long partial message', () {
        final input = '4020060200501403410';
        final output = [1, 2, 3, 4, 5, 6, 7, 8];
        expect(fromOctal(input), equals(output));
      });
      test('182', () {
        expect(() => fromOctal("182"), throwsFormatException);
      });
      test('-10', () {
        expect(() => fromOctal("-10"), throwsFormatException);
      });
      test('01a1', () {
        expect(() => fromOctal("01a1"), throwsFormatException);
      });
    });
  });
}
