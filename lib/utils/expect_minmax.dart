import 'dart:math';

class Node {
  int value;
  Node left, right;
}

// ignore: camel_case_types
class expecMinMax extends Node {
// Initializing Nodes to null
  static Node newNode(int v) {
    Node temp = new Node();
    temp.value = v;
    temp.left = null;
    temp.right = null;
    return temp;
  }

  // Getting expectimax
  static double expectimax(Node node, bool isMax) {
    // Condition for Terminal node
    if (node.left == null && node.right == null) {
      var nodeVal = node.value.toDouble();
      return nodeVal;
    }

    // Maximizer node. Chooses the max from the
    // left and right sub-trees
    if (isMax) {
      return max(expectimax(node.left, false), expectimax(node.right, false));
    }

    // Chance node. Returns the average of
    // the left and right sub-trees
    else {
      return (expectimax(node.left, true) + expectimax(node.right, true)) / 2.0;
    }
  }
}
