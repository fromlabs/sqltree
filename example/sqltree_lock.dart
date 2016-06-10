// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:sqltree/sqltree.dart' as sql;

main() {
  var select = sql.select("*")
    ..from(sql.joins("tabella"))
    ..where(sql.equal("a", sql.parameter("par1")));

  // select.child = "errore 1";
  // print(sql.prettify(sql.format(select)));

  // print(sql.NULL.child);

  select.limitClause.child = 10;
  print(sql.prettify(sql.format(select)));

  // select.children.addAll(sql.text("errore 2"));
  // print(sql.prettify(sql.format(select)));

  // select.children.clear();
  // print(sql.prettify(sql.format(select)));
}
