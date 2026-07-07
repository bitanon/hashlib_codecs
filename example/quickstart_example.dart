import 'package:convertlib/convertlib.dart';

void main() {
  final data = toUtf8('convertlib');

  // Encode the same bytes in a few common ways
  final hex = toHex(data);
  final b64 = toBase64(data);
  final b32 = toBase32(data);

  print('bytes  : $data');
  print('hex    : $hex');
  print('base64 : $b64');
  print('base32 : $b32');

  // Every encoder has an exact inverse
  print('decoded: ${fromUtf8(fromHex(hex))}');
  print('match  : ${fromUtf8(fromBase64(b64)) == 'convertlib'}');
}
