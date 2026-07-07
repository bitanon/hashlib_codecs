## Benchmarks

### Libraries

- **Convertlib** : https://pub.dev/packages/convertlib
- **Base Codecs** : https://pub.dev/packages/base_codecs
- **Base32** : https://pub.dev/packages/base32
- **Dart Convert** : https://api.dart.dev/stable/dart-convert/dart-convert-library.html

> UTF-8 throughput is measured per source code point, not per byte.

### Encoding

<table>
<thead>
  <tr>
    <th>Codec</th>
    <th>Library</th>
    <th>1MB message</th>
    <th>1KB message</th>
    <th>32B message</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>Base-2</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>1.74 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>2.05 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.88 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>Base-8</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.42 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.95 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.3 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-16</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.92 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>5.41 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.35 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>272 Mbps &#128315;18.09x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>223 Mbps &#128315;24.3x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>230 Mbps &#128315;18.92x</small></td>
  </tr>
  <tr>
    <td rowspan="3">Base-32</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>1.88 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>2.03 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.72 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>█████░░░░░░░░░░░</code> <br> <small>543 Mbps &#128315;3.46x</small></td>
    <td><code>███░░░░░░░░░░░░░</code> <br> <small>422 Mbps &#128315;4.81x</small></td>
    <td><code>████░░░░░░░░░░░░</code> <br> <small>381 Mbps &#128315;4.51x</small></td>
  </tr>
  <tr>
    <td>base32</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>636 Kbps &#128315;2961.62x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>129 Mbps &#128315;15.67x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>136 Mbps &#128315;12.68x</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-64</td>
    <td>convertlib</td>
    <td><code>███████░░░░░░░░░</code> <br> <small>2.27 Gbps </small></td>
    <td><code>██████░░░░░░░░░░</code> <br> <small>2.34 Gbps </small></td>
    <td><code>███████░░░░░░░░░</code> <br> <small>2 Gbps </small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>████████████████</code> <br> <small><b>5.51 Gbps</b> &#128314;2.43x</small></td>
    <td><code>████████████████</code> <br> <small><b>6.02 Gbps</b> &#128314;2.57x</small></td>
    <td><code>████████████████</code> <br> <small><b>4.33 Gbps</b> &#128314;2.17x</small></td>
  </tr>
  <tr>
    <td rowspan="2">UTF-8</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small>2.52 Gbps </small></td>
    <td><code>███████████████░</code> <br> <small>2.55 Gbps </small></td>
    <td><code>████████████████</code> <br> <small><b>2.18 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>████████████████</code> <br> <small><b>2.57 Gbps</b> &#128314;1.02x</small></td>
    <td><code>████████████████</code> <br> <small><b>2.69 Gbps</b> &#128314;1.06x</small></td>
    <td><code>███████████████░</code> <br> <small>2.09 Gbps &#128315;1.04x</small></td>
  </tr>
</tbody>
</table>

> This package comes on top 23 out of 33 times.

### Decoding

<table>
<thead>
  <tr>
    <th>Codec</th>
    <th>Library</th>
    <th>1MB message</th>
    <th>1KB message</th>
    <th>32B message</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>Base-2</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>1.71 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.72 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.64 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>Base-8</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.13 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.21 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.69 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-16</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>3.65 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.7 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.13 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>451 Mbps &#128315;8.08x</small></td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>458 Mbps &#128315;8.08x</small></td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>425 Mbps &#128315;7.38x</small></td>
  </tr>
  <tr>
    <td rowspan="3">Base-32</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>2.3 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>2.33 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.89 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>289 Mbps &#128315;7.96x</small></td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>292 Mbps &#128315;7.99x</small></td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>261 Mbps &#128315;7.24x</small></td>
  </tr>
  <tr>
    <td>base32</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>177 Mbps &#128315;12.99x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>195 Mbps &#128315;11.93x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>155 Mbps &#128315;12.18x</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-64</td>
    <td>convertlib</td>
    <td><code>████████████░░░░</code> <br> <small>2.63 Gbps </small></td>
    <td><code>████████████░░░░</code> <br> <small>2.7 Gbps </small></td>
    <td><code>████████████░░░░</code> <br> <small>2.17 Gbps </small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>████████████████</code> <br> <small><b>3.62 Gbps</b> &#128314;1.37x</small></td>
    <td><code>████████████████</code> <br> <small><b>3.63 Gbps</b> &#128314;1.34x</small></td>
    <td><code>████████████████</code> <br> <small><b>2.82 Gbps</b> &#128314;1.3x</small></td>
  </tr>
  <tr>
    <td rowspan="2">UTF-8</td>
    <td>convertlib</td>
    <td><code>█████░░░░░░░░░░░</code> <br> <small>507 Mbps </small></td>
    <td><code>███████░░░░░░░░░</code> <br> <small>811 Mbps </small></td>
    <td><code>██████░░░░░░░░░░</code> <br> <small>680 Mbps </small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>████████████████</code> <br> <small><b>1.74 Gbps</b> &#128314;3.43x</small></td>
    <td><code>████████████████</code> <br> <small><b>1.82 Gbps</b> &#128314;2.25x</small></td>
    <td><code>████████████████</code> <br> <small><b>1.72 Gbps</b> &#128314;2.53x</small></td>
  </tr>
</tbody>
</table>

> This package comes on top 21 out of 33 times.

### BigInt

<table>
<thead>
  <tr>
    <th>Codec</th>
    <th>Library</th>
    <th>4KB message</th>
    <th>256B message</th>
    <th>32B message</th>
  </tr>
</thead>
<tbody>
  <tr>
    <td>bytes → BigInt</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>118 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>115 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>97.66 Mbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>BigInt → bytes</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>208 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>199 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>169 Mbps</b> &#127775;</small></td>
  </tr>
</tbody>
</table>

> This package comes on top 6 out of 6 times.

> All benchmarks are done on 36GB _Apple M3 Pro_ using compiled _exe_
>
> Dart SDK version: 3.12.2 (stable) (Tue Jun 9 01:11:39 2026 -0700) on "macos_arm64"
