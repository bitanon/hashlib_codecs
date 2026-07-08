import 'package:convertlib/convertlib.dart';
import 'package:test/test.dart';

import './utils.dart';

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
    test('encoding empty list to raise error for LSB first', () {
      expect(() => toBigInt([]), throwsFormatException);
    });
    test('decoding negative to raise error for LSB first', () {
      expect(() => fromBigInt(-BigInt.two), throwsFormatException);
    });
    test('encoding empty list to raise error for LSB first', () {
      expect(() {
        toBigInt(
          [],
          codec: BigIntCodec.msbFirst,
        );
      }, throwsFormatException);
    });
    test('decoding negative to raise error for MSB first', () {
      expect(() {
        fromBigInt(
          -BigInt.two,
          codec: BigIntCodec.msbFirst,
        );
      }, throwsFormatException);
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
    group('zero-byte and boundary edges', () {
      test('MSB-first ignores leading zero bytes', () {
        // [0, 0, 1] big-endian is 0x000001 = 1.
        expect(toBigInt([0, 0, 1], msbFirst: true), equals(BigInt.one));
        expect(toBigInt([0, 0, 0, 0xFF], msbFirst: true),
            equals(BigInt.from(0xFF)));
      });
      test('LSB-first ignores trailing zero bytes', () {
        // [1, 0, 0] little-endian is 0x000001 = 1.
        expect(toBigInt([1, 0, 0]), equals(BigInt.one));
        expect(toBigInt([0xFF, 0, 0, 0]), equals(BigInt.from(0xFF)));
      });
      test('single 0xFF byte both endians', () {
        expect(toBigInt([0xFF]), equals(BigInt.from(0xFF)));
        expect(toBigInt([0xFF], msbFirst: true), equals(BigInt.from(0xFF)));
        expect(fromBigInt(BigInt.from(0xFF)), equals([0xFF]));
        expect(fromBigInt(BigInt.from(0xFF), msbFirst: true), equals([0xFF]));
      });
      test('LSB-first decode returns canonical form (trailing zeros dropped)',
          () {
        // Encoding [1, 0, 0] yields 1; decoding 1 yields [1] — the trailing
        // zero bytes are not restored. Documents the canonical-form behavior.
        var value = toBigInt([1, 0, 0]);
        expect(fromBigInt(value), equals([1]));
      });
      test('agrees with BigInt.parse over random inputs', () {
        // External oracle: build the big-endian hex string and parse it.
        for (int i = 1; i < 64; ++i) {
          var b = randomBytes(i);
          var hex = b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
          var expected = BigInt.parse(hex, radix: 16);
          expect(toBigInt(b, msbFirst: true), equals(expected),
              reason: 'length $i');
        }
      });
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
