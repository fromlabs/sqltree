// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:sqltree/sqltree.dart' as sql;

main() {
  var select = sql.select("*")
        ..from(sql.joins("tabella"))
        ..where(sql.equal("a", sql.parameter("par1")))
        ..where(sql.group("ref1", sql.equal("b", sql.parameter("par2"))))
        ..where(sql.qualify("a", "1", "2", "3"))
      //..where(sql.enabled(true, sql.equal("b", sql.parameter("par2"))))
      //..where(sql.enabledGroup("ref1", true, sql.equal("b", sql.parameter("par2"))))
      ;

  print(sql.prettify(sql.format(select)));

  var conversion = sql.convert(sql.format(select));

  print(sql.prettify(conversion.positionalParameterSql));
  print(conversion.positionalParameterNames);

  select.whereClause.getChild(1).disable();

  print(sql.prettify(sql.format(select)));

  conversion = sql.convert(sql.format(select));

  print(sql.prettify(conversion.positionalParameterSql));
  print(conversion.positionalParameterNames);
}
