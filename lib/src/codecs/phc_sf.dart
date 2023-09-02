// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert';

import 'package:hashlib_codecs/hashlib_codecs.dart';

final _id = RegExp(r'^[a-z0-9-]+$');
final _version = RegExp(r'^[0-9]+$');
final _paramName = RegExp(r'^[a-z0-9-]+$');
final _paramValue = RegExp(r'^[a-zA-Z0-9/+.-]+$');

/// The PHC string format data
class PHCSFData {
  /// The symbolic name for the hash function.
  ///
  /// The identifier name must not exceed 32 characters in length and must be a
  /// sequence of characters in: `[a-z0-9-]`.
  ///
  /// Good identifiers should be should be explicit (human readable, not a
  /// single digit), with a length of about 5 to 10 characters.
  final String id;

  /// (Optional) The algorithm version.
  ///
  /// The value for the version must be a sequence of characters in: `[0-9]`.
  ///
  /// It recommended to use a default version.
  final String? version;

  /// (Optional) The salt bytes.
  final List<int>? salt;

  /// (Optional) The output hash bytes.
  final List<int>? hash;

  /// (Optional) The algorithm parameters.
  ///
  /// The parameter names must not exceed 32 characters in length and must be a
  /// sequence of characters in: `[a-z0-9-]`.
  ///
  /// The parameter values must be a sequence of characters in
  /// `[a-zA-Z0-9/+.-]`.
  final Map<String, String>? params;

  /// Creates an instance of [PHCSFData].
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
  const PHCSFData(
    this.id, {
    this.salt,
    this.hash,
    this.version,
    this.params,
  });

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

/// The encoder used by the [PHCSF] codec
class PHCSFEncoder extends Converter<PHCSFData, String> {
  const PHCSFEncoder();

  @override
  String convert(PHCSFData input) {
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
      result += toBase64(input.salt!, padding: false);
    }
    if (input.hash != null && input.hash!.isNotEmpty) {
      result += '\$';
      result += toBase64(input.hash!, padding: false);
    }
    return result;
  }
}

/// The decoder used by the [PHCSF] codec
class PHCSFDecoder extends Converter<String, PHCSFData> {
  const PHCSFDecoder();

  @override
  PHCSFData convert(String input) {
    String id;
    String? version;
    List<int>? salt, hash;
    Map<String, String>? params;
    String name, value;

    Iterable<String> parts = input.split('\$');

    if (parts.isEmpty) {
      throw FormatException('Empty string');
    }
    parts = parts.skip(1);

    if (parts.isEmpty) {
      throw FormatException('Invalid PHC string format');
    }
    id = parts.first;

    if (!_id.hasMatch(id) || id.length > 32) {
      throw FormatException('Invalid identifier name');
    }
    parts = parts.skip(1);

    if (parts.isNotEmpty && parts.first.startsWith('v=')) {
      version = parts.first.substring(2);
      if (!_version.hasMatch(version)) {
        throw FormatException('Invalid version');
      }
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
        if (name.length > 32 || !_paramName.hasMatch(name)) {
          throw FormatException('Invalid param name: $name');
        }
        if (!_paramValue.hasMatch(value)) {
          throw FormatException('Invalid value for param $name: $value');
        }
        params[name] = value;
      }
      parts = parts.skip(1);
    }

    if (parts.isNotEmpty) {
      salt = fromBase64(parts.first, padding: false);
      parts = parts.skip(1);
    }

    if (parts.isNotEmpty) {
      hash = fromBase64(parts.first, padding: false);
      parts = parts.skip(1);
    }

    if (parts.isNotEmpty) {
      throw FormatException('Invalid PHC string format');
    }

    return PHCSFData(
      id,
      version: version,
      salt: salt,
      hash: hash,
      params: params,
    );
  }
}

/// _PHC string format_ is a standardized way to represent password hashes
/// generated by the competing password hashing algorithms. This format is
/// designed to ensure consistency and interoperability between different
/// password hashing implementations.
///
/// The string format specifiction:
/// ```
/// $<id>[$v=<version>][$<param>=<value>(,<param>=<value>)*][$<salt>[$<hash>]]
/// ```
class PHCSF extends Codec<PHCSFData, String> {
  const PHCSF();

  @override
  final encoder = const PHCSFEncoder();

  @override
  final decoder = const PHCSFDecoder();
}
