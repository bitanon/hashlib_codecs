// Copyright (c) 2024, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'package:hashlib_codecs/src/base64.dart';

import 'crypt_builder.dart';

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

  /// Validate this PHC string.
  /// Throws [ArgumentError] when any field is invalid.
  void validate() {
    final digitRe = RegExp(r'^[0-9]+$');
    final alnumRe = RegExp(r'^[a-z0-9-]{1,32}$');
    final base64Re = RegExp(r'^[a-zA-Z0-9/+.-]+$');

    // id
    if (!alnumRe.hasMatch(id)) {
      throw ArgumentError.value(
          id, 'id', 'must be [a-z0-9-] and under 32 characters');
    }

    // version (optional)
    if (version != null && !digitRe.hasMatch(version!)) {
      throw ArgumentError.value(version, 'version', 'must be decimal digits');
    }

    // params (optional)
    if (params != null) {
      for (final e in params!.entries) {
        final k = e.key;
        final v = e.value;
        if (!alnumRe.hasMatch(k)) {
          throw ArgumentError.value(
              k, 'params.key', 'must be [a-z0-9-] and under 32 chars');
        }
        if (k == 'v') {
          throw ArgumentError.value(
              k, 'params.key', 'reserved; use version field instead');
        }
        if (v.isEmpty) {
          throw ArgumentError.value(v, 'params[$k]', 'value is empty');
        } else if (!base64Re.hasMatch(v)) {
          throw ArgumentError.value(
              v, 'params[$k]', 'value has invalid characters');
        }
      }
    }

    // salt (optional)
    if (salt != null && !base64Re.hasMatch(salt!)) {
      throw ArgumentError.value(
          salt, 'salt', 'expected base64 string without padding');
    }

    // hash (optional)
    if (hash != null && !base64Re.hasMatch(hash!)) {
      throw ArgumentError.value(
          hash, 'hash', 'expected base64 string without padding');
    }
  }
}
