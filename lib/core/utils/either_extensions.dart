import 'package:dartz/dartz.dart';
import 'package:flutter/widgets.dart';

extension EitherExtensions<L, R> on Either<L, R> {
  R getRight() => (this as Right<L, R>).value;

  L getLeft() => (this as Left<L, R>).value;

  Widget when({
    required Widget Function(L failure) failure,
    required Widget Function(R data) success,
  }) {
    return fold(failure, success);
  }

  Either<L, T> flatMap<T>(Either<L, T> Function(R r) f) {
    return fold(Left.new, f);
  }
}
