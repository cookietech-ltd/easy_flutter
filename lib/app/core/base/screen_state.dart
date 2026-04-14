import 'package:easy_flutter/easy_flutter.dart';
import 'package:easy_flutter_boilerplate/app/utils/route_ext.dart';
import 'package:flutter/material.dart';

abstract class ScreenState<T extends StatefulWidget> extends BaseState<T> {
  bool _isLoadingDialogVisible = false;

  void showError({
    String routeName = 'errorBottomSheet',
    String? title,
    String? message,
    String? description,
    VoidCallback? onRetry,
  }) {
    // context.pushModalBottomSheet(
    //   routeName: routeName,
    //   isScrollControlled: true,
    //   backgroundColor: Colors.transparent,
    //   builder: (ctx) {
    //     return ErrorBottomSheetLayout(
    //       title: title ?? 'Something went wrong',
    //       message: message ?? 'Please try again.',
    //       onRetry: onRetry,
    //     );
    //   },
    // );
  }

  void onError(Exception error) {
    hideLoading();
    if (error is BaseException) {
      // if (error is NetworkException) {
      //   showError(
      //     title: error.errorResponse?.message ?? error.message,
      //     message: error.errorResponse?.description,
      //   );
      // }
    } else {
      showError(title: 'something went wrong', message: error.toString());
    }
  }

  /// Shows a centered, non-dismissible loading dialog with the provided
  /// Lottie JSON asset path.
  ///
  /// If already visible, subsequent calls are ignored.
  void showLoading({required String lottieAsset, String? routeName}) {
    if (_isLoadingDialogVisible) return;
    _isLoadingDialogVisible = true;

    // Use root navigator to avoid being blocked by nested navigators/sheets
    context
        .pushDialog(
      routeName: 'loader',
      useRootNavigator: true,
      builder: (ctx) {
        return loaderWidget(lottieAsset);
      },
    )
        .whenComplete(() {
      _isLoadingDialogVisible = false;
    });
  }

  /// Hides the loading dialog if it is currently visible.
  void hideLoading() {
    if (!_isLoadingDialogVisible) return;
    // Pop only if we can, using the root navigator where we presented
    final navigator = Navigator.of(context, rootNavigator: true);
    if (navigator.canPop()) {
      navigator.pop();
    }
    _isLoadingDialogVisible = false;
  }

  Widget loaderWidget(String lottieAsset) {
    return Center(
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        // child: Lottie.asset(lottieAsset, repeat: true, fit: BoxFit.contain),
      ),
    );
  }
}
