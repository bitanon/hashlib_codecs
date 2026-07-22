# AGENTS.md

Operating manual for AI coding agents working in this repository. This file
lives at the repo root and applies to the entire repository.

`convertlib` is a **zero-dependency, pure Dart** codec library (base2/8/16/32/64,
UTF-8, BigInt, PHC/crypt string format) published to pub.dev as `convertlib` by
Sudipto Chandra (github: `bitanon/convertlib`). It is the foundation of a package family:
`hashlib` depends on it (`convertlib: ^x.y.z`), and `hashlib`'s `HashDigest`
extends `ByteCollector` from this package. The product here is three things, in
order: **correctness, speed, and a perfect pub.dev score**. Everything below serves
those three.

## Commands

```sh
dart pub get                       # once per checkout
dart test                          # FULL suite: runs BOTH vm and node (dart_test.yaml)
dart test -p vm                    # quick iteration (VM only)
dart test -p node                  # web/JS semantics (node is installed via nvm)
dart format .                      # 80-col; CI fails on any diff
dart analyze --fatal-infos         # CI fails on ANY info, not just errors/warnings
cd test_integration && dart pub get && dart run main.dart   # public-API smoke test
bash scripts/globals.sh            # one-time: activate coverage/cobertura/junitreport/pana
bash scripts/coverage.sh           # lcov + cobertura into coverage/ (gitignored)
dart run benchmark/<file>.dart     # perf comparisons vs other packages
dart run tool/alphabet_maker.dart # generates alphabet tables (edit script, run, paste)
```

There is no build step. `master` is the only branch; commits land on it directly.
Releases are made by pushing a tag `vX.Y.Z` — CI publishes to pub.dev (OIDC), never
publish locally.

## Architecture — three layers, one export list

Data flows through exactly three layers. Put new code in the right one:

1. **`lib/src/core/`** — generic bit machinery. `HashlibConverter` declares
   `source`/`target` bit widths; `BitEncoder`/`BitDecoder` implement generic
   bit-regrouping between any 2–64 bit words; `ByteEncoder`/`ByteDecoder` pin one
   side to 8 bits; `AlphabetEncoder`/`AlphabetDecoder` add table lookup + padding;
   `IterableCodec` is the `dart:convert`-compatible codec base.
2. **`lib/src/codecs/<name>.dart`** — one file per codec. Contains: private
   `const` alphabet tables (forward table = ASCII codes; reverse table = sparse
   lookup with `__` (= -1) for invalid), a codec class with a **private
   constructor**, and **`static const` named instances** per alphabet variant
   (`standard`, `standardNoPadding`, `lowercase`, `hex`, `crockford`, …). Codecs
   that need speed get hand-specialized private encoder/decoder classes
   (see `_Base16Encoder`). Multi-file codecs get a subfolder (`codecs/crypt/`).
3. **`lib/src/<name>.dart`** — the public convenience API: top-level
   `to<Name>()` / `from<Name>()` functions with named params, always including an
   optional `codec:` override, and a private `_codecFromParameters()` that maps
   bool flags to a `static const` instance.

**The export list**: `lib/convertlib.dart` exports only
`src/codecs_base.dart`, which holds an **alphabetized** export list. A new public
file that is not added there does not exist as far as users are concerned.

Encode/decode direction: `encoder` = bytes → representation, `decoder` =
representation → bytes (for `BigIntCodec`, "representation" is the `BigInt`
itself; for `UTF8Codec`, encoder = code points → octets).

## Hard invariants — never break these

- **Zero runtime dependencies.** `pubspec.yaml` has no `dependencies:` section
  and never will. Reference packages (`base_codecs`, `base32`) live under
  `dev_dependencies` only. If you think you
  need a package, you need pure Dart instead.
- **SDK floor is `2.19.0`.** No records, no patterns, no `sealed`/`final`/`base`
  class modifiers, no `switch` expressions, no inline classes. CI runs the full
  test matrix on SDK 2.19 across Linux/macOS/Windows; it will catch you, slowly.
- **Everything runs on the web.** `dart test` runs on node by default. Ints there
  are JS doubles: no 64-bit two's-complement semantics, no shifts past 32 bits
  without testing on node first. VM-specific tests get `@Tags(['vm-only'])`
  (configured in `dart_test.yaml`).
- **Shipped output is a contract.** The exact output of every existing codec —
  even provably wrong output — must not change without the owner's sign-off,
  because downstream packages and stored data depend on it. Fixes to observable
  behavior are semver-relevant (see Escalation).
