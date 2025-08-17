// Copyright (c) 2024, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:hashlib_codecs/src/base64.dart';

import 'crypt_data.dart';

/// Convenient builder for [CryptData].
class CryptDataBuilder {
  final String id;
  String? _version;
  String? _salt;
  String? _hash;
  final _params = <String, String>{};

  /// Creates a new builder for [CryptData].
  ///
  /// Parameters:
  /// - [id] : The identifier name, which must not exceed 32 characters in
  ///   length and must be a sequence of characters in `[a-z0-9-]`.
  ///
  ///   Good identifiers should be should be explicit (human readable, not a
  ///   single digit), with a length of about 5 to 10 characters.
  CryptDataBuilder(this.id);

  /// Set the algorithm version.
  ///
  /// The value for the version must be a sequence of characters in: `[0-9]`.
  ///
  /// It is recommended to use a default version.
  CryptDataBuilder version(String v) {
    _version = v;
    return this;
  }

  /// Set the salt.
  CryptDataBuilder salt(String v) {
    _salt = v;
    return this;
  }

  /// Set the output hash.
  CryptDataBuilder hash(String v) {
    _hash = v;
    return this;
  }

  /// Set the salt bytes using standard Base-64 codecs without padding.
  CryptDataBuilder saltBytes(List<int> v) {
    _salt = toBase64(v, padding: false);
    return this;
  }

  /// Set the output hash bytes using standard Base-64 codecs without padding.
  CryptDataBuilder hashBytes(List<int> v) {
    _hash = toBase64(v, padding: false);
    return this;
  }

  /// Set a parameter value.
  ///
  /// The parameter [name] must not exceed 32 characters in length and must be a
  /// sequence of characters in: `[a-z0-9-]`.
  ///
  /// If [value] is not a [String], it will be converted to one with [toString].
  /// As a string, it must be a sequence of characters in `[a-zA-Z0-9/+.-]`.
  CryptDataBuilder param(String name, dynamic value) {
    _params[name] = value == null ? value : value.toString();
    return this;
  }

  /// Creates the [CryptData] instance.
  ///
  /// This also validates the parameters, and throws [ArgumentError] if
  /// something is wrong.
  CryptData build() {
    var data = CryptData(
      id,
      version: _version,
      salt: _salt,
      hash: _hash,
      params: _params.isEmpty ? null : _params,
    );
    data.validate();
    return data;
  }
}
