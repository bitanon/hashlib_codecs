// Copyright (c) 2024, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import '../../base64.dart';

import 'crypt_builder.dart';

/// A parsed PHC / Modular Crypt Format string: an algorithm [id] with an
/// optional [version], [params], [salt], and [hash].
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
  /// Parameters:
  /// - [id] The identifier name, must not exceed 32 characters in length and
  ///   must be a sequence of characters in: `[a-z0-9-]`.
  /// - [version] (Optional) The value for the version must be a sequence of
  ///   characters in: `[0-9]`, without leading zeros.
  /// - [params] (Optional) A map containing name, value pairs of algorithm
  ///   parameters. The names must not exceed 32 characters in length and must
  ///   be a sequence of characters in: `[a-z0-9-]`, the values must be a
  ///   sequence of characters in: `[a-zA-Z0-9/+.-]` and may be empty.
  /// - [salt] (Optional) The salt, a sequence of characters in:
  ///   `[a-zA-Z0-9/+.-]`.
  /// - [hash] (Optional) The output hash, a sequence of characters in:
  ///   `[a-zA-Z0-9/+.-]`. This stays permissive to accept Modular Crypt Format
  ///   strings such as bcrypt, whose base64 alphabet includes `.`.
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
  ///   Good identifiers should be explicit (human readable, not a single
  ///   digit), with a length of about 5 to 10 characters.
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

  /// Get the value of a parameter by [key]
  String? getParam(String key) => params?[key];

  /// Get the value of a parameter by [key] as integer
  int? getIntParam(String key) {
    var val = getParam(key);
    return val == null ? null : int.tryParse(val);
  }

  /// Validate this PHC string.
  /// Throws [ArgumentError] when any field is invalid.
  void validate() {
    // Character sets follow the PHC string format specification, but the salt
    // and hash stay permissive to accept Modular Crypt Format strings such as
    // bcrypt (whose base64 alphabet uses '.').
    // https://github.com/C2SP/C2SP/blob/main/phc-strings.md
    final versionRe = RegExp(r'^(0|[1-9][0-9]*)$');
    final alnumRe = RegExp(r'^[a-z0-9-]{1,32}$');
    final valueRe = RegExp(r'^[a-zA-Z0-9/+.-]+$');
    final paramValueRe = RegExp(r'^[a-zA-Z0-9/+.-]*$');

    // id
    if (!alnumRe.hasMatch(id)) {
      throw ArgumentError.value(
          id, 'id', 'must be [a-z0-9-] and under 32 characters');
    }

    // version (optional)
    if (version != null && !versionRe.hasMatch(version!)) {
      throw ArgumentError.value(
          version, 'version', 'must be decimal digits without leading zeros');
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
        if (!paramValueRe.hasMatch(v)) {
          throw ArgumentError.value(
              v, 'params[$k]', 'value has invalid characters');
        }
      }
    }

    // salt (optional)
    if (salt != null && !valueRe.hasMatch(salt!)) {
      throw ArgumentError.value(
          salt, 'salt', 'must be characters in [a-zA-Z0-9/+.-]');
    }

    // hash (optional)
    if (hash != null && !valueRe.hasMatch(hash!)) {
      throw ArgumentError.value(
          hash, 'hash', 'must be characters in [a-zA-Z0-9/+.-]');
    }
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! CryptData) return false;
    if (id != other.id ||
        version != other.version ||
        salt != other.salt ||
        hash != other.hash) {
      return false;
    }
    // Treat a null params map and an empty one as equal: both encode to the
    // same string (the encoder skips empty params) and have the same hashCode.
    final p = params ?? const <String, String>{};
    final q = other.params ?? const <String, String>{};
    if (p.length != q.length) return false;
    for (final e in p.entries) {
      if (!q.containsKey(e.key) || q[e.key] != e.value) {
        return false;
      }
    }
    return true;
  }

  @override
  int get hashCode {
    final p = params;
    int paramsHash = 0;
    if (p != null) {
      for (final e in p.entries) {
        paramsHash ^= Object.hash(e.key, e.value);
      }
    }
    return Object.hash(id, version, salt, hash, paramsHash);
  }
}
