import 'package:convertlib/convertlib.dart';
import 'package:test/test.dart';

import './utils.dart';

void main() {
  // Each `tryFrom<X>` returns the same bytes as `from<X>` for valid input, and
  // `null` (instead of throwing) for input that `from<X>` would reject.
  group('tryFromX returns null instead of throwing', () {
    test('tryFromHex', () {
      for (int i = 0; i < 30; ++i) {
        final b = randomBytes(i);
        final s = toHex(b);
        expect(tryFromHex(s), equals(fromHex(s)), reason: '$i');
      }
      expect(tryFromHex('xyz'), isNull); // invalid characters
      expect(tryFromHex('Error'), isNull);
    });
    test('tryFromBinary', () {
      final b = randomBytes(8);
      final s = toBinary(b);
      expect(tryFromBinary(s), equals(fromBinary(s)));
      expect(tryFromBinary('0102'), isNull);
    });
    test('tryFromOctal', () {
      final b = randomBytes(8);
      final s = toOctal(b);
      expect(tryFromOctal(s), equals(fromOctal(s)));
      expect(tryFromOctal('089'), isNull);
    });
    test('tryFromBase32', () {
      for (int i = 0; i < 30; ++i) {
        final b = randomBytes(i);
        final s = toBase32(b);
        expect(tryFromBase32(s), equals(fromBase32(s)), reason: '$i');
      }
      expect(tryFromBase32('Error!'), isNull); // invalid char
      expect(tryFromBase32('B'), isNull); // invalid length
    });
    test('tryFromBase64', () {
      for (int i = 0; i < 30; ++i) {
        final b = randomBytes(i);
        final s = toBase64(b);
        expect(tryFromBase64(s), equals(fromBase64(s)), reason: '$i');
      }
      expect(tryFromBase64('H'), isNull); // invalid length
    });
    test('tryFromUtf8', () {
      final bytes = toUtf8('héllo€😀');
      expect(tryFromUtf8(bytes), equals('héllo€😀'));
      expect(tryFromUtf8([0xC2]), isNull); // truncated 2-byte sequence
    });
    test('tryFromBigInt', () {
      final value = toBigInt([1, 2, 3]);
      expect(tryFromBigInt(value), equals(fromBigInt(value)));
      expect(tryFromBigInt(-BigInt.one), isNull); // negative is rejected
    });
  });
}
