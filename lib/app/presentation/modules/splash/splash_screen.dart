import 'package:easy_flutter_boilerplate/app/core/base/screen_state.dart';
import 'package:easy_flutter_boilerplate/app/presentation/shared/widget/animated_hello/animated_hello.dart';
import 'package:easy_flutter_boilerplate/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ScreenState<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: AnimatedHello(
            onAnimationCompleted: () async {
              context.goNamed(AppRoutes.home.name);
            },
          ),
        ),
      ),
    );
  }
}
