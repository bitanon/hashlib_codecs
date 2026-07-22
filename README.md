# convertlib

[![package version](https://img.shields.io/pub/v/convertlib?label=pub)](https://pub.dev/packages/convertlib)
[![dart support](https://img.shields.io/badge/dart-%3e%3d%202.19.0-39f?logo=dart)](https://dart.dev/guides/whats-new#september-8-2021-214-release)
[![likes](https://img.shields.io/pub/likes/convertlib?logo=dart)](https://pub.dev/packages/convertlib/score)
[![pub points](https://img.shields.io/pub/points/convertlib?logo=dart&color=teal)](https://pub.dev/packages/convertlib/score)
[![codecov](https://codecov.io/gh/bitanon/convertlib/graph/badge.svg?token=ISIYJ8MNI0)](https://codecov.io/gh/bitanon/convertlib)
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
- **Error resilient**: decoders accept case and alphabet variations where the
  encoding allows it (either Base-64 alphabet, upper or lower Base-32), and
  raise typed errors on genuinely invalid input.
- **Convenient output**: results integrate with `ByteCollector`, the digest
  container shared with `hashlib`, for one-call re-encoding.
- **Bytes or strings, throwing or not**: every encoder has a `to<Name>Bytes`
  twin returning a `Uint8List`, every decoder a non-throwing `tryFrom<Name>`
  returning `null` on bad input, plus a top-level `constantTimeEquals` for
  MAC/digest checks.

## Install

```yaml
dependencies:
  convertlib: ^3.6.1
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

Every snippet in this README is also a runnable program in the
[example](https://github.com/bitanon/convertlib/tree/master/example) folder.

## Supported codecs

| Encoding              | Class         | Encode                        | Decode                          |          Source          |
| --------------------- | ------------- | ----------------------------- | ------------------------------- | :----------------------: |
| Binary (Base-2)       | `Base2Codec`  | `toBinary`, `toBinaryBytes`   | `fromBinary`, `tryFromBinary`   |            —             |
| Octal (Base-8)        | `Base8Codec`  | `toOctal`, `toOctalBytes`     | `fromOctal`, `tryFromOctal`     |            —             |
| Hexadecimal (Base-16) | `Base16Codec` | `toHex`, `toHexBytes`         | `fromHex`, `tryFromHex`         |     [RFC-4648][rfc4648]      |
| Base-32               | `Base32Codec` | `toBase32`, `toBase32Bytes`   | `fromBase32`, `tryFromBase32`   |     [RFC-4648][rfc4648]      |
| Base-64               | `Base64Codec` | `toBase64`, `toBase64Bytes`   | `fromBase64`, `tryFromBase64`   |     [RFC-4648][rfc4648]      |
| BigInt                | `BigIntCodec` | `toBigInt`                    | `fromBigInt`, `tryFromBigInt`   |            —             |
| UTF-8                 | `UTF8Codec`   | `toUtf8`                      | `fromUtf8`, `tryFromUtf8`       |     [RFC-3629][rfc3629]      |
| Modular Crypt Format  | `CryptFormat` | `toCrypt`                     | `fromCrypt`                     | [PHC string format][phc] |

[rfc4648]: https://datatracker.ietf.org/doc/html/rfc4648
[rfc3629]: https://datatracker.ietf.org/doc/html/rfc3629
[phc]: https://github.com/C2SP/C2SP/blob/main/phc-strings.md

### Alphabet variants

**Base-16** — `toHex(..., upper: true)` selects the uppercase alphabet:

- `Base16Codec.upper` — `0123456789ABCDEF`
- `Base16Codec.lower` — `0123456789abcdef` (default)

**Base-32** — pass `codec:` to pick an alphabet, `lower:`/`padding:` to tweak it:

- `Base32Codec.standard` (RFC-4648) — `ABCDEFGHIJKLMNOPQRSTUVWXYZ234567` (default)
- `Base32Codec.lowercase` — `abcdefghijklmnopqrstuvwxyz234567`
- `Base32Codec.hex` / `.hexLower` — base32hex, `0-9A-V` / `0-9a-v`
- `Base32Codec.crockford` — `0123456789ABCDEFGHJKMNPQRSTVWXYZ` (decoding is
  case-insensitive and accepts `I`/`i`/`L`/`l` as `1` and `O`/`o` as `0`)
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

### Bytes, non-throwing decode, and constant-time compare

- **Byte output** — the `to<Name>Bytes` encoders in the table above return the
  encoded ASCII as a `Uint8List`, skipping the intermediate `String`.
- **Non-throwing decoders** — the `tryFrom<Name>` decoders return `null` instead
  of throwing a `FormatException` on invalid input.
- **Constant-time compare** — `constantTimeEquals(a, b)` compares two byte lists
  without exiting early on the first mismatch, for verifying MACs and digests.
- **Low-level building blocks** — the generic converters `BitEncoder`/
  `BitDecoder`, `ByteEncoder`/`ByteDecoder`, and `AlphabetEncoder`/
  `AlphabetDecoder` are exported for building custom codecs.

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

## Testing and reliability

Codecs are trivial to get subtly wrong. It is not enough to check just the
`decode(encode(x)) == x` round-trips alone. For example: a dropped bit mask
can produce output that still passes round-trips cleanly. This package is
tested against that failure mode directly:

- **Expectations come from outside the code.** Every codec is checked against
  official vectors (RFC 4648 "foobar", RFC 3629 UTF-8 boundaries, PHC / bcrypt
  strings) **and** differentially against independent reference implementations:
  `dart:convert`, [`base_codecs`][base_codecs], and [`base32`][base32], so a
  consistently-wrong codec cannot hide behind a passing round-trip.
- **Wide input coverage.**
  - Randomized round-trips at every length from 0 to 99 for each alphabet variant
  - Full-range Unicode code points and surrogate-pair handling for UTF-8
  - Per-instance assertions of the exact alphabet string each codec emits,
    which catch miscopied lookup tables.
- **Failure paths are asserted, not assumed.** Malformed UTF-8, invalid
  characters, and exhaustive invalid-length sweeps all verify that a typed
  error is raised (with the exact message and offset), never a silent wrong
  result.
- **Every platform.** The suite runs on the Dart VM, Node.js (JavaScript), and
  Chrome (WASM) in CI across Dart SDK 2.19 and stable on Linux, macOS, and Windows.
  Special care has been given for the web, where integers behave differently.
- **Regressions stay fixed.** Real bugs found in the past (a word-safe Base-32
  table accidentally copied from z-base-32, a dropped `& 0x3F` mask in the
  UTF-8 decoder, a `ByteCollector.isEqual` self-comparison) each have a
  permanent, externally-anchored regression test, and a differential fuzz
  harness re-checks the codecs against the reference implementations.

Because correctness is anchored to independent references rather than the
package's own agreement with itself, `convertlib` is safe to rely on in
production. If you do hit a discrepancy, please [open an issue] and include
your input and the expected output.

[base32]: https://pub.dev/packages/base32
[base_codecs]: https://pub.dev/packages/base_codecs
[open an issue]: https://github.com/bitanon/convertlib/issues

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
    <td><code>████████████████</code> <br> <small><b>1.86 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>2.11 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.94 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>Base-8</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.48 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>5.06 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.4 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-16</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.98 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>5.59 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.51 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>284 Mbps &#128315;17.55x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>247 Mbps &#128315;22.59x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>247 Mbps &#128315;18.24x</small></td>
  </tr>
  <tr>
    <td rowspan="3">Base-32</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>5.44 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>5.99 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.53 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>577 Mbps &#128315;9.43x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>421 Mbps &#128315;14.23x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>387 Mbps &#128315;11.7x</small></td>
  </tr>
  <tr>
    <td>base32</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>631 Kbps &#128315;8618.49x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>132 Mbps &#128315;45.35x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>137 Mbps &#128315;33.02x</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-64</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>6.04 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>6.68 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>5.48 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>███████████████░</code> <br> <small>5.61 Gbps &#128315;1.08x</small></td>
    <td><code>███████████████░</code> <br> <small>6.11 Gbps &#128315;1.09x</small></td>
    <td><code>█████████████░░░</code> <br> <small>4.36 Gbps &#128315;1.26x</small></td>
  </tr>
  <tr>
    <td rowspan="2">UTF-8</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>3.14 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.4 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>2.78 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>█████████████░░░</code> <br> <small>2.6 Gbps &#128315;1.21x</small></td>
    <td><code>█████████████░░░</code> <br> <small>2.73 Gbps &#128315;1.25x</small></td>
    <td><code>█████████████░░░</code> <br> <small>2.22 Gbps &#128315;1.25x</small></td>
  </tr>
</tbody>
</table>

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
    <td><code>████████████████</code> <br> <small><b>1.74 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.76 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.64 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>Base-8</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.15 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.22 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.68 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-16</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>3.65 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.71 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.26 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>406 Mbps &#128315;8.98x</small></td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>410 Mbps &#128315;9.04x</small></td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>396 Mbps &#128315;8.24x</small></td>
  </tr>
  <tr>
    <td rowspan="3">Base-32</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.03 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.09 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.38 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>266 Mbps &#128315;15.13x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>267 Mbps &#128315;15.33x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>239 Mbps &#128315;14.13x</small></td>
  </tr>
  <tr>
    <td>base32</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>176 Mbps &#128315;22.84x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>199 Mbps &#128315;20.62x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>153 Mbps &#128315;22.14x</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-64</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.98 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>5.16 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.32 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>███████████░░░░░</code> <br> <small>3.5 Gbps &#128315;1.42x</small></td>
    <td><code>███████████░░░░░</code> <br> <small>3.6 Gbps &#128315;1.43x</small></td>
    <td><code>███████████░░░░░</code> <br> <small>2.87 Gbps &#128315;1.51x</small></td>
  </tr>
  <tr>
    <td rowspan="2">UTF-8</td>
    <td>convertlib</td>
    <td><code>███████████████░</code> <br> <small>1.65 Gbps </small></td>
    <td><code>███████████████░</code> <br> <small>1.68 Gbps </small></td>
    <td><code>████████████░░░░</code> <br> <small>1.28 Gbps </small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>████████████████</code> <br> <small><b>1.75 Gbps</b> &#128314;1.06x</small></td>
    <td><code>████████████████</code> <br> <small><b>1.81 Gbps</b> &#128314;1.08x</small></td>
    <td><code>████████████████</code> <br> <small><b>1.72 Gbps</b> &#128314;1.35x</small></td>
  </tr>
</tbody>
</table>

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
    <td><code>████████████████</code> <br> <small><b>119 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>115 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>98.21 Mbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>BigInt → bytes</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>256 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>250 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>223 Mbps</b> &#127775;</small></td>
  </tr>
</tbody>
</table>

> All benchmarks are done on 36GB _Apple M3 Pro_ using compiled _exe_
>
> Dart SDK version: 3.12.2 (stable) (Tue Jun 9 01:11:39 2026 -0700) on "macos_arm64"

## License

BSD 3-Clause License. See the [LICENSE](LICENSE) file for details. Issues and
contributions are welcome at
[github.com/bitanon/convertlib](https://github.com/bitanon/convertlib).
