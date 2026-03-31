import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lumen_node_app/app/theme/app_theme.dart';
import 'package:lumen_node_app/features/editor/presentation/widgets/node_canvas.dart';
import 'package:lumen_node_app/features/editor/presentation/widgets/properties_inspector.dart';
import 'package:lumen_node_app/features/editor/presentation/widgets/side_bar.dart';
import 'package:lumen_node_app/features/editor/presentation/widgets/top_nav_bar.dart';
import 'package:lumen_node_app/features/editor/presentation/widgets/bottom_code_panel.dart';

class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: AppColors.surfaceDim,
      body: Column(
        children: [
          const TopNavBar(),
          Expanded(
            child: Row(
              children: [
                const SideBar(),
                Expanded(
                  child: Column(
                    children: [
                      const Expanded(child: NodeCanvas()),
                      Container(height: 1, color: AppColors.outlineVariant), // Тончайший сплиттер
                      const BottomCodePanel(),
                    ],
                  ),
                ),
                Container(width: 1, color: AppColors.outlineVariant),
                const PropertiesInspector(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}