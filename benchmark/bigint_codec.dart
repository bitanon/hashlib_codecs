import 'package:benchmark_harness/benchmark_harness.dart';
import 'package:hashlib_codecs/hashlib_codecs.dart';

class BigIntDecodeBenchmark extends BenchmarkBase {
  final int size = 10000;
  BigInt input = BigInt.zero;

  BigIntDecodeBenchmark(String name) : super(name);

  @override
  void setup() {
    super.setup();
    var hex = List.generate(
      size,
      (i) => (0xFF - (i & 0xFF)).toRadixString(16).padLeft(2, '0'),
    ).join();
    input = BigInt.parse(hex, radix: 16);
  }

  @override
  void run() {
    fromBigInt(input);
  }
}

void main() {
  var time = BigIntDecodeBenchmark("modulus").measure();
  print('modulus runtime: ${time.floor() / 1000} ms');
}
