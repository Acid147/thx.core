package thx.core;

using thx.core.Arrays;
using thx.core.Strings;
using StringTools;

/**
Extension methods for integer values.
**/
class Ints {
  static var pattern_parse = ~/^[+-]?(\d+|0x[0-9A-F]+)$/i;
/**
`abs` returns the absolute integer value of the passed argument.
**/
  inline public static function abs(v : Int) : Int
    return v < 0 ? -v : v;

/**
`canParse` takes a string and return a boolean indicating if the argument can be safely transformed
into a valid integer value.
**/
  public static function canParse(s : String)
    return pattern_parse.match(s);

/**
`clamp` restricts a value within the specified range.
**/
  public static inline function clamp(v : Int, min : Int, max : Int) : Int
    return v < min ? min : (v > max ? max : v);

/**
Like clamp but you only pass one argument (`max`) that is used as the upper limit
and the opposite (additive inverse or `-max`) as the lower limit.
**/
  public static inline function clampSym(v : Int, max : Int) : Int
    return clamp(v, -max, max);

/**
Return a comparison value between `a` and `b`. The number is negative if `a` is
greater than `b`, positive if `a` is lesser than `b` or zero if `a` and `b` are
equals.
**/
  inline public static function compare(a : Int, b : Int) : Int
    return a - b;

/**
Given a value `t` between 0 and 1, it interpolates that value in the range between `a` and `b`.

The returned value is a rounded integer.
*/
  public static function interpolate(f : Float, a : Float, b : Float) : Int
    return Math.round(a + (b - a) * f);

/**
`isEven` returns `true` if `v` is even, `false` otherwise.
**/
  inline public static function isEven(v : Int)
    return v % 2 == 0;

/**
`isOdd` returns `true` if `v` is odd, `false` otherwise.
**/
  inline public static function isOdd(v : Int)
    return v % 2 != 0;

/**
It returns the maximum value between `a` and `b`.
**/
  inline public static function max(a : Int, b : Int) : Int
    return a > b ? a : b;

/**
It returns the minimum value between `a` and `b`.
**/
  inline public static function min(a : Int, b : Int) : Int
    return a < b ? a : b;

/**
Parses a string into an Int value using the provided radix. Default radix is 16 for strings that begin with
0x (after optional sign) or 10 otherwise.

It is also possible to provide an optiona `negativeSign` and/or `positiveSign`.
**/
  public static function parse(s : String, ?radix : Int, ?negativeSign = "-", ?positiveSign = "+") : Null<Int> {
    #if js
    var v : Int = untyped __js__("parseInt")(s, radix);
    return Math.isNaN(v) ? null : v;
    #elseif flash9
    if(radix == null) radix = 0;
    var v : Int = untyped __global__["parseInt"](s, radix);
    return Math.isNaN(v) ? null : v;
    #else

    if(radix != null && (radix < 2 || radix > BASE.length))
      return throw 'invalid radix $radix, it must be between 2 and ${BASE.length}';

    if(s.substring(0, positiveSign.length) == positiveSign)
      s = s.substring(positiveSign.length);

    var negative = s.substring(0, negativeSign.length) == negativeSign;

    if(negative)
      s = s.substring(negativeSign.length);

    if(s.length == 0)
      return null;

    s = s.trim().toLowerCase();

    if(s.startsWith('0x')) {
      if(null != radix && 16 != radix)
        return null; // attempting at converting a hex using a different radix
      radix = 16;
      s = s.substring(2);
    } else if(null == radix) {
      radix = 10;
    }

    return try ((negative ? -1 : 1) * s.toArray().reduce(function(acc, c) {
      var i = BASE.indexOf(c);
      if(i < 0 || i >= radix) throw 'invalid';
      return (acc * radix) + i;
    }, 0) : Null<Int>) catch(e : Dynamic) null;
    #end
  }

/**
Integer random function that includes both upper and lower limits. A roll on a die with
6 sides would be the equivalent to the following:

```haxe
var d6 = Ints.random(1, 6);
```
**/
  inline public static function random(min = 0, max : Int)
    return Std.random(max + 1) + min;

/**
`range` creates an array of integer containing values between  start (included) and stop (excluded)
with a progression set by `step`. A negative value for `step` can be used but in that
case start will need to be a greater value than stop.
**/
  public static function range(start : Int, ?stop : Int, step = 1) : Array<Int> {
    if(null == stop) {
      stop = start;
      start = 0;
    }
    if((stop - start) / step == Math.POSITIVE_INFINITY) throw "infinite range";
    var range = [], i = -1, j;
    if(step < 0)
      while ((j = start + step * ++i) > stop) range.push(j);
    else
      while ((j = start + step * ++i) < stop) range.push(j);
    return range;
  }

  // Base used for toString/parseInt conversions. Supporting base 2 to 36 for now as common standard.
  static var BASE = "0123456789abcdefghijklmnopqrstuvwxyz";

/**
Transform an `Int` value to a `String` using the specified `radix`. A negative sign can be provided optionally.
**/
  #if(js || flash) inline #end
  public static function toString(value : Int, radix : Int, ?negativeSign : String = '-') : String {
    #if(js || flash)
    return untyped value.toString(radix).replace('-', negativeSign);
    #else

    if(radix < 2 || radix > BASE.length)
      return throw 'invalid radix $radix, it must be between 2 and ${BASE.length}';
    if(radix == 10 || value == 0)
      return '$value';

    var buf = "",
        abs = Ints.abs(value);
    while(abs > 0) {
      buf = BASE.charAt(abs % radix) + buf;
      abs = Std.int(abs / radix);
    }

    return (value < 0 ? negativeSign : '') + buf;
    #end
  }

/**
`sign` returns `-1` if `value` is a negative number, `1` otherwise.
*/
  inline public static function sign(value : Int) : Int
    return value < 0 ? -1 : 1;

/**
Similar to `wrap`, it works for numbers between 0 and `max`.
**/
  public static function wrapCircular(v : Int, max : Int) : Int {
    v = v % max;
    if(v < 0)
      v += max;
    return v;
  }
}