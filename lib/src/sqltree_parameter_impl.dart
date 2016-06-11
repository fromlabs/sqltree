// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import "package:collection/collection.dart";

import "sqltree_parameter.dart";

class SqlNamedParameterConverterImpl implements SqlNamedParameterConverter {
  static final Pattern PATTERN = new RegExp(r"\${([\w_\.]+)}");

  SqlNamedParameterConversion convert(String namedParametersSql) {
    String convertedSql = namedParametersSql;
    List<String> parameters = [];
    for (var match
        in PATTERN.allMatches(namedParametersSql).toList().reversed) {
      convertedSql =
          "${convertedSql.substring(0, match.start)}?${convertedSql.substring(match.end)}";
      parameters.insert(0, match.group(1));
    }

    return new SqlNamedParameterConversionImpl(convertedSql, parameters);
  }
}

class SqlNamedParameterConversionImpl implements SqlNamedParameterConversion {
  final String positionalParameterSql;

  final List<String> positionalParameterNames;

  SqlNamedParameterConversionImpl(
      this.positionalParameterSql, List<String> positionalParameterNames)
      : this.positionalParameterNames =
            new UnmodifiableListView(positionalParameterNames);

  List applyNamedParameterValues(Map<String, dynamic> namedParameters) {
    List result = [];

    for (String parameter in positionalParameterNames) {
      if (namedParameters.containsKey(parameter)) {
        result.add(namedParameters[parameter]);
      } else {
        throw new ArgumentError("Parameter not exist: $parameter");
      }
    }

    return result;
  }
}
