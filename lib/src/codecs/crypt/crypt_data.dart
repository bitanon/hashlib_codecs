// Copyright (c) 2024, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'package:hashlib_codecs/src/base64.dart';

import 'crypt_data_builder.dart';

final _id = RegExp(r'^[a-z0-9-]+$');
final _version = RegExp(r'^[0-9]+$');
final _paramName = RegExp(r'^[a-z0-9-]+$');
final _paramValue = RegExp(r'^[a-zA-Z0-9/+.-]+$');
final _saltValue = _paramValue;
final _hashValue = _paramValue;

/// The PHC string format data
class CryptData {
  /// The symbolic name for the hash function.
  final String id;

  /// (Optional) The algorithm version.
  final String? version;

  /// (Optional) The salt.
  final String? salt;

  /// (Optional) The output hash.
  final String? hash;

  /// (Optional) The algorithm parameters.
  final Map<String, String>? params;

  /// Creates an instance of [CryptData].
  ///
  /// Paramaters:
  /// - [id] The identifier name, must not exceed 32 characters in length and
  ///   must be a sequence of characters in: `[a-z0-9-]`.
  /// - [version] (Optional) The value for the version must be a sequence of
  ///   characters in: `[0-9]`.
  /// - [params] (Optional) A map containing name, value pairs of algorithm
  ///   parameters. The names must not exceed 32 characters in length and must
  ///   be a sequence of characters in: `[a-z0-9-]`, the values must be a
  ///   sequence of characters in: `[a-zA-Z0-9/+.-]`.
  /// - [salt] (Optional) The salt bytes.
  /// - [hash] (Optional) The output hash bytes.
  const CryptData(
    this.id, {
    this.salt,
    this.hash,
    this.version,
    this.params,
  });

  /// Returns a [CryptDataBuilder] instance for [id].
  ///
  /// Parameters:
  /// - [id] : The identifier name, which must not exceed 32 characters in
  ///   length and must be a sequence of characters in `[a-z0-9-]`.
  ///
  ///   Good identifiers should be should be explicit (human readable, not a
  ///   single digit), with a length of about 5 to 10 characters.
  static CryptDataBuilder builder(String id) => CryptDataBuilder(id);

  /// Parse the [salt] using standard Base-64 codec
  Uint8List? saltBytes() =>
      salt == null ? null : fromBase64(salt!, padding: false);

  /// Parse the [hash] using standard Base-64 codec
  Uint8List? hashBytes() =>
      hash == null ? null : fromBase64(hash!, padding: false);

  /// Get the version as integer
  int? versionInt() => version == null ? null : int.tryParse(version!);

  /// Check if the [key] parameter exists
  bool hasParam(String key) =>
      params == null ? false : params!.containsKey(key);

  /// Get the value of a paramter by [key]
  String? getParam(String key) => params?[key];

  /// Get the value of a paramter by [key] as integer
  int? getIntParam(String key) {
    var val = getParam(key);
    return val == null ? null : int.tryParse(val);
  }

  /// Validate the parameters
  ///
  /// Throws [ArgumentError] if something is wrong.
  void validate() {
    if (id.length > 32) {
      throw ArgumentError('Exceeds 32 character limit', 'id');
    }
    if (!_id.hasMatch(id)) {
      throw ArgumentError('Invalid character', 'id');
    }
    if (version != null && version!.isNotEmpty) {
      if (!_version.hasMatch(version!)) {
        throw ArgumentError('Invalid character', 'version');
      }
    }
    if (salt != null && salt!.isNotEmpty) {
      if (!_saltValue.hasMatch(salt!)) {
        throw ArgumentError('Invalid salt', 'salt');
      }
    }
    if (hash != null && hash!.isNotEmpty) {
      if (!_hashValue.hasMatch(hash!)) {
        throw ArgumentError('Invalid hash', 'hash');
      }
    }
    if (params != null) {
      for (final e in params!.entries) {
        if (e.key.length > 32) {
          throw ArgumentError('Exceeds 32 character limit', 'params:${e.key}');
        }
        if (!_paramName.hasMatch(e.key)) {
          throw ArgumentError('Invalid character', 'params:${e.key}');
        }
        if (!_paramValue.hasMatch(e.value)) {
          throw ArgumentError('Invalid character', 'params:${e.key}:value');
        }
      }
    }
  }
}
