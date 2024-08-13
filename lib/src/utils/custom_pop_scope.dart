import 'package:flutter/material.dart';

typedef CanGoBackCallback<T> = Future<bool> Function({T? result});

class CustomPopScope<T> extends StatelessWidget {
  const CustomPopScope({
    required this.child,
    this.onPopInvokedWithResult,
    this.canGoBack,
    super.key,
  }) : assert(onPopInvokedWithResult != null || canGoBack != null);

  final Widget child;
  final PopInvokedWithResultCallback<T>? onPopInvokedWithResult;
  final CanGoBackCallback<T>? canGoBack;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: onPopInvokedWithResult ??
          (bool didPop, T? result) {
            if (didPop) return;
            canGoBack?.call(result: result).then((canPop) {
              if (canPop && context.mounted) {
                Navigator.of(context).pop(result);
              }
            });
          },
      child: child,
    );
  }
}
