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
        codec: BigIntCodec.lsbFirst,
      );
      expect(a, equals(o));
      a = toBigInt(
        i,
        codec: BigIntCodec.lsbFirst,
        msbFirst: true,
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
      expect(toBigInt(inp, msbFirst: true), equals(out));
    });
    test('encoding [0, 0, 0] => 0', () {
      var inp = <int>[0, 0, 0];
      var out = BigInt.zero;
      expect(toBigInt(inp), equals(out));
    });
    test('encoding [0, 0, 0] => 0 big endian', () {
      var inp = <int>[0, 0, 0];
      var out = BigInt.zero;
      expect(toBigInt(inp, msbFirst: true), equals(out));
    });
    test('decoding 0 => [0]', () {
      var inp = <int>[0];
      var out = BigInt.zero;
      expect(fromBigInt(out), equals(inp));
    });
    test('decoding 0 => [0] big endian', () {
      var inp = <int>[0];
      var out = BigInt.zero;
      expect(fromBigInt(out, msbFirst: true), equals(inp));
    });
    test('little-endian encoding <-> decoding', () {
      for (int i = 0; i < 100; ++i) {
        var inp = [...randomBytes(i), 1];
        var out = toBigInt(inp);
        var out2 = fromBigInt(out);
        expect(out2, equals(inp), reason: 'length $i');
      }
    });
    test('encoding 32-bit big endian in MSB first order', () {
      var inp = <int>[1, 2, 3, 4];
      var out = BigInt.from(0x01020304);
      expect(toBigInt(inp, msbFirst: true), equals(out));
    });
    test('encoding 32-bit big endian in LSB first order', () {
      var inp = <int>[4, 3, 2, 1];
      var out = BigInt.from(0x01020304);
      expect(toBigInt(inp, msbFirst: false), equals(out));
    });
    test('decoding 32-bit big endian in MSB first order', () {
      var inp = <int>[1, 2, 3, 4];
      var out = BigInt.from(0x01020304);
      expect(fromBigInt(out, msbFirst: true), equals(inp));
    });
    test('decoding 32-bit big endian in LSB first order', () {
      var inp = <int>[4, 3, 2, 1];
      var out = BigInt.from(0x01020304);
      expect(fromBigInt(out, msbFirst: false), equals(inp));
    });
    test('encoding 64-bit big endian in MSB first order', () {
      var inp = <int>[1, 2, 3, 4, 5, 6, 7, 8];
      var out = BigInt.from((0x01020304 << 32) | 0x05060708);
      expect(toBigInt(inp, msbFirst: true), equals(out));
    }, tags: ['vm-only']);
    test('encoding 64-bit big endian in LSB first order', () {
      var inp = <int>[8, 7, 6, 5, 4, 3, 2, 1];
      var out = BigInt.from((0x01020304 << 32) | 0x05060708);
      expect(toBigInt(inp, msbFirst: false), equals(out));
    }, tags: ['vm-only']);
    test('decoding 64-bit big endian in MSB first order', () {
      var inp = <int>[1, 2, 3, 4, 5, 6, 7, 8];
      var out = BigInt.from((0x01020304 << 32) | 0x05060708);
      expect(fromBigInt(out, msbFirst: true), equals(inp));
    }, tags: ['vm-only']);
    test('decoding 64-bit big endian in LSB first order', () {
      var inp = <int>[8, 7, 6, 5, 4, 3, 2, 1];
      var out = BigInt.from((0x01020304 << 32) | 0x05060708);
      expect(fromBigInt(out, msbFirst: false), equals(inp));
    }, tags: ['vm-only']);
    test('big-endian encoding <-> decoding', () {
      for (int i = 0; i < 100; ++i) {
        var inp = [1, ...randomBytes(i)];
        var out = toBigInt(inp, msbFirst: true);
        var out2 = fromBigInt(out, msbFirst: true);
        expect(out2, equals(inp), reason: 'length $i');
      }
    });
  });
}
