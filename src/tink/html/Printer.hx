package tink.html;

class Printer {
  static public function print(node:Node):Fragment {
    return new Fragment(switch node {
      case Comment(v): '<!--$v-->';
      case Text(v): v;
      case Tag(name, attrs, c): 
        var tag = '<$name';
        for (a in attrs)
          tag += a.name + switch a.value {
            case Attribute.EMPTY: '';
            case v: '="$v"';
          }
        tag = '$tag>';
        if (c == null) tag;
        else {
          for (n in c) tag += print(n);
          '$tag</$name>'; 
        }
      default: throw 'what?';
    });
  }
}