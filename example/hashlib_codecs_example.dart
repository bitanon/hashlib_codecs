import 'package:hashlib_codecs/hashlib_codecs.dart';

void main() {
  var input = [0x3, 0xF1];
  print("input => $input");
  print('');

  print("binary => ${toBinary(input)}");
  print("binary (no padding) => ${toBinary(input, padding: false)}");
  print('');

  print("hexadecimal => ${toHex(input)}");
  print("hexadecimal (uppercase) => ${toHex(input, upper: true)}");
  print("hexadecimal (no padding) => ${toHex(input, padding: false)}");
  print('');

  print("base32 => ${toBase32(input)}");
  print("base32 (lowercase) => ${toBase32(input, upper: false)}");
  print("base32 (no padding) => ${toBase32(input, padding: false)}");
  print('');

  print("base64 => ${toBase64(input)}");
  print("base64 (no padding) => ${toBase64(input, padding: false)}");
  print('');

  print("base64url => ${toBase64Url(input)}");
  print("base64url (no padding) => ${toBase64Url(input, padding: false)}");
  print('');
}
