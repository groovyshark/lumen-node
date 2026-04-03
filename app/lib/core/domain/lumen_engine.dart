import 'dart:ffi';
import 'dart:io';
import 'package:ffi/ffi.dart';

import 'package:lumen_node_app/generated_bindings.dart';

import 'package:lumen_node_app/features/editor/model/node_model.dart';

typedef NativeNodeFunc = void Function(Pointer<Void>, Pointer<Char>);

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

  void addNode(String id, NodeType type) {
    if (_graph == null) return;

    final nativeId = id.toNativeUtf8();
    _native.addNode(_graph!, nativeId.cast<Char>(), type.nativeValue);

    malloc.free(nativeId);
  }

  void setNodeParameter(String nodeId, String paramName, double value) {
    if (_graph == null) return;

    final nativeId = nodeId.toNativeUtf8();
    final nativeParam = paramName.toNativeUtf8();

    _native.setNodeParameter(
      _graph!,
      nativeId.cast<Char>(),
      nativeParam.cast<Char>(),
      value,
    );

    malloc.free(nativeId);
    malloc.free(nativeParam);
  }

  void connect(String fromNode, String fromPin, String toNode, String toPin) {
    if (_graph == null) return;

    final nativeFromNode = fromNode.toNativeUtf8();
    final nativeFromPin = fromPin.toNativeUtf8();
    final nativeToNode = toNode.toNativeUtf8();
    final nativeToPin = toPin.toNativeUtf8();

    _native.connectNodes(
      _graph!,
      nativeFromNode.cast<Char>(),
      nativeFromPin.cast<Char>(),
      nativeToNode.cast<Char>(),
      nativeToPin.cast<Char>(),
    );

    malloc.free(nativeFromNode);
    malloc.free(nativeFromPin);
    malloc.free(nativeToNode);
    malloc.free(nativeToPin);
  }

  void disconnect(String targetNode, String targetPin) {
    if (_graph == null) return;

    final nativeTargetNode = targetNode.toNativeUtf8();
    final nativeTargetPin = targetPin.toNativeUtf8();

    _native.disconnectNode(
      _graph!,
      nativeTargetNode.cast<Char>(),
      nativeTargetPin.cast<Char>(),
    );

    malloc.free(nativeTargetNode);
    malloc.free(nativeTargetPin);
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