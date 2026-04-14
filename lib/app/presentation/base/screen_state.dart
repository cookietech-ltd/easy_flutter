import 'package:easy_flutter/easy_flutter.dart';
import 'package:easy_flutter_boilerplate/app/utils/route_ext.dart';
import 'package:flutter/material.dart';

abstract class ScreenState<T extends StatefulWidget> extends BaseState<T> {
  bool _isLoadingDialogVisible = false;

  /// Displays an error [SnackBar] with the given [title] and optional
  /// [message]. If [onRetry] is provided, a "Retry" action is added.
  void showError({
    String? title,
    String? message,
    VoidCallback? onRetry,
  }) {
    final text = [
      if (title != null) title,
      if (message != null) message,
    ].join('\n');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text.isNotEmpty ? text : 'Something went wrong'),
        behavior: SnackBarBehavior.floating,
        action: onRetry != null
            ? SnackBarAction(label: 'Retry', onPressed: onRetry)
            : null,
      ),
    );
  }

  /// Handles an [error] by hiding any active loader and presenting an
  /// appropriate error message. [BaseException] fields are used when
  /// available; otherwise a generic message is shown.
  void onError(Exception error) {
    hideLoading();
    if (error is BaseException) {
      showError(title: error.title, message: error.message);
    } else {
      showError(title: 'Something went wrong', message: error.toString());
    }
  }

  /// Shows a centered, non-dismissible loading dialog with a
  /// [CircularProgressIndicator].
  ///
  /// If already visible, subsequent calls are ignored.
  void showLoading() {
    if (_isLoadingDialogVisible) return;
    _isLoadingDialogVisible = true;

    context
        .pushDialog(
      routeName: 'loader',
      useRootNavigator: true,
      barrierDismissible: false,
      builder: (_) => _buildLoader(),
    )
        .whenComplete(() {
      _isLoadingDialogVisible = false;
    });
  }

  /// Hides the loading dialog if it is currently visible.
  void hideLoading() {
    if (!_isLoadingDialogVisible) return;
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
    _isLoadingDialogVisible = false;
  }

  Widget _buildLoader() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(24),
        child: const CircularProgressIndicator.adaptive(),
      ),
    );
  }
}
