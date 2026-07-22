import 'package:convertlib/convertlib.dart';

void main() {
  // A Base-64 body wrapped across lines the way PEM/MIME fold it.
  const wrapped = 'SGVsbG8sIHdv\n'
      'cmxkISBGcm9t\n'
      'IGNvbnZlcnRs\n'
      'aWIu\n';

  print(fromUtf8(fromBase64(wrapped, ignoreWhitespace: true)));

  // Strict decoding (the default) still rejects the whitespace.
  print(tryFromBase64(wrapped)); // null
  print(tryFromBase64(wrapped, ignoreWhitespace: true) != null); // true
}
