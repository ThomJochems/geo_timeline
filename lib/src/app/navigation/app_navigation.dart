import 'package:flutter/widgets.dart';

import 'app_route.dart';

extension AppNavigation on BuildContext {
  Future<T?> pushRoute<T extends Object?>(
    AppRoute route, {
    Object? arguments,
  }) {
    return Navigator.of(this).pushNamed<T>(
      route.path,
      arguments: arguments,
    );
  }

  Future<T?> replaceWithRoute<T extends Object?, TO extends Object?>(
    AppRoute route, {
    Object? arguments,
    TO? result,
  }) {
    return Navigator.of(this).pushReplacementNamed<T, TO>(
      route.path,
      arguments: arguments,
      result: result,
    );
  }

  void popRoute<T extends Object?>([T? result]) {
    return Navigator.of(this).pop<T>(result);
  }
}
