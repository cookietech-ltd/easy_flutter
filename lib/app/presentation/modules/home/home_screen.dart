import 'package:easy_flutter/easy_flutter.dart';
import 'package:easy_flutter_boilerplate/app/domain/entities/product_entity.dart';
import 'package:easy_flutter_boilerplate/app/presentation/base/screen_state.dart';
import 'package:easy_flutter_boilerplate/app/presentation/modules/home/view_model/home_view_model.dart';
import 'package:easy_flutter_boilerplate/app/routes/app_routes.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ScreenState<HomeScreen> {
  late final HomeViewModel vm = factoryViewModel(HomeViewModel.new);

  @override
  void initState() {
    super.initState();
    vm.loadProducts(onError: onError);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Products'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.pushNamed(AppRoutes.profile.name),
            tooltip: 'Profile',
          ),
        ],
      ),
      body: CommandBuilder<List<ProductEntity>>(
        state: vm.products,
        onLoading: (_) => const Center(child: CircularProgressIndicator()),
        onError: (_, error) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(error.toString()),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () => vm.products.execute(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        builder: (context, products, _) {
          if (products == null || products.isEmpty) {
            return const Center(child: Text('No products found.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductTile(
                product: product,
                onTap: () => context.pushNamed(
                  AppRoutes.order.name,
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProductTile extends StatelessWidget {
  final ProductEntity product;
  final VoidCallback? onTap;

  const _ProductTile({required this.product, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(child: Text(product.id.toString())),
      title: Text(product.name),
      subtitle: Text('\$${product.price.toStringAsFixed(2)}'),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
