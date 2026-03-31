import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumen_node_app/app/theme/app_theme.dart';

import 'package:lumen_node_app/features/editor/providers/editor_provider.dart';
import 'package:lumen_node_app/features/editor/model/node_model.dart';
import 'package:lumen_node_app/features/editor/presentation/painters/canvas_grid_painter.dart';
import 'package:lumen_node_app/features/editor/presentation/painters/connection_painter.dart';
import 'package:lumen_node_app/features/editor/presentation/painters/draft_connection_painter.dart';

final canvasKey = GlobalKey();

class NodeCanvas extends ConsumerWidget {
  const NodeCanvas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(editorProvider);
    final notifier = ref.read(editorProvider.notifier);

    return MouseRegion(
      onHover: (e) {
        if (state.draftingNodeId != null) {
          notifier.updateDraftingConnection(e.localPosition);
        }
      },
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
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

            if (state.draftingNodeId != null && state.draftingPos != null)
              RepaintBoundary(
                child: CustomPaint(
                  painter: DraftConnectionPainter(
                    state.nodes.firstWhere(
                      (n) => n.id == state.draftingNodeId!,
                    ),
                    state.draftingPos!,
                  ),
                  child: SizedBox.expand(),
                ),
              ),

            ...state.nodes.map(
              (node) => Positioned(
                left: node.position.dx,
                top: node.position.dy,
                child: _NodeWidget(node: node),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NodeWidget extends ConsumerWidget {
  final NodeModel node;
  const _NodeWidget({required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onPanUpdate: (d) => ref
          .read(editorProvider.notifier)
          .updateNodePosition(node.id, d.delta),
      child: Container(
        width: 200,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.outlineVariant),
          boxShadow: const [
            BoxShadow(
              color: Colors.black45,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Шапка ноды (стилизована под Input из дизайна)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: const BoxDecoration(
                color: Color(0xFF004050), // on-primary-container
                borderRadius: BorderRadius.vertical(top: Radius.circular(7)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "COLOR INPUT",
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const Icon(Icons.palette, size: 14, color: AppColors.primary),
                ],
              ),
            ),
            // Тело ноды
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: [
                  _nodeProperty("R", "1.0"),
                  const SizedBox(height: 8),
                  _nodeProperty("G", "0.5"),
                ],
              ),
            ),
            // Подвал с пином (точкой выхода)
            GestureDetector(
              onPanStart: (d) {
                final RenderBox? canvasBox =
                    canvasKey.currentContext?.findRenderObject() as RenderBox?;
                if (canvasBox == null) return;

                final localPos = canvasBox.globalToLocal(d.globalPosition);
                ref
                    .read(editorProvider.notifier)
                    .startDraftingConnection(node.id, localPos);
              },
              onPanUpdate: (d) {
                final RenderBox? canvasBox =
                    canvasKey.currentContext?.findRenderObject() as RenderBox?;
                if (canvasBox == null) return;

                // Постоянно обновляем координату хвоста относительно холста
                final localPos = canvasBox.globalToLocal(d.globalPosition);
                ref
                    .read(editorProvider.notifier)
                    .updateDraftingConnection(localPos);
              },
              onPanEnd: (_) {
                ref.read(editorProvider.notifier).endDraftingConnection();
              },
              child: Container(
                height: 24,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.vertical(
                    bottom: Radius.circular(7),
                  ),
                ),
                alignment: Alignment.centerRight,
                child: Transform.translate(
                  offset: const Offset(4, 0),
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _nodeProperty(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppColors.onSurfaceVariant,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            value,
            style: GoogleFonts.firaCode(fontSize: 11, color: AppColors.primary),
          ),
        ),
      ],
    );
  }
}
