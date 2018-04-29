package ;

import tink.html.*;
import tink.html.Parser.parse in html;
import haxe.unit.*;
import deepequal.DeepEqual;
using tink.html.Node;
using tink.CoreApi;

class RunTests extends TestCase {
  function assertDeepEqual<A>(a:A, b:A, ?pos:haxe.PosInfos) {
    switch DeepEqual.compare(a, b, pos) {
      case Failure(e):
        currentTest.success = false;
        currentTest.posInfos = pos;
        currentTest.error = e.message;
        throw currentTest;
      case Success(_): 
        assertTrue(true);
    }
  }

  function testIterator() {
    var found = [
      for (n in html('<div><h1>A list:</h1><ul><li>First</li><li>Second</li><li>Last, but not <strong>Least</strong></li></ul></div>')[0].traverse()) {
        switch n {
          case Tag(name, _, _): '<$name>';
          case Text(s): '"$s"';
          case Comment(s): '//$s';
        }
      }
    ];
    assertEquals('<div>,<h1>,<ul>,"A list:",<li>,<li>,<li>,"First","Second","Last, but not ",<strong>,"Least"', found.join(','));
  }
  function testParser() {
    assertDeepEqual(
      [Text('wurst'), Comment(' foo '), Tag('div', [new Named<Attribute>('contenteditable', Attribute.EMPTY)], [Tag('img', [new Named<Attribute>('src', 'example.png')], null)])], 
      html('wurst<!-- foo --><diV contenteditable><iMg src  = "example.png" ></Div>')
    );
  }

  function testHxx() {
    tink.html.Tags.hxx('<div><a href="http://example.com">Test</a></div>');
    assertTrue(true);
  }

  function testPrinter() {
    inline function expect(s:String, n, ?pos:haxe.PosInfos)
      assertEquals(s, Printer.print(n), pos);

    expect('<div></div>', Tag('div', [], []));
    expect('<br>', Tag('br', [], null));
    expect('<div>Love &gt; Hate</div>', Tag('div', [], [Text('Love > Hate')]));
    expect('<div>Say "what" one more time</div>', Tag('div', [], [Text('Say "what" one more time')]));
    
  }

  static function main() {
    var runner = new TestRunner();
    runner.add(new RunTests());
    travix.Logger.exit(
      if (runner.run()) 0
      else 500
    );
  }
  
}