import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:lumen_node_app/app/theme/app_theme.dart';
import 'package:lumen_node_app/features/editor/model/node_model.dart';
import 'package:lumen_node_app/features/editor/providers/editor_provider.dart';

class SideBar extends ConsumerWidget {
  const SideBar({super.key});

  void _onAddNodePressed(BuildContext context, WidgetRef ref) async {
    // get button position
    final RenderBox button = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
        Navigator.of(context).overlay!.context.findRenderObject()
            as RenderBox;

    final position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(const Offset(0, -10), ancestor: overlay),
        button.localToGlobal(
          button.size.bottomRight(Offset.zero),
          ancestor: overlay,
        ),
      ),
      Offset.zero & overlay.size,
    );

    // show menu
    final selectedType = await showMenu<NodeType>(
      context: context,
      position: position,
      color: AppColors.surfaceContainerHigh,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      items: [
        PopupMenuItem(
          value: NodeType.color,
          child: Row(
            children: [
              Icon(Icons.palette, color: AppColors.primary, size: 16),
              SizedBox(width: 8),
              Text("Color Node", style: TextStyle(color: AppColors.onSurface)),
            ],
          ),
        ),
        PopupMenuItem(
          value: NodeType.multiply,
          child: Row(
            children: [
              Icon(Icons.close, color: AppColors.tertiary, size: 16),
              SizedBox(width: 8),
              Text(
                "Multiply Node",
                style: TextStyle(color: AppColors.onSurface),
              ),
            ],
          ),
        ),
      ],
    );

    // Спавним выбранную ноду
    if (selectedType != null) {
      ref
          .read(editorProvider.notifier)
          .spawnNode(selectedType, const Offset(300, 300));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      width: 250,
      color: AppColors.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.account_tree,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Shader Graph",
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.onSurface,
                      ),
                    ),
                    Text(
                      "v2.4.0-alpha",
                      style: GoogleFonts.inter(
                        fontSize: 10,
                        color: AppColors.onSurfaceVariant,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          _menuItem(Icons.account_tree, "Node Library", active: true),
          _menuItem(Icons.tune, "Parameters"),
          _menuItem(Icons.visibility, "Viewport"),

          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Builder(
              builder: (context) => ElevatedButton.icon(
                onPressed: () => _onAddNodePressed(context, ref),
                icon: const Icon(
                  Icons.add,
                  size: 16,
                  color: AppColors.onSurface,
                ),
                label: Text(
                  "Add Node",
                  style: GoogleFonts.inter(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.surfaceContainerHighest,
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  side: const BorderSide(color: AppColors.outlineVariant),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuItem(IconData icon, String title, {bool active = false}) {
    return Container(
      decoration: active
          ? const BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              border: Border(
                right: BorderSide(color: AppColors.primary, width: 3),
              ),
            )
          : null,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
            color: active ? AppColors.primary : AppColors.onSurfaceVariant,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 12,
              color: active ? AppColors.primary : AppColors.onSurfaceVariant,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
