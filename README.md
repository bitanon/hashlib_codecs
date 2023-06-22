# Hashlib Codecs

[![plugin version](https://img.shields.io/pub/v/hashlib_codecs?label=pub)](https://pub.dev/packages/hashlib_codecs)
[![dependencies](https://img.shields.io/badge/dependencies-zero-889)](https://github.com/bitanon/hashlib_codecs/blob/master/pubspec.yaml)
[![dart support](https://img.shields.io/badge/dart-%3e%3d%202.14.0-39f?logo=dart)](https://dart.dev/guides/whats-new#september-8-2021-214-release)
[![likes](https://img.shields.io/pub/likes/hashlib_codecs?logo=dart)](https://pub.dev/packages/hashlib_codecs/score)
[![pub points](https://img.shields.io/pub/points/hashlib_codecs?logo=dart&color=teal)](https://pub.dev/packages/hashlib_codecs/score)
[![popularity](https://img.shields.io/pub/popularity/hashlib_codecs?logo=dart)](https://pub.dev/packages/hashlib_codecs/score)

<!-- [![test](https://github.com/bitanon/hashlib_codecs/actions/workflows/test.yml/badge.svg)](https://github.com/bitanon/hashlib_codecs/actions/workflows/test.yml) -->

This library contains implementations of fast and error resilient codecs in pure Dart.

## Features

### Binary (Base-2)

| Type    | Available                |
| ------- | ------------------------ |
| Class   | `Base2Codec`             |
| Methods | `fromBinary`, `toBinary` |

Available codecs:

- **standard**: `01` (default)

### Octal (Base-8)

| Type    | Available              |
| ------- | ---------------------- |
| Class   | `Base8Codec`           |
| Methods | `fromOctal`, `toOctal` |

Available codecs:

- **standard**: `012345678` (default)

### Hexadecimal (Base-16)

| Type    | Available          |
| ------- | ------------------ |
| Class   | `Base16Codec`      |
| Methods | `fromHex`, `toHex` |

Available codecs:

- **upper**: `0123456789ABCDEF` (default)
- **lower**: `0123456789abcdef`

### Base-32

> Supports conversion without padding

| Type    | Available                |
| ------- | ------------------------ |
| Class   | `Base32Codec`            |
| Methods | `fromBase32`, `toBase32` |

Available codecs:

- **standard** (RFC-4648): `ABCDEFGHIJKLMNOPQRSTUVWXYZ234567` (default)
- **lowercase**: `abcdefghijklmnopqrstuvwxyz234567`
- **hex**: `0123456789ABCDEFGHIJKLMNOPQRSTUV`
- **hexLower**: `0123456789abcdefghijklmnopqrstuv`
- **crockford**: `0123456789bcdefghjkmnpqrstuvwxyz`
- **z**: `ybndrfg8ejkmcpqxot1uwisza345h769`
- **wordSafe**: `23456789CFGHJMPQRVWXcfghjmpqrvwx`

### Base-64

> Supports conversion without padding, and <br>
> the URL/Filename-safe Base64 conversion.

| Type    | Available                |
| ------- | ------------------------ |
| Class   | `Base64Codec`            |
| Methods | `fromBase64`, `toBase64` |

Available codecs:

- **standard** (RFC-4648): `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/` (default)
- **urlSafe**: `ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_`

### BigInt

> Supports both the Big-Endian and Little-Endian conversion

| Type    | Available                |
| ------- | ------------------------ |
| Class   | `BigIntCodec`            |
| Methods | `fromBigInt`, `toBigInt` |

Available codecs:

- **msbFirst**: treats the input bytes in big-endian order
- **lsbFirst**: treats the input bytes in little-endian order

## Getting Started

The following import will give you access to all of the algorithms in this package.

```dart
import 'package:hashlib_codecs/hashlib_codecs.dart';
```

Check the [API Reference](https://pub.dev/documentation/hashlib_codecs/latest/hashlib_codecs/hashlib_codecs-library.html) for details.

## Usage

Examples can be found inside the `example` folder.

```dart
import 'package:hashlib_codecs/hashlib_codecs.dart';

void main() {
  var inp = [0x3, 0xF1];
  print("input => $inp");
  print('');

  print("binary => ${toBinary(inp)}");
  print('');

  print("octal => ${toOctal(inp)}");
  print('');

  print("hexadecimal => ${toHex(inp)}");
  print("hexadecimal (uppercase) => ${toHex(inp, upper: true)}");
  print('');

  print("base32 => ${toBase32(inp)}");
  print("base32 (lowercase) => ${toBase32(inp, lower: true)}");
  print("base32 (no padding) => ${toBase32(inp, padding: false)}");
  print("base32 (hex) => ${toBase32(inp, codec: Base32Codec.hex)}");
  print("base32 (z-base-32) => ${toBase32(inp, codec: Base32Codec.z)}");
  print("base32 (geohash) => ${toBase32(inp, codec: Base32Codec.geohash)}");
  print("base32 (crockford) => ${toBase32(inp, codec: Base32Codec.crockford)}");
  print("base32 (word-safe) => ${toBase32(inp, codec: Base32Codec.wordSafe)}");
  print('');

  print("base64 => ${toBase64(inp)}");
  print("base64url => ${toBase64(inp, url: true)}");
  print("base64 (no padding) => ${toBase64(inp, padding: false)}");
  print('');
}
```
