import 'package:convertlib/convertlib.dart';

void main() {
  // Build a PHC / Modular Crypt Format string from its parts.
  // `saltBytes` and `hashBytes` are Base-64 encoded (no padding) for you.
  final data = CryptData.builder('argon2id')
      .version('19')
      .param('m', 65536)
      .param('t', 3)
      .param('p', 4)
      .saltBytes(toUtf8('a-16-byte-salt!!'))
      .hashBytes(List.generate(32, (i) => i))
      .build();

  final encoded = toCrypt(data);
  print('encoded : $encoded');

  // Parse the string back into its structured fields.
  final parsed = fromCrypt(encoded);
  print('id      : ${parsed.id}');
  print('version : ${parsed.versionInt()}');
  print('m,t,p   : ${parsed.getIntParam('m')}, '
      '${parsed.getIntParam('t')}, ${parsed.getIntParam('p')}');
  print('salt    : ${fromUtf8(parsed.saltBytes()!)}');
  print('hash    : ${toHex(parsed.hashBytes()!)}');
}
