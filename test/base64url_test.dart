// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert';

import 'package:hashlib_codecs/hashlib_codecs.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Test base64url', () {
    test('encoding', () {
      var b = [0, 0, 0];
      var a = toBase64(b, alphabet: Base64Alphabet.urlSafe);
      expect(a, equals("AAAA"));
    });
    test('encoding no padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var m = base64UrlEncode(b).replaceAll('=', '');
        var a = toBase64(b, alphabet: Base64Alphabet.urlSafe, padding: false);
        expect(a, equals(m), reason: 'length $i');
      }
    });
    test('decoding no padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = base64UrlEncode(b).replaceAll('=', '');
        expect(fromBase64(r), equals(b), reason: 'length $i');
      }
    });
    test('encoding with padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var m = base64UrlEncode(b);
        var a = toBase64(b, alphabet: Base64Alphabet.urlSafe, padding: true);
        expect(a, equals(m), reason: 'length $i');
      }
    });
    test('decoding with padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = base64UrlEncode(b);
        expect(fromBase64(r), equals(b), reason: 'length $i');
      }
    });
    test('encoding <-> decoding no padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = toBase64(b, alphabet: Base64Alphabet.urlSafe, padding: false);
        expect(fromBase64(r), equals(b), reason: 'length $i');
      }
    });
    test('encoding <-> decoding with padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = toBase64(b, alphabet: Base64Alphabet.urlSafe, padding: true);
        expect(fromBase64(r), equals(b), reason: 'length $i');
      }
    });
    group('decoding with invalid chars', () {
      test('"Hashlib!"', () {
        expect(() => fromBase64("Hashlib!"), throwsFormatException);
      });
      test('"-10"', () {
        expect(() => fromBase64(" 10"), throwsFormatException);
      });
      test('"s*mething"', () {
        expect(() => fromBase64("s*mething"), throwsFormatException);
      });
    });
  });
}
