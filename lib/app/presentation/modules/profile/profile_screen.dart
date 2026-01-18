import 'package:easy_flutter_boilerplate/app/core/base/screen_state.dart';
import 'package:easy_flutter_boilerplate/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ScreenState<ProfileScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
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
          child: const Text('Profile Screen'),
        ),
      ),
    );
  }
}
