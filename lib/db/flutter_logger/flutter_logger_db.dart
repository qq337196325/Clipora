// Copyright (c) 2025 Clipora.
//
// This work is licensed under the Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International License.
// To view a copy of this license, visit http://creativecommons.org/licenses/by-nc-nd/4.0/




import 'package:isar/isar.dart';

part 'flutter_logger_db.g.dart';

@collection
class FlutterLogger {

  Id id = Isar.autoIncrement;

  @Index() String userId = "";
  String message = "";
  String linesMessage = "";
  String errorMessage = "";
  String errorLevel = "";
  @Index() bool isUpdateService = false;  // 是否已经上传到服务器

  DateTime createdAt = DateTime.now();

}