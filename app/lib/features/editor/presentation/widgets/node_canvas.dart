import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lumen_node_app/features/editor/providers/editor_provider.dart';
import 'package:lumen_node_app/features/editor/providers/canvas_key_provider.dart';

import 'package:lumen_node_app/features/editor/presentation/painters/canvas_grid_painter.dart';
import 'package:lumen_node_app/features/editor/presentation/painters/connection_painter.dart';
import 'package:lumen_node_app/features/editor/presentation/painters/draft_connection_painter.dart';
import 'package:lumen_node_app/features/editor/presentation/widgets/nodes/node_widget_factory.dart';

class NodeCanvas extends ConsumerWidget {
  const NodeCanvas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);
    final canvasKey = ref.watch(canvasKeyProvider);

    return InteractiveViewer(
      boundaryMargin: const EdgeInsets.all(double.infinity),
      minScale: 0.1,
      maxScale: 2.0,
      constrained: false,

      trackpadScrollCausesScale: true,

      panEnabled: state.draftingNodeId == null,

      child: SizedBox(
        width: 10000,
        height: 10000,

        child: MouseRegion(
          onHover: (e) {
            if (state.draftingNodeId != null) {
              notifier.updateDraftingConnection(e.localPosition);
            }
          },
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => ref.read(editorProvider.notifier).selectNode(null),
            onTertiaryTapDown: (d) {
              final RenderBox? box =
                  canvasKey.currentContext?.findRenderObject() as RenderBox?;
              if (box == null) return;

              final localPos = box.globalToLocal(d.globalPosition);

              notifier.tryDeleteConnectionAt(localPos);
            },
            onPanUpdate: (d) {
              if (state.draftingNodeId != null) {
                notifier.updateDraftingConnection(d.localPosition);
              }
            },
            onPanEnd: (_) {
              if (state.draftingNodeId != null) {
                notifier.endDraftingConnection();
              }
            },
            child: Stack(
              key: canvasKey,
              children: [
                const RepaintBoundary(
                  child: CustomPaint(
                    painter: CanvasGridPainter(),
                    child: SizedBox.expand(),
                  ),
                ),

                RepaintBoundary(
                  child: CustomPaint(
                    painter: ConnectionPainter(state.nodes, state.connections),
                    child: SizedBox.expand(),
                  ),
                ),

                if (state.draftingNodeId != null &&
                    state.draftingPos != null &&
                    state.draftingPinName != null)
                  RepaintBoundary(
                    child: CustomPaint(
                      painter: DraftConnectionPainter(
                        state.nodes.firstWhere(
                          (n) => n.id == state.draftingNodeId!,
                        ),
                        state.draftingPinName!,
                        state.draftingPos!,
                      ),
                      child: SizedBox.expand(),
                    ),
                  ),

                ...state.nodes.map(
                  (node) => Positioned(
                    left: node.position.dx,
                    top: node.position.dy,
                    child: NodeWidgetFactory.build(context, node),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
