import 'dart:math';

import 'package:benchmark_harness/benchmark_harness.dart';

class BigIntParsingBenchmark extends BenchmarkBase {
  final int size = 10000;
  final int radix;
  String input = "0";

  BigIntParsingBenchmark(this.radix) : super('Parse[radix: $radix]');

  @override
  void setup() {
    super.setup();
    int pad = (8 * ln2 / log(radix)).ceil();
    input = List.generate(
      size,
      (i) => (0xFF - (i & 0xFF))
          .toUnsigned(256)
          .toRadixString(radix)
          .padLeft(pad, '0'),
    ).join();
  }

  @override
  void run() {
    BigInt.parse(input, radix: radix);
  }
}

void main() {
  int best = 0;
  double score = 0;
  for (int i = 2; i < 36; i++) {
    var time = BigIntParsingBenchmark(i).measure();
    print('Radix $i, runtime: ${time.floor() / 1000} ms');
    if (score == 0 || time < score) {
      best = i;
      score = time;
    }
  }
  print('---------');
  print('Best radix: $best with runtime: ${score.floor() / 1000} ms');
}
