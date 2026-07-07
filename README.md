# convertlib

[![plugin version](https://img.shields.io/pub/v/convertlib?label=pub)](https://pub.dev/packages/convertlib)
[![dart support](https://img.shields.io/badge/dart-%3e%3d%202.19.0-39f?logo=dart)](https://dart.dev/guides/whats-new#september-8-2021-214-release)
[![codecov](https://codecov.io/gh/bitanon/convertlib/graph/badge.svg?token=ISIYJ8MNI0)](https://codecov.io/gh/bitanon/convertlib)
[![likes](https://img.shields.io/pub/likes/convertlib?logo=dart)](https://pub.dev/packages/convertlib/score)
[![pub points](https://img.shields.io/pub/points/convertlib?logo=dart&color=teal)](https://pub.dev/packages/convertlib/score)
[![test](https://github.com/bitanon/convertlib/actions/workflows/test.yml/badge.svg?branch=master)](https://github.com/bitanon/convertlib/actions/workflows/test.yml)
[![Ask DeepWiki](https://deepwiki.com/badge.svg)](https://deepwiki.com/bitanon/convertlib)

A pure-Dart library of fast, error-resilient codecs: binary, octal, hex,
Base-32, Base-64, BigInt, UTF-8, and the PHC / Modular Crypt Format — with a
rich set of alphabet variants, optional padding, and zero dependencies.

`convertlib` is the foundation layer of a three-package family:

[![convertlib](https://img.shields.io/badge/convertlib-success?style=for-the-badge&logo=dart)](https://pub.dev/packages/convertlib) &rarr; [![hashlib](https://img.shields.io/badge/hashlib-blue?style=for-the-badge&logo=dart)](https://pub.dev/packages/hashlib) &rarr; [![cipherlib](https://img.shields.io/badge/cipherlib-informational?style=for-the-badge&logo=dart)](https://pub.dev/packages/cipherlib)

Both `hashlib` (hashes, MACs, KDFs) and `cipherlib` (ciphers, AEAD, ML-KEM)
build on it, reusing its codecs to render digests, keys, and ciphertext as
text. It carries no runtime dependencies of its own.

## Highlights

- **Runs on every platform**: pure Dart with no native code or FFI, so the same
  library works everywhere Dart does — the VM, Flutter (Android, iOS, Windows,
  macOS, Linux), and the web (dart2js and dart2wasm).
- **Zero dependencies**: nothing is pulled into your dependency tree.
- **Broad coverage**: Base-2, Base-8, Base-16, Base-32, Base-64, BigInt, UTF-8,
  and the PHC / Modular Crypt Format, each with a symmetrical `to`/`from` pair.
- **Many alphabet variants**: RFC 4648 standard, base32hex, Crockford,
  z-base-32, geohash, word-safe, URL/filename-safe Base-64, and bcrypt.
- **Optional padding**: encode and decode with or without `=` padding.
- **Error resilient**: decoders tolerate whitespace and case where the
  alphabet allows, and raise typed errors on genuinely invalid input.
- **Convenient output**: results integrate with `ByteCollector`, the digest
  container shared with `hashlib`, for one-call re-encoding.

## Install

```yaml
dependencies:
  convertlib: ^3.4.0
```

or run `dart pub add convertlib`. A single import exposes every codec:

```dart
import 'package:convertlib/convertlib.dart';
```

Full API reference:
[convertlib library](https://pub.dev/documentation/convertlib/latest/convertlib/convertlib-library.html).

## Quickstart

Every codec exposes a `to<Name>` encoder and a `from<Name>` decoder that are
exact inverses of each other:

<!-- file: example/quickstart_example.dart -->

```dart
import 'package:convertlib/convertlib.dart';

void main() {
  final data = toUtf8('convertlib');

  // Encode the same bytes in a few common ways
  final hex = toHex(data);
  final b64 = toBase64(data);
  final b32 = toBase32(data);

  print('bytes  : $data');
  print('hex    : $hex');
  print('base64 : $b64');
  print('base32 : $b32');

  // Every encoder has an exact inverse
  print('decoded: ${fromUtf8(fromHex(hex))}');
  print('match  : ${fromUtf8(fromBase64(b64)) == 'convertlib'}');
}
```

<!-- file: example/quickstart_example.dart -->

Every snippet in this README is also a runnable program in the
[example](https://github.com/bitanon/convertlib/tree/master/example) folder.

## Supported codecs

| Encoding              | Class         | Functions                |          Source          |
| --------------------- | ------------- | ------------------------ | :----------------------: |
| Binary (Base-2)       | `Base2Codec`  | `toBinary`, `fromBinary` |            —             |
| Octal (Base-8)        | `Base8Codec`  | `toOctal`, `fromOctal`   |            —             |
| Hexadecimal (Base-16) | `Base16Codec` | `toHex`, `fromHex`       |         RFC-4648         |
| Base-32               | `Base32Codec` | `toBase32`, `fromBase32` |         RFC-4648         |
| Base-64               | `Base64Codec` | `toBase64`, `fromBase64` |         RFC-4648         |
| BigInt                | `BigIntCodec` | `toBigInt`, `fromBigInt` |            —             |
| UTF-8                 | `UTF8Codec`   | `toUtf8`, `fromUtf8`     |         RFC-3629         |
| Modular Crypt Format  | `CryptFormat` | `toCrypt`, `fromCrypt`   | [PHC string format][phc] |

[phc]: https://github.com/C2SP/C2SP/blob/main/phc-strings.md

### Alphabet variants

**Base-16** — `toHex(..., upper: true)` selects the uppercase alphabet:

- `Base16Codec.upper` — `0123456789ABCDEF`
- `Base16Codec.lower` — `0123456789abcdef` (default)

**Base-32** — pass `codec:` to pick an alphabet, `lower:`/`padding:` to tweak it:

- `Base32Codec.standard` (RFC-4648) — `ABCDEFGHIJKLMNOPQRSTUVWXYZ234567` (default)
- `Base32Codec.lowercase` — `abcdefghijklmnopqrstuvwxyz234567`
- `Base32Codec.hex` / `.hexLower` — base32hex, `0-9A-V` / `0-9a-v`
- `Base32Codec.crockford` — `0123456789ABCDEFGHJKMNPQRSTVWXYZ`
- `Base32Codec.geohash` — `0123456789bcdefghjkmnpqrstuvwxyz`
- `Base32Codec.z` — z-base-32, `ybndrfg8ejkmcpqxot1uwisza345h769`
- `Base32Codec.wordSafe` — `23456789CFGHJMPQRVWXcfghjmpqrvwx`

**Base-64** — pass `url: true` for URL/filename-safe output, `padding: false`
to drop `=`, or a `codec:`:

- `Base64Codec.standard` (RFC-4648) — `A-Za-z0-9+/` (default)
- `Base64Codec.urlSafe` — `A-Za-z0-9-_`
- `Base64Codec.bcrypt` — `./A-Za-z0-9`

**BigInt** — endianness is selectable via `msbFirst` or an explicit codec:

- `BigIntCodec.msbFirst` — treats bytes in big-endian order
- `BigIntCodec.lsbFirst` — treats bytes in little-endian order (default)

### ByteCollector

`ByteCollector` is the byte container shared with `hashlib`, holding the output
of a hash or encoding function and re-encoding it on demand:

| Method / getter               | Description                                              |
| ----------------------------- | -------------------------------------------------------- |
| `bytes`                       | Raw bytes as `Uint8List`                                 |
| `length`                      | Number of bytes                                          |
| `buffer`                      | The backing `ByteBuffer`                                 |
| `hex([upper])`                | Hexadecimal string (optionally uppercase)                |
| `binary()` / `octal()`        | Binary / octal string representation                     |
| `base32({upper, padding})`    | Base-32 encoding                                         |
| `base64({urlSafe, padding})`  | Base-64 encoding                                         |
| `bigInt({endian})`            | Interprets the bytes as a `BigInt`                       |
| `number([bitLength, endian])` | Reads an unsigned integer of the given bit-length        |
| `ascii()` / `utf8()`          | Decodes bytes as ASCII / UTF-8                           |
| `to(encoding)`                | Decodes bytes with a given `dart:convert` `Encoding`     |
| `isEqual(other)`              | Constant-time compare against bytes, buffer, or hex text |

## Recipes

### Base-32 alphabet variants

The same bytes, rendered in each supported Base-32 alphabet — useful for
human-friendly identifiers (Crockford), URLs (z-base-32), or geospatial codes
(geohash):

<!-- file: example/base32_variants_example.dart -->

```dart
import 'package:convertlib/convertlib.dart';

void main() {
  final data = toUtf8('Hello, convertlib!');

  print('standard   : ${toBase32(data)}');
  print('lowercase  : ${toBase32(data, lower: true)}');
  print('no padding : ${toBase32(data, padding: false)}');
  print('base32hex  : ${toBase32(data, codec: Base32Codec.hex)}');
  print('crockford  : ${toBase32(data, codec: Base32Codec.crockford)}');
  print('z-base-32  : ${toBase32(data, codec: Base32Codec.z)}');
  print('geohash    : ${toBase32(data, codec: Base32Codec.geohash)}');
  print('word-safe  : ${toBase32(data, codec: Base32Codec.wordSafe)}');

  // Decoding is the exact inverse of encoding
  final back = fromBase32(toBase32(data));
  print('roundtrip  : ${fromUtf8(back)}');
}
```

<!-- file: example/base32_variants_example.dart -->

### URL-safe and unpadded Base-64

For tokens embedded in URLs or JSON, drop the padding and switch to the
URL/filename-safe alphabet:

<!-- file: example/base64_example.dart -->

```dart
import 'package:convertlib/convertlib.dart';

void main() {
  final data = toUtf8('a >> b, c/d');

  print('standard    : ${toBase64(data)}');
  print('url-safe    : ${toBase64(data, url: true)}');
  print('no padding  : ${toBase64(data, url: true, padding: false)}');
  print('bcrypt      : ${toBase64(data, codec: Base64Codec.bcrypt)}');

  // Decode back to the original bytes
  final back = fromBase64(toBase64(data, url: true));
  print('roundtrip   : ${fromUtf8(back)}');
}
```

<!-- file: example/base64_example.dart -->

### BigInt ↔ bytes

Read a byte sequence as an arbitrary-precision integer and back. Combine with
`BigInt.toRadixString` for a decimal (or any-base) string representation:

<!-- file: example/decimal_example.dart -->

```dart
import 'package:convertlib/convertlib.dart';

void main() {
  var input = [0x3, 0xF1];
  print("input => $input");
  var encoded = toBigInt(input).toRadixString(10);
  print("to decimal => $encoded");
  var decoded = fromBigInt(BigInt.parse(encoded, radix: 10));
  print("from decimal => $decoded");
}
```

<!-- file: example/decimal_example.dart -->

### PHC / Modular Crypt Format

Build and parse password-hash strings such as
`$argon2id$v=19$m=65536,t=3,p=4$...$...`. The builder Base-64 encodes salt and
hash bytes for you, and `fromCrypt` gives the fields back as typed accessors:

<!-- file: example/crypt_example.dart -->

```dart
import 'package:convertlib/convertlib.dart';

void main() {
  // Build a PHC / Modular Crypt Format string from its parts.
  // `saltBytes` and `hashBytes` are Base-64 encoded (no padding) for you.
  final data = CryptData.builder('argon2id')
      .version('19')
      .param('m', 65536)
      .param('t', 3)
      .param('p', 4)
      .saltBytes(toUtf8('a-16-byte-salt!!'))
      .hashBytes(List.generate(32, (i) => i))
      .build();

  final encoded = toCrypt(data);
  print('encoded : $encoded');

  // Parse the string back into its structured fields.
  final parsed = fromCrypt(encoded);
  print('id      : ${parsed.id}');
  print('version : ${parsed.versionInt()}');
  print('m,t,p   : ${parsed.getIntParam('m')}, '
      '${parsed.getIntParam('t')}, ${parsed.getIntParam('p')}');
  print('salt    : ${fromUtf8(parsed.saltBytes()!)}');
  print('hash    : ${toHex(parsed.hashBytes()!)}');
}
```

<!-- file: example/crypt_example.dart -->

<!-- file: BENCHMARK.md -->

## Benchmarks

### Libraries

- **Convertlib** : https://pub.dev/packages/convertlib
- **Base Codecs** : https://pub.dev/packages/base_codecs
- **Base32** : https://pub.dev/packages/base32
- **Dart Convert** : https://api.dart.dev/stable/dart-convert/dart-convert-library.html

> UTF-8 throughput is measured per source code point, not per byte.

### Encoding

<table>
<thead>
  <tr>
    <th>Codec</th>
    <th>Library</th>
    <th>1MB message</th>
    <th>1KB message</th>
    <th>32B message</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>Base-2</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>1.74 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>2.05 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.88 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>Base-8</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.42 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.95 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.3 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-16</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.92 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>5.41 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.35 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>272 Mbps &#128315;18.09x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>223 Mbps &#128315;24.3x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>230 Mbps &#128315;18.92x</small></td>
  </tr>
  <tr>
    <td rowspan="3">Base-32</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>1.88 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>2.03 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.72 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>█████░░░░░░░░░░░</code> <br> <small>543 Mbps &#128315;3.46x</small></td>
    <td><code>███░░░░░░░░░░░░░</code> <br> <small>422 Mbps &#128315;4.81x</small></td>
    <td><code>████░░░░░░░░░░░░</code> <br> <small>381 Mbps &#128315;4.51x</small></td>
  </tr>
  <tr>
    <td>base32</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>636 Kbps &#128315;2961.62x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>129 Mbps &#128315;15.67x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>136 Mbps &#128315;12.68x</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-64</td>
    <td>convertlib</td>
    <td><code>███████░░░░░░░░░</code> <br> <small>2.27 Gbps </small></td>
    <td><code>██████░░░░░░░░░░</code> <br> <small>2.34 Gbps </small></td>
    <td><code>███████░░░░░░░░░</code> <br> <small>2 Gbps </small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>████████████████</code> <br> <small><b>5.51 Gbps</b> &#128314;2.43x</small></td>
    <td><code>████████████████</code> <br> <small><b>6.02 Gbps</b> &#128314;2.57x</small></td>
    <td><code>████████████████</code> <br> <small><b>4.33 Gbps</b> &#128314;2.17x</small></td>
  </tr>
  <tr>
    <td rowspan="2">UTF-8</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small>2.52 Gbps </small></td>
    <td><code>███████████████░</code> <br> <small>2.55 Gbps </small></td>
    <td><code>████████████████</code> <br> <small><b>2.18 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>████████████████</code> <br> <small><b>2.57 Gbps</b> &#128314;1.02x</small></td>
    <td><code>████████████████</code> <br> <small><b>2.69 Gbps</b> &#128314;1.06x</small></td>
    <td><code>███████████████░</code> <br> <small>2.09 Gbps &#128315;1.04x</small></td>
  </tr>
</tbody>
</table>

> This package comes on top 23 out of 33 times.

### Decoding

<table>
<thead>
  <tr>
    <th>Codec</th>
    <th>Library</th>
    <th>1MB message</th>
    <th>1KB message</th>
    <th>32B message</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>Base-2</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>1.71 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.72 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.64 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>Base-8</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.13 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.21 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.69 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-16</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>3.65 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.7 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.13 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>451 Mbps &#128315;8.08x</small></td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>458 Mbps &#128315;8.08x</small></td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>425 Mbps &#128315;7.38x</small></td>
  </tr>
  <tr>
    <td rowspan="3">Base-32</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>2.3 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>2.33 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.89 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>289 Mbps &#128315;7.96x</small></td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>292 Mbps &#128315;7.99x</small></td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>261 Mbps &#128315;7.24x</small></td>
  </tr>
  <tr>
    <td>base32</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>177 Mbps &#128315;12.99x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>195 Mbps &#128315;11.93x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>155 Mbps &#128315;12.18x</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-64</td>
    <td>convertlib</td>
    <td><code>████████████░░░░</code> <br> <small>2.63 Gbps </small></td>
    <td><code>████████████░░░░</code> <br> <small>2.7 Gbps </small></td>
    <td><code>████████████░░░░</code> <br> <small>2.17 Gbps </small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>████████████████</code> <br> <small><b>3.62 Gbps</b> &#128314;1.37x</small></td>
    <td><code>████████████████</code> <br> <small><b>3.63 Gbps</b> &#128314;1.34x</small></td>
    <td><code>████████████████</code> <br> <small><b>2.82 Gbps</b> &#128314;1.3x</small></td>
  </tr>
  <tr>
    <td rowspan="2">UTF-8</td>
    <td>convertlib</td>
    <td><code>█████░░░░░░░░░░░</code> <br> <small>507 Mbps </small></td>
    <td><code>███████░░░░░░░░░</code> <br> <small>811 Mbps </small></td>
    <td><code>██████░░░░░░░░░░</code> <br> <small>680 Mbps </small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>████████████████</code> <br> <small><b>1.74 Gbps</b> &#128314;3.43x</small></td>
    <td><code>████████████████</code> <br> <small><b>1.82 Gbps</b> &#128314;2.25x</small></td>
    <td><code>████████████████</code> <br> <small><b>1.72 Gbps</b> &#128314;2.53x</small></td>
  </tr>
</tbody>
</table>

> This package comes on top 21 out of 33 times.

### BigInt

<table>
<thead>
  <tr>
    <th>Codec</th>
    <th>Library</th>
    <th>4KB message</th>
    <th>256B message</th>
    <th>32B message</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>bytes → BigInt</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>118 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>115 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>97.66 Mbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>BigInt → bytes</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>208 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>199 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>169 Mbps</b> &#127775;</small></td>
  </tr>
</tbody>
</table>

> This package comes on top 6 out of 6 times.

> All benchmarks are done on 36GB _Apple M3 Pro_ using compiled _exe_
>
> Dart SDK version: 3.12.2 (stable) (Tue Jun 9 01:11:39 2026 -0700) on "macos_arm64"

<!-- file: BENCHMARK.md -->

## License

BSD 3-Clause License. See the [LICENSE](LICENSE) file for details. Issues and
contributions are welcome at
[github.com/bitanon/convertlib](https://github.com/bitanon/convertlib).
