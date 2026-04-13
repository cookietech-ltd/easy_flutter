import 'package:flutter/widgets.dart';

import 'view_model.dart';

/// Base [State] class that manages ViewModel lifecycle.
///
/// Tracks created ViewModels and disposes non-shared ones automatically.
/// Extend this in your feature screen states.
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

  /// Override to set up listeners on ViewModel states.
  void initializeListener() {}

  /// Override to tear down listeners before disposal.
  void removeListener() {}

  /// Creates a ViewModel, tracks it for lifecycle management, and returns it.
  V factoryViewModel<V extends ViewModel>(V Function() create) {
    final vm = create();
    viewModelRefs.add(vm);
    return vm;
  }
}
