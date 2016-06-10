// Copyright (c) 2016, Roberto Tassi. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

List getVargsList(
    [arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9]) {
  var args = [arg0, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9];

  args.removeWhere((arg) => arg == null);

  return args;
}

bool isEmptyString(String string) => string?.isEmpty ?? true;

bool isNotEmptyString(String string) => !isEmptyString(string);
