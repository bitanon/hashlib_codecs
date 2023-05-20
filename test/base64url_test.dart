// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert';

import 'package:hashlib_codecs/hashlib_codecs.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Test base64url', () {
    test('encoding no padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = base64UrlEncode(b).replaceAll('=', '');
        expect(toBase64Url(b, padding: false), r, reason: 'length $i');
      }
    });
    test('decoding no padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = base64UrlEncode(b).replaceAll('=', '');
        expect(fromBase64Url(r), equals(b), reason: 'length $i');
      }
    });
    test('encoding with padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = base64UrlEncode(b);
        expect(toBase64Url(b, padding: true), r, reason: 'length $i');
      }
    });
    test('decoding with padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = base64UrlEncode(b);
        expect(fromBase64Url(r), equals(b), reason: 'length $i');
      }
    });
    test('encoding <-> decoding no padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = toBase64Url(b, padding: false);
        expect(fromBase64Url(r), equals(b), reason: 'length $i');
      }
    });
    test('encoding <-> decoding with padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = toBase64Url(b, padding: true);
        expect(fromBase64Url(r), equals(b), reason: 'length $i');
      }
    });
    group('decoding with invalid chars', () {
      test('"Hashlib!"', () {
        expect(() => fromBase64Url("Hashlib!"), throwsFormatException);
      });
      test('"-10"', () {
        expect(() => fromBase64Url(" 10"), throwsFormatException);
      });
      test('"s/mething"', () {
        expect(() => fromBase64Url("s/mething"), throwsFormatException);
      });
    });
    // group('decoding with invalid length', () {
    //   test('"H"', () {
    //     expect(() => fromBase64Url("H"), throwsFormatException);
    //   });
    //   test('"Ha"', () {
    //     expect(() => fromBase64Url("Ha"), throwsFormatException);
    //   });
    //   test('"Has"', () {
    //     expect(() => fromBase64Url("Has"), throwsFormatException);
    //   });
    //   test('"Hashl"', () {
    //     expect(() => fromBase64Url("Hashl"), throwsFormatException);
    //   });
    //   test('"Hashli"', () {
    //     expect(() => fromBase64Url("Hashli"), throwsFormatException);
    //   });
    //   test('"Hashlib"', () {
    //     expect(() => fromBase64Url("Hashlib"), throwsFormatException);
    //   });
    // });
  });
}
