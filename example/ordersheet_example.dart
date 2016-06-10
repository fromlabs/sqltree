// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

import 'package:sqltree/sqltree.dart' as sql;
import "ordersheet_sql.dart" as orderSheetSql;

main() {
  test1();

  test2();
}

test1() {
  var groupConcatNode = sql.function("GROUP_CONCAT2",
      "DISTINCT(IF(u2.nom_uff_bo ='', NULL, u2.nom_uff_bo)) SEPARATOR ', ')");

  var replaceNode =
      sql.function("REPLACE2", groupConcatNode, sql.text("OBS "), sql.text(""));

  var select = sql.select(
      "modelli.*",
      "ordersheet_info.*",
      "reparti.*",
      "u1.des_nome",
      "u1.des_cognome",
      "funzioni.*",
      "fornitori.*",
      sql.as(replaceNode, "cond_obs"))
    ..from(sql.joins(
        "modelli",
        sql.join("ordersheet_info",
            sql.equal("ordersheet_info.prog_riga", "modelli.pro_riga")),
        sql.join(
            "reparti", sql.equal("reparti.nm_reparto", "modelli.nm_reparto")),
        sql.join(sql.as("utenti", "u1"),
            sql.equal("u1.profilo", "reparti.profilo_compr")),
        sql.leftJoin("funzioni",
            sql.equal("funzioni.od_funzione", "modelli.od_funzione")),
        sql.leftJoin("fornitori",
            sql.equal("modelli.od_fornitore", "fornitori.od_fornitore")),
        sql.leftJoin("condivisioni",
            sql.equal("modelli.pro_riga", "condivisioni.pro_riga")),
        sql.leftJoin(sql.as("utenti", "u2"), sql.equal("condivisioni.utente_destinatario", "u2.profilo"), sql.equal("u2.codice_ruolo_app", 4)),
        sql.join(sql.as("utenti_reparti", "ur"), sql.equal("modelli.nm_reparto", "ur.num_reparto"), sql.equal("ur.annullato", false), sql.equal("ur.profilo", sql.parameter()))))
    ..where(sql.equal("modelli.annullato", 0), sql.notEqual("modelli.des_art_mod", sql.text("#je-test")), sql.equal("modelli.anno_tag", sql.parameter()), sql.equal("modelli.od_periodo", sql.parameter()), sql.equal("modelli.nm_reparto", sql.parameter()))
    ..groupBy("ordersheet_info.prog_riga");

  print(sql.prettify(sql.format(select)));
}

test2() {
  var replaceNode = orderSheetSql.replace(
      orderSheetSql.groupConcat(orderSheetSql.ifThen(
          sql.equal("u2.nom_uff_bo", sql.text("")), sql.NULL, "u2.nom_uff_bo"))
        ..distinct()
        ..separator(sql.text(", ")),
      sql.text("OBS "),
      sql.text(""));

  var select = sql.select(
      "modelli.*",
      "ordersheet_info.*",
      "reparti.*",
      "u1.des_nome",
      "u1.des_cognome",
      "funzioni.*",
      "fornitori.*",
      sql.as(replaceNode, "cond_obs"))
    ..from(sql.joins(
        "modelli",
        sql.join("ordersheet_info",
            sql.equal("ordersheet_info.prog_riga", "modelli.pro_riga")),
        sql.join(
            "reparti", sql.equal("reparti.nm_reparto", "modelli.nm_reparto")),
        sql.join(sql.as("utenti", "u1"),
            sql.equal("u1.profilo", "reparti.profilo_compr")),
        sql.leftJoin("funzioni",
            sql.equal("funzioni.od_funzione", "modelli.od_funzione")),
        sql.leftJoin("fornitori",
            sql.equal("modelli.od_fornitore", "fornitori.od_fornitore")),
        sql.leftJoin("condivisioni",
            sql.equal("modelli.pro_riga", "condivisioni.pro_riga")),
        sql.leftJoin(sql.as("utenti", "u2"), sql.equal("condivisioni.utente_destinatario", "u2.profilo"), sql.equal("u2.codice_ruolo_app", 4)),
        sql.join(sql.as("utenti_reparti", "ur"), sql.equal("modelli.nm_reparto", "ur.num_reparto"), sql.equal("ur.annullato", false), sql.equal("ur.profilo", sql.parameter()))))
    ..where(sql.equal("modelli.annullato", 0), sql.notEqual("modelli.des_art_mod", sql.text("#je-test")), sql.equal("modelli.anno_tag", sql.parameter()), sql.equal("modelli.od_periodo", sql.parameter()), sql.equal("modelli.nm_reparto", sql.parameter()))
    ..groupBy("ordersheet_info.prog_riga");

  print(sql.prettify(sql.format(select)));

  var conversion = sql.convert(sql.format(select));

  print(sql.prettify(conversion.positionalParameterSql));
  print(conversion.positionalParameterNames);
}
