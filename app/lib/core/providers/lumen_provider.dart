import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_node_app/core/domain/lumen_engine.dart';

part 'lumen_provider.g.dart';

@Riverpod(keepAlive: true)
LumenEngine lumenEngine(Ref ref) {
  final engine = LumenEngine();
  ref.onDispose(() => engine.dispose());
  return engine;
}