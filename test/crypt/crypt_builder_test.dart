import 'package:hashlib_codecs/src/base64.dart';
import 'package:hashlib_codecs/src/codecs/crypt/crypt_builder.dart';
import 'package:test/test.dart';

void main() {
  group('CryptDataBuilder', () {
    test('should build with minimal id', () {
      final builder = CryptDataBuilder('testid');
      final data = builder.build();
      expect(data.id, 'testid');
      expect(data.version, isNull);
      expect(data.salt, isNull);
      expect(data.hash, isNull);
      expect(data.params, isNull);
    });

    test('should set version', () {
      final builder = CryptDataBuilder('algo').version('1');
      final data = builder.build();
      expect(data.version, '1');
    });

    test('should set salt', () {
      final builder = CryptDataBuilder('algo').salt('mysalt');
      final data = builder.build();
      expect(data.salt, 'mysalt');
    });

    test('should set hash', () {
      final builder = CryptDataBuilder('algo').hash('myhash');
      final data = builder.build();
      expect(data.hash, 'myhash');
    });

    test('should set saltBytes and hashBytes', () {
      final saltBytes = [1, 2, 3, 4];
      final hashBytes = [5, 6, 7, 8];
      final builder = CryptDataBuilder('algo')
        ..saltBytes(saltBytes)
        ..hashBytes(hashBytes);
      final data = builder.build();
      expect(data.salt, toBase64(saltBytes, padding: false));
      expect(data.hash, toBase64(hashBytes, padding: false));
    });

    test('should set params', () {
      final builder = CryptDataBuilder('algo')
        ..param('rounds', 1000)
        ..param('mode', 'fast');
      final data = builder.build();
      expect(data.params, isNotNull);
      expect(data.params!['rounds'], '1000');
      expect(data.params!['mode'], 'fast');
    });

    test('should throw ArgumentError for invalid id', () {
      expect(
          () => CryptDataBuilder('INVALID_ID!').build(), throwsArgumentError);
    });

    test('should throw ArgumentError for invalid version', () {
      expect(() => CryptDataBuilder('algo').version('v1').build(),
          throwsArgumentError);
    });

    test('should throw ArgumentError for invalid param name', () {
      final builder = CryptDataBuilder('algo').param('invalid*name', 'value');
      expect(() => builder.build(), throwsArgumentError);
    });

    test('should throw ArgumentError for invalid param value', () {
      final builder = CryptDataBuilder('algo').param('valid', 'bad value!');
      expect(() => builder.build(), throwsArgumentError);
    });

    test('should allow chaining', () {
      final builder = CryptDataBuilder('algo')
          .version('2')
          .salt('salt')
          .hash('hash')
          .param('p', 'v');
      final data = builder.build();
      expect(data.id, 'algo');
      expect(data.version, '2');
      expect(data.salt, 'salt');
      expect(data.hash, 'hash');
      expect(data.params!['p'], 'v');
    });
  });
}
