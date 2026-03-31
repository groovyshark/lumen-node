import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:lumen_node_app/generated_bindings.dart';

class LumenEngine {
  late final LumenBindings _native;
  Pointer<Void>? _graph;

  LumenEngine() {
    final dylib = _loadLibrary();
    
    _native = LumenBindings(dylib);
    _graph = _native.createGraph();
  }

  static DynamicLibrary _loadLibrary() {
    if (Platform.isWindows) return DynamicLibrary.open('lumen-node.dll');
    if (Platform.isLinux || Platform.isAndroid) return DynamicLibrary.open('liblumen-node.so');
    throw UnsupportedError('Platform not supported');
  }

  void addColorNode(String id) {
    if (_graph == null) return;

    final nativeId = id.toNativeUtf8();
    _native.addColorNode(_graph!, nativeId.cast<Char>());
    malloc.free(nativeId); // Обязательно чистим память в куче C
  }

  String compile() {
    if (_graph == null) return "Error: Graph not initialized";
    
    final pointer = _native.compile(_graph!);
    return pointer.cast<Utf8>().toDartString();
  }

  void dispose() {
    if (_graph != null) {
      _native.destroyGraph(_graph!);
      _graph = null;
    }
  }
}