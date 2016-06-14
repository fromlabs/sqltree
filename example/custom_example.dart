// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:sqltree/sqltree.dart' as sql;
import "custom/custom_sql.dart" as custom;

main() {
  var replaceNode = custom.replace(
      custom.groupConcat(custom.ifThen(
          sql.equal("u2.col1", sql.text("")), sql.NULL, "u2.col1"))
        ..distinct()
        ..separator(sql.text(", ")),
      sql.text("OBS "),
      sql.text(""));

  var select = sql.select("table1.*", "table2.*", "table3.*", "u1.col2",
      "u1.col3", "table4.*", "table5.*", sql.as(replaceNode, "alias1"))
    ..from(sql.joins(
        "table1",
        sql.join("table2", sql.equal("table2.col4", "table1.col5")),
        sql.join("table3", sql.equal("table3.col6", "table1.col6")),
        sql.join(sql.as("table8", "u1"), sql.equal("u1.col8", "table3.col7")),
        sql.leftJoin("table4", sql.equal("table4.col9", "table1.col9")),
        sql.leftJoin("table5", sql.equal("table1.col10", "table5.col10")),
        sql.leftJoin("table6", sql.equal("table1.col5", "table6.col5")),
        sql.leftJoin(sql.as("table8", "u2"),
            sql.equal("table6.col11", "u2.col8"), sql.equal("u2.col12", 4)),
        sql.join(
            sql.as("table7", "ur"),
            sql.equal("table1.col6", "ur.col13"),
            sql.equal("ur.col14", false),
            sql.equal("ur.col8", sql.parameter()))))
    ..where(
        sql.equal("table1.col14", 0),
        sql.notEqual("table1.col15", sql.text("#key")),
        sql.equal("table1.col16", sql.parameter()),
        sql.equal("table1.col17", sql.parameter()),
        sql.equal("table1.col6", sql.parameter()))
    ..groupBy("table2.col4");

  print(sql.prettify(sql.format(select)));
}
