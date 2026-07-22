# 3.6.0

- [**Breaking Changes**]
  - `CipherlibConverter` -> `BitConverter` (the exported bit-converter base class).
  - `BigIntDecoder` narrows from `Converter<BigInt, Iterable<int>>` to
    `Converter<BigInt, Uint8List>`; `BigIntCodec` decoders now return a `Uint8List`.
- Export the `ByteEncoder`, `ByteDecoder`, `AlphabetEncoder`, and `AlphabetDecoder`
  base classes, previously part of the API surface but not reachable through
  `package:convertlib/convertlib.dart`.
- Fix the UTF-8 encoder emitting invalid bytes for scalar code points in
  `U+10000..U+10FFFF`; `UTF8Encoder.convert` now uses the 4-byte form (the public
  `toUtf8` was unaffected). Verified against `dart:convert`.
- Make the Crockford Base-32 decoder case-insensitive and decode the ambiguous
  letters `I`/`i`/`L`/`l` as `1` and `O`/`o` as `0`. Encoding output is unchanged.
- Fix `ByteCollector.number` truncating values wider than 32 bits on the web; it
  now accumulates with multiplication and is exact up to `2^53` (VM unchanged).
- `ByteCollector.isEqual` returns `false` for a [String] that is not valid
  hexadecimal instead of throwing a `FormatException`, matching its contract.
- Add value-based `==` and `hashCode` to `CryptData`.
- PHC/crypt: allow empty parameter values (e.g. `$id$data=`), and fix the decoder
  mis-classifying a comma-containing `v=...` segment as the version.
- Speed up `fromBase32`/`fromBase64` decoding and the generic `AlphabetEncoder` by
  removing extra allocations and passes; output is byte-identical.

# 3.5.1

- Widen `fromUtf8` to accept any `List<int>` input instead of requiring a
  `Uint8List`. Non-`Uint8List` inputs are copied to a `Uint8List` before
  decoding.

# 3.5.0

- [**Breaking Changes**]
  - Removes `encodeString`, `decodeString` from `IterableCodec`.
- Renames internal abstract class `HashlibConverter` to `CipherlibConverter`.
- Fix `CryptDataBuilder.param` to throw an `ArgumentError` when the value is
  `null`, instead of a raw `TypeError`.
- Speed up Base-64 and Base-32 **encoding** with specialized single-pass encoders.
  Base-64 encoding now outperforms `dart:convert`.
- Speed up Base-64 and Base-32 **decoding** with specialized single-pass decoders.
  Base-64 decoding now outperforms `dart:convert`.
- Speed up `toUtf8` using `Uint8List` buffer instead of plain `List<int>`.
  UTF-8 encoding now outperforms `dart:convert`.
- Speed up `fromUtf8` with a dedicated byte-to-string decoder.
  UTF-8 decoding now matches closely with `dart:convert`.
- Refactor existing benchmarks and add missing ones. Dropping `benchmark_harness`
  dependency in favor of custom benchmarking class with better flexibility.

# 3.4.0

- Rename the package from `hashlib_codecs` to `convertlib`. The public API is
  unchanged: update the dependency to `convertlib` and imports to
  `package:convertlib/convertlib.dart`.
- The `hashlib_codecs` package continues to be published as a thin re-export of
  `convertlib` for backward compatibility, and will be discontinued after a
  migration period.

# 3.3.1

- Fix `CryptData.validate` rejecting valid Modular Crypt Format hashes such as
  `bcrypt`, whose base64 alphabet uses `.`. The `hash` field now accepts the
  same characters as the `salt` (`[a-zA-Z0-9/+.-]`), reverting the overly
  strict B64 restriction introduced in `3.3.0`.
- Document every public API element (100% dartdoc coverage) and correct several
  inaccurate doc comments, including the `Base8Codec` alphabet (`01234567`) and
  the octal/binary notes on `toOctal`.

# 3.3.0

