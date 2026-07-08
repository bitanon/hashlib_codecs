// Copyright (c) 2026, Sudipto Chandra
// All rights reserved. Check LICENSE file for details.

import 'dart:typed_data';

import 'package:convertlib/convertlib.dart';

import '_base.dart';

// Benchmarks the generic `AlphabetEncoder`/`AlphabetDecoder` fallback engine
// (used by custom-alphabet codecs) against the hand-specialized Base-64 path,
// using the standard Base-64 alphabet for both so the comparison is apples to
// apples.

final _b64 = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    .codeUnits;
const _pad = 0x3d;

List<int> _decodeTable() {
  final table = List<int>.filled(256, -1);
  for (var i = 0; i < _b64.length; i++) {
    table[_b64[i]] = i;
  }
  return table;
}

Uint8List _sample(int size) => Uint8List.fromList(List.filled(size, 0x3f));

class GenericAlphabetEncode extends SyncBenchmark {
  final Uint8List input;
  final AlphabetEncoder enc =
      AlphabetEncoder(bits: 6, alphabet: _b64, padding: _pad);

  GenericAlphabetEncode(int size)
      : input = _sample(size),
        super('AlphabetEncoder', size);

  @override
  void run() {
    enc.convert(input);
  }
}

class SpecializedBase64Encode extends SyncBenchmark {
  final Uint8List input;

  SpecializedBase64Encode(int size)
      : input = _sample(size),
        super('Base64Encoder', size);

  @override
  void run() {
    Base64Codec.standard.encoder.convert(input);
  }
}

class GenericAlphabetDecode extends SyncBenchmark {
  final int _size;
  final AlphabetDecoder dec =
      AlphabetDecoder(bits: 6, alphabet: _decodeTable(), padding: _pad);
  Uint8List encoded = Uint8List(0);

  GenericAlphabetDecode(int size)
      : _size = size,
        super('AlphabetDecoder', size);

  @override
  void setup() {
    encoded = Base64Codec.standard.encoder.convert(_sample(_size));
  }

  @override
  void run() {
    dec.convert(encoded);
  }
}

class SpecializedBase64Decode extends SyncBenchmark {
  final int _size;
  Uint8List encoded = Uint8List(0);

  SpecializedBase64Decode(int size)
      : _size = size,
        super('Base64Decoder', size);

  @override
  void setup() {
    encoded = Base64Codec.standard.encoder.convert(_sample(_size));
  }

  @override
  void run() {
    Base64Codec.standard.decoder.convert(encoded);
  }
}

void main() async {
  print('--------- Generic Alphabet (base64 alphabet) ----------');
  for (var size in [1 << 20, 1 << 10, 1 << 5]) {
    print('---- encode: ${formatSize(size)} ----');
    await GenericAlphabetEncode(size).measureDiff([
      SpecializedBase64Encode(size),
    ]);
    print('---- decode: ${formatSize(size)} ----');
    await GenericAlphabetDecode(size).measureDiff([
      SpecializedBase64Decode(size),
    ]);
    print('');
  }
}
