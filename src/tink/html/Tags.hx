package tink.html;

class Tags {
  static function h(name, attributes:haxe.DynamicAccess<tink.Stringly>, ?children:Array<Child>) {
    return Node.Tag(
      name, 
      [for (name in attributes.keys()) new Named(name, ((attributes[name]:String):Attribute))],
      children
    );
  }

  static public function html(attrs:BaseAttr, children)
    return h('html', cast attrs, children);

  static public function body(attrs:BaseAttr, children)
    return h('body', cast attrs, children);

  static public function head(attrs:BaseAttr, children)
    return h('head', cast attrs, children);

  static public function header(attrs:BaseAttr, children)
    return h('header', cast attrs, children);

  static public function footer(attrs:BaseAttr, children)
    return h('footer', cast attrs, children);

  static public function div(attrs:BaseAttr, children)
    return h('div', cast attrs, children);

  static public function h1(attrs:BaseAttr, children)
    return h('h1', cast attrs, children);

  static public function h2(attrs:BaseAttr, children)
    return h('h2', cast attrs, children);

  static public function h3(attrs:BaseAttr, children)
    return h('h3', cast attrs, children);

  static public function h4(attrs:BaseAttr, children)
    return h('h4', cast attrs, children);

  static public function h5(attrs:BaseAttr, children)
    return h('h5', cast attrs, children);

  static public function h6(attrs:BaseAttr, children)
    return h('h6', cast attrs, children);

  macro static public function hxx(e) {
    return new Generator().root(tink.hxx.Parser.parseRoot(e));
  }
}

typedef BaseAttr = {
  @:optional var className(default, never):String;
}

abstract Child(Node) from Node to Node {
  @:from static inline function ofString(s:String)
    return ofFragment(s);

  @:from static inline function ofFragment(fragment:Fragment)
    return Node.Text(fragment);
}

#if macro
class Generator extends tink.hxx.Generator {
  public function new() {
    super([function (s) return {
      pos: s.pos,
      value: 'tink.html.Tags.${s.value}',
    }]);
  }
}
#end