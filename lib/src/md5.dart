import 'dart:async';

class MD5 {
  static const mask32 = 0xFFFFFFFF;
  static Future<int> safe_add(int x, int y) async {
    var lsw = (0xFFFF & x) + (0xFFFF & y);
    var msw = (x >> 16) + (y >> 16) + (lsw >> 16);
    return (msw << 16) | (lsw & 0xFFFF);
  }

  static Future<int> bit_rol(int nber, int cnt) async {
    // Dans strophe.js (nber << cnt) | (nber >>> (32 - cnt))
    // l'operateur >>> n'existe pas dans dart
    return (nber << cnt) | _zeroFillRightShift(nber, (32 - cnt));
  }

  static Future<List<int>> str2binl(String str) async {
    List bin = [];
    for (int i = 0; i < str.length * 8; i += 8) {
      if (bin.length <= (i >> 5)) {
        var length = bin.length;
        bin.length = (i >> 5) + 1;
        bin.fillRange(length, (i >> 5) + 1, 0);
      }
      bin[i >> 5] |= (str.codeUnitAt((i / 8).floor()) & 255) << (i % 32);
    }
    return bin;
  }

  /*
     * Convert an array of little-endian words to a string
     */
  static Future<String> binl2str(List<int> bin) async {
    String str = "";
    for (int i = 0; i < bin.length * 32; i += 8) {
      //str += new String.fromCharCode((bin[i >> 5] >>> (i % 32)) & 255);
      str += new String.fromCharCode(
          _zeroFillRightShift(bin[i >> 5], (i % 32)) & 255);
    }
    return str;
  }

  static Future<String> binl2hex(List binarray) async {
    const String hex_tab = "0123456789abcdef";
    String str = "";
    for (int i = 0; i < binarray.length * 4; i++) {
      str += hex_tab
              .split('')
              .elementAt((binarray[i >> 2] >> ((i % 4) * 8 + 4)) & 0xF) +
          hex_tab
        ..split('').elementAt((binarray[i >> 2] >> ((i % 4) * 8)) & 0xF);
    }
    return str;
  }

  static int _zeroFillRightShift(int n, int amount) {
    //return (n & 0xffffffff) >> amount;
    return ((n & mask32) >> (32 - (amount & 31)));
  }

  static Future<int> md5_cmn(int q, int a, int b, int x, int s, int t) async {
    return safe_add(
        await bit_rol(
            await safe_add(await safe_add(a, q), await safe_add(x, t)), s),
        b);
  }

  static Future<int> md5_ff(
      int a, int b, int c, int d, int x, int s, int t) async {
    return md5_cmn((b & c) | ((~b) & d), a, b, x, s, t);
  }

  static Future<int> md5_gg(
      int a, int b, int c, int d, int x, int s, int t) async {
    return md5_cmn((b & d) | (c & (~d)), a, b, x, s, t);
  }

  static Future<int> md5_hh(
      int a, int b, int c, int d, int x, int s, int t) async {
    return md5_cmn(b ^ c ^ d, a, b, x, s, t);
  }

  static Future<int> md5_ii(
      int a, int b, int c, int d, int x, int s, int t) async {
    return md5_cmn(c ^ (b | (~d)), a, b, x, s, t);
  }

