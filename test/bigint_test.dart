// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:hashlib_codecs/hashlib_codecs.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() {
  group('Test BigInt', () {
    test('parameter overrides', () {
      var i = [0, 0, 1];
      var o = BigInt.one << 16;
      var a = toBigInt(i);
      expect(a, equals(o));
      a = toBigInt(
        i,
        codec: BigIntCodec.little,
      );
      expect(a, equals(o));
      a = toBigInt(
        i,
        codec: BigIntCodec.little,
        bigEndian: true,
      );
      expect(a, equals(o));
    });
    test('encoding empty list to raise error', () {
      expect(() => toBigInt([]), throwsFormatException);
    });
    test('decoding negative to raise error', () {
      expect(() => fromBigInt(-BigInt.two), throwsFormatException);
    });
    test('encoding [0] => 0', () {
      var inp = <int>[0];
      var out = BigInt.zero;
      expect(toBigInt(inp), equals(out));
    });
    test('encoding [0] => 0 big endian', () {
      var inp = <int>[0];
      var out = BigInt.zero;
      expect(toBigInt(inp, bigEndian: true), equals(out));
    });
    test('encoding [0, 0, 0] => 0', () {
      var inp = <int>[0, 0, 0];
      var out = BigInt.zero;
      expect(toBigInt(inp), equals(out));
    });
    test('encoding [0, 0, 0] => 0 big endian', () {
      var inp = <int>[0, 0, 0];
      var out = BigInt.zero;
      expect(toBigInt(inp, bigEndian: true), equals(out));
    });
    test('decoding 0 => [0]', () {
      var inp = <int>[0];
      var out = BigInt.zero;
      expect(fromBigInt(out), equals(inp));
    });
    test('decoding 0 => [0] big endian', () {
      var inp = <int>[0];
      var out = BigInt.zero;
      expect(fromBigInt(out, bigEndian: true), equals(inp));
    });
    test('little-endian encoding <-> decoding', () {
      for (int i = 0; i < 100; ++i) {
        var inp = [...randomBytes(i), 1];
        var out = toBigInt(inp);
        var out2 = fromBigInt(out);
        expect(out2, equals(inp), reason: 'length $i');
      }
    });
    test('big-endian encoding <-> decoding', () {
      for (int i = 0; i < 100; ++i) {
        var inp = [1, ...randomBytes(i)];
        var out = toBigInt(inp, bigEndian: true);
        var out2 = fromBigInt(out, bigEndian: true);
        expect(out2, equals(inp), reason: 'length $i');
      }
    });
  });
}
