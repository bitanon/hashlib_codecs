import 'package:convertlib/convertlib.dart';

void main() {
  final data = toUtf8('Hello, convertlib!');

  print('standard   : ${toBase32(data)}');
  print('lowercase  : ${toBase32(data, lower: true)}');
  print('no padding : ${toBase32(data, padding: false)}');
  print('base32hex  : ${toBase32(data, codec: Base32Codec.hex)}');
  print('crockford  : ${toBase32(data, codec: Base32Codec.crockford)}');
  print('z-base-32  : ${toBase32(data, codec: Base32Codec.z)}');
  print('geohash    : ${toBase32(data, codec: Base32Codec.geohash)}');
  print('word-safe  : ${toBase32(data, codec: Base32Codec.wordSafe)}');

  // Decoding is the exact inverse of encoding
  final back = fromBase32(toBase32(data));
  print('roundtrip  : ${fromUtf8(back)}');
}
