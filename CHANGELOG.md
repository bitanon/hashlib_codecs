# 2.0.0

- **Breaking**: Removes all constant exports, instead they are now available inside codec class. e.g.: `Base64Codec.urlSafe`
- An optional padding character can now be passed as a constant to the `convert` method.
- **Breaking**: Replaces some parameters with `alphabet` config. Affected methods:
  - `toBase64`
  - `toBase32`
  - `toHex`
- Improves encoding and decoding algorithm.
- Adds Base-8 (Octal) codec support
  - New class: `Base8Codec`
  - New methods: `fromOctal`, `toOctal`
- Renames a lot of exports
  - `Uint8Converter` -> `BitConverter`
  - `Uint8Codec` -> `ByteCodec`
  - `BinaryCodec` -> `Base2Codec`
  - `B16Codec` -> `Base16Codec`
  - `B64Codec` -> `Base64Codec`
- Change internal methods of `ByteCodec`
- Separates base encoder and decoders
  - Generic encoders: `BitEncoder`, `AlphabetEncoder`
  - Generic decoders: `BitDecoder`, `AlphabetDecoder`
- Exports two new types:
  - `BigIntEncoder`
  - `BigIntDecoder`

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
