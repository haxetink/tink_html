package tink.html;

enum Node {
  Tag(name:Tag, attributes:Array<Named<Attribute>>, children:Array<Node>);
  Text(value:Fragment);
  Comment(value:Fragment);
}

class NodeTools {
  static public function map(n:Node, f:Node->Node)
    return switch n {
      case Tag(n, a, c) if (c != null): Tag(n, a, [for (c in c) f(c)]);
      default: n;
    }
}