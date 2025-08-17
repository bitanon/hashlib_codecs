import 'package:hashlib_codecs/src/core/encoder.dart';
import 'package:test/test.dart';

class Bits3to8Encoder extends BitEncoder {
  const Bits3to8Encoder();
  @override
  int get source => 3;
  @override
  int get target => 8;
}

class BadSourceEncoder extends BitEncoder {
  const BadSourceEncoder();
  @override
  int get source => 1; // invalid (<2)
  @override
  int get target => 8;
}

class BadTargetEncoder extends BitEncoder {
  const BadTargetEncoder();
  @override
  int get source => 3;
  @override
  int get target => 65; // invalid (>64)
}

void main() {
  group('BitEncoder (3 → 8)', () {
    test('packs 8×3-bit symbols into 3 bytes (exact fit)', () {
      // 8 symbols × 3 bits = 24 bits → 3 bytes
      final enc = const Bits3to8Encoder();
      final out = enc.convert([0, 1, 2, 3, 4, 5, 6, 7]);
      expect(out, equals([5, 57, 119])); // known-good packing
    });

    test('pads partial word with zeros (single symbol)', () {
      // 3 bits → pad 5 zeros on the right → 00100000 = 32
      final enc = const Bits3to8Encoder();
      expect(enc.convert([1]), equals([32]));
    });

    test('pads partial word with zeros (two symbols)', () {
      // symbols: 7 (111), 1 (001)
      // accumulate: (7<<3)|1 = 57; pad with 2 zeros: 57<<2 = 228
      final enc = const Bits3to8Encoder();
      expect(enc.convert([7, 1]), equals([228]));
    });

    test('multiple full and partial groups', () {
      final enc = const Bits3to8Encoder();
      // 11 symbols → 33 bits → 5 bytes (last byte padded)
      final out = enc.convert([0, 1, 2, 3, 4, 5, 6, 7, 7, 7, 7]);
      // Compute expected manually:
      // first 8 → [5,57,119] ; remaining 3 symbols: 7,7,7 → 9 bits:
      // p=(7<<6)|(7<<3)|7 = (448)|(56)|7 = 511 ; n=9 → emit one byte (511>>>1=255), n=1
      // pad remaining 1 bit with 7 zeros: (p & (1)) << 7 = 1<<7 = 128
      expect(out, equals([5, 57, 119, 255, 128]));
    });

    test('BitEncoder accepts negative symbol by masking (surprising)', () {
      final enc = const Bits3to8Encoder();
      final outNeg = enc.convert([-1]); // -1 & 0x7 == 7
      final outSeven = enc.convert([7]);
      expect(outNeg, equals(outSeven),
          reason:
              'Negative input got masked to 3-bit value; likely unintended');
    });
  });

  group('BitEncoder argument checks', () {
    test('rejects invalid source bit length', () {
      final enc = const BadSourceEncoder();
      expect(() => enc.convert(const []), throwsA(isA<ArgumentError>()));
    });

    test('rejects invalid target bit length', () {
      final enc = const BadTargetEncoder();
      expect(() => enc.convert(const []), throwsA(isA<ArgumentError>()));
    });
  });
}
