package thx.text.table;

using thx.Arrays;
using thx.Functions;
using thx.Strings;
using thx.format.DateFormat;
using thx.format.NumberFormat;
using thx.format.TimeFormat;
using thx.culture.Culture;
using thx.culture.Embed;
using thx.Options;
import haxe.ds.Option;
import thx.text.table.CellValue;

class Style implements IStyle {
  @:isVar public var type(get, set) : CellType;
  @:isVar public var maxHeight(get, set) : Null<Int>;
  @:isVar public var minHeight(get, set) : Null<Int>;
  @:isVar public var maxWidth(get, set) : Null<Int>;
  @:isVar public var minWidth(get, set) : Null<Int>;
  @:isVar public var formatter(get, set) : Formatter;
  @:isVar public var aligner(get, set) : Aligner;
  public function new() {}

  public function setAlign(align : HAlign)
    aligner = function(_, _) return align;

  function get_type()
    return type;

  function set_type(value : CellType)
    return type = value;

  function get_maxHeight() : Null<Int>
    return maxHeight;

  function set_maxHeight(value : Null<Int>) : Null<Int>
    return maxHeight = value;

  function get_minHeight() : Null<Int>
    return minHeight;

  function set_minHeight(value : Null<Int>) : Null<Int>
    return minHeight = value;

  function get_maxWidth() : Null<Int>
    return maxWidth;

  function set_maxWidth(value : Null<Int>) : Null<Int>
    return maxWidth = value;

  function get_minWidth() : Null<Int>
    return minWidth;

  function set_minWidth(value : Null<Int>) : Null<Int>
    return minWidth = value;

  function get_formatter() : Formatter
    return formatter;

  function set_formatter(value : Formatter) : Formatter
    return formatter = value;

  function get_aligner() : Aligner
    return aligner;

  function set_aligner(value : Aligner) : Aligner
    return aligner = value;
}

class CompositeStyle implements IStyle {
  public var type(get, set) : CellType;
  public var maxHeight(get, set) : Null<Int>;
  public var minHeight(get, set) : Null<Int>;
  public var maxWidth(get, set) : Null<Int>;
  public var minWidth(get, set) : Null<Int>;
  public var formatter(get, set) : Formatter;
  public var aligner(get, set) : Aligner;
  var base : IStyle;
  var all : Array<IStyle>;
  public function new(parents : Array<IStyle>) {
    this.base = new Style();
    this.all = [base].concat(parents);
  }

  function extract<T>(f: IStyle -> Null<T>)
    return all.findMap(function(v) return Options.ofValue(f(v))).get();

  function get_type()
    return extract.fn(_.type);

  function set_type(value : CellType)
    return base.type = value;

  function get_maxHeight() : Null<Int>
    return extract.fn(_.maxHeight);

  function set_maxHeight(value : Null<Int>) : Null<Int>
    return base.maxHeight = value;

  function get_minHeight() : Null<Int>
    return extract.fn(_.minHeight);

  function set_minHeight(value : Null<Int>) : Null<Int>
    return base.minHeight = value;

  function get_maxWidth() : Null<Int>
    return extract.fn(_.maxWidth);

  function set_maxWidth(value : Null<Int>) : Null<Int>
    return base.maxWidth = value;

  function get_minWidth() : Null<Int>
    return extract.fn(_.minWidth);

  function set_minWidth(value : Null<Int>) : Null<Int>
    return base.minWidth = value;

  function get_formatter() : Formatter
    return extract.fn(_.formatter);

  function set_formatter(value : Formatter) : Formatter
    return base.formatter = value;

  function get_aligner() : Aligner
    return extract.fn(_.aligner);

  function set_aligner(value : Aligner) : Aligner
    return base.aligner = value;

  public function setAlign(align : HAlign)
    aligner = function(_, _) return align;
}

