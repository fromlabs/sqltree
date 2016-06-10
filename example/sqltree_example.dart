// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:sqltree/sqltree.dart' as sql;

main() {
  var select = sql.select("*")
        ..from(sql.joins("tabella"))
        ..where(sql.equal("a", sql.parameter("par1")))
        ..where(sql.group("ref1", sql.equal("b", sql.parameter("par2"))))
        ..where(sql.qualify("a", "1", "2", "3"))
        ..where(sql.group("ref2", sql.sqlInTuple("a")))
        ..where(sql.sqlIn("a", sql.group("ref3", sql.tuple())))
        ..where(sql.sqlInTuple("a"))
      //..where(sql.enabled(true, sql.equal("b", sql.parameter("par2"))))
      //..where(sql.enabledGroup("ref1", true, sql.equal("b", sql.parameter("par2"))))
      ;

  select.whereClause.children.last.children.last
      .addChildren(sql.text("OPEN", "CLOSED"));

  select.getSingleNodeByReference("ref1").disable();

  select
      .getSingleNodeByReference("ref2")
      .child
      .children
      .last
      .addChildren(sql.text("OPEN", "CLOSED"));

  select
      .getSingleNodeByReference("ref3")
      .child
      .addChildren(sql.text("OPEN", "CLOSED"));

  print(sql.prettify(sql.format(select)));

  var conversion = sql.convert(sql.format(select));

  print(sql.prettify(conversion.positionalParameterSql));
  print(conversion.positionalParameterNames);

  print(sql.prettify(sql.format(select.clone())));
}
