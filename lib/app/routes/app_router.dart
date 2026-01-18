import 'package:easy_flutter_boilerplate/app/core/state_management/view_model.dart';
import 'package:easy_flutter_boilerplate/app/presentation/modules/profile/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:easy_flutter_boilerplate/app/core/base/screen_builder.dart';
import 'package:easy_flutter_boilerplate/app/presentation/modules/home/home_screen.dart';
import 'package:easy_flutter_boilerplate/app/presentation/modules/order/order_screen.dart';
import 'package:easy_flutter_boilerplate/app/presentation/modules/splash/splash_screen.dart';
import 'package:easy_flutter_boilerplate/app/routes/app_routes.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: rootNavigatorKey,
  initialLocation: AppRoutes.splash.path,
  observers: <NavigatorObserver>[ViewModelRouteObserver()],
  routes: <RouteBase>[
    ScreenBuilder<SplashScreen>(
      path: AppRoutes.splash.path,
      name: AppRoutes.splash.name,
      screenBuilder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    ScreenBuilder<OrderScreen>(
      path: AppRoutes.order.path,
      name: AppRoutes.order.name,
      screenBuilder: (BuildContext context, GoRouterState state) {
        return const OrderScreen();
      },
    ),
    ScreenBuilder<HomeScreen>(
      path: AppRoutes.home.path,
      name: AppRoutes.home.name,
      screenBuilder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    ScreenBuilder<HomeScreen>(
      path: AppRoutes.profile.path,
      name: AppRoutes.profile.name,
      screenBuilder: (BuildContext context, GoRouterState state) {
        return const ProfileScreen();
      },
    ),
  ],
);
