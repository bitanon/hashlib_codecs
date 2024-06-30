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
