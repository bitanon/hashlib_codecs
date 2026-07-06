import 'package:test/test.dart';
import 'package:hashlib_codecs/src/codecs/crypt/crypt_data.dart';

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
      expect(() => data.validate(), throwsArgumentError);
    });

    test('validate fails for invalid version', () {
      final data = CryptData('id', version: 'v19');
      expect(() => data.validate(), throwsArgumentError);
    });

    test('validate fails for invalid param key', () {
      final data = CryptData('id', params: {'bad_key!': '123'});
      expect(() => data.validate(), throwsArgumentError);
    });

    test('validate fails for reserved param key "v"', () {
      final data = CryptData('id', params: {'v': '123'});
      expect(() => data.validate(), throwsArgumentError);
    });

    test('validate fails for empty param value', () {
      final data = CryptData('id', params: {'x': ''});
      expect(() => data.validate(), throwsArgumentError);
    });

    test('validate fails for invalid param value', () {
      final data = CryptData('id', params: {'x': 'bad*value'});
      expect(() => data.validate(), throwsArgumentError);
    });

    test('validate fails for invalid salt', () {
      final data = CryptData('id', salt: 'bad*salt');
      expect(() => data.validate(), throwsArgumentError);
    });

    test('validate fails for invalid hash', () {
      final data = CryptData('id', hash: 'bad*hash');
      expect(() => data.validate(), throwsArgumentError);
    });

    test('validate fails for version with leading zeros', () {
      // Spec: version is a non-negative decimal without leading zeros.
      // https://github.com/C2SP/C2SP/blob/main/phc-strings.md
      final data = CryptData('id', version: '019');
      expect(() => data.validate(), throwsArgumentError);
      expect(() => CryptData('id', version: '0').validate(), returnsNormally);
    });

    test('validate accepts "." and "-" in salt but not in hash', () {
      // Spec: salt characters are [a-zA-Z0-9/+.-]; the hash is strict B64
      // ([a-zA-Z0-9/+], no padding).
      // https://github.com/C2SP/C2SP/blob/main/phc-strings.md
      expect(() => CryptData('id', salt: 'le.gacy-salt').validate(),
          returnsNormally);
      expect(() => CryptData('id', hash: 'aGFz.aA').validate(),
          throwsArgumentError);
      expect(() => CryptData('id', hash: 'aGFz-aA').validate(),
          throwsArgumentError);
      expect(() => CryptData('id', hash: 'aGFzaA==').validate(),
          throwsArgumentError);
    });

    test('builder returns CryptDataBuilder', () {
      final builder = CryptData.builder('argon2id');
      expect(builder.runtimeType.toString(), contains('CryptDataBuilder'));
    });
  });
}
