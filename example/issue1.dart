class Node {}

class NodeWrapper<T extends Node> {
  T wrapped;
}

main() {
  NodeWrapper<Node> nodeWrapper = new NodeWrapper<Node>();
  // nodeWrapper.wrapped = 10; // ERRORE
  nodeWrapper.wrapped = new Node(); // OK

  NodeWrapper wrapper = new NodeWrapper();
  wrapper.wrapped = 10; // ???
  wrapper.wrapped = new Node(); // OK
}
