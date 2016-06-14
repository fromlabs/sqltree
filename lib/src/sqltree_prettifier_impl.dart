import "sqltree_prettifier.dart";

class SqlPrettifierImpl implements SqlPrettifier {
  String prettify(String sql) {
    return new _FormatProcess(sql).perform();
  }
}

class _SqlGrammar {
  final Pattern _PATTERN = new RegExp(r'[A-Za-z_]');

  final Set<String> _BEGIN_CLAUSES = new Set<String>();
  final Set<String> _END_CLAUSES = new Set<String>();
  final Set<String> _LOGICAL = new Set<String>();
  final Set<String> _QUANTIFIERS = new Set<String>();
  final Set<String> _DML = new Set<String>();
  final Set<String> _MISC = new Set<String>();

  _SqlGrammar() {
    _BEGIN_CLAUSES.add("left");
    _BEGIN_CLAUSES.add("right");
    _BEGIN_CLAUSES.add("inner");
    _BEGIN_CLAUSES.add("outer");
    _BEGIN_CLAUSES.add("group");
    _BEGIN_CLAUSES.add("order");
    _BEGIN_CLAUSES.add("limit");
    _BEGIN_CLAUSES.add("offset");

    _END_CLAUSES.add("where");
    _END_CLAUSES.add("set");
    _END_CLAUSES.add("having");
    _END_CLAUSES.add("join");
    _END_CLAUSES.add("from");
    _END_CLAUSES.add("by");
    _END_CLAUSES.add("join");
    _END_CLAUSES.add("into");
    _END_CLAUSES.add("union");

    _LOGICAL.add("and");
    _LOGICAL.add("or");
    _LOGICAL.add("when");
    _LOGICAL.add("else");
    _LOGICAL.add("end");

    _QUANTIFIERS.add("in");
    _QUANTIFIERS.add("all");
    _QUANTIFIERS.add("exists");
    _QUANTIFIERS.add("some");
    _QUANTIFIERS.add("any");

    _DML.add("insert");
    _DML.add("update");
    _DML.add("delete");

    _MISC.add("select");
    _MISC.add("on");
  }

  bool isFunctionName(String tok) {
    var begin = tok[0];
    bool isIdentifier = isJavaIdentifierStart(begin) || '"' == begin;
    return isIdentifier &&
        !_LOGICAL.contains(tok) &&
        !_END_CLAUSES.contains(tok) &&
        !_QUANTIFIERS.contains(tok) &&
        !_DML.contains(tok) &&
        !_MISC.contains(tok);
  }

  bool isJavaIdentifierStart(String begin) => begin.startsWith(_PATTERN);
}

class _FormatProcess {
  static final Pattern _PATTERN =
      new RegExp("""[()+*/=<>'`"[\\], \n\r\f\t-]""");
  static final _SqlGrammar _grammar = new _SqlGrammar();

  static final String _WHITESPACE = " \n\r\f\t";
  // static final String indentString = "    ";
  static final String indentString = "  ";
  // static final String initial = "\n    ";
  static final String initial = "";

  bool beginLine = true;
  bool afterBeginBeforeEnd = false;
  bool afterByOrSetOrFromOrSelect = false;
  bool afterValues = false;
  bool afterOn = false;
  bool afterBetween = false;
  bool afterInsert = false;
  int inFunction = 0;
  int parensSinceSelect = 0;
  List<int> parenCounts = [];
  List<bool> afterByOrFromOrSelects = [];

  int indent = 1;

  StringBuffer result = new StringBuffer();
  Iterator<String> tokens;
  String lastToken;
  String token;
  String lcToken;

  _FormatProcess(String sql) {
    tokens = tokenize(sql, _PATTERN).iterator;
  }

  String perform() {
    result.write(initial);

    while (tokens.moveNext()) {
      token = tokens.current;
      lcToken = token.toLowerCase();

      if ("'" == token) {
        String t;
        // cannot handle single quotes
        while ("'" != t && tokens.moveNext()) {
          t = tokens.current;
          token += t;
        }
      } else if ("\"" == token) {
        String t;
        while ("\"" != t && tokens.moveNext()) {
          t = tokens.current;
          token += t;
        }
      }

      if (afterByOrSetOrFromOrSelect && "," == token) {
        commaAfterByOrFromOrSelect();
      } else if (afterOn && "," == token) {
        commaAfterOn();
      } else if ("(" == token) {
        openParen();
      } else if (")" == token) {
        closeParen();
      } else if (_grammar._BEGIN_CLAUSES.contains(lcToken)) {
        beginNewClause();
      } else if (_grammar._END_CLAUSES.contains(lcToken)) {
        endNewClause();
      } else if ("select" == lcToken) {
        select();
      } else if (_grammar._DML.contains(lcToken)) {
        updateOrInsertOrDelete();
      } else if ("values" == lcToken) {
        values();
      } else if ("on" == lcToken) {
        on();
      } else if (afterBetween && lcToken == "and") {
        misc();
        afterBetween = false;
      } else if (_grammar._LOGICAL.contains(lcToken)) {
        logical();
      } else if (isWhitespace(token)) {
        white();
      } else {
        misc();
      }

      if (!isWhitespace(token)) {
        lastToken = lcToken;
      }
    }
    return result.toString();
  }

