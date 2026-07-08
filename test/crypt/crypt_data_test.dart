import 'package:test/test.dart';
import 'package:convertlib/src/codecs/crypt/crypt_data.dart';

void main() {
  group('CryptData', () {
    test('constructor and fields', () {
      final data = CryptData(
        'argon2id',
        version: '19',
        salt: 'c2FsdA', // "salt" in base64
        hash: 'aGFzaA', // "hash" in base64
        params: {'m': '65536', 't': '3', 'p': '4'},
      );
      expect(data.id, 'argon2id');
      expect(data.version, '19');
      expect(data.salt, 'c2FsdA');
      expect(data.hash, 'aGFzaA');
      expect(data.params, {'m': '65536', 't': '3', 'p': '4'});
    });

    test('saltBytes and hashBytes', () {
      final data = CryptData('id', salt: 'c2FsdA', hash: 'aGFzaA');
      expect(data.saltBytes(), isA<List<int>>());
      expect(data.hashBytes(), isA<List<int>>());
      expect(String.fromCharCodes(data.saltBytes()!), 'salt');
      expect(String.fromCharCodes(data.hashBytes()!), 'hash');
    });

    test('versionInt', () {
      final data = CryptData('id', version: '42');
      expect(data.versionInt(), 42);

      final invalid = CryptData('id', version: 'abc');
      expect(invalid.versionInt(), null);

      final none = CryptData('id');
      expect(none.versionInt(), null);
    });

    test('hasParam, getParam, getIntParam', () {
      final data = CryptData('id', params: {'x': '123', 'y': 'abc'});
      expect(data.hasParam('x'), true);
      expect(data.hasParam('z'), false);
      expect(data.getParam('x'), '123');
      expect(data.getParam('y'), 'abc');
      expect(data.getParam('z'), null);
      expect(data.getIntParam('x'), 123);
      expect(data.getIntParam('y'), null);
      expect(data.getIntParam('z'), null);
    });

    test('validate passes for valid data', () {
      final data = CryptData(
        'argon2id',
        version: '19',
        salt: 'c2FsdA',
        hash: 'aGFzaA',
        params: {'m': '65536', 't': '3', 'p': '4'},
      );
      expect(() => data.validate(), returnsNormally);
    });

    test('validate fails for invalid id', () {
      final data = CryptData('Argon2id!');
      expect(
          () => data.validate(),
          throwsA(isA<ArgumentError>()
              .having((e) => e.name, 'name', 'id')
              .having((e) => e.message, 'message',
                  'must be [a-z0-9-] and under 32 characters')));
    });

    test('validate fails for invalid version', () {
      final data = CryptData('id', version: 'v19');
      expect(
          () => data.validate(),
          throwsA(isA<ArgumentError>()
              .having((e) => e.name, 'name', 'version')
              .having((e) => e.message, 'message',
                  'must be decimal digits without leading zeros')));
    });

    test('validate fails for invalid param key', () {
      final data = CryptData('id', params: {'bad_key!': '123'});
      expect(
          () => data.validate(),
          throwsA(isA<ArgumentError>()
              .having((e) => e.name, 'name', 'params.key')
              .having((e) => e.message, 'message',
                  'must be [a-z0-9-] and under 32 chars')));
    });

    test('validate fails for reserved param key "v"', () {
      final data = CryptData('id', params: {'v': '123'});
      expect(
          () => data.validate(),
          throwsA(isA<ArgumentError>()
              .having((e) => e.name, 'name', 'params.key')
              .having((e) => e.message, 'message',
                  'reserved; use version field instead')));
    });

    test('validate allows empty param value (PHC spec permits it)', () {
      // The PHC string format spec states parameter values MAY be empty.
      // https://github.com/C2SP/C2SP/blob/main/phc-strings.md
      final data = CryptData('id', params: {'x': ''});
      expect(() => data.validate(), returnsNormally);
    });

    test('validate fails for invalid param value', () {
      final data = CryptData('id', params: {'x': 'bad*value'});
      expect(
          () => data.validate(),
          throwsA(isA<ArgumentError>()
              .having((e) => e.name, 'name', 'params[x]')
              .having((e) => e.message, 'message',
                  'value has invalid characters')));
    });

    test('validate fails for invalid salt', () {
      final data = CryptData('id', salt: 'bad*salt');
      expect(
          () => data.validate(),
          throwsA(isA<ArgumentError>()
              .having((e) => e.name, 'name', 'salt')
              .having((e) => e.message, 'message',
                  'must be characters in [a-zA-Z0-9/+.-]')));
    });

    test('validate fails for invalid hash', () {
      final data = CryptData('id', hash: 'bad*hash');
      expect(
          () => data.validate(),
          throwsA(isA<ArgumentError>()
              .having((e) => e.name, 'name', 'hash')
              .having((e) => e.message, 'message',
                  'must be characters in [a-zA-Z0-9/+.-]')));
    });

    test('validate fails for version with leading zeros', () {
      // Spec: version is a non-negative decimal without leading zeros.
      // https://github.com/C2SP/C2SP/blob/main/phc-strings.md
      final data = CryptData('id', version: '019');
      expect(
          () => data.validate(),
          throwsA(isA<ArgumentError>()
              .having((e) => e.name, 'name', 'version')
              .having((e) => e.message, 'message',
                  'must be decimal digits without leading zeros')));
      expect(() => CryptData('id', version: '0').validate(), returnsNormally);
    });

    test('validate accepts "." and "-" in both salt and hash', () {
      // The salt and hash stay permissive ([a-zA-Z0-9/+.-]) to accept Modular
      // Crypt Format strings such as bcrypt, whose base64 alphabet uses '.'.
      // https://en.wikipedia.org/wiki/Bcrypt#base64_encoding_alphabet
      expect(() => CryptData('id', salt: 'le.gacy-salt').validate(),
          returnsNormally);
      expect(
          () => CryptData('id', hash: 'aGFz.aA').validate(), returnsNormally);
      expect(
          () => CryptData('id', hash: 'aGFz-aA').validate(), returnsNormally);
      // Padding ('=') is still not part of the allowed character set.
      expect(
          () => CryptData('id', hash: 'aGFzaA==').validate(),
          throwsA(isA<ArgumentError>()
              .having((e) => e.name, 'name', 'hash')
              .having((e) => e.message, 'message',
                  'must be characters in [a-zA-Z0-9/+.-]')));
    });

    test('builder returns CryptDataBuilder', () {
      final builder = CryptData.builder('argon2id');
      expect(builder.runtimeType.toString(), contains('CryptDataBuilder'));
    });

    group('equality and hashCode', () {
      CryptData base() => CryptData(
            'argon2id',
            version: '19',
            salt: 'c2FsdA',
            hash: 'aGFzaA',
            params: {'m': '65536', 't': '3'},
          );

      test('identical instance is equal to itself', () {
        final a = base();
        expect(a == a, isTrue);
      });

      test('not equal to an object of a different type', () {
        final Object other = 'not a CryptData';
        expect(base() == other, isFalse);
      });

      test('differing id is not equal', () {
        expect(base() == CryptData('scrypt', version: '19'), isFalse);
      });

      test('differing version is not equal (id equal)', () {
        final a = CryptData('id', version: '19');
        final b = CryptData('id', version: '20');
        expect(a == b, isFalse);
      });

      test('differing salt is not equal (id and version equal)', () {
        final a = CryptData('id', version: '19', salt: 'AAAA');
        final b = CryptData('id', version: '19', salt: 'BBBB');
        expect(a == b, isFalse);
      });

      test('differing hash is not equal (id, version, salt equal)', () {
        final a = CryptData('id', version: '19', salt: 'AAAA', hash: 'AAAA');
        final b = CryptData('id', version: '19', salt: 'AAAA', hash: 'BBBB');
        expect(a == b, isFalse);
      });

      test('equal when all fields equal and both params null', () {
        final a = CryptData('id', version: '19', salt: 'AAAA', hash: 'BBBB');
        final b = CryptData('id', version: '19', salt: 'AAAA', hash: 'BBBB');
        expect(a == b, isTrue);
        expect(a.hashCode, b.hashCode);
      });

      test('not equal when one params is null and the other is not', () {
        final withParams = CryptData('id', params: {'m': '1'});
        final withoutParams = CryptData('id');
        // exercises both operands of the `p == null || q == null` guard
        expect(withoutParams == withParams, isFalse);
        expect(withParams == withoutParams, isFalse);
      });

      test('not equal when params have different lengths', () {
        final a = CryptData('id', params: {'m': '1', 't': '2'});
        final b = CryptData('id', params: {'m': '1'});
        expect(a == b, isFalse);
      });

      test('not equal when a param key is missing (same length)', () {
        final a = CryptData('id', params: {'m': '1', 't': '2'});
        final b = CryptData('id', params: {'m': '1', 'x': '2'});
        expect(a == b, isFalse);
      });

      test('not equal when a param value differs (same keys)', () {
        final a = CryptData('id', params: {'m': '1', 't': '2'});
        final b = CryptData('id', params: {'m': '1', 't': '9'});
        expect(a == b, isFalse);
      });

      test('equal when params have equal content in distinct maps', () {
        final a = base();
        final b = base();
        expect(identical(a.params, b.params), isFalse);
        expect(a == b, isTrue);
        expect(a.hashCode, b.hashCode);
      });

      test('hashCode is order-independent for params', () {
        final a = CryptData('id', params: {'m': '1', 't': '2'});
        final b = CryptData('id', params: {'t': '2', 'm': '1'});
        expect(a == b, isTrue);
        expect(a.hashCode, b.hashCode);
      });

      test('hashCode without params is stable and equal for equal values', () {
        final a = CryptData('id', version: '1', salt: 's', hash: 'h');
        final b = CryptData('id', version: '1', salt: 's', hash: 'h');
        expect(a.hashCode, b.hashCode);
        expect(a.hashCode, a.hashCode);
      });
    });
  });
}
