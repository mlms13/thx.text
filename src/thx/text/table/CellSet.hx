package thx.text.table;

using thx.Ints;
using thx.Maps;

class CellSet {
  var values : Map<Int, Cell>;
  public var size(default, null) : Int;
  public var table(default, null) : thx.text.Table;
  public var index(default, null) : Int;

  public function new(table : Table, index : Int) {
    this.index = index;
    this.table = table;
    values = new Map();
    size = 0;
  }

  public function get(index : Int) {
    return values.get(index);
  }

  function _set(index : Int, cell : Cell) {
    size = index.max(size);
    values.set(index, cell);
  }
}