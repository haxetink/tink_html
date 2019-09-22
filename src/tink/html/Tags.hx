package tink.html;

using tink.CoreApi;

#if macro
  import haxe.macro.Expr;
  import haxe.macro.Type;
  import haxe.macro.Context;
  #if tink_hxx
    using tink.MacroApi;
    import tink.hxx.*;
  #end
  #if tink_domspec
    import tink.domspec.Macro.tags;
  #end
#else
  @:build(tink.html.Tags.build())
#end
class Tags {
  #if !macro
  static function h(name, attributes:haxe.DynamicAccess<tink.Stringly>, ?children:Children) 
    return Node.Tag(
      name, 
      [for (name in attributes.keys()) new Named(name, ((attributes[name]:String):Attribute))],
      children
    );
  #else
    #if tink_hxx
    static public var generator = new tink.hxx.Generator(
      #if tink_domspec
        Tag.extractAllFrom(macro tink.html.Tags)
      #else
        []
      #end
    );
    #end

  static function build() {
    #if !(tink_domspec && tink_hxx)
      return Context.fatalError('using tink.html.Tags requires -lib tink_domspec and -lib tink_hxx', Context.currentPos());
    #else  
    var fields = Context.getBuildFields();

    var children = macro : Array<tink.html.Tags.Child>;

    for (name in tags.keys()) {
      var tag = tags[name];
      fields.push({
        name: name,
        pos: tag.pos,
        access: [AStatic, APublic],
        kind: FFun({
          ret: macro : tink.html.Node,
          args: 
            [{ name: 'attr', type: tag.attr, opt: false }].concat(
              if (children == null) []
              else [{ name: 'children', type: children, opt: true }]
            ),
          expr: {
            var children = switch tag.kind {
              case NORMAL: children;
              case OPAQUE: macro : tink.html.Fragment;
              case VOID: null;
            }
            if (children == null)
              macro return h($v{name}, cast attr)
            else
              macro return h($v{name}, cast attr, children);
          },
        }),
      });    
    }
    
    return fields;
    #end
  }
  #end
  macro static public function hxx(e:Expr) {
    #if !(tink_hxx && tink_domspec)
      return Context.fatalError('must compile with -lib tink_hxx and -lib tink_domspec to enable HXX support', Context.currentPos());
    #else

      var ctx = generator.createContext();
      return ctx.generateRoot(
        tink.hxx.Parser.parseRoot(e, { 
          defaultExtension: 'hxx', 
          noControlStructures: false, 
          defaultSwitchTarget: macro __data__,
          isVoid: ctx.isVoid,
          fragment: Context.definedValue('hxx_fragment'),
          treatNested: function (children) return ctx.generateRoot.bind(children).bounce(),
        })
      );
    #end
  }
}

#if !macro
abstract Children(Array<Node>) from Array<Child> to Array<Node> {

  @:from static function ofString(s:String):Children 
    return [(s:Child)];

  @:from static function ofFragment(f:Fragment):Children 
    return [(f:Child)];
}

abstract Child(Node) from Node to Node {
  @:from static inline function ofString(s:String):Child
    return ofFragment(s);

  @:from static inline function ofFragment(fragment:Fragment):Child
    return Node.Text(fragment);
}
#end