import 'package:hashlib_codecs/hashlib_codecs.dart';

void main() {
  var input = [0x3, 0xF1];
  print("input => $input");
  var encoded = toBigInt(input).toRadixString(10);
  print("to decimal => $encoded");
  var decoded = fromBigInt(BigInt.parse(encoded, radix: 10));
  print("from decimal => $decoded");
}
