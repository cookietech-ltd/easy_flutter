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

  // static final GoRouterState? _currentState = appRouter.state;
  //TODO: Implement Other Routing Helper Getter

  static String? get currentRouteName =>
      appRouter.routerDelegate.currentConfiguration.last.route.name;

  Future<void> start() async {
    await DiInitializer().init();

    // Initialize Firebase service which will orchestrate all other firebase sub-services.
    // await FirebaseService().initialize();
  }

  /// Reset all dependencies
  /// Useful for testing or logging out
  Future<void> reset() async {
    // if (getIt.isRegistered<SessionManager>()) {
    //   final authProvider = getIt<SessionManager>();
    //   await authProvider.clear(); // Clear credentials on reset
    // }
    
    // Reset Firebase service and all its sub-services
    // await FirebaseService().reset();
    
    await getIt.reset();
    await DiInitializer().init(); // Reinitialize DI if needed
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
