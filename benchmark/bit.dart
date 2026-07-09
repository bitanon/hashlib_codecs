// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'package:convertlib/convertlib.dart';

import '_base.dart';

// Benchmarks the generic `BitEncoder`/`BitDecoder` engine from
// `lib/src/core/bit.dart`. These abstract classes are the reference
// bit-regrouping implementation; every shipped codec overrides `convert` with a
// specialized loop, so nothing on the production hot path actually reaches them.
// This file measures the bare engine directly at the widths the base codecs use
// (8 -> 6/5/4 for encode, 6/5/4 -> 8 for decode), then contrasts it with the
// specialized Base-64 path for scale. Note the diff is not apples-to-apples: the
// alphabet/Base-64 paths additionally do a table lookup and padding that the raw
// engine does not, so treat that section as "engine vs. full codec", not a race.

/// A concrete [BitEncoder] over an arbitrary [source] -> [target] width pair.
class _BitEncoder extends BitEncoder {
  @override
  final int source;
  @override
  final int target;
  const _BitEncoder(this.source, this.target);
}

/// A concrete [BitDecoder] over an arbitrary [source] -> [target] width pair.
class _BitDecoder extends BitDecoder {
  @override
  final int source;
  @override
  final int target;
  const _BitDecoder(this.source, this.target);
}

Uint8List _sample(int size) => Uint8List.fromList(List.filled(size, 0x5a));

class BitEncode extends SyncBenchmark {
  final int target;
  final Uint8List input;
  late final _BitEncoder enc = _BitEncoder(8, target);

  BitEncode(int size, this.target)
      : input = _sample(size),
        super('BitEncoder(8->$target)', size);

  @override
  dynamic run() {
    return enc.convert(input);
  }
}

class BitDecode extends SyncBenchmark {
  final int source;
  final int _size;
  late final _BitDecoder dec = _BitDecoder(source, 8);
  Uint8List encoded = Uint8List(0);

  BitDecode(int size, this.source)
      : _size = size,
        super('BitDecoder($source->8)', size);

  @override
  void setup() {
    // Repack the sample into `source`-bit words to get a valid decode input.
    encoded =
        Uint8List.fromList(_BitEncoder(8, source).convert(_sample(_size)));
  }

  @override
  dynamic run() {
    return dec.convert(encoded);
  }
}

// ---- Reference: the specialized Base-64 path over the same 8 <-> 6 work ----

final _b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    .codeUnits;

class SpecializedBase64Encode extends SyncBenchmark {
  final Uint8List input;

  SpecializedBase64Encode(int size)
      : input = _sample(size),
        super('Base64Encoder', size);

  @override
  dynamic run() {
    return Base64Codec.standard.encoder.convert(input);
  }
}

class GenericAlphabetEncode extends SyncBenchmark {
  final Uint8List input;
  final AlphabetEncoder enc = AlphabetEncoder(bits: 6, alphabet: _b64);

  GenericAlphabetEncode(int size)
      : input = _sample(size),
        super('AlphabetEncoder(6)', size);

  @override
  dynamic run() {
    return enc.convert(input);
  }
}

void main() async {
  print('--------- BitEncoder (raw regroup engine) ----------');
  for (var size in [1 << 20, 1 << 10, 1 << 5]) {
    print('---- encode: ${formatSize(size)} ----');
    await BitEncode(size, 6).measureRate();
    await BitEncode(size, 5).measureRate();
    await BitEncode(size, 4).measureRate();
    print('---- decode: ${formatSize(size)} ----');
    await BitDecode(size, 6).measureRate();
    await BitDecode(size, 5).measureRate();
    await BitDecode(size, 4).measureRate();
    print('');
  }

  print('--------- BitEncoder(8->6) vs specialized paths ----------');
  print('(engine does no table lookup or padding; not a like-for-like race)');
  for (var size in [1 << 20, 1 << 10, 1 << 5]) {
    print('---- encode: ${formatSize(size)} ----');
    await BitEncode(size, 6).measureDiff([
      GenericAlphabetEncode(size),
      SpecializedBase64Encode(size),
    ]);
    print('');
  }
}
