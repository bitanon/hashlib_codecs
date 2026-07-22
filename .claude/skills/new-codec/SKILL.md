---
name: new-codec
description: Scaffold a new codec or a new alphabet variant for convertlib the house way - generated alphabet tables, codec class with static const instances, top-level to/from functions, the six standard test groups with differential checks, README/CHANGELOG/example updates, and exports. Use when adding any new encoding (a new baseN, a new alphabet like base58/base85/z85, or a new format codec).
---

# New codec — the full checklist, in order

Adding an encoding here touches **nine** places. History shows the recurring
unit of work in this repo is exactly this (base8 → bigint → base32 alphabets →
bcrypt → PHC/crypt → utf8 → ByteCollector), so do all nine in one pass; a codec
missing its README table, its export line, or its differential test is not done.

Before writing anything, read one complete existing example top to bottom and
imitate it structurally: `lib/src/codecs/base32.dart` + `lib/src/base32.dart` +
`test/base32_test.dart` for alphabet codecs; the `codecs/crypt/` folder for
structured formats.

## 1. Find the spec and a reference implementation — first, not last

Locate the RFC/Wikipedia/spec page (it goes in the dartdoc) and a reference
implementation to test against: `dart:convert` if it has one, else a pub.dev
package added to **dev_dependencies only** (`dependencies:` stays empty,
always), else the spec's own test vectors. If you cannot find any external
source of expected values, stop and ask the owner — a codec validated only
against itself is how this repo got the wordSafe bug.

## 2. Generate the alphabet tables — never type them

Edit `tool/alphabet_maker.dart`: add the alphabet as a string literal, print
with `fwd()` (forward table) and `rev()` (reverse table; pass multiple
alphabets to one `rev()` call to make a case-insensitive decoder, and an
optional alias map for substitutions like Crockford's `I/L -> 1`). Run
`dart run tool/alphabet_maker.dart` and paste the output. Leave the new section
in the script (commented like the others) so the table is regenerable. Keep the
trailing `//` after the first row of each table so `dart format` preserves the
grid layout.

## 3. Codec class — `lib/src/codecs/<name>.dart`

Follow the house pattern exactly:

```dart
// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'package:convertlib/src/core/alphabet.dart';
import 'package:convertlib/src/core/codec.dart';

const int _padding = 0x3d;
// ignore: constant_identifier_names
const int __ = -1;

// <generated tables here, private const>

class BaseNCodec extends IterableCodec {
  @override
  final AlphabetEncoder encoder;
  @override
  final AlphabetDecoder decoder;

  const BaseNCodec._({required this.encoder, required this.decoder});

  /// Codec instance to encode and decode 8-bit integer sequence to K-bit
  /// Base-N character sequence using the alphabet described in
  /// [RFC-XXXX](https://...):
  /// ```
  /// <the alphabet, literally>
  /// ```
  ///
  /// It is padded with `=` / It is not padded.
  static const BaseNCodec standard = BaseNCodec._(...);
}
```

Rules: private constructor; one `static const` instance per variant with names
matching the family (`standard`, `standardNoPadding`, `lowercase`, `hex`, …);
dartdoc on every instance showing the alphabet in a code block and linking the
spec. If the generic `AlphabetEncoder/Decoder` path is too slow (only prove
this with `benchmark/`, don't assume it), hand-specialize private
`_<Name>Encoder/_<Name>Decoder` classes like `codecs/base16.dart` does —
preallocated `Uint8List`, up-front `int` locals, no closures, no `sync*`.
Non-power-of-2 or structured codecs extend the right base (`Codec<A, B>`
directly, like `BigIntCodec`/`CryptFormat`) instead of forcing the bit path.

## 4. Top-level functions — `lib/src/<name>.dart`

`to<Name>()` and `from<Name>()` with: bool convenience flags, an always-present
`codec:` override, a private `_codecFromParameters()` mapping flags to the
`static const` instances, `String` out / `Uint8List` in for encoders and the
reverse for decoders. Dartdoc with `Parameters:` and `Throws:` sections —
written fresh, not pasted (re-read every parameter line against the code;
polarity drift is a known failure mode here).

## 5. Export — `lib/src/codecs_base.dart`

Add both new files, **alphabetically ordered**. Without this the API doesn't
exist for users.

## 6. Tests — `test/<name>_test.dart`, all six groups

1. **parameter overrides** — `codec:` wins over bool flags;
2. **encoding <-> decoding** — random roundtrips, every length 0..99, per
   variant (`randomBytes` from `test/utils.dart` for byte inputs,
   `randomCodePoints`/`randomNumbers` for wider domains — never store wide
   values in a `Uint8List`, it clips to bytes);
3. **encoding** known-answer vectors from the spec (the RFC 4648 set is
   `""`,`f`,`fo`,`foo`,`foob`,`fooba`,`foobar` where applicable);
4. **decoding** known-answer vectors, including alternate-case input if the
   decoder is case-insensitive;
5. **invalid input** — invalid characters and invalid lengths, each
   `throwsFormatException`;
6. **differential** — every variant against the reference implementation from
   step 1, plus one test that encodes each of the N alphabet values once and
   asserts the resulting **full alphabet string** equals the documented one.

Roundtrip-only coverage is explicitly insufficient in this repo (see AGENTS.md
failure mode #1).

## 7. Docs — README.md

Add the feature section in the established shape: heading, optional blockquote
note, the Type/Class/Methods table, and the "Available codecs:" list with the
literal alphabet per variant (copy the string your alphabet-string test
asserts — they must agree).

## 8. CHANGELOG.md

Bullet(s) under the `# _next_` heading at the top (add it if absent; the owner
renames it to the real version at release), house style:
`- Adds Base-N codec support` with sub-bullets for `New class:`/`New methods:`.

## 9. Showcase — `example/convertlib_example.dart` and `test_integration/main.dart`

Add a couple of representative calls to each. The integration program is CI's
public-API smoke test; a codec absent from it is a codec CI never imports.

## Finish

Run the `preflight` skill (format, analyze --fatal-infos, `dart test` on
vm+node, integration). Then run `bash scripts/coverage.sh` and confirm the new
files are ~100% line-covered. Leave everything uncommitted and propose a
commit message in house style (`Adds Base-N codec support` — imperative,
backticks for identifiers); commit only if the owner's current message asks
for it. Never bump the version or tag — that's the `release` skill, on the
owner's request.
