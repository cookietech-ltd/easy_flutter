import 'package:go_router/go_router.dart';

/// Extension on [GoRouter] providing convenient access to the current
/// route's metadata without needing a [BuildContext].
extension GoRouterStateExtension on GoRouter {
  RouteMatchList get _matchList {
    final RouteMatch lastMatch =
        routerDelegate.currentConfiguration.last;
    return lastMatch is ImperativeRouteMatch
        ? lastMatch.matches
        : routerDelegate.currentConfiguration;
  }

  /// Name of the currently active route, or `null` if unnamed.
  String? get currentRouteName =>
      routerDelegate.currentConfiguration.last.route.name;

  /// The matched location path of the deepest route.
  String get currentPath =>
      routerDelegate.currentConfiguration.last.matchedLocation;

  /// Extra object attached via `GoRouterState.extra`.
  Object? get argument => _matchList.extra;

  /// Parsed query parameters from the current URI.
  Map<String, String> get queryParams => _matchList.uri.queryParameters;

  /// Path parameters extracted from the matched route template.
  Map<String, String> get pathParams => _matchList.pathParameters;

  /// Whether the current URI contains a query string.
  bool get hasQuery => _matchList.uri.hasQuery;
}
