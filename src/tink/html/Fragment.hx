package tink.html;

abstract Fragment(String) to String {

  public inline function new(s) 
    this = s;

  public inline function toText():String
    return StringTools.htmlUnescape(this);

  @:from static public function escape(s:String):Fragment
    return new Fragment(s.htmlEscape());
}