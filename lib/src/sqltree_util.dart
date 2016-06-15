// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

Iterable getVargsIterable(
        [arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9]) =>
    [arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9]
        .where((arg) => arg != null);

bool isEmptyString(String string) => string?.isEmpty ?? true;

bool isNotEmptyString(String string) => !isEmptyString(string);

String formatByRule(Iterable<String> formattedChildren,
    {String prefix,
    String separator,
    String postfix,
    bool isFormatEmptyChildrenEnabled: false}) {
  if (formattedChildren.isNotEmpty || isFormatEmptyChildrenEnabled) {
    StringBuffer buffer = new StringBuffer();

    if (isNotEmptyString(prefix)) {
      buffer.write(prefix);
    }

    if (formattedChildren != null) {
      buffer.write(formattedChildren.join(separator ?? ""));
    }

    if (isNotEmptyString(postfix)) {
      buffer.write(postfix);
    }

    return buffer.toString();
  } else {
    return "";
  }
}