package tink.html;

enum Node {
  Tag(name:TagName, attributes:Array<Named<Attribute>>, children:Array<Node>);
  Text(value:Fragment);
  Comment(value:Fragment);
}

class NodeTools {
  static public function traverse(n:Node)
    return new NodeIterator(n);

  static public function mapInward(n:Node, f:Node->Node) 
    return switch f(n) {
      case Tag(name, attr, c) if (c != null): Tag(name, attr, [for (c in c) mapInward(c, f)]);
      case v: v;
    }

  static public function mapOutward(n:Node, f:Node->Node) 
    return f(switch n {
      case Tag(name, attr, c) if (c != null): Tag(name, attr, [for (c in c) mapOutward(c, f)]);
      default: n;
    });

  static public function map(n:Node, f:Node->Node)
    return switch n {
      case Tag(name, attr, c) if (c != null): Tag(name, attr, [for (c in c) f(c)]);
      default: f(n);
    }
}

class NodeIterator {
  var todo:Array<Node>;

  public function new(n) {
    todo = [n];
  }
  public inline function hasNext() 
    return todo.length > 0;
  
  public function next() {
    //TODO: the below operations are not particularly memory efficient outside the JS target
    var next = todo.shift();
    switch next {
      case Tag(_, _, c) if (c != null): todo = todo.concat(c);
      default:
    }
    return next;
  }
}
