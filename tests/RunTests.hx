package ;

import tink.html.*;
import haxe.unit.*;
import deepequal.DeepEqual;
import tink.html.Node;
using tink.CoreApi;

class RunTests extends TestCase {
  function tags() {
    
  }
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
  function testParser() {
    assertDeepEqual(
      [Text('wurst'), Comment(' foo '), Tag('div', [new Named<Attribute>('contenteditable', Attribute.EMPTY)], [Tag('img', [new Named<Attribute>('src', 'example.png')], null)])], 
      new Parser('wurst<!-- foo --><diV contenteditable><iMg src  = "example.png" ></Div>').parseHtml()
    );
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