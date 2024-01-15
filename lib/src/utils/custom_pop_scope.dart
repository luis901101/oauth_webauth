import 'package:flutter/material.dart';

typedef CanGoBackCallback = Future<bool> Function();

class CustomPopScope extends StatelessWidget {
  const CustomPopScope({
    required this.child,
    this.onPopInvoked,
    this.canGoBack,
    super.key,
  }) : assert(onPopInvoked != null || canGoBack != null);

  final Widget child;
  final PopInvokedCallback? onPopInvoked;
  final CanGoBackCallback? canGoBack;

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: onPopInvoked ??
          (didPop) {
            if (didPop) return;
            canGoBack?.call().then((canPop) {
              if (canPop) {
                Navigator.of(context).pop();
              }
            });
          },
      child: child,
    );
  }
}
