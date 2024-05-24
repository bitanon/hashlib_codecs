// Copyright (c) 2024, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert';

import 'crypt_data.dart';

/// The encoder used by the [CryptFormat] codec
class CryptEncoder extends Converter<CryptData, String> {
  const CryptEncoder();

  @override
  String convert(CryptData input) {
    input.validate();
    String result = '\$${input.id}';
    if (input.version != null && input.version!.isNotEmpty) {
      result += '\$v=${input.version!}';
    }
    if (input.params != null && input.params!.isNotEmpty) {
      result += '\$';
      result += input.params!.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join(',');
    }
    if (input.salt != null && input.salt!.isNotEmpty) {
      result += '\$';
      result += input.salt!;
    }
    if (input.hash != null && input.hash!.isNotEmpty) {
      result += '\$';
      result += input.hash!;
    }
    return result;
  }
}

/// The decoder used by the [CryptFormat] codec
class CryptDecoder extends Converter<String, CryptData> {
  const CryptDecoder();

  @override
  CryptData convert(String input) {
    String id, name, value;
    String? version, salt, hash;
    Map<String, String>? params;

    Iterable<String> parts = input.split('\$');

    if (parts.isEmpty) {
      throw FormatException('Empty string');
    }
    parts = parts.skip(1);

    if (parts.isEmpty) {
      throw FormatException('Invalid PHC string format');
    }
    id = parts.first;

    parts = parts.skip(1);

    if (parts.isNotEmpty && parts.first.startsWith('v=')) {
      version = parts.first.substring(2);
      parts = parts.skip(1);
    }

    if (parts.isNotEmpty && parts.first.contains('=')) {
      params = {};
      for (final kv in parts.first.split(',')) {
        var pair = kv.split('=');
        if (pair.length != 2) {
          throw FormatException('Invalid param format: $kv');
        }
        name = pair[0];
        value = pair[1];
        params[name] = value;
      }
      parts = parts.skip(1);
    }

    if (parts.isNotEmpty) {
      salt = parts.first;
      parts = parts.skip(1);
    }

    if (parts.isNotEmpty) {
      hash = parts.first;
      parts = parts.skip(1);
    }

    if (parts.isNotEmpty) {
      throw FormatException('Invalid PHC string format');
    }

    var data = CryptData(
      id,
      version: version,
      salt: salt,
      hash: hash,
      params: params,
    );

    try {
      data.validate();
    } on ArgumentError catch (e) {
      throw FormatException(e.message, e);
    }

    return data;
  }
}

/// Provides encoding and decoding of [PHC string format][phc] data.
///
/// **PHC string format** is a standardized way to represent password hashes
/// generated by the competing password hashing algorithms. This format is
/// designed to ensure consistency and interoperability between different
/// password hashing implementations.
///
/// The string format specifiction:
/// ```
/// $<id>[$v=<version>][$<param>=<value>(,<param>=<value>)*][$<salt>[$<hash>]]
/// ```
///
/// [phc]: https://github.com/P-H-C/phc-string-format/blob/master/phc-sf-spec.md
class CryptFormat extends Codec<CryptData, String> {
  const CryptFormat();

  @override
  final encoder = const CryptEncoder();

  @override
  final decoder = const CryptDecoder();
}
