package tink.html;

import tink.html.Node;
import tink.parse.Char.*;
import tink.parse.ParserBase;
import tink.parse.StringSlice;

typedef Pos = {
  var min(default, never):Int;
  var max(default, never):Int;
}

class Parser extends ParserBase<Pos, Pair<String, Pos>> {

  function parseChildren(?closing:TagName):Array<Node> {
    var ret = [];

    function text(s:StringSlice)
      if (s.length > 0)
        ret.push(Text(new Fragment(s)));
    
    while (pos < max) 
      switch upto('<', false) {
        case Failure(_): 
          text(source.after(pos));
          break;
        case Success(v):
          text(v);
          if (allowHere('/')) {
            if (closing == null) die('unexpected </');
            else {
              var found = ident().sure() + wi(expect.bind('>'));
              if ((found.toString():TagName) == closing) {
                closing = null;
                break;
              }
              else die('Expected $closing but found $found', found.start...found.end);
            }
          }
          else if (allowHere('!--')) 
            switch upto('-->') {
              case Failure(_): die('unclosed comment');
              case Success(v): ret.push(Comment(new Fragment(v)));
            }
          else ret.push(open());
      }
    if (closing != null)
      die('Unclosed <$closing>');
    return ret;
  }
  var ignoreWhite:Bool = false;

  override function doSkipIgnored()
    if (ignoreWhite) readWhile(WHITE);

  function wi<T>(f:Void->T):T {
    ignoreWhite = true;
    var ret = f();//TODO: use Error.tryFinally
    ignoreWhite = false;
    return ret;
  }

  function open() {
    var raw = ident(true).sure(),
        attr = [];
    var tag:TagName = (raw:String);
    var selfClosing = wi(function () {
      while (pos < max) {
        switch ident() {
          case Failure(_): break;
          case Success(name):
            attr.push(new Named(
              name,             
              if (allow('=')) 
                new Attribute(parseString())
              else
                Attribute.EMPTY
            ));
        }
      }
      return
        if (allow('/>')) {
          //TODO: warn here
          true;
        }
        else expect('>') + false;
    });
    return Tag(
      tag, 
      attr, 
      if (tag.isVoid()) null 
      else if (selfClosing) [] 
      else parseChildren(tag)
    );
  }

  override function makeError(message:String, pos:Pos) 
    return new Pair(message, pos);

  override function doMakePos(from:Int, to:Int):Pos
    return { min: from, max: to };

  function skipWhite():Continue {
    doReadWhile(WHITE);
    return null;
  }
  
  function parseString() {
    var end = 
      if (allow("'")) "'";
      else {
        expect('"');
        '"';
      }
    return upto(end).sure();
  }

  static public function parse(html)
    return new Parser(html).parseChildren();

  static var IDENT_START = UPPER || LOWER || '_'.code;
  static var IDENT_CONTD = IDENT_START || DIGIT || '-'.code || '.'.code;
  
  function ident(here = false) 
    return 
      if ((here && is(IDENT_START)) || (!here && upNext(IDENT_START)))
        Success(readWhile(IDENT_CONTD));
      else 
        Failure(makeError('Identifier expected', makePos(pos)));    
}