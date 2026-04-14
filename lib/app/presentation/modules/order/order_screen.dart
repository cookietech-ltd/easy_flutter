import 'package:easy_flutter_boilerplate/app/presentation/base/screen_state.dart';
import 'package:easy_flutter_boilerplate/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends ScreenState<OrderScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order'),
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
            context.pushNamed(AppRoutes.profile.name);
          },
          child: const Text('Order Screen'),
        ),
      ),
    );
  }
}
