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
      var a = toBase64(b, urlSafe: true);
      expect(a, equals("AAAA"));
    });
    test('encoding no padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var m = base64UrlEncode(b).replaceAll('=', '');
        var a = toBase64(b, noPadding: true, urlSafe: true);
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
        var a = toBase64(b, urlSafe: true);
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
        var r = toBase64(b, noPadding: true, urlSafe: true);
        expect(fromBase64(r), equals(b), reason: 'length $i');
      }
    });
    test('encoding <-> decoding with padding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomBytes(i);
        var r = toBase64(b, urlSafe: true);
        expect(fromBase64(r), equals(b), reason: 'length $i');
      }
    });
    group('decoding with invalid chars', () {
      test('Hashlib!', () {
        try {
          fromBase64("Hashlib!", urlSafe: true);
          throw Exception('No error thrown');
        } on FormatException catch (err) {
          expect(err.message, equals("Invalid character 33"));
        }
      });
      test('a.10', () {
        try {
          fromBase64("a.10", urlSafe: true);
          throw Exception('No error thrown');
        } on FormatException catch (err) {
          expect(err.message, equals("Invalid character 46"));
        }
      });
      test('s*methings', () {
        try {
          fromBase64("s*methings", urlSafe: true);
          throw Exception('No error thrown');
        } on FormatException catch (err) {
          expect(err.message, equals("Invalid character 42"));
        }
      });
    });
  });
}
