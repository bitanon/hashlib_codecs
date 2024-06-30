// Copyright (c) 2024, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert';

import 'package:hashlib_codecs/src/utf8.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('utf8 test', () {
    test('ππππππππ', () {
      var test = r"ππππππππ";
      var actual = Utf8Encoder().convert(test);
      var mine = toUtf8(test);
      expect(mine, equals(actual));
      var decoded = fromUtf8(mine);
      expect(decoded, equals(test));
    });
    test('encoding <-> decoding', () {
      for (int i = 0; i < 100; ++i) {
        var b = randomNumbers(i, stop: 0x0010FFFF);
        var test = String.fromCharCodes(b);
        var actual = Utf8Encoder().convert(test);
        var mine = toUtf8(test);
        expect(mine, equals(actual), reason: 'Encoding: #$i');
        var decoded = fromUtf8(mine);
        expect(decoded, equals(test), reason: 'Decoding: #$i');
      }
    });
  });
}
