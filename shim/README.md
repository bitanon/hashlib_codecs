# hashlib_codecs → convertlib

> **This package has been renamed to [`convertlib`](https://pub.dev/packages/convertlib).**

`hashlib_codecs` is now a thin compatibility shim that re-exports `convertlib`
with no API changes. Existing code continues to work, but new code should
depend on `convertlib` directly. This package will be discontinued after a
migration period.

## Migrating

Replace the dependency in your `pubspec.yaml`:

```yaml
dependencies:
  convertlib: ^3.5.0
```

And update your imports:

```dart
import 'package:convertlib/convertlib.dart';
```

The public API is identical — no other changes are required.

See the [convertlib repository](https://github.com/bitanon/convertlib) for
documentation and source.
