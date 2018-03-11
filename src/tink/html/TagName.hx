package tink.html;

abstract TagName(String) to String {
  inline function new(s:String)
    this = s;

  @:from static function ofString(s:String):TagName
    return new TagName(s.toLowerCase());//TODO: validate

  @:op(a == b) static inline function eqTag(a:TagName, b:TagName)
    return (a:String) == (b:String);

  @:op(a != b) static inline function neqTag(a:TagName, b:TagName)
    return !(a == b);

  @:commutative
  @:op(a == b) static inline function eqString(a:TagName, b:String)
    return eqTag(a, b);

  @:commutative
  @:op(a != b) static inline function neqString(a:TagName, b:String)
    return neqTag(a, b);

  public function isVoid()
    return switch this {
      case 'area' | 'base' | 'br' | 'col' | 'embed' | 'hr' | 'img' | 'input' | 'keygen' | 'link' | 'meta' | 'param' | 'source' | 'track' | 'wbr': true;
      default: false;
    }
}