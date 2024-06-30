// Copyright (c) 2024, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'codecs/utf8.dart';

/// Converts UTF-8 character code points to 8-bit UTF-8 octet sequence.
///
/// Parameters:
/// - [input] is a sequence of UTF-8 character code points.
/// - [codec] is the [UTF8Codec] to use.
Uint8List toUtf8(
  String input, {
  UTF8Codec codec = UTF8Codec.standard,
}) {
  var out = codec.encoder.convert(input.codeUnits);
  return Uint8List.fromList(out as List<int>);
}

/// Converts 8-bit UTF-8 octet sequence to UTF-8 character code points.
///
/// Parameters:
/// - [input] should be a valid UTF-8 octet sequence.
/// - [codec] is the [UTF8Codec] to use.
///
/// Throws:
/// - [FormatException] if the [input] contains invalid characters.
///
/// This implementation can handle both uppercase and lowercase alphabets. If a
/// partial string is detected, the following bits are assumed to be zeros.
String fromUtf8(
  Iterable<int> input, {
  UTF8Codec codec = UTF8Codec.standard,
}) {
  var out = codec.decoder.convert(input);
  return String.fromCharCodes(out);
}
