
import 'package:flutter/material.dart';
import 'app.dart';
import 'services/level_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final levelService = LevelService();
  await levelService.init();
  await levelService.ensurePuzzlesGenerated();

  await settingsService.init();

  runApp(const SudokuApp());
}