  static Future<List<int>> core_md5(List<int> x, int len) async {
    /* append padding */
    x[len >> 5] |= 0x80 << ((len) % 32);
    int length = x.length;
    //x.length = (((len + 64) >>> 9) << 4) + 14;
    x.length = (_zeroFillRightShift((len + 64), 9) << 4) + 14;
    if (length < x.length) {
      x.fillRange(
          length - 1, (_zeroFillRightShift((len + 64), 9) << 4) + 14, 0);
      x.add(len);
      x.add(0);
    }
    //x[(((len + 64) >> 9) << 4) + 14] = len;

    int a = 1732584193;
    int b = -271733879;
    int c = -1732584194;
    int d = 271733878;

    var olda, oldb, oldc, oldd;
    for (int i = 0; i < x.length; i += 16) {
      olda = a;
      oldb = b;
      oldc = c;
      oldd = d;

      a = await md5_ff(a, b, c, d, x[i + 0], 7, -680876936);
      d = await md5_ff(d, a, b, c, x[i + 1], 12, -389564586);
      c = await md5_ff(c, d, a, b, x[i + 2], 17, 606105819);
      b = await md5_ff(b, c, d, a, x[i + 3], 22, -1044525330);
      a = await md5_ff(a, b, c, d, x[i + 4], 7, -176418897);
      d = await md5_ff(d, a, b, c, x[i + 5], 12, 1200080426);
      c = await md5_ff(c, d, a, b, x[i + 6], 17, -1473231341);
      b = await md5_ff(b, c, d, a, x[i + 7], 22, -45705983);
      a = await md5_ff(a, b, c, d, x[i + 8], 7, 1770035416);
      d = await md5_ff(d, a, b, c, x[i + 9], 12, -1958414417);
      c = await md5_ff(c, d, a, b, x[i + 10], 17, -42063);
      b = await md5_ff(b, c, d, a, x[i + 11], 22, -1990404162);
      a = await md5_ff(a, b, c, d, x[i + 12], 7, 1804603682);
      d = await md5_ff(d, a, b, c, x[i + 13], 12, -40341101);
      c = await md5_ff(c, d, a, b, x[i + 14], 17, -1502002290);
      b = await md5_ff(b, c, d, a, x[i + 15], 22, 1236535329);

      a = await md5_gg(a, b, c, d, x[i + 1], 5, -165796510);
      d = await md5_gg(d, a, b, c, x[i + 6], 9, -1069501632);
      c = await md5_gg(c, d, a, b, x[i + 11], 14, 643717713);
      b = await md5_gg(b, c, d, a, x[i + 0], 20, -373897302);
      a = await md5_gg(a, b, c, d, x[i + 5], 5, -701558691);
      d = await md5_gg(d, a, b, c, x[i + 10], 9, 38016083);
      c = await md5_gg(c, d, a, b, x[i + 15], 14, -660478335);
      b = await md5_gg(b, c, d, a, x[i + 4], 20, -405537848);
      a = await md5_gg(a, b, c, d, x[i + 9], 5, 568446438);
      d = await md5_gg(d, a, b, c, x[i + 14], 9, -1019803690);
      c = await md5_gg(c, d, a, b, x[i + 3], 14, -187363961);
      b = await md5_gg(b, c, d, a, x[i + 8], 20, 1163531501);
      a = await md5_gg(a, b, c, d, x[i + 13], 5, -1444681467);
      d = await md5_gg(d, a, b, c, x[i + 2], 9, -51403784);
      c = await md5_gg(c, d, a, b, x[i + 7], 14, 1735328473);
      b = await md5_gg(b, c, d, a, x[i + 12], 20, -1926607734);

      a = await md5_hh(a, b, c, d, x[i + 5], 4, -378558);
      d = await md5_hh(d, a, b, c, x[i + 8], 11, -2022574463);
      c = await md5_hh(c, d, a, b, x[i + 11], 16, 1839030562);
      b = await md5_hh(b, c, d, a, x[i + 14], 23, -35309556);
      a = await md5_hh(a, b, c, d, x[i + 1], 4, -1530992060);
      d = await md5_hh(d, a, b, c, x[i + 4], 11, 1272893353);
      c = await md5_hh(c, d, a, b, x[i + 7], 16, -155497632);
      b = await md5_hh(b, c, d, a, x[i + 10], 23, -1094730640);
      a = await md5_hh(a, b, c, d, x[i + 13], 4, 681279174);
      d = await md5_hh(d, a, b, c, x[i + 0], 11, -358537222);
      c = await md5_hh(c, d, a, b, x[i + 3], 16, -722521979);
      b = await md5_hh(b, c, d, a, x[i + 6], 23, 76029189);
      a = await md5_hh(a, b, c, d, x[i + 9], 4, -640364487);
      d = await md5_hh(d, a, b, c, x[i + 12], 11, -421815835);
      c = await md5_hh(c, d, a, b, x[i + 15], 16, 530742520);
      b = await md5_hh(b, c, d, a, x[i + 2], 23, -995338651);

      a = await md5_ii(a, b, c, d, x[i + 0], 6, -198630844);
      d = await md5_ii(d, a, b, c, x[i + 7], 10, 1126891415);
      c = await md5_ii(c, d, a, b, x[i + 14], 15, -1416354905);
      b = await md5_ii(b, c, d, a, x[i + 5], 21, -57434055);
      a = await md5_ii(a, b, c, d, x[i + 12], 6, 1700485571);
      d = await md5_ii(d, a, b, c, x[i + 3], 10, -1894986606);
      c = await md5_ii(c, d, a, b, x[i + 10], 15, -1051523);
      b = await md5_ii(b, c, d, a, x[i + 1], 21, -2054922799);
      a = await md5_ii(a, b, c, d, x[i + 8], 6, 1873313359);
      d = await md5_ii(d, a, b, c, x[i + 15], 10, -30611744);
      c = await md5_ii(c, d, a, b, x[i + 6], 15, -1560198380);
      b = await md5_ii(b, c, d, a, x[i + 13], 21, 1309151649);
      a = await md5_ii(a, b, c, d, x[i + 4], 6, -145523070);
      d = await md5_ii(d, a, b, c, x[i + 11], 10, -1120210379);
      c = await md5_ii(c, d, a, b, x[i + 2], 15, 718787259);
      b = await md5_ii(b, c, d, a, x[i + 9], 21, -343485551);

      a = await safe_add(a, olda);
      b = await safe_add(b, oldb);
      c = await safe_add(c, oldc);
      d = await safe_add(d, oldd);
    }
    return [a, b, c, d];
  }

  static Future<String> hexdigest(String s) async {
    return binl2hex(await core_md5(await str2binl(s), s.length * 8));
  }

  static Future<String> hash(String s) async {
    return binl2str(await core_md5(await str2binl(s), s.length * 8));
  }
}
