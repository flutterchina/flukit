import 'package:flukit/flukit.dart';
import 'package:flutter/widgets.dart';

/// A box constraints with extra information.
///
/// See also:
///   * [SliverFlexibleHeader], which use [ExtraInfoBoxConstraints].
///   * [SliverPersistentHeaderToBox], which use [ExtraInfoBoxConstraints].
class ExtraInfoBoxConstraints<T> extends BoxConstraints {
  ExtraInfoBoxConstraints(
    this.extra,
    BoxConstraints constraints,
  ) : super(
          minWidth: constraints.minWidth,
          minHeight: constraints.minHeight,
          maxWidth: constraints.maxWidth,
          maxHeight: constraints.maxHeight,
        );

  //滑动方向
  final T extra;

  BoxConstraints asBoxConstraints() => copyWith();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ExtraInfoBoxConstraints &&
        super == other &&
        other.extra == extra;
  }

  @override
  int get hashCode {
    return hashValues(super.hashCode, extra);
  }
}
