import 'package:convertlib/convertlib.dart';
import 'package:test/test.dart';

import './utils.dart';

void main() {
  group('Test base2', () {
    group("encoding", () {
      test('[] => empty string', () {
        expect(toBinary([]), "");
      });
      test('[1] => 00000001', () {
        expect(toBinary([1]), "00000001");
      });
      test('[0] => 00000000', () {
        expect(toBinary([0]), "00000000");
      });
      test('[0x80] => 10000000', () {
        expect(toBinary([0x80]), "10000000");
      });
      test('[0xFF] => 11111111', () {
        expect(toBinary([0xFF]), "11111111");
      });
      test('[0xFF, 0x00] => 1111111100000000', () {
        expect(toBinary([0xFF, 0x00]), "1111111100000000");
      });
      test('[7] => 00000111', () {
        expect(toBinary([7]), "00000111");
      });
      test('[10] => 00001010', () {
        expect(toBinary([10]), "00001010");
      });
      test('[0,10] => 00001010', () {
        expect(toBinary([0, 10]), "0000000000001010");
      });
      test('random', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var r = b.map((x) => x.toRadixString(2).padLeft(8, '0')).join();
          expect(toBinary(b), equals(r), reason: 'length $i');
        }
      });
    });
    group("decoding", () {
      test('empty string => []', () {
        expect(fromBinary(""), <int>[]);
      });
      test('1010 => [10]', () {
        expect(fromBinary("1010"), [10]);
      });
      test('00000000 => [0]', () {
        expect(fromBinary("00000000"), [0]);
      });
      test('10000000 => [0x80]', () {
        expect(fromBinary("10000000"), [0x80]);
      });
      test('11111111 => [0xFF]', () {
        expect(fromBinary("11111111"), [0xFF]);
      });
      test('1111111100000000 => [0xFF, 0x00]', () {
        expect(fromBinary("1111111100000000"), [0xFF, 0x00]);
      });
      test('01010 => [10]', () {
        expect(fromBinary("01010"), [10]);
      });
      test('0001010 => [10]', () {
        expect(fromBinary("0001010"), [10]);
      });
      test('00001010 => [10]', () {
        expect(fromBinary("00001010"), [10]);
      });
      test('000001010 => [0, 10]', () {
        expect(fromBinary("000001010"), [0, 10]);
      });
      test('0000000001010 => [0, 10]', () {
        expect(fromBinary("0000000001010"), [0, 10]);
      });
      test('100001010 => [1, 10]', () {
        expect(fromBinary("100001010"), [1, 10]);
      });
      test('10000001010 => [4, 10]', () {
        expect(fromBinary("10000001010"), [4, 10]);
      });
      test('random', () {
        for (int i = 0; i < 100; ++i) {
          var b = randomBytes(i);
          var r = b.map((x) => x.toRadixString(2).padLeft(8, '0')).join();
          expect(fromBinary(r), equals(b), reason: 'length $i');
        }
      });
    });
    test('encoding <-> decoding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = toBinary(b);
        expect(fromBinary(r), equals(b), reason: 'length $i');
      }
    });
    group('decoding with invalid chars', () {
      test('0158', () {
        expect(
          () => fromBinary("0158"),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', 'Invalid character at 2')),
        );
      });
      test('-10', () {
        expect(
          () => fromBinary("-10"),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', 'Invalid character at 0')),
        );
      });
      test('01a1', () {
        expect(
          () => fromBinary("01a1"),
          throwsA(isA<FormatException>()
              .having((e) => e.message, 'message', 'Invalid character at 2')),
        );
      });
    });
  });
}
