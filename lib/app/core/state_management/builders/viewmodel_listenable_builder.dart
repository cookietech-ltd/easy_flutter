import 'package:flutter/material.dart';

import '../ViewModel.dart';

@Deprecated('use multi state builder')
class ViewModelListenableBuilder<T extends ViewModel> extends ListenableBuilder {
  final T viewModel;
  
  const ViewModelListenableBuilder({
    super.key,
    required this.viewModel,
    required super.builder,
    super.child,
  }) : super(listenable: viewModel);
}
