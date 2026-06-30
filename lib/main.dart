
import 'package:flutter/material.dart';
import 'app.dart';
import 'services/level_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Pre-generate puzzles on first launch
  final levelService = LevelService();
  await levelService.init();
  await levelService.ensurePuzzlesGenerated();

  runApp(const SudokuApp());
}
