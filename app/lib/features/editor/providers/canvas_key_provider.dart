import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'canvas_key_provider.g.dart';

@riverpod
GlobalKey canvasKey(Ref ref) {
  return GlobalKey();
}