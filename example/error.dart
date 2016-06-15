// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:sqltree/sqltree.dart' as sql;

main() {
  var nodes = sql.normalize("USERS");

  var reference = "U";

  nodes = nodes.map((node) => node..reference = reference);

  print(nodes.first.reference);

  if (nodes.first.reference != "U") {
    throw new StateError("Error");
  }
}
