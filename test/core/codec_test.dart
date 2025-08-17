import 'dart:typed_data';

import 'package:hashlib_codecs/src/core/codec.dart';
import 'package:hashlib_codecs/src/core/decoder.dart';
import 'package:hashlib_codecs/src/core/encoder.dart';
import 'package:test/test.dart';

class PlusOneCodec extends IterableCodec {
  const PlusOneCodec();

  @override
  Iterable<int> encode(Iterable<int> input) => input.map((e) => (e + 1) & 0xFF);

  @override
  Iterable<int> decode(Iterable<int> input) => input.map((e) => (e - 1) & 0xFF);

  // Not needed for these tests.
  @override
  BitEncoder get encoder => throw UnimplementedError();

  @override
  BitDecoder get decoder => throw UnimplementedError();
}

class IdentityConverter extends HashlibConverter {
  @override
  final int source;

  @override
  final int target;
  const IdentityConverter(this.source, this.target);

  @override
  Iterable<int> convert(Iterable<int> input) => input;
}

void main() {
  group('IterableCodec convenience methods', () {
    const codec = PlusOneCodec();

    test('encodeString increments code units', () {
      final out = codec.encodeString('ABC').toList();
      expect(out, [66, 67, 68]);
    });

    test('decodeString decrements code units', () {
      final out = codec.decodeString('BCD').toList();
      expect(out, [66 - 1, 67 - 1, 68 - 1]);
      expect(String.fromCharCodes(out), 'ABC');
    });

    test('round trip with unicode', () {
      final s = String.fromCharCodes([104, 233, 0xD8, 0x3D, 0xDE, 0x42]);
      final enc = codec.encodeString(s).toList();
      final dec = codec.decode(enc).toList();
      expect(String.fromCharCodes(dec), s);
    });

    test('encodeBuffer works', () {
      final bytes = Uint8List.fromList([0, 1, 254, 255]);
      final out = codec.encodeBuffer(bytes.buffer).toList();
      expect(out, [1, 2, 255, 0]); // wrapped by & 0xFF
    });

    test('decodeBuffer works', () {
      final bytes = Uint8List.fromList([1, 2, 0]);
      final out = codec.decodeBuffer(bytes.buffer).toList();
      expect(out, [0, 1, 255]);
    });

    test('empty inputs', () {
      expect(codec.encodeString('').toList(), isEmpty);
      expect(codec.decode(const <int>[]).toList(), isEmpty);
    });
  });

  group('HashlibConverter base class', () {
    test('identity converter preserves data', () {
      const conv = IdentityConverter(8, 8);
      final input = [0, 1, 127, 255];
      final out = conv.convert(input).toList();
      expect(out, input);
    });

    test('source/target properties exposed', () {
      const conv = IdentityConverter(5, 7);
      expect(conv.source, 5);
      expect(conv.target, 7);
    });

    test('convert iterable laziness (multiple iterations consistent)', () {
      const conv = IdentityConverter(8, 8);
      final input = [10, 20, 30];
      final converted = conv.convert(input);
      expect(converted.toList(), [10, 20, 30]);

      input[1] = 99;
      expect(converted.toList(), [10, 99, 30]);
    });
  });
}
