
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