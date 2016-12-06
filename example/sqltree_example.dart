// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:sqltree/sqltree.dart' as sql;

main() {
  var nodes3 = sql.node("USERS");

  var node3 = nodes3.single;
  node3.reference = "USERS";
  print(node3.reference);
  print(nodes3.single.reference);

  var nodes2 = sql.setReference("USERS", "USERS");
  print(nodes2.first.reference);

  var nodes = sql.node(sql.setReference("USERS", "USERS"));

  print(nodes);
  print(nodes.first.reference);

  sql
      .setReference("USERS", "USERS")
      .single
      .whereReference("USERS")
      .single
      .disable();

  var select2 = sql.select("USERS.ID")
    ..from(sql.setReference("USERS", "USERS"));

  // select2.fromClause.children.first.reference = "USERS";

  print(select2.fromClause.children.first.reference);

  print(sql.prettify(sql.format(select2)));

  print(select2.fromClause.children.first.reference);

  select2.whereReference("USERS").single.disable();

  sql.custom("ciao").clone();

  var select = sql.select("*")
    ..from(sql.joins("tabella"))
    ..where(sql.equal("a", sql.parameter("par1")))
    ..where(sql.setReference("ref1", sql.equal("b", sql.parameter("par2"))))
    ..where(sql.qualify("a", "1", "2", "3"))
    ..where(sql.setReference("ref2", sql.sqlInTuple("a")))
    ..where(sql.sqlIn("a", sql.setReference("ref3", sql.tuple())))
    ..where(sql.sqlInTuple("a"))
    ..limit(10)
    ..offset(200);

  select.whereClause.children.last.children.last.children
      .addAll(sql.text("OPEN", "CLOSED"));

  select.whereReference("ref1").single.disable();

  select
      .whereReference("ref2")
      .single
      .children
      .last
      .children
      .addAll(sql.text("OPEN", "CLOSED"));

  select
      .whereReference("ref3")
      .single
      .children
      .addAll(sql.text("OPEN", "CLOSED"));

  print(sql.prettify(sql.format(select)));

  var conversion = sql.convert(sql.format(select));

  print(sql.prettify(conversion.positionalParameterSql));
  print(conversion.positionalParameterNames);

  print(sql.prettify(sql.format(select.clone())));

  var cloned = select.clone();

  cloned.whereReference("ref1").single.disable();

  print(sql.prettify(sql.format(cloned)));

  // select.clone(freeze: true).getSingleNodeByReference("ref1").disable();
  // select.clone(freeze: true).clone().getSingleNodeByReference("ref1").disable();

  var freezed = select.clone(freeze: true).clone(freeze: false);

  freezed
      .whereReference("ref3")
      .single
      .children
      .addAll(sql.text("OPEN", "CLOSED"));

  print(sql.prettify(sql.format(freezed)));

  select = select.clone(freeze: false);

  print(select == select.clone(freeze: false));

  select = select.clone(freeze: true);

  print(select == select.clone(freeze: true));

  print(sql.prettify(sql.format(sql.text(r"ci'\'ao").single)));

  print(sql.prettify(
      sql.format(sql.select(sql.function("coalesce", "ID", "REF_ID")))));
}
