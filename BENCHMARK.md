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
    <td><code>████████████████</code> <br> <small><b>1.78 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>2.11 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.99 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>Base-8</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.44 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>5.01 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.34 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-16</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.99 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>5.44 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.38 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>285 Mbps &#128315;17.5x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>246 Mbps &#128315;22.09x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>248 Mbps &#128315;17.67x</small></td>
  </tr>
  <tr>
    <td rowspan="3">Base-32</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>5.45 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>5.95 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.46 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>571 Mbps &#128315;9.54x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>417 Mbps &#128315;14.27x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>384 Mbps &#128315;11.63x</small></td>
  </tr>
  <tr>
    <td>base32</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>622 Kbps &#128315;8760.49x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>131 Mbps &#128315;45.34x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>137 Mbps &#128315;32.67x</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-64</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>6.1 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>6.49 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>5.33 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>███████████████░</code> <br> <small>5.64 Gbps &#128315;1.08x</small></td>
    <td><code>███████████████░</code> <br> <small>5.99 Gbps &#128315;1.08x</small></td>
    <td><code>█████████████░░░</code> <br> <small>4.32 Gbps &#128315;1.23x</small></td>
  </tr>
  <tr>
    <td rowspan="2">UTF-8</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>3.14 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.37 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>2.72 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>█████████████░░░</code> <br> <small>2.55 Gbps &#128315;1.23x</small></td>
    <td><code>█████████████░░░</code> <br> <small>2.67 Gbps &#128315;1.26x</small></td>
    <td><code>█████████████░░░</code> <br> <small>2.22 Gbps &#128315;1.23x</small></td>
  </tr>
</tbody>
</table>

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
    <td><code>████████████████</code> <br> <small><b>1.73 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.72 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.62 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>Base-8</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.1 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.17 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.66 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-16</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>3.54 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.65 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.2 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>446 Mbps &#128315;7.94x</small></td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>449 Mbps &#128315;8.12x</small></td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>438 Mbps &#128315;7.3x</small></td>
  </tr>
  <tr>
    <td rowspan="3">Base-32</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>3.47 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.95 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.12 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>285 Mbps &#128315;12.19x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>287 Mbps &#128315;13.76x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>258 Mbps &#128315;12.13x</small></td>
  </tr>
  <tr>
    <td>base32</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>177 Mbps &#128315;19.61x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>191 Mbps &#128315;20.67x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>152 Mbps &#128315;20.52x</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-64</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.92 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.95 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.87 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>████████████░░░░</code> <br> <small>3.55 Gbps &#128315;1.39x</small></td>
    <td><code>███████████░░░░░</code> <br> <small>3.47 Gbps &#128315;1.43x</small></td>
    <td><code>████████████░░░░</code> <br> <small>2.99 Gbps &#128315;1.29x</small></td>
  </tr>
  <tr>
    <td rowspan="2">UTF-8</td>
    <td>convertlib</td>
    <td><code>███████████████░</code> <br> <small>1.64 Gbps </small></td>
    <td><code>███████████████░</code> <br> <small>1.69 Gbps </small></td>
    <td><code>████████████░░░░</code> <br> <small>1.29 Gbps </small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>████████████████</code> <br> <small><b>1.75 Gbps</b> &#128314;1.07x</small></td>
    <td><code>████████████████</code> <br> <small><b>1.84 Gbps</b> &#128314;1.09x</small></td>
    <td><code>████████████████</code> <br> <small><b>1.73 Gbps</b> &#128314;1.34x</small></td>
  </tr>
</tbody>
</table>

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
    <td><code>████████████████</code> <br> <small><b>117 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>113 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>97.33 Mbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>BigInt → bytes</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>208 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>201 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>168 Mbps</b> &#127775;</small></td>
  </tr>
</tbody>
</table>

> All benchmarks are done on 36GB _Apple M3 Pro_ using compiled _exe_
>
> Dart SDK version: 3.12.2 (stable) (Tue Jun 9 01:11:39 2026 -0700) on "macos_arm64"
