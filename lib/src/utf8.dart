// Copyright (c) 2024, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/utf8.dart';

/// Converts UTF-8 character code points to 8-bit UTF-8 octet sequence.
///
/// Parameters:
/// - [input] is a sequence of UTF-8 character code points.
/// - [codec] is the [UTF8Codec] to use.
///
/// Throws:
/// - [FormatException] if the [input] contains unpaired surrogates.
///
/// Unlike the encoder from `dart:convert`, which replaces unpaired surrogates
/// with the replacement character `U+FFFD`, this implementation rejects them.
Uint8List toUtf8(
  String input, {
  UTF8Codec codec = UTF8Codec.standard,
}) {
  var out = codec.encoder.convert(input.codeUnits);
  return Uint8List.fromList(out);
}

/// Converts 8-bit UTF-8 octet sequence to UTF-8 character code points.
///
/// Parameters:
/// - [input] should be a valid UTF-8 octet sequence.
/// - [codec] is the [UTF8Codec] to use.
///
/// Throws:
/// - [FormatException] if the [input] is not a valid UTF-8 octet sequence.
String fromUtf8(
  List<int> input, {
  UTF8Codec codec = UTF8Codec.standard,
}) {
  var out = codec.decoder.convert(input);
  return String.fromCharCodes(out);
}
