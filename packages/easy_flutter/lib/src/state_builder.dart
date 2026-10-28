import 'package:flutter/widgets.dart';
import 'state.dart';

/// A builder that listens to a [DataState] and rebuilds the UI accordingly.
/// Automatically adds and removes listeners on lifecycle boundaries.
class StateBuilder<V> extends StatefulWidget {
  final DataState<V> state;
  final void Function(V value)? listener;
  final Widget Function(BuildContext context, V value, Widget? child) builder;
  final Widget? child;

  const StateBuilder({
    super.key,
    required this.state,
    required this.builder,
    this.child,
    this.listener,
  });

  @override
  State<StateBuilder<V>> createState() => _StateBuilderState<V>();
}

class _StateBuilderState<V> extends State<StateBuilder<V>> {
  VoidCallback? _listenerCallback;

  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onStateChanged);
    if (widget.listener != null) {
      _listenerCallback = () => widget.listener?.call(widget.state.value);
      widget.state.addListener(_listenerCallback!);
    }
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChanged);
    if (_listenerCallback != null) {
      widget.state.removeListener(_listenerCallback!);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.state.value, widget.child);
  }
}

/// A builder that listens to multiple [DataState] instances and rebuilds
/// when any of them change.
///
/// Read typed values from the states themselves (`vm.counter.value`) rather
/// than casting entries of `values`.
class MultiStateBuilder extends StatelessWidget {
  final List<DataState<dynamic>> states;
  final Widget Function(BuildContext context, List<dynamic> values, Widget? child) builder;
  final Widget? child;

  const MultiStateBuilder({
    super.key,
    required this.states,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(states),
      builder: (context, child) =>
          builder(context, [for (final s in states) s.value], child),
      child: child,
    );
  }
}

/// A convenient builder specifically for [CommandState] that handles loading, error, and success states.
class CommandBuilder<T> extends StatelessWidget {
  final CommandState<T> state;
  final Widget Function(BuildContext context)? onLoading;
  final Widget Function(BuildContext context, Exception error)? onError;
  final Widget Function(BuildContext context, T? value, Widget? child) builder;
  final Widget? child;

  const CommandBuilder({
    super.key,
    required this.state,
    this.onLoading,
    this.onError,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return StateBuilder<T?>(
      state: state,
      builder: (context, value, child) {
        if (state.isLoading && onLoading != null) {
          return onLoading!(context);
        }
        if (state.error != null && onError != null) {
          return onError!(context, state.error!.error);
        }
        return builder(context, value, child);
      },
      child: child,
    );
  }
}