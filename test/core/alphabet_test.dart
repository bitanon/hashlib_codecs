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
      final data = List<int>.generate(256, (i) => i); // 0..255
      final out = enc.convert(data);
      expect(out, data);
      // Decode back
      final decodeAlphabet =
          List<int>.generate(256, (i) => i); // inverse (identity)
      final dec = AlphabetDecoder(bits: 8, alphabet: decodeAlphabet);
      final back = dec.convert(out);
      expect(back, data);
    });

    test('5-bit encoding with padding to full byte boundary', () {
      final bits = 5;
      final encodeAlphabet = List<int>.generate(32, (i) => i); // identity
      const pad = 255;
      final enc =
          AlphabetEncoder(bits: bits, alphabet: encodeAlphabet, padding: pad);
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
      final dec =
          AlphabetDecoder(bits: bits, alphabet: decodeAlphabet, padding: pad);
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
      final withJunk = [
        ...encoded,
        pad, // an explicit early padding (should stop here)
        10, 11, 12
      ];
      final decodeAlphabet = List<int>.generate(256, (i) => i < 32 ? i : -1);
      final dec =
          AlphabetDecoder(bits: bits, alphabet: decodeAlphabet, padding: pad);
      final decoded = dec.convert(withJunk);
      expect(decoded, input);
    });

    test('Decoder throws on invalid character (out of range)', () {
      final dec = AlphabetDecoder(
        bits: 5,
        alphabet: List<int>.generate(32, (i) => i),
      );
      expect(() => dec.convert([40]), throwsFormatException);
    });

    test('Decoder throws on invalid character (negative mapping)', () {
      // alphabet[y] < 0 triggers FormatException
      final badAlphabet = List<int>.generate(32, (i) => i == 10 ? -1 : i);
      final dec = AlphabetDecoder(bits: 5, alphabet: badAlphabet);
      expect(() => dec.convert([10]), throwsFormatException);
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

    test('Base64 decoder ignores data after padding', () {
      final pad = '='.codeUnitAt(0);
      final enc = AlphabetEncoder(bits: 6, alphabet: b64codes, padding: pad);
      final input = 'Ma'.codeUnits;
      final encoded = enc.convert(input); // TWE=
      final withJunk = [...encoded, 'A'.codeUnitAt(0), 'B'.codeUnitAt(0)];
      final decodeAlphabet = List<int>.filled(256, -1);
      for (var i = 0; i < b64codes.length; i++) {
        decodeAlphabet[b64codes[i]] = i;
      }
      final dec =
          AlphabetDecoder(bits: 6, alphabet: decodeAlphabet, padding: pad);
      final decoded = dec.convert(withJunk);
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