- **`const` everything constructible.** Codec instances are `static const` with
  private constructors; converters have `const` constructors. Users rely on
  const-ness in const contexts.
- **Perfect pana score.** Release CI runs `pana --exit-code-threshold 0`. Public
  API without dartdoc, format drift, or analyzer infos will block a release.

## House conventions

**Files.** Every `lib/` file starts with the two-line header (year = file
creation year, do not update old files):

```dart
// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.
```

**Dartdoc.** Every public class, member, constant, and function gets dartdoc.
House format: one-line summary; blank line; `Parameters:` bulleted list using
`[param]` references; `Throws:` bulleted list naming exception types; alphabets
shown in triple-backtick blocks; specs cited with reference-style markdown links
to the RFC/Wikipedia/spec page. Copy the style of `lib/src/base32.dart` and
`lib/src/codecs/base32.dart` verbatim.

**Hot-loop style.** Conversion inner loops declare `int` locals up front
(`int a, b, i, j, n, p, x;`), use bitwise ops and `>>>`, preallocate `Uint8List`
of the exact output size, and avoid lazy `Iterable` chains, closures, and
`sync*` generators (`sync*` was purged in 2.4.1 for performance — do not
reintroduce). One-line wrappers get `@pragma('vm:prefer-inline')`. Public
converters accept `List<int>` (not `Iterable<int>`, per the 2.6.0 breaking
change) and return `Uint8List` where the output is bytes.

**Alphabet tables** are generated, never typed. Edit the relevant section of
`tool/alphabet_maker.dart` (`fwd()` for forward, `rev()` for reverse — `rev`
accepts multiple alphabets to build case-insensitive tables), run it, paste the
output. Keep the trailing `//` after the first row so `dart format` preserves
the table layout.

**Tests.** One file per codec: `test/<name>_test.dart`, plus `test/core/` and
`test/crypt/` for those areas. Every codec test file contains these groups:

1. _parameter overrides_ — `codec:` beats the bool flags;
2. _encoding <-> decoding_ — random roundtrips at every length 0..99, per variant;
3. _encoding_ known-answer vectors (RFC test vectors: `""`, `f`, `fo`, `foo`, …);
4. _decoding_ known-answer vectors, including lowercase/alternate-case inputs;
5. _invalid input_ — bad chars and bad lengths each `throwsFormatException`;
6. _differential_ — same input through a reference implementation
   (`dart:convert`, `package:base_codecs`, `package:base32`) must match ours.

**Commits.** Imperative sentence, capitalized, no conventional-commit prefixes,
backticks around identifiers: `Add constructor to ByteCollector abstract class`,
`Introduce \`ByteCollector\` abstract class`. One logical change per commit.

**Pull requests.** Do not append the "Generated with Claude Code" footer, or any
other bot attribution, to PR bodies.

**CHANGELOG.md.** Newest first, `# X.Y.Z` heading, `-` bullets. Breaking changes
lead with `**Breaking Changes**:` and list renames as `` `old` -> `new` ``.
Every released version has an entry; the top entry is extracted verbatim into
the GitHub release notes by CI.

