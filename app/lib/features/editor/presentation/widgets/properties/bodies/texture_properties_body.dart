import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:file_picker/file_picker.dart';

import 'package:lumen_node_app/app/theme/app_theme.dart';
import 'package:lumen_node_app/features/editor/providers/editor_provider.dart';
import 'package:lumen_node_app/features/editor/model/node_model.dart';

class TexturePropertiesBody extends ConsumerWidget {
  final NodeModel node;

  const TexturePropertiesBody({super.key, required this.node});

  Future<void> _pickTexture(BuildContext context, WidgetRef ref) async {
    FilePickerResult? result = await FilePicker.pickFiles(type: FileType.image);

    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;

      ref
          .read(editorProvider.notifier)
          .updateNodeParameter(node.id, "path", path);

      ref.read(editorProvider.notifier).loadTexture(path);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = node.parameters["path"] as String?;

    final pathValue = currentPath != null && currentPath.isNotEmpty ? currentPath.split('/').last : "No texture loaded";

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Image.file(
          File(currentPath ?? ""),
          width: double.infinity,
          height: 200,
          fit: BoxFit.fitWidth,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 200,
              color: Colors.black,
              child: const Center(
                child: Icon(
                  Icons.image_not_supported,
                  color: Colors.grey,
                  size: 16,
                ),
              ),
            );
          },
        ),

        const SizedBox(height: 8),

        ElevatedButton.icon(
          icon: const Icon(Icons.image, size: 16),
          label: const Text("Load Image", style: TextStyle(fontSize: 12)),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.secondary,
            foregroundColor: AppColors.surfaceBright,
            minimumSize: const Size(double.infinity, 34),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6),
            ),
          ),
          onPressed: () => _pickTexture(context, ref),
        ),

        const SizedBox(height: 16),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "PATH:",
              style: GoogleFonts.inter(
                fontSize: 11,
                color: AppColors.onSurfaceVariant,
              ),
            ),
            Text(
              pathValue,
              style: GoogleFonts.firaCode(fontSize: 11, color: AppColors.secondary),
            ),
          ],
        ),
      ],
    );
  }
}
