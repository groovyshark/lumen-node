import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lumen_node_app/features/editor/providers/editor_provider.dart';
import 'package:lumen_node_app/features/editor/presentation/widgets/node_canvas.dart';

class EditorScreen extends ConsumerWidget {
  const EditorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final shaderCode = ref.watch(editorProvider.select((s) => s.shaderCode));

    return Scaffold(
      body: Row(
        children: [
          const Expanded(flex: 3, child: NodeCanvas()),
          Container(width: 1, color: Colors.white10),
          Expanded(
            flex: 1,
            child: Container(
              color: const Color(0xFF0F0F0F),
              padding: const EdgeInsets.all(12),
              child: SingleChildScrollView(
                child: Text(
                  shaderCode,
                  style: const TextStyle(
                    color: Colors.orangeAccent,
                    fontFamily: 'Consolas',
                    fontSize: 13,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}