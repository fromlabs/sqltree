// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.


// TODO rinominare con qualcosa che dica che comprime (toglie i null) i varagrs in una lista

List getNodes(
    node0, node1, node2, node3, node4, node5, node6, node7, node8, node9) {
  var nodes = [
    node0,
    node1,
    node2,
    node3,
    node4,
    node5,
    node6,
    node7,
    node8,
    node9
  ];

  nodes.removeWhere((node) => node == null);

  return nodes;
}

bool isEmptyString(String string) => string?.isEmpty ?? true;

bool isNotEmptyString(String string) => !isEmptyString(string);
