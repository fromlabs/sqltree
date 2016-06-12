// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:sqltree/sqltree.dart' as sql;

main() {
  sql.normalize("ciao").single.clone();

  var select = sql.select("*")
        ..from(sql.joins("tabella"))
        ..where(sql.equal("a", sql.parameter("par1")))
        ..where(sql.setReference("ref1", sql.equal("b", sql.parameter("par2"))))
        ..where(sql.qualify("a", "1", "2", "3"))
        ..where(sql.setReference("ref2", sql.sqlInTuple("a")))
        ..where(sql.sqlIn("a", sql.setReference("ref3", sql.tuple())))
        ..where(sql.sqlInTuple("a"))
      //..where(sql.enabled(true, sql.equal("b", sql.parameter("par2"))))
      //..where(sql.enabledGroup("ref1", true, sql.equal("b", sql.parameter("par2"))))
      ;

  select.whereClause.children.last.children.last
      .addChildren(sql.text("OPEN", "CLOSED"));

  select.getSingleNodeByReference("ref1").disable();

  select
      .getSingleNodeByReference("ref2")
      .children
      .last
      .addChildren(sql.text("OPEN", "CLOSED"));

  select
      .getSingleNodeByReference("ref3")
      .addChildren(sql.text("OPEN", "CLOSED"));

  print(sql.prettify(sql.format(select)));

  var conversion = sql.convert(sql.format(select));

  print(sql.prettify(conversion.positionalParameterSql));
  print(conversion.positionalParameterNames);

  print(sql.prettify(sql.format(select.clone())));

  var cloned = select.clone();

  cloned.getSingleNodeByReference("ref1").disable();

  print(sql.prettify(sql.format(cloned)));

  // select.clone(freeze: true).getSingleNodeByReference("ref1").disable();
  // select.clone(freeze: true).clone().getSingleNodeByReference("ref1").disable();

  var freezed = select.clone(freeze: true).clone(freeze: false);

  freezed
      .getSingleNodeByReference("ref3")
      .addChildren(sql.text("OPEN", "CLOSED"));

  print(sql.prettify(sql.format(freezed)));

  select = select.clone(freeze: false);

  print(select == select.clone(freeze: false));

  select = select.clone(freeze: true);

  print(select == select.clone(freeze: true));
}
