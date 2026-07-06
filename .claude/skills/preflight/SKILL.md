---
name: preflight
description: Run the exact checks hashlib_codecs CI runs, locally, before any commit or release. Use before committing, when asked "is this ready", "run the checks", or as the first step of a release. Catches format drift, analyzer infos, vm/node test failures, and integration breakage without waiting 20 minutes for the GitHub Actions matrix.
---

# Preflight — mirror CI locally

CI for this repo is strict in ways local habits miss: format must produce zero
diffs, `analyze` runs with `--fatal-infos`, tests run on **node as well as vm**,
and an integration script exercises the public API from a consumer's point of
view. Run all of it locally, in the same order as CI, and report one table.

## Steps

Run from the repo root. Do not stop at the first failure — collect all results,
then fix, then re-run until everything passes.

1. **Dependencies** (skip if `.dart_tool/package_config.json` is fresh):
   ```sh
   dart pub get
   ```

2. **Format gate** (CI: `dart format --output=none --set-exit-if-changed .`):
   ```sh
   dart format --output=none --set-exit-if-changed .
   ```
   On failure, run `dart format .` and inspect the diff — if formatting mangled
   an alphabet table, add a trailing `//` after the first row to pin the layout,
   then re-format.

3. **Analyzer gate** (the flag matters — infos are fatal in CI):
   ```sh
   dart analyze --fatal-infos
   ```

4. **Unit tests, both platforms** (plain `dart test` runs vm AND node per
   `dart_test.yaml`; node is available via nvm):
   ```sh
   dart test
   ```
   If node fails where vm passed, suspect JS int semantics (53-bit ints, shift
   behavior). Either fix the code or, if genuinely VM-only, tag the test
   `@Tags(['vm-only'])`.

5. **Integration smoke test** (CI job `integration` — runs the example program
   against the local package):
   ```sh
   cd test_integration && dart pub get && dart run main.dart && cd ..
   ```
   It must exit 0. Also eyeball the output: it prints every codec's result, so
   a wrong-looking line here is a real finding even with exit code 0.

6. **Publish dry-run + pana — only when preparing a release** (release CI runs
   `pana --exit-code-threshold 0`, i.e. a perfect score is required):
   ```sh
   dart pub publish --dry-run
   dart pub global activate pana && pana --exit-code-threshold 0
   ```

7. **Coverage — only when the task touched `lib/`** and you need to prove new
   lines are covered:
   ```sh
   bash scripts/globals.sh    # one-time activation of tools
   bash scripts/coverage.sh   # writes coverage/lcov.info + cobertura.xml
   ```
   New/changed files should be at ~100% line coverage; the codecov gate fails
   CI on upload errors and the owner tracks the badge.

## Report format

End with a single table, one row per gate, PASS/FAIL plus a one-line detail for
failures. If anything failed and you fixed it, say what you changed and show
the final all-green run. Never report "tests pass" from a `-p vm`-only run —
that is not what CI runs.

| Gate | Command | Result |
|---|---|---|
| format | `dart format --set-exit-if-changed` | PASS |
| analyze | `dart analyze --fatal-infos` | PASS |
| test (vm+node) | `dart test` | PASS (366) |
| integration | `test_integration/main.dart` | PASS |
| pana (release only) | `pana --exit-code-threshold 0` | — |
