import 'dart:typed_data';

import 'package:convertlib/convertlib.dart';
import 'package:test/test.dart';

import './utils.dart';

void main() {
  // Each `to<X>Bytes` must return the ASCII codes of the corresponding
  // `to<X>` string, as a Uint8List, across random inputs of every length.
  group('encode-to-bytes matches the string encoders', () {
    test('toHexBytes', () {
      for (int i = 0; i < 50; ++i) {
        final b = randomBytes(i);
        expect(toHexBytes(b), isA<Uint8List>());
        expect(toHexBytes(b), equals(toHex(b).codeUnits), reason: '$i');
        expect(toHexBytes(b, upper: true),
            equals(toHex(b, upper: true).codeUnits));
      }
    });
    test('toBinaryBytes', () {
      for (int i = 0; i < 50; ++i) {
        final b = randomBytes(i);
        expect(toBinaryBytes(b), equals(toBinary(b).codeUnits), reason: '$i');
      }
    });
    test('toOctalBytes', () {
      for (int i = 0; i < 50; ++i) {
        final b = randomBytes(i);
        expect(toOctalBytes(b), equals(toOctal(b).codeUnits), reason: '$i');
      }
    });
    test('toBase32Bytes (padded and unpadded)', () {
      for (int i = 0; i < 50; ++i) {
        final b = randomBytes(i);
        expect(toBase32Bytes(b), equals(toBase32(b).codeUnits), reason: '$i');
        // Exercises the padding-strip branch on a padded codec.
        expect(
          toBase32Bytes(b, padding: false),
          equals(toBase32(b, padding: false).codeUnits),
          reason: 'unpadded $i',
        );
        // A codec that never pads skips the strip branch.
        expect(
          toBase32Bytes(b, codec: Base32Codec.crockford, padding: false),
          equals(toBase32(b, codec: Base32Codec.crockford).codeUnits),
        );
      }
    });
    test('toBase64Bytes (padded and unpadded)', () {
      for (int i = 0; i < 50; ++i) {
        final b = randomBytes(i);
        expect(toBase64Bytes(b), equals(toBase64(b).codeUnits), reason: '$i');
        expect(
          toBase64Bytes(b, url: true, padding: false),
          equals(toBase64(b, url: true, padding: false).codeUnits),
          reason: 'url unpadded $i',
        );
      }
    });
  });
}
