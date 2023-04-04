import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

extension WidgetUtils on Widget {
  Future<void> buildWidgetOnBackground({
    Duration waitToRender = const Duration(milliseconds: 300),
  }) async {
    final widget = RepaintBoundary(
      child: MediaQuery(
          data: const MediaQueryData(),
          child: Directionality(textDirection: TextDirection.ltr, child: this)),
    );
    await _buildImageFromWidget(
      widget,
      waitToRender,
    );
  }

  /// Builds an image from the given widget by first spinning up a element and render tree,
  /// wait [waitToRender] to render the widget
  Future<void> _buildImageFromWidget(
      Widget widget, Duration waitToRender) async {
    final RenderRepaintBoundary repaintBoundary = RenderRepaintBoundary();

    final logicalSize = ui.window.physicalSize / ui.window.devicePixelRatio;
    final imageSize = ui.window.physicalSize;

    final RenderView renderView = RenderView(
      window: WidgetsBinding.instance.window,
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
