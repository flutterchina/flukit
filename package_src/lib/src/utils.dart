import 'dart:async';
import 'package:flutter/material.dart';

bool isListEqual(List? a, List? b) {
  if (a == b) return true;
  if (a == null || b == null || a.length != b.length) return false;
  int i = 0;
  return a.every((e) => b[i++] == e);
}

VoidCallback debounce(
  VoidCallback func, [
  Duration delay = const Duration(milliseconds: 400),
]) {
  Timer? timer;
  return () {
    if (timer?.isActive == true) {
      timer?.cancel();
    }
    timer = Timer(delay, () {
      func.call();
    });
  };
}

typedef Arg1Callback<T> = void Function(T);

Arg1Callback<T> debounceArg1<T>(
  Arg1Callback<T> func, [
  Duration delay = const Duration(milliseconds: 2000),
]) {
  Timer? timer;
  return (T arg) {
    if (timer?.isActive == true) {
      timer?.cancel();
    }
    timer = Timer(delay, () {
      func.call(arg);
    });
  };
}