  void commaAfterOn() {
    out();
    indent--;
    newline();
    afterOn = false;
    afterByOrSetOrFromOrSelect = true;
  }

  void commaAfterByOrFromOrSelect() {
    out();
    newline();
  }

  void logical() {
    if ("end" == lcToken) {
      indent--;
    }
    newline();
    out();
    beginLine = false;
  }

  void on() {
    indent++;
    afterOn = true;
    newline();
    out();
    beginLine = false;
  }

  void misc() {
    out();
    if ("between" == lcToken) {
      afterBetween = true;
    }
    if (afterInsert) {
      newline();
      afterInsert = false;
    } else {
      beginLine = false;
      if ("case" == lcToken) {
        indent++;
      }
    }
  }

  void white() {
    if (!beginLine) {
      result.write(" ");
    }
  }

  void updateOrInsertOrDelete() {
    out();
    indent++;
    beginLine = false;
    if ("update" == lcToken) {
      newline();
    }
    if ("insert" == lcToken) {
      afterInsert = true;
    }
  }

  void select() {
    out();
    indent++;
    newline();
    parenCounts.add(parensSinceSelect);
    afterByOrFromOrSelects.add(afterByOrSetOrFromOrSelect);
    parensSinceSelect = 0;
    afterByOrSetOrFromOrSelect = true;
  }

  void out() {
    result.write(token);
  }

  void endNewClause() {
    if (!afterBeginBeforeEnd) {
      indent--;
      if (afterOn) {
        indent--;
        afterOn = false;
      }
      newline();
    }
    out();
    if ("union" != lcToken) {
      indent++;
    }
    newline();
    afterBeginBeforeEnd = false;
    afterByOrSetOrFromOrSelect =
        "by" == lcToken || "set" == lcToken || "from" == lcToken;
  }

  void beginNewClause() {
    if (!afterBeginBeforeEnd) {
      if (afterOn) {
        indent--;
        afterOn = false;
      }
      indent--;
      newline();
    }
    out();
    beginLine = false;
    afterBeginBeforeEnd = true;
  }

  void values() {
    indent--;
    newline();
    out();
    indent++;
    newline();
    afterValues = true;
  }

  void closeParen() {
    parensSinceSelect--;
    if (parensSinceSelect < 0) {
      indent--;
      parensSinceSelect = parenCounts.removeLast();
      afterByOrSetOrFromOrSelect = afterByOrFromOrSelects.removeLast();
    }
    if (inFunction > 0) {
      inFunction--;
      out();
    } else {
      if (!afterByOrSetOrFromOrSelect) {
        indent--;
        newline();
      }
      out();
    }
    beginLine = false;
  }

  void openParen() {
    if (_grammar.isFunctionName(lastToken) || inFunction > 0) {
      inFunction++;
    }
    beginLine = false;
    if (inFunction > 0) {
      out();
    } else {
      out();
      if (!afterByOrSetOrFromOrSelect) {
        indent++;
        newline();
        beginLine = true;
      }
    }
    parensSinceSelect++;
  }

  static bool isWhitespace(String token) {
    return _WHITESPACE.indexOf(token) >= 0;
  }

  void newline() {
    result.writeln();
    for (int i = 0; i < indent; i++) {
      result.write(indentString);
    }
    beginLine = true;
  }

  Iterable<String> tokenize(String query, Pattern pattern) sync* {
    var matches = pattern.allMatches(query);

    var start = 0;
    var end;
    var token;
    for (var match in matches) {
      end = match.start;
      token = query.substring(start, end);
      if (token.isNotEmpty) {
        yield token;
        start = end;
      }

      end = start + 1;
      token = query.substring(start, end);
      if (token.isNotEmpty) {
        yield token;
        start = end;
      }
    }
    token = query.substring(start);
    if (token.isNotEmpty) {
      yield token;
      start = end;
    }
  }
}
