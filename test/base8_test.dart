// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:hashlib_codecs/hashlib_codecs.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Test base8', () {
    group("encoding", () {
      test('[] => empty string', () {
        expect(toOctal([]), "");
      });
      test('[1] => 002', () {
        expect(toOctal([1]), "002");
      });
      test('[0, 1] => 000004', () {
        expect(toOctal([0, 1]), "000004");
      });
      test('[1, 0] => 002000', () {
        expect(toOctal([1, 0]), "002000");
      });
      test('[7] => 016', () {
        expect(toOctal([7]), "016");
      });
      test('[10] => 024', () {
        expect(toOctal([10]), "024");
      });
      test('[0, 10] => 000050', () {
        expect(toOctal([0, 10]), "000050");
      });
    });
    group("decoding", () {
      test('empty string => []', () {
        expect(fromOctal(""), []);
      });
      test('12 |001 010| => invalid length', () {
        expect(() => fromOctal("12"), throwsFormatException);
      });
      test('012 |000 001 01|0| => [5]', () {
        expect(fromOctal("012"), equals([5]));
      });
      test('0012 |000 000 00|1 010| => invalid length', () {
        expect(() => fromOctal("0012"), throwsFormatException);
      });
      test('00012 |000 000 00|0 001 010| => invalid length', () {
        expect(() => fromOctal("00012"), throwsFormatException);
      });
      test('000012 |000 000 00|0 000 001 0|10| => invalid length', () {
        expect(() => fromOctal("000012"), throwsFormatException);
      });
      test('0000012 |000 000 00|0 000 000 0|01 010| => : invalid length', () {
        expect(() => fromOctal("0000012"), throwsFormatException);
      });
      test('00000012 |000 000 00|0 000 000 0|00 001 010| => [0, 0, 10]', () {
        expect(fromOctal("00000012"), equals([0, 0, 10]));
      });
    });
    test('encoding <-> decoding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = toOctal(b);
        expect(fromOctal(r), equals(b), reason: 'length $i');
      }
    });
    group('decoding with invalid chars', () {
      test('0182', () {
        expect(() => fromOctal("0182"), throwsFormatException);
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
