import 'package:convertlib/src/base64.dart';
import 'package:convertlib/src/codecs/crypt/crypt_builder.dart';
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
          () => CryptDataBuilder('INVALID_ID!').build(),
          throwsA(isA<ArgumentError>()
              .having((e) => e.name, 'name', 'id')
              .having((e) => e.message, 'message',
                  'must be [a-z0-9-] and under 32 characters')));
    });

    test('should throw ArgumentError for invalid version', () {
      expect(
          () => CryptDataBuilder('algo').version('v1').build(),
          throwsA(isA<ArgumentError>()
              .having((e) => e.name, 'name', 'version')
              .having((e) => e.message, 'message',
                  'must be decimal digits without leading zeros')));
    });

    test('should throw ArgumentError when param value is null', () {
      final builder = CryptDataBuilder('algo');
      expect(
          () => builder.param('rounds', null),
          throwsA(isA<ArgumentError>()
              .having((e) => e.name, 'name', 'value')
              .having((e) => e.message, 'message', 'Must not be null')));
    });

    test('should throw ArgumentError for invalid param name', () {
      final builder = CryptDataBuilder('algo').param('invalid*name', 'value');
      expect(
          () => builder.build(),
          throwsA(isA<ArgumentError>()
              .having((e) => e.name, 'name', 'params.key')
              .having((e) => e.message, 'message',
                  'must be [a-z0-9-] and under 32 chars')));
    });

    test('should throw ArgumentError for invalid param value', () {
      final builder = CryptDataBuilder('algo').param('valid', 'bad value!');
      expect(
          () => builder.build(),
          throwsA(isA<ArgumentError>()
              .having((e) => e.name, 'name', 'params[valid]')
              .having((e) => e.message, 'message',
                  'value has invalid characters')));
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
