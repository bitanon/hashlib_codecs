import 'package:test/test.dart';
import 'package:hashlib_codecs/src/core/alphabet.dart';

final b64codes =
    'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
        .codeUnits;

void main() {
  group('AlphabetEncoder / AlphabetDecoder', () {
    test('8-bit identity alphabet without padding', () {
      // bits = 8 so encoder should behave like identity before alphabet map
      final encodeAlphabet = List<int>.generate(256, (i) => i); // identity
      final enc = AlphabetEncoder(bits: 8, alphabet: encodeAlphabet);
      expect(enc.source, equals(8), reason: 'encoder source');
      expect(enc.target, equals(8), reason: 'encoder target');
      final data = List<int>.generate(256, (i) => i); // 0..255
      final out = enc.convert(data);
      expect(out, data);
      // Decode back
      final decodeAlphabet =
          List<int>.generate(256, (i) => i); // inverse (identity)
      final dec = AlphabetDecoder(bits: 8, alphabet: decodeAlphabet);
      expect(dec.source, equals(8), reason: 'decoder source');
      expect(dec.target, equals(8), reason: 'decoder source');
      final back = dec.convert(out);
      expect(back, data);
    });

    test('5-bit encoding with padding to full byte boundary', () {
      final bits = 5;
      final encodeAlphabet = List<int>.generate(32, (i) => i); // identity
      const pad = 255;
      final enc = AlphabetEncoder(
        bits: bits,
        alphabet: encodeAlphabet,
        padding: pad,
      );
      expect(enc.source, equals(8), reason: 'encoder source');
      expect(enc.target, equals(bits), reason: 'encoder target');
      final input = [0xAB]; // single byte
      final encoded = enc.convert(input);
      // Expect length padded so that length * bits is multiple of 8.
      expect((encoded.length * bits) % 8, 0);
      // Without padding we would have ceil(8/5)=2 symbols; padding extends to 8 symbols (like base32 style)
      expect(encoded.length, 8);
      // First two symbols are from data, remaining are padding
      for (int i = 2; i < encoded.length; i++) {
        expect(encoded[i], pad);
      }

      // Build decoder inverse alphabet (identity) with padding
      final decodeAlphabet = List<int>.generate(256, (i) => i < 32 ? i : -1);
      final dec = AlphabetDecoder(
        bits: bits,
        alphabet: decodeAlphabet,
        padding: pad,
      );
      expect(dec.source, equals(bits), reason: 'decoder source');
      expect(dec.target, equals(8), reason: 'decoder target');
      final decoded = dec.convert(encoded);
      expect(decoded, input);
    });

    test('Decoder stops at padding', () {
      final bits = 5;
      const pad = 200;
      final encodeAlphabet = List<int>.generate(32, (i) => i);
      final enc =
          AlphabetEncoder(bits: bits, alphabet: encodeAlphabet, padding: pad);
      final input = [1, 2, 3];
      final encoded = enc.convert(input);
      // Manually append extra data after padding that should be ignored
      final withJunk = [...encoded, pad, pad];
      final decodeAlphabet = List<int>.generate(256, (i) => i < 32 ? i : -1);
      final dec =
          AlphabetDecoder(bits: bits, alphabet: decodeAlphabet, padding: pad);
      final decoded = dec.convert(withJunk);
      expect(decoded, input);
    });

    test('Decoder throws for invalid bit size', () {
      expect(
        () => AlphabetDecoder(bits: 1, alphabet: [2]).convert([20, 40, 40, 24]),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message',
            'The source bit length should be between 2 to 64')),
      );
      expect(
        () =>
            AlphabetDecoder(bits: 128, alphabet: [2]).convert([20, 40, 40, 24]),
        throwsA(isA<ArgumentError>().having((e) => e.message, 'message',
            'The source bit length should be between 2 to 64')),
      );
    });

    test('Decoder throws on invalid character (out of range)', () {
      final dec = AlphabetDecoder(
        bits: 5,
        alphabet: List<int>.generate(32, (i) => i),
      );
      expect(
        () => dec.convert([40]),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', 'Invalid character 40 at 0')),
      );
    });

    test('Decoder throws on invalid character (negative mapping)', () {
      // alphabet[y] < 0 triggers FormatException
      final badAlphabet = List<int>.generate(32, (i) => i == 10 ? -1 : i);
      final dec = AlphabetDecoder(bits: 5, alphabet: badAlphabet);
      expect(
        () => dec.convert([10]),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', 'Invalid character 10 at 0')),
      );
    });

    test('Decoder throws for invalid character after padding', () {
      final dec = AlphabetDecoder(
        bits: 5,
        padding: 40,
        alphabet: List<int>.generate(32, (i) => i),
      );
      expect(
        () => dec.convert([20, 40, 39]),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', 'Invalid character 39 at 2')),
      );
      expect(
        () => dec.convert([20, 40, 40, 24]),
        throwsA(isA<FormatException>()
            .having((e) => e.message, 'message', 'Invalid character 24 at 3')),
      );
    });

    test('Base64 encode/decode (no padding)', () {
      final enc = AlphabetEncoder(
        bits: 6,
        alphabet: b64codes,
        padding: '='.codeUnitAt(0),
      );
      final input = 'Man'.codeUnits; // 3 bytes -> 4 chars, no padding
      final encoded = enc.convert(input);
      expect(String.fromCharCodes(encoded), 'TWFu');

      final decodeAlphabet = List<int>.filled(256, -1);
      for (var i = 0; i < b64codes.length; i++) {
        decodeAlphabet[b64codes[i]] = i;
      }
      final dec = AlphabetDecoder(
        bits: 6,
        alphabet: decodeAlphabet,
        padding: '='.codeUnitAt(0),
      );
      final decoded = dec.convert(encoded);
      expect(decoded, input);
    });

    test('Base64 encode/decode (single padding)', () {
      final pad = '='.codeUnitAt(0);
      final enc = AlphabetEncoder(bits: 6, alphabet: b64codes, padding: pad);
      final input = 'Ma'.codeUnits; // 2 bytes -> 3 data chars + 1 pad
      final encoded = enc.convert(input);
      expect(String.fromCharCodes(encoded), 'TWE=');

      final decodeAlphabet = List<int>.filled(256, -1);
      for (var i = 0; i < b64codes.length; i++) {
        decodeAlphabet[b64codes[i]] = i;
      }
      final dec =
          AlphabetDecoder(bits: 6, alphabet: decodeAlphabet, padding: pad);
      final decoded = dec.convert(encoded);
      expect(decoded, input);
    });

    test('Base64 encode/decode (double padding)', () {
      final pad = '='.codeUnitAt(0);
      final enc = AlphabetEncoder(bits: 6, alphabet: b64codes, padding: pad);
      final input = 'M'.codeUnits; // 1 byte -> 2 data chars + 2 pads
      final encoded = enc.convert(input);
      expect(String.fromCharCodes(encoded), 'TQ==');

      final decodeAlphabet = List<int>.filled(256, -1);
      for (var i = 0; i < b64codes.length; i++) {
        decodeAlphabet[b64codes[i]] = i;
      }
      final dec =
          AlphabetDecoder(bits: 6, alphabet: decodeAlphabet, padding: pad);
      final decoded = dec.convert(encoded);
      expect(decoded, input);
    });

    test('Base64 decoder rejects invalid character', () {
      final decodeAlphabet = List<int>.filled(256, -1);
      for (var i = 0; i < b64codes.length; i++) {
        decodeAlphabet[b64codes[i]] = i;
      }
      final dec = AlphabetDecoder(
        bits: 6,
        alphabet: decodeAlphabet,
        padding: '='.codeUnitAt(0),
      );
      expect(() => dec.convert('?'.codeUnits), throwsFormatException);
    });
  });
}
