import 'package:hashlib_codecs/hashlib_codecs.dart';

void main() {
  var inp = [0x3, 0xF1];
  print("input => $inp");
  print('');

  print("binary => ${toBinary(inp)}");
  print('');

  print("octal => ${toOctal(inp)}");
  print('');

  print("hexadecimal => ${toHex(inp)}");
  print("hexadecimal (uppercase) => ${toHex(inp, upper: true)}");
  print('');

  print("base32 => ${toBase32(inp)}");
  print("base32 (lowercase) => ${toBase32(inp, lower: true)}");
  print("base32 (no padding) => ${toBase32(inp, padding: false)}");
  print("base32 (hex) => ${toBase32(inp, codec: Base32Codec.hex)}");
  print("base32 (z-base-32) => ${toBase32(inp, codec: Base32Codec.z)}");
  print("base32 (geohash) => ${toBase32(inp, codec: Base32Codec.geohash)}");
  print("base32 (crockford) => ${toBase32(inp, codec: Base32Codec.crockford)}");
  print("base32 (word-safe) => ${toBase32(inp, codec: Base32Codec.wordSafe)}");
  print('');

  print("base64 => ${toBase64(inp)}");
  print("base64url => ${toBase64(inp, url: true)}");
  print("base64 (no padding) => ${toBase64(inp, padding: false)}");
  print("bcrypt => ${toBase64(inp, codec: Base64Codec.bcrypt)}");
  print('');
}
