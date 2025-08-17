import 'package:test/test.dart';
import 'dart:typed_data';

// Import the library under test
import 'package:hashlib_codecs/src/core/byte.dart';

// Dummy concrete implementations to enable testing the abstract classes
class PassthroughByteEncoder extends ByteEncoder {
  const PassthroughByteEncoder({required super.bits});
  @override
  Uint8List convert(List<int> input) => Uint8List.fromList(input);
}

class PassthroughByteDecoder extends ByteDecoder {
  const PassthroughByteDecoder({required super.bits});
  @override
  Uint8List convert(List<int> encoded) => Uint8List.fromList(encoded);
}

void main() {
  group('ByteEncoder basics', () {
    for (final b in [4, 5, 6, 7, 8, 12, 16]) {
      test('properties with bits=$b', () {
        final enc = PassthroughByteEncoder(bits: b);
        expect(enc.bits, b);
        expect(enc.source, 8);
        expect(enc.target, b);
      });
    }

    test('convert returns a Uint8List copy', () {
      final enc = PassthroughByteEncoder(bits: 8);
      final input = [1, 2, 255, 0];
      final out = enc.convert(input);
      expect(out, equals(input));
      expect(out, isA<Uint8List>());
      // Ensure it is a different instance (defensive copy semantics)
      input[0] = 9;
      expect(out[0], isNot(9));
    });
  });

  group('ByteDecoder basics', () {
    for (final b in [3, 5, 6, 8, 10]) {
      test('properties with bits=$b', () {
        final dec = PassthroughByteDecoder(bits: b);
        expect(dec.bits, b);
        expect(dec.source, b);
        expect(dec.target, 8);
      });
    }

    test('convert returns a Uint8List copy', () {
      final dec = PassthroughByteDecoder(bits: 6);
      final input = [10, 20, 30];
      final out = dec.convert(input);
      expect(out, equals(input));
      expect(out, isA<Uint8List>());
      input[1] = 99;
      expect(out[1], isNot(99));
    });
  });

  group('Symmetry (encoder->decoder passthrough)', () {
    test('round trip with identical passthrough implementations', () {
      final enc = PassthroughByteEncoder(bits: 8);
      final dec = PassthroughByteDecoder(bits: 8);
      final original = List<int>.generate(32, (i) => (i * 7) & 0xFF);
      final mid = enc.convert(original);
      final again = dec.convert(mid);
      expect(again, equals(original));
    });
  });
}
