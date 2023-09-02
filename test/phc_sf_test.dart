// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:hashlib_codecs/hashlib_codecs.dart';
import 'package:test/test.dart';

void main() {
  group('Test PHC String Format', () {
    test('full format', () {
      var v =
          r"$argon2id$v=19$m=65536,t=2,p=1$gZiV/M1gPc22ElAH/Jh1Hw$CWOrkoo7oJBQ/iyh7uJ0LO2aLEfrHwTWllSAxT0zRno";
      expect(toPHCSF(fromPHCSF(v)), equals(v));
    });
    test('without version', () {
      var v =
          r"$argon2id$m=65536,t=2,p=1$gZiV/M1gPc22ElAH/Jh1Hw$CWOrkoo7oJBQ/iyh7uJ0LO2aLEfrHwTWllSAxT0zRno";
      expect(toPHCSF(fromPHCSF(v)), equals(v));
    });
    test('without params', () {
      var v =
          r"$argon2id$v=19$gZiV/M1gPc22ElAH/Jh1Hw$CWOrkoo7oJBQ/iyh7uJ0LO2aLEfrHwTWllSAxT0zRno";
      expect(toPHCSF(fromPHCSF(v)), equals(v));
    });
    test('without hash', () {
      String v = r"$argon2id$v=19$m=65536,t=2,p=1$gZiV/M1gPc22ElAH/Jh1Hw";
      expect(toPHCSF(fromPHCSF(v)), equals(v));
    });
    test('without salt and hash', () {
      String v = r"$argon2id$v=19$m=65536,t=2,p=1";
      expect(toPHCSF(fromPHCSF(v)), equals(v));
    });
    test('without version and params', () {
      var v =
          r"$argon2id$gZiV/M1gPc22ElAH/Jh1Hw$CWOrkoo7oJBQ/iyh7uJ0LO2aLEfrHwTWllSAxT0zRno";
      expect(toPHCSF(fromPHCSF(v)), equals(v));
    });
    test('without version, params and hash', () {
      var v = r"$argon2id$gZiV/M1gPc22ElAH/Jh1Hw";
      expect(toPHCSF(fromPHCSF(v)), equals(v));
    });
    test('without version, params, salt and hash', () {
      var v = r"$argon2id";
      expect(toPHCSF(fromPHCSF(v)), equals(v));
    });
    test('without params, salt and hash', () {
      var v = r"$argon2id$v=19";
      expect(toPHCSF(fromPHCSF(v)), equals(v));
    });
    test('empty string', () {
      var v = r"";
      expect(() => toPHCSF(fromPHCSF(v)), throwsFormatException);
    });
    test('empty string with a single dollar sign', () {
      var v = r"$";
      expect(() => toPHCSF(fromPHCSF(v)), throwsFormatException);
    });
    test('without id', () {
      var v = r"$v=19";
      expect(() => toPHCSF(fromPHCSF(v)), throwsFormatException);
    });
    test('invalid version', () {
      var v = r"$argon2id$v=invalid";
      expect(() => toPHCSF(fromPHCSF(v)), throwsFormatException);
    });
    test('invalid parameter name', () {
      var v = r"$argon2id$_m=65536,t=2,p=1";
      expect(() => toPHCSF(fromPHCSF(v)), throwsFormatException);
    });
    test('invalid parameter value', () {
      var v = r"$argon2id$m=*65536,t=2,p=1";
      expect(() => toPHCSF(fromPHCSF(v)), throwsFormatException);
    });
    test('invalid id', () {
      var v = r"$argo*n2id$v=19";
      expect(() => toPHCSF(fromPHCSF(v)), throwsFormatException);
    });
  });
}
