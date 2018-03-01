package tink.html;

abstract Tag(String) to String {
  inline function new(s:String)
    this = s;

  @:from static function ofString(s:String):Tag
    return new Tag(s.toLowerCase());//TODO: validate

  @:op(a == b) static inline function eqTag(a:Tag, b:Tag)
    return (a:String) == (b:String);

  @:op(a != b) static inline function neqTag(a:Tag, b:Tag)
    return !(a == b);

  @:commutative
  @:op(a == b) static inline function eqString(a:Tag, b:String)
    return eqTag(a, b);

  @:commutative
  @:op(a != b) static inline function neqString(a:Tag, b:String)
    return neqTag(a, b);

  public function isVoid()
    return switch this {
      case 'area' | 'base' | 'br' | 'col' | 'embed' | 'hr' | 'img' | 'input' | 'keygen' | 'link' | 'meta' | 'param' | 'source' | 'track' | 'wbr': true;
      default: false;
    }
}