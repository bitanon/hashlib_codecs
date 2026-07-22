// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:convert' as cvt;
import 'dart:typed_data';

import 'base16.dart' show fromHex;
import 'base16.dart' show toHex;
import 'base2.dart' show toBinary;
import 'base32.dart' show toBase32;
import 'base64.dart' show toBase64;
import 'base8.dart' show toOctal;
import 'bigint.dart' show toBigInt;

/// A container for digest bytes produced by a hash or encoding function.
///
/// It provides a rich set of methods to extract the underlying bytes as
/// different encoded strings (hex, base32, base64, binary, octal),
/// `BigInt`, numbers of arbitrary length, or decode them as ASCII or UTF-8.
///
/// It also features convenient equality checks and utilities for converting
/// and comparing digests across representations.
abstract class ByteCollector extends Object {
  /// Creates a new [ByteCollector].
  const ByteCollector();

  /// The collected bytes.
  Uint8List get bytes;

  /// Returns the length of this digest in bytes.
  int get length => bytes.length;

  /// Returns the byte buffer associated with this digest.
  ByteBuffer get buffer => bytes.buffer;

  /// The message digest as a string of hexadecimal digits.
  @override
  String toString() => hex();

  /// The message digest as a binary string.
  String binary() => toBinary(bytes);

  /// The message digest as an octal string.
  String octal() => toOctal(bytes);

  /// The message digest as a hexadecimal string.
  ///
  /// Parameters:
  /// - If [upper] is true, the string will be in uppercase alphabets.
  String hex([bool upper = false]) => toHex(bytes, upper: upper);

  /// The message digest as a Base-32 string.
  ///
  /// If [upper] is true, the output will have uppercase alphabets.
  /// If [padding] is true, the output will have `=` padding at the end.
  String base32({bool upper = true, bool padding = true}) =>
      toBase32(bytes, lower: !upper, padding: padding);

  /// The message digest as a Base-64 string.
  ///
  /// If [urlSafe] is true, the output will have URL-safe base64 alphabets.
  /// If [padding] is true, the output will have `=` padding at the end.
  String base64({bool urlSafe = false, bool padding = true}) =>
      toBase64(bytes, padding: padding, url: urlSafe);

  /// The message digest as a BigInt.
  ///
  /// If [endian] is [Endian.little], it will treat the digest bytes as a little
  /// endian number; Otherwise, if [endian] is [Endian.big], it will treat the
  /// digest bytes as a big endian number.
  BigInt bigInt({Endian endian = Endian.little}) =>
      toBigInt(bytes, msbFirst: endian == Endian.big);

  /// Gets an unsigned integer of [bitLength]-bit from the message digest.
  ///
  /// If [endian] is [Endian.little], it will treat the digest bytes as a little
  /// endian number; Otherwise, if [endian] is [Endian.big], it will treat the
  /// digest bytes as a big endian number.
  ///
  /// On the web, an `int` is a 64-bit floating point number, so results above
  /// `2^53` cannot be represented exactly. Keep [bitLength] at 53 or below for
  /// exact values on that platform.
  int number([int bitLength = 64, Endian endian = Endian.big]) {
    if (bitLength < 8 || bitLength > 64 || (bitLength & 7) > 0) {
      throw ArgumentError(
        'Invalid bit length. '
        'It must be a number between 8 to 64 and a multiple of 8.',
      );
    } else {
      bitLength >>>= 3;
    }
    // Accumulate with `* 256 +` rather than `<< 8 |` to support the web
    int result = 0;
    int n = bytes.length;
    if (endian == Endian.little) {
      for (int i = (n > bitLength ? bitLength : n) - 1; i >= 0; i--) {
        result = result * 256 + bytes[i];
      }
    } else {
      for (int i = n > bitLength ? n - bitLength : 0; i < n; i++) {
        result = result * 256 + bytes[i];
      }
    }
    return result;
  }

  /// The message digest as a string of ASCII alphabets.
  String ascii() => cvt.ascii.decode(bytes);

  /// The message digest as a string of UTF-8 alphabets.
  String utf8() => cvt.utf8.decode(bytes);

  /// Returns the digest in the given [encoding]
  String to(cvt.Encoding encoding) => encoding.decode(bytes);

  @override
  int get hashCode => Object.hashAll(bytes);

  /// Two [ByteCollector] instances are equal if their [bytes] are equal.
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ByteCollector && isEqual(other.bytes));

  /// Checks if the message digest equals to [other].
  ///
  /// Here, the [other] can be a one of the following:
  /// - An [Iterable] containing an array of bytes
  /// - Any [ByteBuffer] or [TypedData] that will be converted to [Uint8List]
  /// - A [String], which will be treated as a hexadecimal encoded byte array
  ///
  /// This function will return True if all bytes in the [other] matches with
  /// the [bytes] of this object. If the length does not match, the type of
  /// [other] is not supported, or a [String] is not valid hexadecimal, it
  /// returns False immediately.
  ///
  /// The content comparison is constant-time: it does not exit early on the
  /// first mismatching byte, making this method safe for comparing MACs and
  /// message digests.
  bool isEqual(Object? other) {
    if (identical(this, other)) {
      return true;
    } else if (other is ByteCollector) {
      return isEqual(other.bytes);
    } else if (other is ByteBuffer) {
      return isEqual(Uint8List.view(other));
    } else if (other is TypedData && other is! Uint8List) {
      return isEqual(
        Uint8List.view(other.buffer, other.offsetInBytes, other.lengthInBytes),
      );
    } else if (other is String) {
      Uint8List decoded;
      try {
        decoded = fromHex(other);
      } on FormatException {
        // A string that is not valid hexadecimal cannot match these bytes.
        return false;
      }
      return isEqual(decoded);
    } else if (other is Iterable<int>) {
      int i = 0, diff = 0;
      for (int x in other) {
        if (i >= bytes.length) {
          return false;
        }
        diff |= x ^ bytes[i++];
      }
      return i == bytes.length && diff == 0;
    }
    return false;
  }
}