class DefaultStyle implements IStyle {
  public static var instance(default, null) : DefaultStyle = new DefaultStyle();
  public static var defaultType : CellType = BodyCompact;
  public static var defaultMaxHeight : Null<Int> = null;
  public static var defaultMinHeight : Int = 1;
  public static var defaultMaxWidth : Null<Int> = null;
  public static var defaultMinWidth : Int = 1;
  public static var defaultCulture : Culture = Embed.culture("en-us");
  public static var defaultIntFormatter : Int -> String = function(v : Int) return NumberFormat.integer(v, defaultCulture);
  public static var defaultFloatFormatter : Float -> String = function(v : Float) return NumberFormat.format(v, "#,#.#####", defaultCulture);
  public static var defaultStringFormatter : String -> String = function(v : String) return v;
  public static var defaultBoolFormatter : Bool -> String = function(v : Bool) return v ? "✓" : "✕";
  public static var defaultDateTimeFormatter : DateTime -> String = function(v : DateTime) return DateFormat.dateShort(v, defaultCulture);
  public static var defaultTimeFormatter : Time -> String = function(v : Time) return TimeFormat.timeLong(v, defaultCulture);
  public static var defaultNAFormatter : Void -> String = function() return "NA";
  public static var defaultEmptyFormatter : Void -> String = function() return "";
  public static var defaultFormatter : Formatter = function(value : CellValue, maxWidth : Null<Int>) {
    switch value {
      case StringCell(v):
        if(null != maxWidth && maxWidth > 0)
          v = v.wrapColumns(maxWidth);
        return StringBlock.fromString(v);
      case _: // do nothing
    }
    var s = switch value {
      case IntCell(v): defaultIntFormatter(v);
      case FloatCell(v): defaultFloatFormatter(v);
      case StringCell(v): defaultStringFormatter(v);
      case BoolCell(v): defaultBoolFormatter(v);
      case DateTimeCell(v): defaultDateTimeFormatter(v);
      case TimeCell(v): defaultTimeFormatter(v);
      case NA: defaultNAFormatter();
      case Empty: defaultEmptyFormatter();
    };
    if(null != maxWidth && maxWidth > 0)
      s = s.ellipsisMiddle();
    return new StringBlock([s]);
  };

  public static var defaultAligner : Aligner = function(value : CellValue, type : CellType)
    return switch [value, type] {
      case [_, HeaderCompact], [BoolCell(_), _]:
        Center;
      case [_, Header], [StringCell(_), _], [Empty, _]:
        Left;
      case [DateTimeCell(_), _], [TimeCell(_), _], [NA, _]:
        Right;
      case [IntCell(_), _], [FloatCell(_), _]:
        OnSymbol(defaultCulture.number.separatorDecimalNumber);
      case [_, _]:
        throw 'unmatched pattern $value, $type';
    };

  public var type(get, set) : CellType;
  public var maxHeight(get, set) : Null<Int>;
  public var minHeight(get, set) : Null<Int>;
  public var maxWidth(get, set) : Null<Int>;
  public var minWidth(get, set) : Null<Int>;
  public var formatter(get, set) : Formatter;
  public var aligner(get, set) : Aligner;

  public function new() {}

  public function setAlign(align : HAlign)
    aligner = function(_, _) return align;

  function get_type() : CellType
    return defaultType;

  function set_type(value : CellType) : CellType
    return defaultType = value;

  function get_maxHeight() : Null<Int>
    return defaultMaxHeight;

  function set_maxHeight(value : Null<Int>) : Null<Int>
    return defaultMaxHeight = value;

  function get_minHeight() : Null<Int>
    return defaultMinHeight;

  function set_minHeight(value : Null<Int>) : Null<Int>
    return defaultMinHeight = value;

  function get_maxWidth() : Null<Int>
    return defaultMaxWidth;

  function set_maxWidth(value : Null<Int>) : Null<Int>
    return defaultMaxWidth = value;

  function get_minWidth() : Null<Int>
    return defaultMinWidth;

  function set_minWidth(value : Null<Int>) : Null<Int>
    return defaultMinWidth = value;

  function get_formatter() : Formatter
    return defaultFormatter;

  function set_formatter(value : Formatter) : Formatter
    return defaultFormatter = value;

  function get_aligner() : Aligner
    return defaultAligner;

  function set_aligner(value : Aligner) : Aligner
    return defaultAligner = value;
}

interface IStyle {
  public var type(get, set) : CellType;
  public var minWidth(get, set) : Null<Int>;
  public var maxWidth(get, set) : Null<Int>;
  public var minHeight(get, set) : Null<Int>;
  public var maxHeight(get, set) : Null<Int>;
  public var formatter(get, set) : Formatter;
  public var aligner(get, set) : Aligner;

  public function setAlign(align : HAlign) : Void;
}

enum CellType {
  Header;
  HeaderCompact;
  Body;
  BodyCompact;
}

enum BorderStyle {
  None;
  Normal;
  Double;
}

enum Border {
  Removable;
  RemovableCross(top : BorderStyle, right : BorderStyle, bottom : BorderStyle, left : BorderStyle);
  Cross(top : BorderStyle, right : BorderStyle, bottom : BorderStyle, left : BorderStyle);
}

typedef Formatter = CellValue -> Null<Int> -> StringBlock;
typedef Aligner = CellValue -> CellType -> HAlign;
