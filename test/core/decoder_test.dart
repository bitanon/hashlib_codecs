import 'package:test/test.dart';
import 'package:hashlib_codecs/src/core/decoder.dart';

// Minimal concrete decoders for testing:
class Bits3to8Decoder extends BitDecoder {
  const Bits3to8Decoder();
  @override
  int get source => 3;
  @override
  int get target => 8;
}

class BadSourceDecoder extends BitDecoder {
  const BadSourceDecoder();
  @override
  int get source => 1; // invalid (< 2)
  @override
  int get target => 8;
}

class BadTargetDecoder extends BitDecoder {
  const BadTargetDecoder();
  @override
  int get source => 3;
  @override
  int get target => 65; // invalid (> 64)
}

void main() {
  group('BitDecoder (3→8)', () {
    test('packs 8 x 3-bit symbols into 3 bytes', () {
      // 8 valid symbols → 24 bits → 3 bytes
      final dec = const Bits3to8Decoder();
      final out = dec.convert([0, 1, 2, 3, 4, 5, 6, 7]);
      expect(out, equals([5, 57, 119])); // computed packing result
    });

    test('ignores data after first invalid symbol (no partial word)', () {
      // 8 valid symbols complete 3 bytes; trailing invalid symbol is ignored.
      final dec = const Bits3to8Decoder();
      final out =
          dec.convert([0, 1, 2, 3, 4, 5, 6, 7, 9, 0, 0]); // 9 > 7 → terminates
      expect(out, equals([5, 57, 119]));
    });

    test('throws FormatException on non-zero partial word (short input)', () {
      // Only 1 symbol → partial word remains → must throw.
      final dec = const Bits3to8Decoder();
      expect(() => dec.convert([1]), throwsA(isA<FormatException>()));
    });

    test('throws FormatException when invalid appears mid-group', () {
      // 5 symbols (15 bits) then invalid → leaves partial word → throw.
      final dec = const Bits3to8Decoder();
      expect(() => dec.convert([0, 1, 2, 3, 4, 9, 6, 7]),
          throwsA(isA<FormatException>()));
    });

    test('negative symbol terminates (after full group is OK)', () {
      final dec = const Bits3to8Decoder();
      final out = dec.convert([0, 1, 2, 3, 4, 5, 6, 7, -1, 0, 0]);
      expect(out, equals([5, 57, 119]));
    });
  });

  group('BitDecoder argument checks', () {
    test('rejects invalid source bit length', () {
      final dec = const BadSourceDecoder();
      expect(() => dec.convert(const []), throwsA(isA<ArgumentError>()));
    });

    test('rejects invalid target bit length', () {
      final dec = const BadTargetDecoder();
      expect(() => dec.convert(const []), throwsA(isA<ArgumentError>()));
    });
  });
}
