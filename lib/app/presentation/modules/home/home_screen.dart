import 'package:easy_flutter_boilerplate/app/core/base/screen_state.dart';
import 'package:easy_flutter_boilerplate/app/routes/app_routes.dart';
import 'package:easy_flutter_boilerplate/app/utils/context_ext.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ScreenState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.pop();
          },
        ),
        elevation: 4.0,
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            context.pushNamed(AppRoutes.order.name);
          },
          child: Text(
            context.localized.home,
          ),
        ),
      ),
    );
  }
}
