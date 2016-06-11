// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

abstract class SqlNamedParameterConverter {
  SqlNamedParameterConversion convert(String namedParametersSql);
}

abstract class SqlNamedParameterConversion {
  String get positionalParameterSql;

  List<String> get positionalParameterNames;

  List applyNamedParameterValues(Map<String, dynamic> namedParameters);
}
