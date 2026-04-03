import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:lumen_node_app/features/editor/model/node_model.dart';

class AddNodeBody extends ConsumerWidget {
  final NodeModel node;

  const AddNodeBody({super.key, required this.node});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox.shrink();
  }
}
