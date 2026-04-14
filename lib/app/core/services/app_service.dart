import 'package:easy_flutter_boilerplate/app/di/initializer/di_initializer.dart';
import 'package:easy_flutter_boilerplate/app/di/service_locator.dart';
import 'package:easy_flutter_boilerplate/app/routes/app_router.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppService {
  AppService._internal();

  static final AppService _instance = AppService._internal();

  factory AppService() => _instance;

  static BuildContext get context =>
      appRouter.routerDelegate.navigatorKey.currentContext!;

  static String? get currentRouteName =>
      appRouter.routerDelegate.currentConfiguration.last.route.name;

  Future<void> start() async {
    await DiInitializer().init();
  }

  /// Resets all registered dependencies and re-initializes the DI graph.
  Future<void> reset() async {
    await getIt.reset();
    await DiInitializer().init();
  }

  RouteMatchList get _matchList {
    final RouteMatch lastMatch =
        appRouter.routerDelegate.currentConfiguration.last;
    return lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : appRouter.routerDelegate.currentConfiguration;
  }

  Object? get argument => _matchList.extra;

  Map<String, String> get queryParams => _matchList.uri.queryParameters;

  Map<String, String> get pathParams => _matchList.pathParameters;

  bool get hasQuery => _matchList.uri.hasQuery;

  static String get path =>
      appRouter.routerDelegate.currentConfiguration.last.matchedLocation;
}
