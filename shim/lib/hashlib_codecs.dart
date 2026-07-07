// Copyright (c) 2023, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

/// Compatibility shim: this package has been renamed to `convertlib`.
///
/// This library re-exports `package:convertlib/convertlib.dart` unchanged, so
/// existing imports keep working without code changes. Please migrate to the
/// `convertlib` package; `hashlib_codecs` will be discontinued after a
/// migration period.
library;

export 'package:convertlib/convertlib.dart';
