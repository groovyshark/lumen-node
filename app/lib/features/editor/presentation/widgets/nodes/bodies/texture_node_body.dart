import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lumen_node_app/features/editor/model/node_model.dart';

class TextureNodeBody extends ConsumerWidget {
  const TextureNodeBody({super.key, required this.node});

  final NodeModel node;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentPath = node.parameters["path"] as String?;

    final bool hasImage = currentPath != null && File(currentPath).existsSync();

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: 24,
                  // margin: const EdgeInsets.only(bottom: 2),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: Colors.grey.shade700),
                    image: hasImage
                        ? DecorationImage(
                            image: FileImage(File(currentPath)),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: hasImage
                      ? null
                      : const Center(
                          child: Icon(
                            Icons.image_not_supported,
                            color: Colors.grey,
                            size: 16,
                          ),
                        ),
                ),
              ),
            ],
          ),

          // Container(
          //   padding: const EdgeInsets.all(6),
          //   decoration: BoxDecoration(
          //     color: Colors.black45,
          //     borderRadius: BorderRadius.circular(4),
          //   ),
          //   child: Text(
          //     currentPath ?? "No file selected",
          //     style: TextStyle(
          //       fontSize: 9,
          //       color: hasImage ? Colors.greenAccent.shade100 : Colors.grey,
          //       fontFamily: 'Consolas',
          //     ),
          //     maxLines: 2, // Разрешаем перенос на 2 строки, если путь длинный
          //     overflow: TextOverflow.ellipsis,
          //     textAlign: TextAlign.center,
          //   ),
          // ),
        ],
      ),
    );
  }
}
