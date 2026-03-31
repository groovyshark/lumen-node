
import 'package:flutter/material.dart';

import 'package:lumen_node_app/features/editor/presentation/screens/editor_screen.dart';

class LumenApp extends StatelessWidget {
  const LumenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumen Node Editor',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const EditorScreen(),
    );
  }
}