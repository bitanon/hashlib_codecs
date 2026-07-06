---
name: fuzz-codecs
description: Differential-fuzz every hashlib_codecs codec against external reference implementations (dart:convert, base_codecs, base32) with full-domain inputs and a reproducible seed. Use before releases, after touching any encoder/decoder or alphabet table, or when asked to "fuzz", "cross-check", or "audit" the codecs. Finds the class of bug that roundtrip tests structurally cannot (wrong-alphabet tables, masking errors).
---

# Differential codec fuzzing

The permanent test suite proves round-trip consistency; this skill proves
**agreement with the outside world**. It exists because three real bugs
(z-alphabet pasted into `wordSafe`, a missing `& 0x3F` in UTF-8 2-byte decode,
`isEqual(ByteBuffer)` comparing to itself) each survived 366 green tests —
every one is invisible to a codec testing itself.

## Ground rules

- Expected values must come from **outside** `lib/`: `dart:convert`, the
  dev-dependency packages (`base_codecs`, `base32`), or arithmetic done inline
  (`toRadixString`). Never compute the expectation with the code under test.
- Use a **printed, fixed seed** so any failure is replayable. Default seed 1;
  bump iterations/seeds for release audits.
- For inputs wider than a byte, generate plain `List<int>` values (e.g.
  `randomCodePoints()` in `test/utils.dart`) — never a `Uint8List`, which
  silently clips to 0..255 (AGENTS.md failure mode #2).
- A confirmed mismatch against a reference implementation is a finding to
  report, not to fix: observable behavior changes need the owner
  (AGENTS.md failure mode #11). Propose the regression test and stop.

## Procedure

1. Write the harness below to `test/tmp_differential_fuzz_test.dart` (the name
   must end `_test.dart`; the `tmp_` prefix marks it disposable).
2. Run it on both platforms: `dart test test/tmp_differential_fuzz_test.dart`.
3. For each failure: minimize to the smallest failing input, state input
   bytes → our output → reference output, and check whether
   `test/differential_test.dart` already covers it. New findings get a
   permanent regression test proposed (with the external expected value) —
   show the test, let the owner decide about the fix.
4. Delete the temp file. `git status` must come back clean.

## The harness

```dart
import 'dart:convert' as cvt;
import 'dart:math';
import 'dart:typed_data';

import 'package:base32/base32.dart' as b32pkg;
import 'package:base_codecs/base_codecs.dart' as bc;
import 'package:hashlib_codecs/hashlib_codecs.dart';
import 'package:test/test.dart';

const int seed = 1;      // print in failures; change to widen the search
const int rounds = 2000; // per property

final rng = Random(seed);

Uint8List rndBytes(int n) =>
    Uint8List.fromList(List.generate(n, (_) => rng.nextInt(256)));

/// Random VALID code points, full range, surrogates excluded.
/// Plain List<int> on purpose — Uint8List clips (AGENTS.md failure mode #2).
List<int> rndCodePoints(int n) => List.generate(n, (_) {
      while (true) {
        var c = rng.nextInt(0x110000);
        if (c < 0xD800 || c > 0xDFFF) return c;
      }
    });

void main() {
  group('differential fuzz (seed=$seed)', () {
    test('hex vs toRadixString', () {
      for (int i = 0; i < rounds; ++i) {
        var b = rndBytes(rng.nextInt(65));
        var expected =
            b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
        expect(toHex(b), expected, reason: 'seed=$seed round=$i input=$b');
        expect(fromHex(expected), b, reason: 'seed=$seed round=$i');
      }
    });

    test('base64 vs dart:convert', () {
      for (int i = 0; i < rounds; ++i) {
        var b = rndBytes(rng.nextInt(65));
        expect(toBase64(b), cvt.base64.encode(b),
            reason: 'seed=$seed round=$i input=$b');
        expect(toBase64(b, url: true), cvt.base64Url.encode(b),
            reason: 'seed=$seed round=$i input=$b');
        expect(fromBase64(cvt.base64.encode(b)), b,
            reason: 'seed=$seed round=$i');
      }
    });

    test('base32 vs base_codecs and package:base32', () {
      for (int i = 0; i < rounds; ++i) {
        var b = rndBytes(rng.nextInt(65));
        expect(toBase32(b), bc.base32RfcEncode(b),
            reason: 'seed=$seed round=$i input=$b');
        expect(toBase32(b), b32pkg.base32.encode(Uint8List.fromList(b)),
            reason: 'seed=$seed round=$i input=$b');
        expect(fromBase32(bc.base32RfcEncode(b)), b,
            reason: 'seed=$seed round=$i');
      }
    });

    test('base32hex vs base_codecs', () {
      for (int i = 0; i < rounds; ++i) {
        var b = rndBytes(rng.nextInt(65));
        expect(toBase32(b, codec: Base32Codec.hex), bc.base32RfcHexEncode(b),
            reason: 'seed=$seed round=$i input=$b');
      }
    });

    test('crockford vs base_codecs', () {
      for (int i = 0; i < rounds; ++i) {
        var b = rndBytes(rng.nextInt(65));
        expect(toBase32(b, codec: Base32Codec.crockford),
            bc.base32CrockfordEncode(b),
            reason: 'seed=$seed round=$i input=$b');
      }
    });

    test('utf8 encode/decode vs dart:convert (full code-point range)', () {
      for (int i = 0; i < rounds; ++i) {
        var s = String.fromCharCodes(rndCodePoints(rng.nextInt(33)));
        var ref = cvt.utf8.encode(s);
        expect(toUtf8(s), ref, reason: 'seed=$seed round=$i cps=${s.runes}');
        expect(fromUtf8(ref), s, reason: 'seed=$seed round=$i cps=${s.runes}');
      }
    });

    test('utf8 decoder rejects what dart:convert rejects', () {
      for (int i = 0; i < rounds; ++i) {
        var b = rndBytes(rng.nextInt(17));
        String? ref;
        try {
          ref = cvt.utf8.decode(b); // allowMalformed: false
        } on FormatException {
          ref = null;
        }
        if (ref != null) {
          expect(fromUtf8(b), ref, reason: 'seed=$seed round=$i input=$b');
        } else {
          expect(() => fromUtf8(b), throwsFormatException,
              reason: 'seed=$seed round=$i input=$b');
        }
      }
    });

    test('bigint vs BigInt.parse on hex', () {
      for (int i = 0; i < rounds; ++i) {
        var b = rndBytes(1 + rng.nextInt(64));
        var expected = BigInt.parse(toHexRef(b), radix: 16);
        expect(toBigInt(b, msbFirst: true), expected,
            reason: 'seed=$seed round=$i input=$b');
        expect(toBigInt(b.reversed.toList()), expected,
            reason: 'seed=$seed round=$i input=$b');
      }
    });

    test('every documented alphabet string is what the codec emits', () {
      // encode each 5-bit value once => the emitted alphabet, in order
      String alphabetOf(Base32Codec c) => String.fromCharCodes(
          List.generate(32, (v) => c.encoder.convert([v << 3])[0]));
      // keep these strings in sync with README.md
      expect(alphabetOf(Base32Codec.standard),
          'ABCDEFGHIJKLMNOPQRSTUVWXYZ234567');
      expect(alphabetOf(Base32Codec.lowercase),
          'abcdefghijklmnopqrstuvwxyz234567');
      expect(alphabetOf(Base32Codec.hex), '0123456789ABCDEFGHIJKLMNOPQRSTUV');
      expect(alphabetOf(Base32Codec.hexLower),
          '0123456789abcdefghijklmnopqrstuv');
      expect(alphabetOf(Base32Codec.crockford),
          '0123456789ABCDEFGHJKMNPQRSTVWXYZ');
      expect(alphabetOf(Base32Codec.geohash),
          '0123456789bcdefghjkmnpqrstuvwxyz');
      expect(alphabetOf(Base32Codec.z), 'ybndrfg8ejkmcpqxot1uwisza345h769');
      expect(alphabetOf(Base32Codec.wordSafe),
          '23456789CFGHJMPQRVWXcfghjmpqrvwx');
    });
  });
}

String toHexRef(List<int> b) =>
    b.map((x) => x.toRadixString(16).padLeft(2, '0')).join();
```

Adjust package APIs if `base_codecs`/`base32` differ from the assumed function
names — check their docs rather than deleting a comparison. If a reference
package lacks a variant, fall back to spec vectors, and say so in the report.

## Report format

One line per property: PASS (n rounds) or FAIL with the minimized
counterexample and whether it matches a Known issue. Finish with the list of
proposed permanent regression tests, the seed(s) used, and confirmation that
the temp file was deleted.
