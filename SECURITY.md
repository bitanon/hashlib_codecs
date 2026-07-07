# Security policy

## Supported versions

Security fixes are published in new releases on [pub.dev](https://pub.dev/packages/convertlib). We recommend using the latest release compatible with your Dart SDK. Older major or minor lines may not receive backports; ask in a report if you need a fix on a specific version line.

## Reporting a vulnerability

**Do not** open a public issue, pull request, or discussion for undisclosed security vulnerabilities. That can put users at risk before a fix is available. Use **Report a vulnerability** (private vulnerability reporting) in the [**Security** tab](https://github.com/bitanon/convertlib/security).

## What to include

Helpful information for triage and fixes:

- A short description of the issue and the affected component (e.g. a Base-32/64 codec, hex, BigInt conversion, UTF-8, PHC/Modular Crypt Format parsing, `ByteCollector`, API usage).
- The **affected version(s)** or commit, if known, and your environment (Dart SDK, platform) if relevant.
- **Steps to reproduce** or a minimal proof of concept, when it is safe to share.
- **Impact** (confidentiality, integrity, availability) and any suggested mitigation, if you have one.

## Our process

- We aim to **acknowledge** new reports within a few business days.
- We will work with you on **coordinated disclosure**: we prefer to fix the issue, ship a release, and only then publish an advisory, unless there is a strong reason to do otherwise.
- We may ask follow-up questions or for a re-test of a pre-release fix.

## Scope (in)

Reports we want to see include:

- Incorrect encode/decode behavior with a security impact, such as a decoder accepting malformed input as valid, or wrong-alphabet / masking errors that silently corrupt or confuse data.
- Memory-safety or denial-of-service issues when handling untrusted or malformed input — for example unbounded allocation, crashes, or pathological slowdowns while decoding a Base-N string, a BigInt, or a PHC/Modular Crypt Format string.
- Timing or side-channel weaknesses in the constant-time comparison helper (`ByteCollector.isEqual`) that could leak information about the bytes being compared.
- **Downstream integration**: convertlib is the base of the [`hashlib`](https://pub.dev/packages/hashlib) and [`cipherlib`](https://pub.dev/packages/cipherlib) packages. Issues in how those packages *consume* convertlib should be reported to that project; report it here if you believe the flaw is in convertlib itself.

## Scope (out of scope or lower priority)

- Theoretical issues without a plausible impact for this package’s use on supported platforms.
- Treating an encoding as if it were encryption. convertlib provides **codecs, not cryptography** — Base-64, hex, and the other encodings are reversible transformations and hide nothing; using them to protect secrets is a misuse, not a vulnerability.
- Vulnerabilities in your application that only misuse the public API (we may still document hardening, but the fix may be in your code).
- Automated tool output without a clear, reproducible security impact.

We appreciate responsible disclosure and will credit reporters in release notes or advisories when they wish to be named.
