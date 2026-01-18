import 'package:easy_flutter_boilerplate/app/core/state_management/viewModel.dart';
import 'package:flutter/material.dart';


abstract class BaseState<T extends StatefulWidget> extends State<T> {
  final List<ViewModel> viewModelRefs = [];

  @override
  void initState() {
    initializeListener();
    super.initState();
  }

  @override
  void dispose() {
    removeListener();

    for (final vm in viewModelRefs) {
      if (!vm.isShared) {
        vm.dispose();
      }
    }

    viewModelRefs.clear();
    super.dispose();
  }

  void initializeListener() {}

  void removeListener() {}

  /// Creates a ViewModel, tracks it, and returns it
  V factoryViewModel<V extends ViewModel>(V Function() create) {
    final vm = create();
    viewModelRefs.add(vm);
    return vm;
  }
}

