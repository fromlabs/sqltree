// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "package:sqltree/sqltree.dart" as sql;

void main() {
  var st1 = sql.insert("TABELLA")
    ..columns("C1", "C2", "C3")
    ..values(sql.text("V1"), sql.text("V2"), sql.text("V3"));

  print(sql.prettify(sql.format(st1)));

  var st2 = sql.insert("TABELLA")
    ..set(sql.equal("C1", sql.text("V1")), sql.equal("C2", sql.text("V2")),
        sql.equal("C3", sql.text("V3")));

  print(sql.prettify(sql.format(st2)));
}
