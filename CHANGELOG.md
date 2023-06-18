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