**Put unreleased changes under a `_next_` heading.** Add a `# _next_` heading
at the top of the CHANGELOG (if one isn't there already) and list your changes
under it. The owner renames `_next_` to the real `X.Y.Z` and bumps `pubspec.yaml`
at release time. Never edit a concrete `# X.Y.Z` section below it — those are
frozen release history.

**Releases.** One commit contains the CHANGELOG entry + `pubspec.yaml` version
bump (+ the change itself if small). Tag that commit `vX.Y.Z` and push commit
and tag. CI: verifies tag == pubspec version → full release-test matrix
(stable/2.19/beta × 3 OS × vm/node + pana) → `dart pub publish` → GitHub
release. After a release, bump the dependency in `~/projects/hashlib`
(`convertlib: ^X.Y.Z`) as its own commit there. Use the `release` skill.

**Conventions added by this manual** (owner may veto; follow until then):

- _(new)_ **No roundtrip-only test groups.** Every codec variant needs at least
  one known-answer vector or a differential check. Reason: three real bugs
  survived a roundtrip-only suite (see failure modes 1–4).
- _(new)_ Every alphabet-based codec instance gets a test asserting the **full
  alphabet string** it produces, character by character, against the string
  documented in README.md (encode each of the 32/64 values once).
- _(new)_ Fuzz helpers for domains wider than a byte must not use `Uint8List`
  storage (see failure mode #2).
- _(new)_ When a change touches public API surface, update `example/` and
  `test_integration/main.dart` in the same commit if the new API belongs in the
  showcase — the integration job is the smoke test of the public surface.

## Failure modes — named, with the rule that prevents each

These are the specific ways models (and humans) have gotten or will get this
codebase wrong. Read this list before writing code, not after.

1. **The roundtrip mirage.** `decode(encode(x)) == x` passes even when both
   sides share the same bug. This is not hypothetical: the `wordSafe` base32
   tables were copy-pasted z-base-32 tables, and the UTF-8 2-byte decoder
   dropped a mask — both sailed through 366 green tests for years because the
   tests only round-tripped (found and fixed 2026-07; the regression tests live
   in `test/differential_test.dart`). **Rule: a test proves correctness only if
   the expected value comes from outside the code under test** — an RFC vector,
   `dart:convert`, or a reference package.
2. **The truncating fuzz helper.** `test/utils.dart` `randomNumbers()` used to
   store into a `Uint8List`, silently clipping every value to 0–255 — the UTF-8
   fuzz test asked for code points up to 0x10FFFF and actually got bytes
   (fixed 2026-07; use `randomCodePoints()` for code-point inputs). **Rule:
   when generating test inputs wider than 8 bits, build a plain `List<int>`;
   when reviewing a fuzz test, check the generator's element type first.**
3. **The hand-typed alphabet.** 32–128 entry integer tables cannot be reviewed
   by eye; the `wordSafe` bug was a paste error in exactly such a table. **Rule:
   never hand-write or hand-edit an alphabet table. Generate it with
   `tool/alphabet_maker.dart` and add the alphabet-string assertion test.**
4. **The missing mask.** Hand-rolled bit surgery fails on inputs where flag
   bits and payload bits disagree (`fromUtf8(toUtf8('Ā'))` returned `'ƀ'`
   because a continuation byte was OR-ed in without `& 0x3F`; U+00A9 masked the
   bug, U+0100 exposed it — fixed 2026-07). **Rule: for every bit-manipulation
   path, test both boundary values of every range AND at least one value whose
   payload bits are zero where a flag bit is one** (e.g. 0x80, 0x100, 0x800,
   0x10000 — not just é and emoji).
5. **The Dart-3 reflex.** Modern Dart syntax compiles fine on your local 3.x SDK
   and dies on the CI 2.19 matrix 20 minutes later. **Rule: before using any
   language feature you didn't see elsewhere in this repo, confirm it existed in
   Dart 2.19.**
6. **The dependency reflex.** Reaching for `package:convert` or similar to "save
   time". **Rule: the `dependencies:` section stays empty. Implement it in
   `lib/src/core/` instead, or don't.**
7. **The export hole.** Creating `lib/src/foo.dart` and forgetting
   `lib/src/codecs_base.dart`, shipping a package where the new API is
   invisible. **Rule: every new public file gets an alphabetically-placed export
   line in `codecs_base.dart` in the same commit, verified by importing it in a
   test via `package:convertlib/convertlib.dart` (not via a deep
   `src/` import).**
8. **The info-level fail.** Local `dart analyze` looks clean but CI runs
   `--fatal-infos`, and pana requires dartdoc on public API. **Rule: run
   `dart analyze --fatal-infos` (exact flag) and `dart format .` before every
   commit; document every new public symbol.**
9. **The tag/pubspec mismatch.** Tag `v3.1.1` exists but was never published:
   the release job hard-fails unless the tag exactly equals `pubspec.yaml`'s
   `version:`; the fix shipped as 3.1.2. **Rule: version bump, CHANGELOG
   heading, and tag are one atomic unit; check all three match before pushing,
   and never move or reuse a tag.**
10. **The web-int assumption.** Code passes `-p vm`, breaks on node where ints
    are doubles (53-bit mantissa, different shift semantics). **Rule: run plain
    `dart test` (which includes node) before declaring tests green; anything
    genuinely VM-only gets `@Tags(['vm-only'])`.**
11. **The silent behavior fix.** "This output is wrong per the RFC, I'll fix
    it" — and every stored hash string downstream breaks. **Rule: an observable
    output change to a shipped codec is a breaking change even when it's a
    correctness fix. Write the failing test, report, and wait for the owner's
    semver decision.**
12. **The doc polarity drift.** Dartdoc gets copy-pasted between `to<X>`/
    `from<X>` and between codecs; **Rule: after copying any dartdoc block,
    re-read every `Parameters:` line against the actual code path; never propagate
    a description you haven't checked.**

## Quality bar per deliverable

Adjectives don't count; these checklists do. "Done" means every box checks.

**Any change (minimum bar):**

- [ ] `dart format --output=none --set-exit-if-changed .` exits 0
- [ ] `dart analyze --fatal-infos` reports "No issues found!"
- [ ] `dart test` passes — vm **and** node
- [ ] `cd test_integration && dart run main.dart` still runs without error
- [ ] No new entries under `dependencies:`; no SDK floor change
- [ ] Copyright header present on any new `lib/` file

**Bug fix:**

- [ ] A regression test exists that fails on the pre-fix code and passes after
      (state this explicitly, with the failing value as the test name/vector)
- [ ] The expected value in that test comes from an external source (RFC,
      `dart:convert`, reference package) — cite which in a comment or the test name
- [ ] If observable output changed: owner approved it, CHANGELOG entry written,
      version bump matches impact (behavior change → at least minor, usually major)
- [ ] Sibling code with the same pattern was checked for the same bug
      (e.g. a mask bug in the 2-byte path → inspect 3- and 4-byte paths too)

**New codec or new alphabet:**

- [ ] Tables generated by `tool/alphabet_maker.dart` (script section committed/updated)
- [ ] Codec class: private ctor, `static const` instances, dartdoc with alphabet
      block + spec link on every instance
- [ ] Top-level `to<Name>`/`from<Name>` in `lib/src/<name>.dart` with `codec:` override
- [ ] Export added to `codecs_base.dart` (alphabetical)
- [ ] Test file with all six standard groups (see House conventions), including
      a differential group against a named reference implementation and the
      alphabet-string assertion
- [ ] README.md feature section: class/methods table + alphabet list
- [ ] CHANGELOG.md entry; `example/` and `test_integration/main.dart` updated
- [ ] Coverage of the new files is ~100% lines (`bash scripts/coverage.sh`)

**Performance change:**

- [ ] Benchmark in `benchmark/` run before and after; both numbers reported in
      the commit message or summary — a perf change without numbers is a no
- [ ] Differential tests prove output is byte-identical to before
- [ ] No `sync*`, no allocation added inside the hot loop

**Docs/README change:**

- [ ] Every alphabet string in README matches what the code emits (spot-check by
      encoding, don't trust the old table)
- [ ] Links resolve; tables render; `dart format` untouched files stay untouched

**Release:** use the `release` skill; its checklist is the bar.

## When uncertain — exact escalation rules

**Proceed without asking** (reversible, inside the contract): adding tests,
docs, benchmarks; internal refactors with identical public API and
byte-identical output; new codecs/alphabets/methods (additive, minor);
tooling and script changes; fixing this manual.

**Never `git commit` or `git push` on your own initiative.** Run either only
when the owner's _current_ message explicitly asks for it — a request or
approval in an earlier message does not carry forward, and "finish the task"
does not imply "commit it". Otherwise leave the working tree ready and report
what a commit would contain (proposed message included).

**Stop and ask the owner first** (blocking; one message, options + your
recommendation):

1. Any change to the **observable output** of an existing codec — including
   correctness fixes (present the failing external vector when asking).
2. Any **removal or rename** of a public symbol.
3. Adding **any** dependency, changing the **SDK floor**, or changing the CI
   **matrix/thresholds**.
4. **Choosing a version number** and anything involving `git tag`, `git push`
   of a release, or publishing.
5. Editing an already-released CHANGELOG section, or anything requiring
   force-push or tag deletion — these you don't even propose; flag and stop.

**Resolving behavioral uncertainty** — exhaust in this order before asking:

1. The spec linked in the dartdoc of the code you're touching (RFC 4648, 3629,
   PHC spec, Wikipedia article — the links are the source of truth).
2. `dart:convert`'s implementation of the same conversion.
3. The reference packages in dev_dependencies (`base_codecs`, `base32`).
4. Existing known-answer tests and `CHANGELOG.md` history (behavior changes are
   documented there — e.g. Base-8 semantics changed deliberately in 2.6.0).
5. Only then ask — with a minimal repro: input bytes, our output, the reference
   output, one sentence per candidate behavior.

If a task requires violating a Hard Invariant, the task is wrong, not the
invariant: stop and say so.
