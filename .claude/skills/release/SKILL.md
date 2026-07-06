---
name: release
description: Cut a hashlib_codecs release end to end - version choice, CHANGELOG, pubspec bump, atomic release commit, vX.Y.Z tag, push, CI watch, pub.dev verification, and the follow-up dependency bump in ~/projects/hashlib. Use when asked to release, publish, ship, cut a version, or tag. Prevents the tag/pubspec-mismatch failure that killed v3.1.1.
---

# Release — tag-driven publish to pub.dev

Releases here are fully automated from a tag push: the `Release` workflow
verifies `tag == pubspec version`, runs the big matrix (stable/2.19/beta × 3 OS
× vm/node), runs pana at a perfect-score threshold, publishes via OIDC, and
creates a GitHub release from the **top CHANGELOG section**. Your job is to make
the tag, the pubspec, and the CHANGELOG agree, and to never push a tag that
CI will reject. **Never run `dart pub publish` locally** (only `--dry-run`).

## Hard rules

- Version number choice is the **owner's call**. Propose one with reasoning
  (see step 2) and get explicit confirmation before creating the tag.
- Tag, `pubspec.yaml` `version:`, and the top `# X.Y.Z` CHANGELOG heading must
  be **identical** and on the **same commit**. v3.1.1 was tagged with a
  mismatched state, never published, and had to be re-released as 3.1.2.
- Never move, reuse, or delete a tag. A botched release gets a new patch
  version, not a re-tag.
- Do not release with uncommitted changes or from any branch but `master`.

## Steps

1. **Preflight.** Run the `preflight` skill including the release-only steps
   (`dart pub publish --dry-run` and pana). All gates green before proceeding.

2. **Determine the version.** List what shipped since the last tag:
   ```sh
   git describe --tags --abbrev=0        # last release
   git log --oneline $(git describe --tags --abbrev=0)..HEAD
   git diff $(git describe --tags --abbrev=0)..HEAD --stat -- lib/
   ```
   Semver mapping for this package:
   - removed/renamed public symbol, changed output of an existing codec,
     SDK floor change → **major**
   - new codec, new alphabet, new public method/class/parameter → **minor**
   - bug fix with no observable-output change, docs, perf → **patch**

   Propose the number to the owner with a one-line justification. **Wait for
   confirmation.**

3. **Write the CHANGELOG entry.** New `# X.Y.Z` section at the very top of
   `CHANGELOG.md`, matching house style: `-` bullets, backticks around
   identifiers, breaking changes led by `**Breaking Changes**:` with
   `` `old` -> `new` `` rename lists. This text becomes the GitHub release notes
   verbatim (CI extracts the top section), so write it for readers, not for git.

4. **Bump `pubspec.yaml`** `version:` to the same X.Y.Z.

5. **Release commit + tag** (one atomic unit):
   ```sh
   git add CHANGELOG.md pubspec.yaml
   git commit -m "Version X.Y.Z"
   git tag vX.Y.Z
   ```
   Before pushing, verify all three agree:
   ```sh
   grep '^version:' pubspec.yaml && head -1 CHANGELOG.md && git tag --points-at HEAD
   ```

6. **Push — after owner confirmation** that they want it live now:
   ```sh
   git push origin master vX.Y.Z
   ```

7. **Watch CI to completion.** The publish is not done until the workflow is:
   ```sh
   gh run list --workflow=release.yml --limit 1
   gh run watch <run-id> --exit-status
   ```
   If the release workflow fails **before** the publish job, fix the problem on
   master and release as a new patch version (do not re-tag). If it fails
   **after** publish succeeded (e.g. the changelog job), the release is live;
   fix quietly and note it.

8. **Verify on pub.dev:**
   ```sh
   curl -s https://pub.dev/api/packages/hashlib_codecs | python3 -c 'import json,sys; print(json.load(sys.stdin)["latest"]["version"])'
   ```

9. **Bump the dependent.** In `~/projects/hashlib`:
   - `pubspec.yaml`: `hashlib_codecs: ^X.Y.Z`
   - bump hashlib's own patch version in the same edit, add its CHANGELOG entry
   - commit in hashlib's style, e.g.
     `Bump version to A.B.C and update hashlib_codecs dependency to X.Y.Z`
   - run `dart pub get && dart test -p vm` there before committing; push only
     with the owner's go-ahead (hashlib has its own release cadence).

## Report

End with: released version, workflow run URL/status, pub.dev latest version,
and the hashlib bump commit (or the reason it was skipped).
