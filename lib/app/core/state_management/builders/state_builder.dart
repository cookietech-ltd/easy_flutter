import 'package:flutter/widgets.dart';
import '../state/state.dart';

/// A builder that listens to a [DataState] and rebuilds the UI accordingly.
/// Automatically removes listener and optionally disposes the state.
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
  @override
  void initState() {
    super.initState();
    widget.state.addListener(_onStateChanged);
    if (widget.listener != null) {
      widget.state.addListener(() => widget.listener?.call(widget.state.value));
    }
  }

  void _onStateChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.state.removeListener(_onStateChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, widget.state.value, widget.child);
  }
}

class MultiStateBuilder extends StatefulWidget {
  final List<DataState<dynamic>> states;
  final List<void Function(dynamic value)?>? listeners;
  final Widget Function(BuildContext context, List<dynamic> values, Widget? child) builder;
  final Widget? child;

  const MultiStateBuilder({
    super.key,
    required this.states,
    required this.builder,
    this.child,
    this.listeners,
  });

  @override
  State<MultiStateBuilder> createState() => _MultiStateBuilderState();
}

class _MultiStateBuilderState extends State<MultiStateBuilder> {
  final List<VoidCallback> _stateListeners = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < widget.states.length; i++) {
      final state = widget.states[i];
      void onStateChanged() {
        if (mounted) setState(() {});
      }
      state.addListener(onStateChanged);
      _stateListeners.add(onStateChanged);
      // Attach listener if provided
      if (widget.listeners != null && i < widget.listeners!.length && widget.listeners![i] != null) {
        state.addListener(() => widget.listeners![i]?.call(state.value));
      }
    }
  }

  @override
  void dispose() {
    for (int i = 0; i < widget.states.length; i++) {
      widget.states[i].removeListener(_stateListeners[i]);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final values = widget.states.map((s) => s.value).toList();
    return widget.builder(context, values, widget.child);
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