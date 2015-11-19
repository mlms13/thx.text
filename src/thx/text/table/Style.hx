package thx.text.table;

using thx.Strings;
using thx.format.DateFormat;
using thx.format.NumberFormat;
using thx.format.TimeFormat;
using thx.culture.Culture;
using thx.culture.Embed;
import thx.text.table.CellValue;

class Style implements IStyle {
  @:isVar public var type(get, set) : CellType;
  @:isVar public var maxHeight(get, set) : Null<Int>;
  @:isVar public var maxWidth(get, set) : Null<Int>;
  @:isVar public var formatter(get, set) : Formatter;
  public function new() {}

  function get_type()
    return type;

  function set_type(value : CellType)
    return type = value;

  function get_maxHeight() : Null<Int>
    return maxHeight;

  function set_maxHeight(value : Null<Int>) : Null<Int>
    return maxHeight = value;

  function get_maxWidth() : Null<Int>
    return maxWidth;

  function set_maxWidth(value : Null<Int>) : Null<Int>
    return maxWidth = value;

  function get_formatter() : Formatter
    return formatter;

  function set_formatter(value : Formatter) : Formatter
    return formatter = value;
}

class CompositeStyle extends Style {
  var parents : Array<IStyle>;
  public function new(parents : Array<IStyle>) {
    super();
    this.parents = parents;
  }

  override function get_type()
    return getProperty("type");

  override function set_type(value : CellType)
    return type = value;

  override function get_maxHeight() : Null<Int>
    return getProperty("maxHeight");

  override function set_maxHeight(value : Null<Int>) : Null<Int>
    return maxHeight = value;

  override function get_maxWidth() : Null<Int>
    return getProperty("maxWidth");

  override function set_maxWidth(value : Null<Int>) : Null<Int>
    return maxWidth = value;

  override function get_formatter() : Formatter
    return getProperty("formatter");

  override function set_formatter(value : Formatter) : Formatter
    return formatter = value;

  // TODO, this should expand to a macro
  function getProperty<T>(name : String) : Null<T> {
    var value = Reflect.field(this, name);
    if(null != value)
      return value;
    for(parent in parents) {
      value = Reflect.getProperty(parent, name);
      if(null != value)
        return value;
    }
    return null;
  }
}

class DefaultStyle implements IStyle {
  public static var instance(default, null) : DefaultStyle = new DefaultStyle();
  public static var defaultType : CellType = BodyCompact;
  public static var defaultMaxHeight : Null<Int> = null;
  public static var defaultMaxWidth : Null<Int> = null;
  public static var defaultCulture : Culture = Embed.culture("en-us");
  public static var defaultIntFormatter : Int -> String = function(v : Int) return NumberFormat.integer(v, defaultCulture);
  public static var defaultFloatFormatter : Float -> String = function(v : Float) return NumberFormat.number(v, 2, defaultCulture);
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

  public var type(get, set) : CellType;
  public var maxHeight(get, set) : Null<Int>;
  public var maxWidth(get, set) : Null<Int>;
  public var formatter(get, set) : Formatter;

  public function new() {}

  function get_type() : CellType
    return defaultType;

  function set_type(value : CellType) : CellType
    return defaultType = value;

  function get_maxHeight() : Null<Int>
    return defaultMaxHeight;

  function set_maxHeight(value : Null<Int>) : Null<Int>
    return defaultMaxHeight = value;

  function get_maxWidth() : Null<Int>
    return defaultMaxWidth;

  function set_maxWidth(value : Null<Int>) : Null<Int>
    return defaultMaxWidth = value;

  function get_formatter() : Formatter
    return defaultFormatter;

  function set_formatter(value : Formatter) : Formatter
    return defaultFormatter = value;
}

interface IStyle {
  public var type(get, set) : CellType;
  public var maxWidth(get, set) : Null<Int>;
  public var maxHeight(get, set) : Null<Int>;
  public var formatter(get, set) : Formatter;
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
  Cross(top : BorderStyle, right : BorderStyle, bottom : BorderStyle, left : BorderStyle);
}

typedef Formatter = CellValue -> Null<Int> -> StringBlock;
