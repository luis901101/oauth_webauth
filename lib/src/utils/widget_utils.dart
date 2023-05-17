import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

extension WidgetUtils on Widget {
  /// It's recommended to use a context when using this function.
  /// Check docs: https://docs.flutter.dev/release/breaking-changes/window-singleton#migration-guide
  Future<void> buildWidgetOnBackground({
    BuildContext? context,
    Duration waitToRender = const Duration(milliseconds: 300),
  }) async {
    final widget = RepaintBoundary(
      child: MediaQuery(
          data: const MediaQueryData(),
          child: Directionality(textDirection: TextDirection.ltr, child: this)),
    );
    await _buildImageFromWidget(
      context,
      widget,
      waitToRender,
    );
  }

  /// Builds an image from the given widget by first spinning up a element and render tree,
  /// wait [waitToRender] to render the widget
  /// It's recommended to use a context when using this function.
  /// Check docs: https://docs.flutter.dev/release/breaking-changes/window-singleton#migration-guide
  Future<void> _buildImageFromWidget(
    BuildContext? context,
    Widget widget,
    Duration waitToRender,
  ) async {
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    final view = context != null
        ? View.of(context)
        : WidgetsBinding.instance.platformDispatcher.implicitView ??
            WidgetsBinding.instance.platformDispatcher.views.first;

    final logicalSize = view.physicalSize / view.devicePixelRatio;
    final imageSize = view.physicalSize;

    final RenderView renderView = RenderView(
      view: view,
      child: RenderPositionedBox(
          alignment: Alignment.center, child: repaintBoundary),
      configuration: ViewConfiguration(
        size: logicalSize,
        devicePixelRatio: 1.0,
      ),
    );

    final PipelineOwner pipelineOwner = PipelineOwner();
    final BuildOwner buildOwner = BuildOwner(focusManager: FocusManager());

    pipelineOwner.rootNode = renderView;
    renderView.prepareInitialFrame();

    final RenderObjectToWidgetElement<RenderBox> rootElement =
        RenderObjectToWidgetAdapter<RenderBox>(
      container: repaintBoundary,
      child: widget,
    ).attachToRenderTree(buildOwner);

    buildOwner.buildScope(rootElement);

    await Future.delayed(waitToRender);

    buildOwner.buildScope(rootElement);
    buildOwner.finalizeTree();

    pipelineOwner.flushLayout();
    pipelineOwner.flushCompositingBits();
    pipelineOwner.flushPaint();

    final ui.Image image = await repaintBoundary.toImage(
        pixelRatio: imageSize.width / logicalSize.width);
    await image.toByteData();
  }
}