- [**Breaking Changes**]
  - `ByteCollector.isEqual` requires an `Iterable` argument to match the full
    length; previously a strict prefix of the bytes compared equal.
  - `CryptData.validate` now follows the [PHC string format specification](https://github.com/C2SP/C2SP/blob/main/phc-strings.md)
    strictly: the hash must be a B64 string (`[a-zA-Z0-9/+]`, no `.` or `-`),
    and the version must not have leading zeros.
  - Reject invalid values after padding in `AlphabetDecoder`. Affected codecs are `Base32` and `Base64`.
- `ByteCollector.isEqual` now compares content in constant time, making it safe
  for comparing MACs and message digests
- Performance improvements (measured on Apple Silicon, 10KB inputs):
  - Base-32 decoding: ~6x faster (425 Mbps -> 2.52 Gbps)
  - Base-64 decoding: ~6.4x faster (453 Mbps -> 2.9 Gbps)
  - UTF-8 encoding: ~6.5x faster (403 Mbps -> 2.61 Gbps)
- Update the PHC string format specification link to its new home at C2SP

# 3.2.0

- [**Breaking Changes**]
  - Fix `Base32Codec.wordSafe` to use the documented word-safe alphabet
    (`23456789CFGHJMPQRVWXcfghjmpqrvwx`); it previously used the z-base-32 alphabet.
  - `ByteCollector` equality is now value-based: `==` and `hashCode` compare the
    collected bytes instead of the identity of the underlying list.
- Fix UTF-8 decoder producing wrong code points for some 2-byte sequences (e.g. `U+0100`)
- Fix `ByteCollector.isEqual` comparing against its own buffer when given a `ByteBuffer`
- Fix `ByteCollector.isEqual` ignoring the offset and length of a partial `TypedData` view
- Fix incorrect alphabets of `crockford` and `geohash` in the README
- Fix incorrect parameter descriptions of `toBase32`, `fromBase32`, `fromBase64`, and `fromUtf8`
- Document that `toUtf8` rejects unpaired surrogates

# 3.1.2

- Add const constructor to `ByteCollector` class.

# 3.1.0

- Introduce `ByteCollector` abstract class with methods for various encoding formats (hex, binary, octal, base32, base64, BigInt).
  and utility methods for equality check.

# 3.0.1

- Test release with workflow

# 3.0.0

- Set minimum Dart SDK to 2.19.0

# 2.6.0

- [**Breaking Changes**]
  - Change the behavior of the Base-8 encoder to follow the standard
  - Accept only `List<int>` instead of `Iterable<int>` in converters

# 2.5.0

- Support UTF-8 encoding and decoding.
  - New class: `UTF8Codec`
  - New methods: `toUtf8`, `fromUtf8`
- Renames:
  - `HashlibCodec` -> `IterableCodec`
- Minor performance impovements

# 2.4.1

- Refactor: Remove all sync generator to improve runtime.

# 2.4.0

- **Breaking Changes**: Uses string for salt and hash in `CryptData`
- New class `CryptDataBuilder` is available to construct `CryptData` instances.

# 2.3.0

- **Breaking Changes**: Renames PHCSF -> CryptFormat. Affected names:
  - Class:
    - `PHCSF` -> `CryptFormat`
    - `PHCSFData` -> `CryptData`
    - `PHCSFEncoder` -> `CryptEncoder`
    - `PHCSFDecoder` -> `CryptDecoder`
  - Constant:
    - `phcsf` -> `crypt`
  - Methods:
    - `toPHCSF` -> `toCrypt`
    - `fromPHCSF` -> `fromCrypt`

# 2.2.0

- Support encoding and decoding with [PHC string format specification](https://github.com/P-H-C/phc-string-format/blob/master/phc-sf-spec.md)
  - New Class : `PHCSF`
  - New Constant: `phcsf`
  - New Methods : `toPHCSF`, `fromPHCSF`

# 2.1.1

- Adds new alphabet to `Base64Codec`: [bcrypt](https://en.wikipedia.org/wiki/Bcrypt#base64_encoding_alphabet)

# 2.1.0

- Adds more alphabets to `Base32Codec`. Additional alphabets are:
  - [base32hex](https://en.wikipedia.org/wiki/Base32#base32hex)
  - Lowerase base32hex
  - [Crockford's Base32](https://en.wikipedia.org/wiki/Base32#Crockford's_Base32)
  - [Geohash's Base32](https://en.wikipedia.org/wiki/Base32#Geohash)
  - [z-base-32](https://en.wikipedia.org/wiki/Base32#z-base-32)
  - [Word-safe alphabet](https://en.wikipedia.org/wiki/Base32#Word-safe_alphabet)
- Allows the `padding` parameter to be effective to any codecs in `Base32Codec` and `Base64Codec`.

# 2.0.0

- **Breaking**: Removes all constant exports.
  - They are now available inside codec class. e.g.: `Base64Codec.urlSafe`
- **Breaking**: Modify parameters of all public methods.
- Improves encoding and decoding algorithm.
- Adds Base-8 (Octal) codec support
  - New class: `Base8Codec`
  - New methods: `fromOctal`, `toOctal`
- Renames a lot of exports
  - `Uint8Converter` -> `BitConverter`
  - `Uint8Codec` -> `HashlibCodec`
  - `BinaryCodec` -> `Base2Codec`
  - `B16Codec` -> `Base16Codec`
  - `B64Codec` -> `Base64Codec`
- Separates base encoder and decoders
  - Generic encoders: `BitEncoder`, `AlphabetEncoder`
  - Generic decoders: `BitDecoder`, `AlphabetDecoder`

# 1.2.0

- Adds `BigInt` codec support.
  - New class: `BigIntCodec`
  - New methods: `fromBigInt`, `toBigInt`
  - New constant: `bigintLE`, `bigintBE`
- Updates documentations.

# 1.1.1

- Updates project description.

# 1.1.0

- Fixes padding issues with `base2` and `base16`
- In `toBase32`, uses the parameter `lower` replacing `upper`.
- Transfers `fromBase64Url` to `fromBase64` with extended alphabet.
- Transfers `toBase64Url` to `toBase64` with optional `url` parameter.
- Improves documentation

# 1.0.0

- First release
