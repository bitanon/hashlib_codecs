import 'package:hashlib_codecs/hashlib_codecs.dart';

void main() {
  var input = [0x3, 0xF1];
  print("input => $input");
  print('');

  print("binary => ${toBinary(input)}");
  print('');

  print("octal => ${toOctal(input)}");
  print('');

  print("hexadecimal => ${toHex(input)}");
  print("hexadecimal (uppercase) => ${toHex(input, upper: true)}");
  print('');

  print("base32 => ${toBase32(input)}");
  print("base32 (no padding) => ${toBase32(input, padding: false)}");
  print("base32 (lowercase) => ${toBase32(
    input,
    alphabet: Base32Alphabet.lower,
  )}");
  print('');

  print("base64 => ${toBase64(input)}");
  print("base64 (no padding) => ${toBase64(input, padding: false)}");
  print("base64url => ${toBase64(
    input,
    alphabet: Base64Alphabet.urlSafe,
  )}");
  print('');
}
