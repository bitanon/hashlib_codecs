import 'package:convertlib/convertlib.dart';

void main() {
  final data = toUtf8('a >> b, c/d');

  print('standard    : ${toBase64(data)}');
  print('url-safe    : ${toBase64(data, url: true)}');
  print('no padding  : ${toBase64(data, url: true, padding: false)}');
  print('bcrypt      : ${toBase64(data, codec: Base64Codec.bcrypt)}');

  // Decode back to the original bytes
  final back = fromBase64(toBase64(data, url: true));
  print('roundtrip   : ${fromUtf8(back)}');

  // Line-wrapped input (PEM/MIME style) decodes with ignoreWhitespace
  const pem = 'YSA+\nPiBi\nLCBj\nL2Q=\n';
  final body = fromBase64(pem, ignoreWhitespace: true);
  print('pem body    : ${fromUtf8(body)}');
}
