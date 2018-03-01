package tink.html;

abstract Attribute(String) {
  static public inline var EMPTY = new Attribute(null);
  public inline function new(v:String)
    this = v;

  public inline function toText():String
    return if (this == null) '' else this.htmlUnescape();

  @:from static public function escape(s:String):Attribute
    return new Attribute(s.htmlEscape(true));
}