## 🚀 Benchmarks

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
    <td><code>████████████████</code> <br> <small><b>1.86 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>2.11 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.94 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>Base-8</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.48 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>5.06 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.4 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-16</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.98 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>5.59 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.51 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>284 Mbps &#128315;17.55x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>247 Mbps &#128315;22.59x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>247 Mbps &#128315;18.24x</small></td>
  </tr>
  <tr>
    <td rowspan="3">Base-32</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>5.44 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>5.99 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.53 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>577 Mbps &#128315;9.43x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>421 Mbps &#128315;14.23x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>387 Mbps &#128315;11.7x</small></td>
  </tr>
  <tr>
    <td>base32</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>631 Kbps &#128315;8618.49x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>132 Mbps &#128315;45.35x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>137 Mbps &#128315;33.02x</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-64</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>6.04 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>6.68 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>5.48 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>███████████████░</code> <br> <small>5.61 Gbps &#128315;1.08x</small></td>
    <td><code>███████████████░</code> <br> <small>6.11 Gbps &#128315;1.09x</small></td>
    <td><code>█████████████░░░</code> <br> <small>4.36 Gbps &#128315;1.26x</small></td>
  </tr>
  <tr>
    <td rowspan="2">UTF-8</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>3.14 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.4 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>2.78 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>█████████████░░░</code> <br> <small>2.6 Gbps &#128315;1.21x</small></td>
    <td><code>█████████████░░░</code> <br> <small>2.73 Gbps &#128315;1.25x</small></td>
    <td><code>█████████████░░░</code> <br> <small>2.22 Gbps &#128315;1.25x</small></td>
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
    <td><code>████████████████</code> <br> <small><b>1.74 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.76 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>1.64 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>Base-8</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.15 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.22 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.68 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-16</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>3.65 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.71 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.26 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>406 Mbps &#128315;8.98x</small></td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>410 Mbps &#128315;9.04x</small></td>
    <td><code>██░░░░░░░░░░░░░░</code> <br> <small>396 Mbps &#128315;8.24x</small></td>
  </tr>
  <tr>
    <td rowspan="3">Base-32</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.03 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.09 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>3.38 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>base_codecs</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>266 Mbps &#128315;15.13x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>267 Mbps &#128315;15.33x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>239 Mbps &#128315;14.13x</small></td>
  </tr>
  <tr>
    <td>base32</td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>176 Mbps &#128315;22.84x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>199 Mbps &#128315;20.62x</small></td>
    <td><code>█░░░░░░░░░░░░░░░</code> <br> <small>153 Mbps &#128315;22.14x</small></td>
  </tr>
  <tr>
    <td rowspan="2">Base-64</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>4.98 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>5.16 Gbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>4.32 Gbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>███████████░░░░░</code> <br> <small>3.5 Gbps &#128315;1.42x</small></td>
    <td><code>███████████░░░░░</code> <br> <small>3.6 Gbps &#128315;1.43x</small></td>
    <td><code>███████████░░░░░</code> <br> <small>2.87 Gbps &#128315;1.51x</small></td>
  </tr>
  <tr>
    <td rowspan="2">UTF-8</td>
    <td>convertlib</td>
    <td><code>███████████████░</code> <br> <small>1.65 Gbps </small></td>
    <td><code>███████████████░</code> <br> <small>1.68 Gbps </small></td>
    <td><code>████████████░░░░</code> <br> <small>1.28 Gbps </small></td>
  </tr>
  <tr>
    <td>dart:convert</td>
    <td><code>████████████████</code> <br> <small><b>1.75 Gbps</b> &#128314;1.06x</small></td>
    <td><code>████████████████</code> <br> <small><b>1.81 Gbps</b> &#128314;1.08x</small></td>
    <td><code>████████████████</code> <br> <small><b>1.72 Gbps</b> &#128314;1.35x</small></td>
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
    <td><code>████████████████</code> <br> <small><b>119 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>115 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>98.21 Mbps</b> &#127775;</small></td>
  </tr>
  <tr>
    <td>BigInt → bytes</td>
    <td>convertlib</td>
    <td><code>████████████████</code> <br> <small><b>256 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>250 Mbps</b> &#127775;</small></td>
    <td><code>████████████████</code> <br> <small><b>223 Mbps</b> &#127775;</small></td>
  </tr>
</tbody>
</table>


> All benchmarks are done on 36GB _Apple M3 Pro_ using compiled _exe_
>
> Dart SDK version: 3.12.2 (stable) (Tue Jun 9 01:11:39 2026 -0700) on "macos_arm64"
