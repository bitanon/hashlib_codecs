// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert' as cvt;
import 'dart:typed_data';

import 'package:hashlib_codecs/src/bytes_collector.dart';
import 'package:test/test.dart';

class TestCollector extends ByteCollector {
  @override
  final Uint8List bytes;

  const TestCollector(this.bytes);
}

/// [Iterable<int>] that is not a [List] (exercises `isEqual` Iterable branch).
class _BytesIterable extends Iterable<int> {
  final List<int> _data;
  const _BytesIterable(this._data);

  @override
  Iterator<int> get iterator => _data.iterator;
}

void main() {
  group('ByteCollector', () {
    test('length and bytes reference', () {
      final u8 = Uint8List.fromList([1, 2, 3]);
      final c = TestCollector(u8);
      expect(c.length, 3);
      expect(c.bytes, same(u8));
      // `Uint8List.buffer` may not return identical [ByteBuffer] wrappers across
      // reads; value is still the same backing store as `c.bytes.buffer`.
      expect(c.buffer.lengthInBytes, u8.buffer.lengthInBytes);
    });

    test('toString matches hex()', () {
      final c = TestCollector(Uint8List.fromList([0xab, 0xcd]));
      expect(c.toString(), c.hex());
      expect(c.hex(), 'abcd');
      expect(c.hex(true), 'ABCD');
    });

    test('binary octal base32 base64', () {
      final c = TestCollector(Uint8List.fromList([0xff]));
      expect(c.binary(), '11111111');
      expect(c.octal(), '377');
      expect(c.base32(upper: true, padding: false), '74');
      expect(c.base32(upper: false, padding: true), '74======');
      expect(c.base64(), '/w==');
      expect(c.base64(padding: false), '/w');
      expect(c.base64(urlSafe: true, padding: false), '_w');
    });

    test('bigInt endian', () {
      final c = TestCollector(Uint8List.fromList([0x01, 0x00]));
      expect(c.bigInt(endian: Endian.little), BigInt.from(1));
      expect(c.bigInt(endian: Endian.big), BigInt.from(256));
    });

    group('number', () {
      test('big endian', () {
        final c = TestCollector(Uint8List.fromList([0x01, 0x02]));
        expect(c.number(16, Endian.big), 0x0102);
      });

      test('little endian', () {
        final c = TestCollector(Uint8List.fromList([0x01, 0x02]));
        expect(c.number(16, Endian.little), 0x0201);
      });

      test('invalid bit length throws', () {
        final c = TestCollector(Uint8List(1));
        expect(() => c.number(7), throwsArgumentError);
        expect(() => c.number(65), throwsArgumentError);
        expect(() => c.number(12), throwsArgumentError);
      });

      test('8-bit window', () {
        final one = TestCollector(Uint8List.fromList([0xfe]));
        expect(one.number(8, Endian.big), 0xfe);
        expect(one.number(8, Endian.little), 0xfe);
      });

      test('digest longer than requested window (n > byteLength)', () {
        final c = TestCollector(
          Uint8List.fromList([0x01, 0x02, 0x03, 0x04]),
        );
        expect(c.number(16, Endian.little), 0x0201);
        expect(c.number(16, Endian.big), 0x0304);
      });

      test('defaults use 64-bit big-endian window', () {
        final c = TestCollector(
          Uint8List.fromList([0, 0, 0, 0, 0, 0, 0x12, 0x34]),
        );
        expect(c.number(), 0x1234);
      });

      test('number 64-bit window full width', () {
        final eight = TestCollector(
          Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]),
        );
        expect(
          eight.number(64, Endian.big),
          (0x01020304 << 32) | 0x05060708,
        );
        expect(
          eight.number(64, Endian.little),
          (0x08070605 << 32) | 0x04030201,
        );
      }, tags: ['vm-only']);
    });

    test('ascii and utf8', () {
      final c = TestCollector(Uint8List.fromList('hi'.codeUnits));
      expect(c.ascii(), 'hi');
      expect(c.utf8(), 'hi');
    });

    test('to(encoding)', () {
      final c = TestCollector(Uint8List.fromList([0x61, 0x62]));
      expect(c.to(cvt.ascii), 'ab');
    });

    test('equality and hashCode with shared Uint8List buffer', () {
      // [Uint8List]== uses identity; same backing buffer yields == / hashCode match.
      final shared = Uint8List.fromList([1, 2]);
      final a = TestCollector(shared);
      final b = TestCollector(shared);
      final c = TestCollector(Uint8List.fromList([1, 3]));
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
      expect(a.hashCode, b.hashCode);
    });

    test('operator == identical and ByteCollector equality', () {
      final shared = Uint8List.fromList([9]);
      final a = TestCollector(shared);
      final b = TestCollector(shared);
      expect(a == a, isTrue);
      expect(a == b, isTrue);
      expect(a == TestCollector(Uint8List.fromList([8])), isFalse);
      expect(a == Object(), isFalse);
    });

    group('isEqual', () {
      test('identical', () {
        final x = TestCollector(Uint8List.fromList([1]));
        expect(x.isEqual(x), isTrue);
      });

      test('ByteCollector unwraps to bytes', () {
        final shared = Uint8List.fromList([1, 2]);
        final a = TestCollector(shared);
        final b = TestCollector(shared);
        expect(a.isEqual(b), isTrue);
      });

      test('hex string', () {
        final x = TestCollector(Uint8List.fromList([0xde, 0xad]));
        expect(x.isEqual('dead'), isTrue);
        expect(x.isEqual('bead'), isFalse);
      });

      test('List<int> length mismatch', () {
        final x = TestCollector(Uint8List.fromList([1, 2, 3, 4]));
        expect(x.isEqual(<int>[1, 2, 3]), isFalse);
      });

      test('Iterable<int>', () {
        final x = TestCollector(Uint8List.fromList([10, 20]));
        expect(x.isEqual([10, 20].map((e) => e)), isTrue);
        expect(x.isEqual([10, 21].map((e) => e)), isFalse);
      });

      test('Iterable<int> non-List success and failures', () {
        final x = TestCollector(Uint8List.fromList([1, 2, 3]));
        expect(x.isEqual(const _BytesIterable([1, 2, 3])), isTrue);
        expect(x.isEqual(const _BytesIterable([1, 2, 9])), isFalse);
        // Extra elements: exhaust digest length then fail on excess.
        expect(x.isEqual(const _BytesIterable([1, 2, 3, 4])), isFalse);
        // Fewer elements than digest: loop ends with return true (known API).
        expect(x.isEqual(const _BytesIterable([1, 2])), isTrue);
      });

      test('List<int> byte mismatch', () {
        final x = TestCollector(Uint8List.fromList([1, 2, 3]));
        expect(x.isEqual(<int>[1, 9, 3]), isFalse);
      });

      test('List<int> exact match', () {
        final x = TestCollector(Uint8List.fromList([4, 5, 6]));
        expect(x.isEqual(<int>[4, 5, 6]), isTrue);
      });

      test('null and unsupported for final branch', () {
        final x = TestCollector(Uint8List.fromList([1]));
        expect(x.isEqual(null), isFalse);
      });

      test('ByteBuffer via TypedData path', () {
        final u8 = Uint8List.fromList([5, 6, 7]);
        final x = TestCollector(u8);
        final copy = Uint8List.fromList([5, 6, 7]);
        expect(x.isEqual(copy.buffer), isTrue);
      });

      test('non-Uint8List TypedData (ByteData)', () {
        final bd = ByteData(3);
        bd.setUint8(0, 9);
        bd.setUint8(1, 8);
        bd.setUint8(2, 7);
        final x = TestCollector(Uint8List.fromList([9, 8, 7]));
        expect(x.isEqual(bd), isTrue);
        bd.setUint8(2, 0);
        expect(x.isEqual(bd), isFalse);
      });

      test('non-Uint8List TypedData (Uint16List)', () {
        final u16 = Uint16List(2);
        u16[0] = 0x0201;
        u16[1] = 0x0403;
        final backing = Uint8List.view(u16.buffer, u16.offsetInBytes, 4);
        final x = TestCollector(Uint8List.fromList(backing));
        expect(x.isEqual(u16), isTrue);
      });

      test('non-Uint8List TypedData (Float32List)', () {
        final f = Float32List(1)..[0] = 1.0;
        final x = TestCollector(
          Uint8List.view(f.buffer, f.offsetInBytes, 4),
        );
        expect(x.isEqual(f), isTrue);
      });

      test('unsupported type returns false', () {
        final x = TestCollector(Uint8List.fromList([1]));
        expect(x.isEqual(42), isFalse);
      });
    });
  });
}
