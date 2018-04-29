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
    #if (tink_domspec && tink_hxx)
  
    static var tags = {
      var ret = {
        opaque: new Array<ClassField>(),
        void: new Array<ClassField>(),
        normal: new Array<ClassField>(),
      };

      for (g in Context.getType('tink.domspec.Tags').getFields().sure()) {
        var kind = switch g.name {
          case 'normal': ret.normal;
          case 'opaque': ret.opaque;
          case 'void': ret.void;
          default: continue;
        }
        
        for (t in g.type.getFields().sure()) 
          kind.push(t);
        
      }

      ret;
    };
    #end

  static function build() {
    #if !(tink_domspec && tink_hxx)
      return Context.fatalError('using tink.html.Tags requires -lib tink_domspec and -lib tink_hxx', Context.currentPos());
    #else  
    var fields = Context.getBuildFields();

    function add(f:ClassField, ?children:ComplexType)
      fields.push({
        name: f.name,
        pos: f.pos,
        access: [AStatic, APublic],
        kind: FFun({
          ret: macro : tink.html.Node,
          args: 
            [{ name: 'attr', type: f.type.toComplex(), opt: false }].concat(
              if (children == null) []
              else [{ name: 'children', type: children, opt: true }]
            ),
          expr: 
            if (children == null)
              macro return h($v{f.name}, cast attr)
            else
              macro return h($v{f.name}, cast attr, children),
        }),
      });    

    var children = macro : Array<tink.html.Tags.Child>;
    for (f in tags.normal)
      add(f, children); 

    for (f in tags.void)
      add(f); 

    for (f in tags.opaque)
      add(f, macro : tink.html.Fragment);
    
    return fields;
    #end
  }
  #end
  macro static public function hxx(e:Expr) {
    #if !(tink_hxx && tink_domspec)
      return Context.fatalError('must compile with -lib tink_hxx and -lib tink_domspec to enable HXX support', Context.currentPos());
    #else
      var p = tink.hxx.Parser.parseRoot(e, {
        defaultExtension: 'hxx',
        isVoid: [for (f in tags.void) f.name => true].get
      });
      return new Generator(Generator.extractTags(macro tink.html.Tags)).root(p);
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