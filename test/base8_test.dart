import 'package:convertlib/convertlib.dart';
import 'package:test/test.dart';

import './utils.dart';

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
    group('[0] <=> 000', () {
      final input = <int>[0];
      final output = "000";
      test('encoding', () {
        expect(toOctal(input), equals(output));
      });
      test('decoding', () {
        expect(fromOctal(output), equals(input));
      });
    });
    group('[0xFF] <=> 377', () {
      // 0xFF is 255, and 255 in octal is 377 (int.toRadixString(8)).
      final input = <int>[0xFF];
      final output = "377";
      test('encoding', () {
        expect(toOctal(input), equals(output));
      });
      test('decoding', () {
        expect(fromOctal(output), equals(input));
      });
    });
    group('[0xFF, 0xFF] <=> 177777', () {
      // 0xFFFF is 65535, and 65535 in octal is 177777 (int.toRadixString(8)).
      final input = <int>[0xFF, 0xFF];
      final output = "177777";
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
      test('200000', () {
        var input = '200000';
        var output = [1, 0, 0];
        expect(fromOctal(input), equals(output));
      });
      test('182', () {
        expect(
          () => fromOctal("182"),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', 'Invalid character at 1')),
        );
      });
      test('-10', () {
        expect(
          () => fromOctal("-10"),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', 'Invalid character at 0')),
        );
      });
      test('01a1', () {
        expect(
          () => fromOctal("01a1"),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', 'Invalid character at 2')),
        );
      });
    });
  });
}
