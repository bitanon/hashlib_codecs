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

### Octal (Base-8)

| Type    | Available              |
| ------- | ---------------------- |
| Class   | `Base8Codec`           |
| Methods | `fromOctal`, `toOctal` |

### Hexadecimal (Base-16)

| Type    | Available          |
| ------- | ------------------ |
| Class   | `Base16Codec`      |
| Methods | `fromHex`, `toHex` |

### Base-32 (RFC-4648)

> Supports conversion without padding

| Type    | Available                |
| ------- | ------------------------ |
| Class   | `Base32Codec`            |
| Methods | `fromBase32`, `toBase32` |

### Base-64 (RFC-4648)

> Supports conversion without padding, and <br>
> the URL/Filename-safe Base64 conversion.

| Type    | Available                |
| ------- | ------------------------ |
| Class   | `Base64Codec`            |
| Methods | `fromBase64`, `toBase64` |

### BigInt

> Supports both the Big-Endian and Little-Endian conversion

| Type    | Available                |
| ------- | ------------------------ |
| Class   | `BigIntCodec`            |
| Methods | `fromBigInt`, `toBigInt` |

## Getting Started

The following import will give you access to all of the algorithms in this package.

```dart
import 'package:hashlib_codecs/hashlib_codecs.dart';
```

Check the [API Reference](https://pub.dev/documentation/hashlib_codecs/latest/) for details.

## Usage

Examples can be found inside the `example` folder.

```dart
import 'package:hashlib_codecs/hashlib_codecs.dart';

void main() {
  var input = [0x3, 0xF1];
  print("input => $input");
  print('');

  print("binary => ${toBinary(input)}");
  print("binary (no padding) => ${toBinary(input, padding: false)}");
  print('');

  print("hexadecimal => ${toHex(input)}");
  print("hexadecimal (uppercase) => ${toHex(input, upper: true)}");
  print('');

  print("base32 => ${toBase32(input)}");
  print("base32 (lowercase) => ${toBase32(input, lower: true)}");
  print("base32 (no padding) => ${toBase32(input, padding: false)}");
  print('');

  print("base64 => ${toBase64(input)}");
  print("base64url => ${toBase64(input, url: true)}");
  print("base64 (no padding) => ${toBase64(input, padding: false)}");
  print('');
}
```
