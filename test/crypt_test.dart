import 'package:hashlib_codecs/hashlib_codecs.dart';
import 'package:test/test.dart';

void expectError<T>(Function fun, String message) {
  expect(fun, throwsA(isA<T>().having((e) => '$e', 'message', message)));
}

void main() {
  group('Modular Crypt Format', () {
    group('on valid string', () {
      test('including all parts', () {
        var v =
            r"$argon2id$v=19$m=65536,t=2,p=1$gZiV/M1gPc22ElAH/Jh1Hw$CWOrkoo7oJBQ/iyh7uJ0LO2aLEfrHwTWllSAxT0zRno";
        expect(toCrypt(fromCrypt(v)), equals(v));
      });
      test('without version', () {
        var v =
            r"$argon2id$m=65536,t=2,p=1$gZiV/M1gPc22ElAH/Jh1Hw$CWOrkoo7oJBQ/iyh7uJ0LO2aLEfrHwTWllSAxT0zRno";
        expect(toCrypt(fromCrypt(v)), equals(v));
      });
      test('without params', () {
        var v =
            r"$argon2id$v=19$gZiV/M1gPc22ElAH/Jh1Hw$CWOrkoo7oJBQ/iyh7uJ0LO2aLEfrHwTWllSAxT0zRno";
        expect(toCrypt(fromCrypt(v)), equals(v));
      });
      test('without hash', () {
        String v = r"$argon2id$v=19$m=65536,t=2,p=1$gZiV/M1gPc22ElAH/Jh1Hw";
        expect(toCrypt(fromCrypt(v)), equals(v));
      });
      test('without salt and hash', () {
        String v = r"$argon2id$v=19$m=65536,t=2,p=1";
        expect(toCrypt(fromCrypt(v)), equals(v));
      });
      test('without version and params', () {
        var v =
            r"$argon2id$gZiV/M1gPc22ElAH/Jh1Hw$CWOrkoo7oJBQ/iyh7uJ0LO2aLEfrHwTWllSAxT0zRno";
        expect(toCrypt(fromCrypt(v)), equals(v));
      });
      test('without params, salt and hash', () {
        var v = r"$argon2id$v=19";
        expect(toCrypt(fromCrypt(v)), equals(v));
      });
      test('without version, params and hash', () {
        var v = r"$argon2id$gZiV/M1gPc22ElAH/Jh1Hw";
        expect(toCrypt(fromCrypt(v)), equals(v));
      });
      test('without version, params, salt and hash', () {
        var v = r"$argon2id";
        expect(toCrypt(fromCrypt(v)), equals(v));
      });
    });

    group('Decoder failure cases', () {
      test('throws on empty string', () {
        expectError<FormatException>(
          () => fromCrypt(''),
          'FormatException: Empty string',
        );
      });
      test('throws on invalid start character', () {
        expectError<FormatException>(
          () => fromCrypt('s'),
          r'FormatException: Does not start with "$"',
        );
      });

      test('empty string with a single dollar sign', () {
        expectError<ArgumentError>(
          () => fromCrypt(r'$'),
          'Invalid argument (id): must be [a-z0-9-] and under 32 characters: ""',
        );
      });
      test('id is more than 32 characters', () {
        var name = List.filled(50, 'a').join();
        expectError<ArgumentError>(
          () => fromCrypt('\$$name'),
          'Invalid argument (id): must be [a-z0-9-] and under 32 characters: "$name"',
        );
      });
      test('id contains invalid characters', () {
        expectError<ArgumentError>(
          () => fromCrypt(r"$v=19"),
          'Invalid argument (id): must be [a-z0-9-] and under 32 characters: "v=19"',
        );
      });

      test('empty version', () {
        expectError<ArgumentError>(
          () => fromCrypt(r"$argon2id$v=sd"),
          'Invalid argument (version): must be decimal digits: "sd"',
        );
      });
      test('using reserved key in parameter', () {
        expectError<ArgumentError>(
          () => fromCrypt(r"$argon2id$v=3$v=42"),
          'Invalid argument (params.key): reserved; use version field instead: "v"',
        );
      });
      test('using reserved key in parameter', () {
        expectError<ArgumentError>(
          () => fromCrypt(r"$argon2id$v=3$p=3,v=42"),
          'Invalid argument (params.key): reserved; use version field instead: "v"',
        );
      });
      test('empty parameter name', () {
        expectError<ArgumentError>(
          () => fromCrypt(r"$argon2id$=1"),
          'Invalid argument (params.key): must be [a-z0-9-] and under 32 chars: ""',
        );
      });
      test('empty parameter value', () {
        expectError<ArgumentError>(
          () => fromCrypt(r"$argon2id$sd=,3=2"),
          'Invalid argument (params[sd]): value is empty: ""',
        );
      });
      test('parameter value with invalid character', () {
        expectError<ArgumentError>(
          () => fromCrypt(r"$argon2id$sd=o@o,3=2"),
          'Invalid argument (params[sd]): value has invalid characters: "o@o"',
        );
      });
      test('parameter without equal sign', () {
        expectError<FormatException>(
          () => fromCrypt(r"$argon2id$k,f=3$salt$hash"),
          'FormatException: Invalid parameter: "k"',
        );
      });
      test('duplicate parameter keys', () {
        expectError<FormatException>(
          () => fromCrypt(r"$argon2id$k=1,k=2$salt$hash"),
          'FormatException: Duplicate parameter key: "k"',
        );
      });
      test('empty parameters fields', () {
        expectError<FormatException>(
          () => fromCrypt(r"$argon2id$,$salt"),
          'FormatException: Invalid parameter: ""',
        );
      });
      test('invalid character in salt value', () {
        expectError<ArgumentError>(
          () => fromCrypt(r"$3$v=3$p=2$p&p"),
          'Invalid argument (salt): expected base64 string without padding: "p&p"',
        );
      });
      test('equal sign with salt value', () {
        expectError<ArgumentError>(
          () => fromCrypt(r"$3$v=3$p=2$salt="),
          'Invalid argument (salt): expected base64 string without padding: "salt="',
        );
      });
      test('invalid character in hash value', () {
        expectError<ArgumentError>(
          () => fromCrypt(r"$2$salt$er*er"),
          'Invalid argument (hash): expected base64 string without padding: "er*er"',
        );
      });
      test('equal sign with hash value', () {
        expectError<ArgumentError>(
          () => fromCrypt(r"$2$salt$hash="),
          'Invalid argument (hash): expected base64 string without padding: "hash="',
        );
      });
      test('extra characters at the end', () {
        expectError<FormatException>(
          () => fromCrypt(r"$argon2id$salt$hash$extra"),
          'FormatException: Extra characters at the end',
        );
      });
      test('extra dollar sign at the end', () {
        expectError<FormatException>(
          () => fromCrypt(r"$argon2id$salt$hash$"),
          'FormatException: Extra characters at the end',
        );
      });
    });
  });
}
